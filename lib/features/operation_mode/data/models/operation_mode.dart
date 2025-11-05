enum OperationMode {
  manual,
  automatic,
}

class OperationState {
  final OperationMode mode;
  final bool isPumpActive;
  final double currentHumidity;
  final double minThreshold;
  final double maxThreshold;
  final DateTime lastUpdate;

  OperationState({
    required this.mode,
    required this.isPumpActive,
    required this.currentHumidity,
    required this.minThreshold,
    required this.maxThreshold,
    required this.lastUpdate,
  });

  OperationState copyWith({
    OperationMode? mode,
    bool? isPumpActive,
    double? currentHumidity,
    double? minThreshold,
    double? maxThreshold,
    DateTime? lastUpdate,
  }) {
    return OperationState(
      mode: mode ?? this.mode,
      isPumpActive: isPumpActive ?? this.isPumpActive,
      currentHumidity: currentHumidity ?? this.currentHumidity,
      minThreshold: minThreshold ?? this.minThreshold,
      maxThreshold: maxThreshold ?? this.maxThreshold,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }

  Map<String, dynamic> toJson() => {
    'mode': mode.name,
    'isPumpActive': isPumpActive,
    'currentHumidity': currentHumidity,
    'minThreshold': minThreshold,
    'maxThreshold': maxThreshold,
    'lastUpdate': lastUpdate.toIso8601String(),
  };

  factory OperationState.fromJson(Map<String, dynamic> json) => OperationState(
    mode: OperationMode.values.firstWhere((e) => e.name == json['mode']),
    isPumpActive: json['isPumpActive'],
    currentHumidity: json['currentHumidity'],
    minThreshold: json['minThreshold'],
    maxThreshold: json['maxThreshold'],
    lastUpdate: DateTime.parse(json['lastUpdate']),
  );

  String get modeText => mode == OperationMode.automatic ? 'Automático' : 'Manual';
  
  bool get shouldActivatePump {
    return mode == OperationMode.automatic && currentHumidity < minThreshold;
  }

  bool get shouldDeactivatePump {
    return mode == OperationMode.automatic && currentHumidity > maxThreshold;
  }
}