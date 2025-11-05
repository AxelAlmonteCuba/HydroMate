import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/operation_mode_provider.dart';
import '../widgets/mode_selector.dart';
import '../widgets/pump_control.dart';
import '../widgets/humidity_monitor.dart';
import '../../data/models/operation_mode.dart';

class OperationModeScreen extends StatefulWidget {
  const OperationModeScreen({super.key});

  @override
  State<OperationModeScreen> createState() => _OperationModeScreenState();
}

class _OperationModeScreenState extends State<OperationModeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OperationModeProvider>().refreshState();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Control de Riego'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<OperationModeProvider>().refreshState();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Estado actualizado'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: Consumer<OperationModeProvider>(
        builder: (context, provider, child) {
          if (provider.currentState == null) {
            return const Center(child: CircularProgressIndicator());
          }

          // Mostrar errores si existen
          if (provider.error != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(provider.error!),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 3),
                ),
              );
            });
          }

          return RefreshIndicator(
            onRefresh: provider.refreshState,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Estado de conexión
                  _ConnectionStatusCard(
                    lastUpdate: provider.currentState!.lastUpdate,
                  ),
                  const SizedBox(height: 16),
                  
                  // Selector de modo
                  ModeSelector(
                    currentMode: provider.currentMode,
                    isLoading: provider.isLoading,
                    onModeChanged: (mode) async {
                      await provider.changeMode(mode);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Modo cambiado a ${mode == OperationMode.automatic ? 'Automático' : 'Manual'}',
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Control de bomba
                  PumpControl(
                    isPumpActive: provider.isPumpActive,
                    isManualMode: provider.currentMode == OperationMode.manual,
                    isLoading: provider.isLoading,
                    onToggle: () async {
                      await provider.togglePump(!provider.isPumpActive);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              provider.isPumpActive
                                  ? 'Riego iniciado'
                                  : 'Riego detenido',
                            ),
                            backgroundColor: Colors.blue,
                          ),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Monitor de humedad
                  HumidityMonitor(
                    currentHumidity: provider.currentHumidity,
                    minThreshold: provider.minThreshold,
                    maxThreshold: provider.maxThreshold,
                    onThresholdsChanged: (min, max) async {
                      await provider.updateThresholds(min, max);
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Información adicional
                  _InfoCard(
                    mode: provider.currentMode,
                    isPumpActive: provider.isPumpActive,
                    currentHumidity: provider.currentHumidity,
                    minThreshold: provider.minThreshold,
                    maxThreshold: provider.maxThreshold,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ConnectionStatusCard extends StatelessWidget {
  final DateTime lastUpdate;

  const _ConnectionStatusCard({required this.lastUpdate});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final difference = now.difference(lastUpdate);
    final isConnected = difference.inSeconds < 10;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isConnected ? Colors.green[50] : Colors.red[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isConnected ? Colors.green[200]! : Colors.red[200]!,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isConnected ? Icons.check_circle : Icons.error,
            color: isConnected ? Colors.green[700] : Colors.red[700],
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isConnected ? 'Conectado' : 'Desconectado',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: isConnected ? Colors.green[700] : Colors.red[700],
                  ),
                ),
                Text(
                  'Última actualización: hace ${difference.inSeconds}s',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final OperationMode mode;
  final bool isPumpActive;
  final double currentHumidity;
  final double minThreshold;
  final double maxThreshold;

  const _InfoCard({
    required this.mode,
    required this.isPumpActive,
    required this.currentHumidity,
    required this.minThreshold,
    required this.maxThreshold,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue, size: 20),
                SizedBox(width: 8),
                Text(
                  'Información del Sistema',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 20),
            _InfoRow(
              label: 'Modo actual',
              value: mode == OperationMode.automatic ? 'Automático' : 'Manual',
              icon: mode == OperationMode.automatic
                  ? Icons.settings_suggest
                  : Icons.touch_app,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Estado de bomba',
              value: isPumpActive ? 'Activa' : 'Inactiva',
              icon: Icons.water_drop,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Humedad actual',
              value: '${currentHumidity.toStringAsFixed(1)}%',
              icon: Icons.opacity,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Rango objetivo',
              value: '${minThreshold.toInt()}% - ${maxThreshold.toInt()}%',
              icon: Icons.straighten,
            ),
            if (mode == OperationMode.automatic) ...[
              const Divider(height: 20),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lightbulb_outline, size: 16, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        currentHumidity < minThreshold
                            ? 'El riego se activará automáticamente'
                            : currentHumidity > maxThreshold
                                ? 'El riego se detendrá automáticamente'
                                : 'La humedad está en el rango óptimo',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}