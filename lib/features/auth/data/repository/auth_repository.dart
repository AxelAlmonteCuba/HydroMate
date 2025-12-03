import '../model/user_model.dart';
import '../datasources/local_datasources.dart';

class AuthRepository {
  final LocalDataSource localDataSource;
  
  AuthRepository(this.localDataSource);
  
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final exists = await localDataSource.emailExists(email);
    if (exists) {
      throw Exception('El email ya está registrado');
    }
    
    if (password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres');
    }
    
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );
    
    await localDataSource.insertUser(user);
    await localDataSource.insertPassword(user.id, password); // 🆕 Guardar contraseña
    
    print('📦 Usuario registrado: ${user.email}');
    return user;
  }

  Future<User> login({
    required String email,
    required String password,
  }) async {
    final user = await localDataSource.getUserByEmail(email);
    
    if (user == null) {
      throw Exception('Usuario no encontrado');
    }
    
    // 🆕 Verificar contraseña
    final isValid = await localDataSource.verifyPassword(user.id, password);
    if (!isValid) {
      throw Exception('Contraseña incorrecta');
    }
    
    print('🔑 Login exitoso: ${user.email}');
    return user;
  }
  
  // Para debugging: ver todos los usuarios
  Future<List<User>> getAllUsers() async {
    return await localDataSource.getAllUsers();
  }
}