import 'package:flutter/material.dart';

class HumidityMonitor extends StatelessWidget {
  final double currentHumidity;
  final double minThreshold;
  final double maxThreshold;
  final Function(double, double) onThresholdsChanged;

  const HumidityMonitor({
    super.key,
    required this.currentHumidity,
    required this.minThreshold,
    required this.maxThreshold,
    required this.onThresholdsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.opacity, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  'Humedad del Suelo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            
            // Indicador de humedad actual
            Center(
              child: Column(
                children: [
                  Text(
                    '${currentHumidity.toStringAsFixed(1)}%',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: _getHumidityColor(currentHumidity),
                    ),
                  ),
                  Text(
                    _getHumidityStatus(currentHumidity),
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Barra de progreso visual
            _HumidityBar(
              current: currentHumidity,
              min: minThreshold,
              max: maxThreshold,
            ),
            const SizedBox(height: 24),
            
            // Configuración de umbrales
            const Text(
              'Umbrales de Riego',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _ThresholdSlider(
              label: 'Mínimo',
              value: minThreshold,
              color: Colors.orange,
              onChanged: (value) => onThresholdsChanged(value, maxThreshold),
            ),
            const SizedBox(height: 12),
            _ThresholdSlider(
              label: 'Máximo',
              value: maxThreshold,
              color: Colors.green,
              onChanged: (value) => onThresholdsChanged(minThreshold, value),
            ),
          ],
        ),
      ),
    );
  }

  Color _getHumidityColor(double humidity) {
    if (humidity < minThreshold) return Colors.red;
    if (humidity > maxThreshold) return Colors.blue;
    return Colors.green;
  }

  String _getHumidityStatus(double humidity) {
    if (humidity < minThreshold) return 'Muy bajo - Requiere riego';
    if (humidity > maxThreshold) return 'Óptimo';
    return 'Normal';
  }
}

class _HumidityBar extends StatelessWidget {
  final double current;
  final double min;
  final double max;

  const _HumidityBar({
    required this.current,
    required this.min,
    required this.max,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          children: [
            Container(
              height: 30,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: const LinearGradient(
                  colors: [Colors.red, Colors.orange, Colors.green, Colors.blue],
                ),
              ),
            ),
            Positioned(
              left: (current / 100) * MediaQuery.of(context).size.width * 0.8,
              top: 0,
              bottom: 0,
              child: Container(
                width: 4,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${min.toInt()}%', style: const TextStyle(fontSize: 12)),
            Text('${max.toInt()}%', style: const TextStyle(fontSize: 12)),
          ],
        ),
      ],
    );
  }
}

class _ThresholdSlider extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  final Function(double) onChanged;

  const _ThresholdSlider({
    required this.label,
    required this.value,
    required this.color,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Text(
              '${value.toInt()}%',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: 0,
          max: 100,
          divisions: 100,
          activeColor: color,
          onChanged: onChanged,
        ),
      ],
    );
  }
}