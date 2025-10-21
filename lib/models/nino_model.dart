import 'package:cloud_firestore/cloud_firestore.dart';

class NinoModel {
  final String id;
  final String nombres;
  final String apellidos;
  final String dniNino;
  final DateTime fechaNacimiento;
  final String sexo;
  final String residencia;
  final String nombreTutor;
  final String dniPadre;
  final double peso;
  final double talla;
  final double? imc;
  final String? clasificacionIMC;
  final DateTime fechaRegistro;
  final bool activo;

  NinoModel({
    required this.id,
    required this.nombres,
    required this.apellidos,
    required this.dniNino,
    required this.fechaNacimiento,
    required this.sexo,
    required this.residencia,
    required this.nombreTutor,
    required this.dniPadre,
    required this.peso,
    required this.talla,
    this.imc,
    this.clasificacionIMC,
    required this.fechaRegistro,
    this.activo = true,
  });

  // Factory constructor para crear desde Map (Firestore)
  factory NinoModel.fromMap(Map<String, dynamic> map, String documentId) {
    return NinoModel(
      id: documentId,
      nombres: map['nombres'] ?? '',
      apellidos: map['apellidos'] ?? '',
      dniNino: map['dniNino'] ?? '',
      fechaNacimiento: (map['fechaNacimiento'] as Timestamp).toDate(),
      sexo: map['sexo'] ?? '',
      residencia: map['residencia'] ?? '',
      nombreTutor: map['nombreTutor'] ?? '',
      dniPadre: map['dniPadre'] ?? '',
      peso: (map['peso'] ?? 0.0).toDouble(),
      talla: (map['talla'] ?? 0.0).toDouble(),
      imc: map['imc']?.toDouble(),
      clasificacionIMC: map['clasificacionIMC'],
      fechaRegistro: (map['fechaRegistro'] as Timestamp).toDate(),
      activo: map['activo'] ?? true,
    );
  }

  // Convertir a Map para guardar en Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombres': nombres,
      'apellidos': apellidos,
      'dniNino': dniNino,
      'fechaNacimiento': Timestamp.fromDate(fechaNacimiento),
      'sexo': sexo,
      'residencia': residencia,
      'nombreTutor': nombreTutor,
      'dniPadre': dniPadre,
      'peso': peso,
      'talla': talla,
      'imc': imc,
      'clasificacionIMC': clasificacionIMC,
      'fechaRegistro': Timestamp.fromDate(fechaRegistro),
      'activo': activo,
    };
  }

  // Crear copia con cambios
  NinoModel copyWith({
    String? id,
    String? nombres,
    String? apellidos,
    String? dniNino,
    DateTime? fechaNacimiento,
    String? sexo,
    String? residencia,
    String? nombreTutor,
    String? dniPadre,
    double? peso,
    double? talla,
    double? imc,
    String? clasificacionIMC,
    DateTime? fechaRegistro,
    bool? activo,
  }) {
    return NinoModel(
      id: id ?? this.id,
      nombres: nombres ?? this.nombres,
      apellidos: apellidos ?? this.apellidos,
      dniNino: dniNino ?? this.dniNino,
      fechaNacimiento: fechaNacimiento ?? this.fechaNacimiento,
      sexo: sexo ?? this.sexo,
      residencia: residencia ?? this.residencia,
      nombreTutor: nombreTutor ?? this.nombreTutor,
      dniPadre: dniPadre ?? this.dniPadre,
      peso: peso ?? this.peso,
      talla: talla ?? this.talla,
      imc: imc ?? this.imc,
      clasificacionIMC: clasificacionIMC ?? this.clasificacionIMC,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
      activo: activo ?? this.activo,
    );
  }

  // Calcular edad en años
  int get edad {
    final ahora = DateTime.now();
    int edad = ahora.year - fechaNacimiento.year;
    if (ahora.month < fechaNacimiento.month ||
        (ahora.month == fechaNacimiento.month && ahora.day < fechaNacimiento.day)) {
      edad--;
    }
    return edad;
  }

  // Nombre completo
  String get nombreCompleto => '$nombres $apellidos';

  @override
  String toString() {
    return 'NinoModel{id: $id, nombres: $nombres, apellidos: $apellidos, dniNino: $dniNino}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NinoModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

