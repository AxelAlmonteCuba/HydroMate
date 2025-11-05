import 'package:flutter/material.dart';

class PumpControl extends StatelessWidget {
  final bool isPumpActive;
  final bool isManualMode;
  final bool isLoading;
  final VoidCallback onToggle;

  const PumpControl({
    super.key,
    required this.isPumpActive,
    required this.isManualMode,
    required this.isLoading,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Row(
              children: [
                Icon(Icons.water, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Control de Bomba',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Estado visual de la bomba
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isPumpActive ? Colors.blue[100] : Colors.grey[200],
                boxShadow: isPumpActive
                    ? [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.5),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ]
                    : [],
              ),
              child: Icon(
                Icons.water_drop,
                size: 60,
                color: isPumpActive ? Colors.blue[700] : Colors.grey[400],
              ),
            ),
            const SizedBox(height: 16),
            
            // Estado textual
            Text(
              isPumpActive ? 'BOMBA ACTIVA' : 'BOMBA INACTIVA',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isPumpActive ? Colors.blue[700] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            
            // Botón de control
            if (isManualMode)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : onToggle,
                  icon: isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Icon(isPumpActive ? Icons.stop : Icons.play_arrow),
                  label: Text(
                    isPumpActive ? 'DETENER RIEGO' : 'INICIAR RIEGO',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isPumpActive ? Colors.red : Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              )
            else
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.lock, size: 20, color: Colors.amber[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Control manual deshabilitado en modo automático',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.amber[700],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}