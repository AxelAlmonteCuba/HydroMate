import 'package:flutter/material.dart';
import '../../data/repository/auth_repository.dart';
import '../../data/model/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository authRepository;
  
  AuthProvider(this.authRepository);
  
  // Estado
  bool _isLoading = false;
  String? _error;
  User? _currentUser;
  
  // Getters
  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get currentUser => _currentUser;
  bool get isLoggedIn => _currentUser != null;
  
  // Registrar usuario CON SQLite
  Future<bool> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final user = await authRepository.register(
        email: email,
        password: password,
        name: name,
      );
      
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      
      print('✅ Usuario registrado en SQLite: ${user.email}');
      await _debugPrintUsers();
      
      return true;
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Login CON SQLite
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    try {
      _isLoading = true;
      _error = null;
      notifyListeners();
      
      final user = await authRepository.login(
        email: email,
        password: password,
      );
      
      _currentUser = user;
      _isLoading = false;
      notifyListeners();
      return true;
      
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
  
  // Logout
  void logout() {
    _currentUser = null;
    _error = null;
    notifyListeners();
  }
  
  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
  
  // Para debug
  Future<void> _debugPrintUsers() async {
    try {
      final users = await authRepository.getAllUsers();
      print('📋 USUARIOS EN SQLITE:');
      if (users.isEmpty) {
        print('   (base de datos vacía)');
      } else {
        for (var user in users) {
          print('   - ${user.email} (${user.name})');
        }
      }
    } catch (e) {
      print('⚠️ Debug: $e');
    }
  }
}