// 👤 Modelo de Usuario - WasiApp
// Define la información de cada usuario registrado en la app

class UsuarioModel {
  final String id; // ID único en Firebase
  final String usuario; // Nombre de usuario (puede ser el email)
  final String contrasena; // Contraseña (en producción debería estar encriptada)
  final String? nombre; // Nombre real (opcional)
  final String? apellido; // Apellido (opcional)
  final String? email; // Correo electrónico
  final DateTime? fechaCreacion; // Cuándo se creó la cuenta
  final DateTime? ultimoAcceso; // Último inicio de sesión
  final bool activo; // Si la cuenta está activa

  UsuarioModel({
    required this.id,
    required this.usuario,
    required this.contrasena,
    this.nombre,
    this.apellido,
    this.email,
    this.fechaCreacion,
    this.ultimoAcceso,
    this.activo = true,
  });

  // Factory constructor para crear desde Map (Firestore)
  factory UsuarioModel.fromMap(Map<String, dynamic> map, String documentId) {
    return UsuarioModel(
      id: documentId,
      usuario: map['usuario'] ?? '',
      contrasena: map['contraseña'] ?? '',
      nombre: map['nombre'],
      apellido: map['apellido'],
      email: map['email'],
      fechaCreacion: map['fechaCreacion']?.toDate(),
      ultimoAcceso: map['ultimoAcceso']?.toDate(),
      activo: map['activo'] ?? true,
    );
  }

  // Convertir el objeto a un Map para guardar en Firebase
  // (Firebase no entiende objetos, solo Maps)
  Map<String, dynamic> toMap() {
    return {
      'usuario': usuario,
      'contraseña': contrasena,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'fechaCreacion': fechaCreacion,
      'ultimoAcceso': ultimoAcceso,
      'activo': activo,
    };
  }

  // Crear copia con cambios
  UsuarioModel copyWith({
    String? id,
    String? usuario,
    String? contrasena,
    String? nombre,
    String? apellido,
    String? email,
    DateTime? fechaCreacion,
    DateTime? ultimoAcceso,
    bool? activo,
  }) {
    return UsuarioModel(
      id: id ?? this.id,
      usuario: usuario ?? this.usuario,
      contrasena: contrasena ?? this.contrasena,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      fechaCreacion: fechaCreacion ?? this.fechaCreacion,
      ultimoAcceso: ultimoAcceso ?? this.ultimoAcceso,
      activo: activo ?? this.activo,
    );
  }

  @override
  String toString() {
    return 'UsuarioModel{id: $id, usuario: $usuario, nombre: $nombre, apellido: $apellido}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UsuarioModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
