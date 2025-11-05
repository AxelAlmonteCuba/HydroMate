import '../models/irrigation_record.dart';

class IrrigationHistoryRepository {
  // Simulación de base de datos local (en producción usar SQLite/Hive)
  final List<IrrigationRecord> _records = [];

  IrrigationHistoryRepository() {
    _generateMockData();
  }

  // Generar datos de ejemplo
  void _generateMockData() {
    final now = DateTime.now();
    
    _records.addAll([
      IrrigationRecord.fromTimestamps(
        id: '1',
        startTime: now.subtract(const Duration(days: 1, hours: 10)),
        endTime: now.subtract(const Duration(days: 1, hours: 9, minutes: 45)),
        initialHumidity: 25.0,
        finalHumidity: 68.0,
        mode: 'automatic',
      ),
      IrrigationRecord.fromTimestamps(
        id: '2',
        startTime: now.subtract(const Duration(days: 2, hours: 14)),
        endTime: now.subtract(const Duration(days: 2, hours: 13, minutes: 30)),
        initialHumidity: 30.0,
        finalHumidity: 72.0,
        mode: 'automatic',
      ),
      IrrigationRecord.fromTimestamps(
        id: '3',
        startTime: now.subtract(const Duration(days: 3, hours: 8)),
        endTime: now.subtract(const Duration(days: 3, hours: 7, minutes: 50)),
        initialHumidity: 28.0,
        finalHumidity: 65.0,
        mode: 'manual',
      ),
      IrrigationRecord.fromTimestamps(
        id: '4',
        startTime: now.subtract(const Duration(days: 4, hours: 16)),
        endTime: now.subtract(const Duration(days: 4, hours: 15, minutes: 35)),
        initialHumidity: 22.0,
        finalHumidity: 70.0,
        mode: 'automatic',
      ),
      IrrigationRecord.fromTimestamps(
        id: '5',
        startTime: now.subtract(const Duration(days: 5, hours: 12)),
        endTime: now.subtract(const Duration(days: 5, hours: 11, minutes: 40)),
        initialHumidity: 26.0,
        finalHumidity: 66.0,
        mode: 'manual',
      ),
    ]);
  }

  // Obtener todos los registros
  Future<List<IrrigationRecord>> getAllRecords() async {
    await Future.delayed(const Duration(milliseconds: 500)); // Simular latencia
    return List.from(_records)..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  // Filtrar por rango de fechas
  Future<List<IrrigationRecord>> getRecordsByDateRange(DateTime start, DateTime end) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _records.where((record) {
      return record.startTime.isAfter(start) && record.startTime.isBefore(end);
    }).toList()..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  // Filtrar por modo
  Future<List<IrrigationRecord>> getRecordsByMode(String mode) async {
    await Future.delayed(const Duration(milliseconds: 300));
    return _records.where((record) => record.mode == mode).toList()
      ..sort((a, b) => b.startTime.compareTo(a.startTime));
  }

  // Agregar nuevo registro
  Future<void> addRecord(IrrigationRecord record) async {
    await Future.delayed(const Duration(milliseconds: 200));
    _records.add(record);
  }

  // Obtener estadísticas
  Future<Map<String, dynamic>> getStatistics() async {
    await Future.delayed(const Duration(milliseconds: 400));
    
    if (_records.isEmpty) {
      return {
        'totalIrrigations': 0,
        'totalWaterUsed': 0.0,
        'averageDuration': 0,
        'automaticCount': 0,
        'manualCount': 0,
      };
    }

    final totalWater = _records.fold<double>(0, (sum, record) => sum + record.waterUsed);
    final avgDuration = _records.fold<int>(0, (sum, record) => sum + record.durationMinutes) / _records.length;
    final automaticCount = _records.where((r) => r.mode == 'automatic').length;
    final manualCount = _records.where((r) => r.mode == 'manual').length;

    return {
      'totalIrrigations': _records.length,
      'totalWaterUsed': totalWater,
      'averageDuration': avgDuration.round(),
      'automaticCount': automaticCount,
      'manualCount': manualCount,
    };
  }
}