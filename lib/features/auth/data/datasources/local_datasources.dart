import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../model/user_model.dart';

class LocalDataSource {
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }
  
  Future<Database> _initDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = join(databasePath, 'hydromate.db');
    
    return await openDatabase(
      path,
      version: 2, // ⚠️ Incrementa a 2
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id TEXT PRIMARY KEY,
            email TEXT UNIQUE NOT NULL,
            name TEXT NOT NULL,
            created_at INTEGER NOT NULL
          )
        ''');
        
        // 🆕 Tabla de contraseñas
        await db.execute('''
          CREATE TABLE passwords(
            user_id TEXT PRIMARY KEY,
            password_hash TEXT NOT NULL,
            FOREIGN KEY (user_id) REFERENCES users (id)
          )
        ''');
        
        print('✅ Tablas creadas');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute('''
            CREATE TABLE passwords(
              user_id TEXT PRIMARY KEY,
              password_hash TEXT NOT NULL,
              FOREIGN KEY (user_id) REFERENCES users (id)
            )
          ''');
          print('✅ Tabla passwords agregada');
        }
      },
    );
  }
  
  // Guardar usuario
  Future<String> insertUser(User user) async {
    final db = await database;
    await db.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
    print('✅ Usuario guardado en SQLite: ${user.email}');
    return user.id;
  }
  
  // Buscar por email
  Future<User?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query(
      'users',
      where: 'email = ?',
      whereArgs: [email],
    );
    
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }
  
  // Verificar si email existe
  Future<bool> emailExists(String email) async {
    final db = await database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery(
        'SELECT COUNT(*) FROM users WHERE email = ?',
        [email],
      ),
    );
    return count != null && count > 0;
  }
  
  // Obtener todos los usuarios (para debugging)
  Future<List<User>> getAllUsers() async {
    final db = await database;
    final maps = await db.query('users');
    return maps.map((map) => User.fromMap(map)).toList();
  }

  // Guardar contraseña
  Future<void> insertPassword(String userId, String password) async {
    final db = await database;
    await db.insert(
      'passwords',
      {
        'user_id': userId,
        'password_hash': password,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    print('🔐 Contraseña guardada para user: $userId');
  }

  // Verificar contraseña
  Future<bool> verifyPassword(String userId, String password) async {
    final db = await database;
    final maps = await db.query(
      'passwords',
      where: 'user_id = ? AND password_hash = ?',
      whereArgs: [userId, password],
    );
    return maps.isNotEmpty;
  }
}