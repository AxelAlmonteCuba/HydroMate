// ============================================
// lib/features/irrigation_history/presentation/screens/irrigation_history_screen.dart
// ============================================
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/irrigation_history_provider.dart';
import '../widgets/irrigation_record_card.dart';
import '../widgets/filter_bottom_sheet.dart';

class IrrigationHistoryScreen extends StatefulWidget {
  const IrrigationHistoryScreen({super.key});

  @override
  State<IrrigationHistoryScreen> createState() => _IrrigationHistoryScreenState();
}

class _IrrigationHistoryScreenState extends State<IrrigationHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IrrigationHistoryProvider>().loadRecords();
    });
  }

  void _showFilterSheet() {
    final provider = context.read<IrrigationHistoryProvider>();
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FilterBottomSheet(
        initialStartDate: provider.startDateFilter,
        initialEndDate: provider.endDateFilter,
        initialMode: provider.modeFilter,
        onApplyFilter: (start, end, mode) {
          provider.setDateFilter(start, end);
          provider.setModeFilter(mode);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial de Riego'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSheet,
          ),
        ],
      ),
      body: Consumer<IrrigationHistoryProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    provider.error!,
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.loadRecords(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          if (provider.records.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.water_drop_outlined, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'No hay registros de riego',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los riegos aparecerán aquí',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.loadRecords,
            child: CustomScrollView(
              slivers: [
                // Estadísticas
                SliverToBoxAdapter(
                  child: _StatisticsCard(statistics: provider.statistics),
                ),
                
                // Información de filtros activos
                if (provider.startDateFilter != null || 
                    provider.modeFilter != null && provider.modeFilter != 'all')
                  SliverToBoxAdapter(
                    child: _ActiveFiltersChip(
                      onClear: () => provider.clearFilters(),
                    ),
                  ),
                
                // Lista de registros
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final record = provider.records[index];
                      return IrrigationRecordCard(record: record);
                    },
                    childCount: provider.records.length,
                  ),
                ),
                
                // Espaciado final
                const SliverToBoxAdapter(
                  child: SizedBox(height: 16),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _StatisticsCard extends StatelessWidget {
  final Map<String, dynamic> statistics;

  const _StatisticsCard({required this.statistics});

  @override
  Widget build(BuildContext context) {
    if (statistics.isEmpty) return const SizedBox.shrink();

    final totalIrrigations = statistics['totalIrrigations'] ?? 0;
    final totalWater = statistics['totalWaterUsed'] ?? 0.0;
    final avgDuration = statistics['averageDuration'] ?? 0;
    final automaticCount = statistics['automaticCount'] ?? 0;
    final manualCount = statistics['manualCount'] ?? 0;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue[400]!, Colors.blue[600]!],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.analytics, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Estadísticas',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white54, height: 24),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.water_drop,
                  value: '${totalWater.toStringAsFixed(1)} L',
                  label: 'Agua total',
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.event,
                  value: '$totalIrrigations',
                  label: 'Total riegos',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _StatItem(
                  icon: Icons.timer,
                  value: '${avgDuration} min',
                  label: 'Duración promedio',
                ),
              ),
              Expanded(
                child: _StatItem(
                  icon: Icons.pie_chart,
                  value: '$automaticCount / $manualCount',
                  label: 'Auto / Manual',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _ActiveFiltersChip extends StatelessWidget {
  final VoidCallback onClear;

  const _ActiveFiltersChip({required this.onClear});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(Icons.filter_list, size: 16, color: Colors.blue),
          const SizedBox(width: 8),
          const Text(
            'Filtros activos',
            style: TextStyle(
              fontSize: 14,
              color: Colors.blue,
              fontWeight: FontWeight.w500,
            ),
          ),
          const Spacer(),
          TextButton(
            onPressed: onClear,
            child: const Text('Limpiar'),
          ),
        ],
      ),
    );
  }
}