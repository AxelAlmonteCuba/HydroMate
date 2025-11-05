import 'package:flutter/material.dart';
import '../../data/models/operation_mode.dart';
import '../../data/repositories/operation_mode_repository.dart';

class OperationModeProvider extends ChangeNotifier {
  final OperationModeRepository _repository;

  OperationModeProvider(this._repository) {
    _initializeState();
    _startHumiditySimulation();
  }

  OperationState? _currentState;
  bool _isLoading = false;
  String? _error;

  // Getters
  OperationState? get currentState => _currentState;
  bool get isLoading => _isLoading;
  String? get error => _error;
  
  OperationMode get currentMode => _currentState?.mode ?? OperationMode.manual;
  bool get isPumpActive => _currentState?.isPumpActive ?? false;
  double get currentHumidity => _currentState?.currentHumidity ?? 0.0;
  double get minThreshold => _currentState?.minThreshold ?? 30.0;
  double get maxThreshold => _currentState?.maxThreshold ?? 70.0;

  // Inicializar estado
  Future<void> _initializeState() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentState = await _repository.getCurrentState();
    } catch (e) {
      _error = 'Error al inicializar: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cambiar modo de operación
  Future<void> changeMode(OperationMode mode) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentState = await _repository.changeMode(mode);
    } catch (e) {
      _error = 'Error al cambiar modo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Alternar bomba (solo en modo manual)
  Future<void> togglePump(bool active) async {
    if (currentMode != OperationMode.manual) {
      _error = 'Solo puedes controlar la bomba en modo manual';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentState = await _repository.togglePump(active);
    } catch (e) {
      _error = 'Error al controlar bomba: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar umbrales
  Future<void> updateThresholds(double min, double max) async {
    if (min >= max) {
      _error = 'El umbral mínimo debe ser menor al máximo';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentState = await _repository.updateThresholds(min, max);
    } catch (e) {
      _error = 'Error al actualizar umbrales: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Simular sensor de humedad
  void _startHumiditySimulation() {
    _repository.simulateHumiditySensor().listen((humidity) {
      _currentState = _currentState?.copyWith(
        currentHumidity: humidity,
        lastUpdate: DateTime.now(),
      );
      notifyListeners();
    });
  }

  // Refrescar estado
  Future<void> refreshState() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentState = await _repository.getCurrentState();
    } catch (e) {
      _error = 'Error al refrescar estado: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}