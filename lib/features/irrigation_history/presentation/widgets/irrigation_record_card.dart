import 'package:flutter/material.dart';
import '../../data/models/irrigation_record.dart';

class IrrigationRecordCard extends StatelessWidget {
  final IrrigationRecord record;

  const IrrigationRecordCard({super.key, required this.record});

  @override
  Widget build(BuildContext context) {
    final isAutomatic = record.mode == 'automatic';
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con fecha y modo
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      record.dateFormatted,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAutomatic ? Colors.blue[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        isAutomatic ? Icons.settings_suggest : Icons.touch_app,
                        size: 14,
                        color: isAutomatic ? Colors.blue[700] : Colors.orange[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isAutomatic ? 'Automático' : 'Manual',
                        style: TextStyle(
                          color: isAutomatic ? Colors.blue[700] : Colors.orange[700],
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            
            // Información del riego
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.access_time,
                    label: 'Hora',
                    value: record.timeFormatted,
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.timer,
                    label: 'Duración',
                    value: record.formattedDuration,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    icon: Icons.water_drop,
                    label: 'Agua usada',
                    value: '${record.waterUsed.toStringAsFixed(1)} L',
                  ),
                ),
                Expanded(
                  child: _InfoItem(
                    icon: Icons.opacity,
                    label: 'Humedad',
                    value: '${record.initialHumidity.toInt()}% → ${record.finalHumidity.toInt()}%',
                  ),
                ),
              ],
            ),
            
            // Indicador de mejora de humedad
            const SizedBox(height: 12),
            _HumidityImprovement(
              initial: record.initialHumidity,
              final_: record.finalHumidity,
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: Colors.grey[600]),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
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

class _HumidityImprovement extends StatelessWidget {
  final double initial;
  final double final_;

  const _HumidityImprovement({
    required this.initial,
    required this.final_,
  });

  @override
  Widget build(BuildContext context) {
    final improvement = final_ - initial;
    final percentage = (improvement / initial * 100).toStringAsFixed(0);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.trending_up, size: 16, color: Colors.green[700]),
          const SizedBox(width: 8),
          Text(
            'Mejora: +${improvement.toStringAsFixed(1)}% ($percentage% aumento)',
            style: TextStyle(
              fontSize: 12,
              color: Colors.green[700],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}