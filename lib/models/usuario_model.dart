class UsuarioModel {
  final String id;
  final String usuario;
  final String contrasena;
  final String? nombre;
  final String? apellido;
  final String? email;
  final DateTime? fechaCreacion;
  final DateTime? ultimoAcceso;
  final bool activo;

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

  // Convertir a Map para guardar en Firestore
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
