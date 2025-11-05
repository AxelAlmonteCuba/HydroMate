import 'package:flutter/material.dart';
import '../../data/models/irrigation_record.dart';
import '../../data/repositories/irrigation_history_repository.dart';

class IrrigationHistoryProvider extends ChangeNotifier {
  final IrrigationHistoryRepository _repository;

  IrrigationHistoryProvider(this._repository);

  List<IrrigationRecord> _records = [];
  List<IrrigationRecord> _filteredRecords = [];
  Map<String, dynamic> _statistics = {};
  bool _isLoading = false;
  String? _error;

  // Filtros
  DateTime? _startDateFilter;
  DateTime? _endDateFilter;
  String? _modeFilter; // 'all', 'manual', 'automatic'

  // Getters
  List<IrrigationRecord> get records => _filteredRecords;
  Map<String, dynamic> get statistics => _statistics;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime? get startDateFilter => _startDateFilter;
  DateTime? get endDateFilter => _endDateFilter;
  String? get modeFilter => _modeFilter;

  // Cargar todos los registros
  Future<void> loadRecords() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _records = await _repository.getAllRecords();
      _applyFilters();
      await loadStatistics();
    } catch (e) {
      _error = 'Error al cargar registros: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cargar estadísticas
  Future<void> loadStatistics() async {
    try {
      _statistics = await _repository.getStatistics();
      notifyListeners();
    } catch (e) {
      _error = 'Error al cargar estadísticas: $e';
    }
  }

  // Aplicar filtros
  void _applyFilters() {
    _filteredRecords = List.from(_records);

    // Filtro por fecha
    if (_startDateFilter != null && _endDateFilter != null) {
      _filteredRecords = _filteredRecords.where((record) {
        return record.startTime.isAfter(_startDateFilter!) &&
               record.startTime.isBefore(_endDateFilter!.add(const Duration(days: 1)));
      }).toList();
    }

    // Filtro por modo
    if (_modeFilter != null && _modeFilter != 'all') {
      _filteredRecords = _filteredRecords.where((record) {
        return record.mode == _modeFilter;
      }).toList();
    }
  }

  // Establecer filtro de fechas
  void setDateFilter(DateTime? start, DateTime? end) {
    _startDateFilter = start;
    _endDateFilter = end;
    _applyFilters();
    notifyListeners();
  }

  // Establecer filtro de modo
  void setModeFilter(String? mode) {
    _modeFilter = mode;
    _applyFilters();
    notifyListeners();
  }

  // Limpiar filtros
  void clearFilters() {
    _startDateFilter = null;
    _endDateFilter = null;
    _modeFilter = 'all';
    _applyFilters();
    notifyListeners();
  }

  // Agregar nuevo registro
  Future<void> addRecord(IrrigationRecord record) async {
    try {
      await _repository.addRecord(record);
      await loadRecords();
    } catch (e) {
      _error = 'Error al agregar registro: $e';
      notifyListeners();
    }
  }
}