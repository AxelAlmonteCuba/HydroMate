import '../models/operation_mode.dart';

class OperationModeRepository {
  OperationState _currentState = OperationState(
    mode: OperationMode.manual,
    isPumpActive: false,
    currentHumidity: 45.0,
    minThreshold: 30.0,
    maxThreshold: 70.0,
    lastUpdate: DateTime.now(),
  );

  // Obtener estado actual
  Future<OperationState> getCurrentState() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _currentState;
  }

  // Cambiar modo de operación
  Future<OperationState> changeMode(OperationMode mode) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentState = _currentState.copyWith(
      mode: mode,
      lastUpdate: DateTime.now(),
    );
    
    // Si cambiamos a automático, verificar si debe activarse la bomba
    if (mode == OperationMode.automatic) {
      if (_currentState.shouldActivatePump) {
        _currentState = _currentState.copyWith(isPumpActive: true);
      } else if (_currentState.shouldDeactivatePump) {
        _currentState = _currentState.copyWith(isPumpActive: false);
      }
    }
    
    return _currentState;
  }

  // Control manual de la bomba
  Future<OperationState> togglePump(bool active) async {
    await Future.delayed(const Duration(milliseconds: 300));
    
    if (_currentState.mode == OperationMode.manual) {
      _currentState = _currentState.copyWith(
        isPumpActive: active,
        lastUpdate: DateTime.now(),
      );
    }
    
    return _currentState;
  }

  // Actualizar umbrales
  Future<OperationState> updateThresholds(double min, double max) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _currentState = _currentState.copyWith(
      minThreshold: min,
      maxThreshold: max,
      lastUpdate: DateTime.now(),
    );
    return _currentState;
  }

  // Actualizar humedad (simulación de sensor)
  Future<OperationState> updateHumidity(double humidity) async {
    _currentState = _currentState.copyWith(
      currentHumidity: humidity,
      lastUpdate: DateTime.now(),
    );

    // En modo automático, verificar si debe cambiar estado de bomba
    if (_currentState.mode == OperationMode.automatic) {
      if (_currentState.shouldActivatePump && !_currentState.isPumpActive) {
        _currentState = _currentState.copyWith(isPumpActive: true);
      } else if (_currentState.shouldDeactivatePump && _currentState.isPumpActive) {
        _currentState = _currentState.copyWith(isPumpActive: false);
      }
    }

    return _currentState;
  }

  // Simular lectura de sensor (para pruebas)
  Stream<double> simulateHumiditySensor() async* {
    while (true) {
      await Future.delayed(const Duration(seconds: 3));
      // Simular variación de humedad
      final variation = (_currentState.isPumpActive ? 0.5 : -0.3);
      final newHumidity = (_currentState.currentHumidity + variation).clamp(0.0, 100.0);
      
      _currentState = await updateHumidity(newHumidity);
      yield newHumidity;
    }
  }
}