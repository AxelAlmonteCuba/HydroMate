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
    // 1. Validar email único
    final exists = await localDataSource.emailExists(email);
    if (exists) {
      throw Exception('El email ya está registrado');
    }
    
    // 2. Validar contraseña
    if (password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres');
    }
    
    // 3. Crear usuario
    final user = User(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      email: email,
      name: name,
      createdAt: DateTime.now(),
    );
    
    // 4. Guardar en SQLite
    await localDataSource.insertUser(user);
    
    // 5. (OPCIONAL) Guardar contraseña hasheada
    // En producción deberías usar: flutter_secure_storage
    print('📦 Usuario guardado en SQLite: ${user.email}');
    
    return user;
  }
  
  Future<User> login({
    required String email,
    required String password,
  }) async {
    // 1. Buscar usuario
    final user = await localDataSource.getUserByEmail(email);
    
    if (user == null) {
      throw Exception('Usuario no encontrado');
    }
    
    // 2. Validar contraseña
    // En producción: comparar hash
    // Por ahora solo validamos que no esté vacía
    if (password.isEmpty) {
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