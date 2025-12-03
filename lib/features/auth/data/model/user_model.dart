class User {
  final String id;
  final String email;
  final String name;
  final DateTime createdAt;
  
  User({
    required this.id,
    required this.email,
    required this.name,
    required this.createdAt,
  });
  
  // Para guardar en SQLite
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'created_at': createdAt.millisecondsSinceEpoch,
    };
  }
  
  // Para leer de SQLite
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['created_at'] as int),
    );
  }
}