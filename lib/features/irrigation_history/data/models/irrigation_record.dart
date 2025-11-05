class IrrigationRecord {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final double initialHumidity;
  final double finalHumidity;
  final int durationMinutes;
  final String mode; // 'manual' o 'automatic'
  final double waterUsed; // en litros

  IrrigationRecord({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.initialHumidity,
    required this.finalHumidity,
    required this.durationMinutes,
    required this.mode,
    required this.waterUsed,
  });

  // Calcular duración desde timestamps
  factory IrrigationRecord.fromTimestamps({
    required String id,
    required DateTime startTime,
    required DateTime endTime,
    required double initialHumidity,
    required double finalHumidity,
    required String mode,
    double waterFlowRate = 2.0, // litros por minuto
  }) {
    final duration = endTime.difference(startTime).inMinutes;
    final waterUsed = duration * waterFlowRate;

    return IrrigationRecord(
      id: id,
      startTime: startTime,
      endTime: endTime,
      initialHumidity: initialHumidity,
      finalHumidity: finalHumidity,
      durationMinutes: duration,
      mode: mode,
      waterUsed: waterUsed,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'initialHumidity': initialHumidity,
    'finalHumidity': finalHumidity,
    'durationMinutes': durationMinutes,
    'mode': mode,
    'waterUsed': waterUsed,
  };

  factory IrrigationRecord.fromJson(Map<String, dynamic> json) => IrrigationRecord(
    id: json['id'],
    startTime: DateTime.parse(json['startTime']),
    endTime: DateTime.parse(json['endTime']),
    initialHumidity: json['initialHumidity'],
    finalHumidity: json['finalHumidity'],
    durationMinutes: json['durationMinutes'],
    mode: json['mode'],
    waterUsed: json['waterUsed'],
  );

  String get formattedDuration {
    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get dateFormatted {
    return '${startTime.day.toString().padLeft(2, '0')}/${startTime.month.toString().padLeft(2, '0')}/${startTime.year}';
  }

  String get timeFormatted {
    return '${startTime.hour.toString().padLeft(2, '0')}:${startTime.minute.toString().padLeft(2, '0')}';
  }
}