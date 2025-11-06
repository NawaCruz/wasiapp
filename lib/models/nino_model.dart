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
  
  // Campos del cuestionario de salud
  final String? anemia;
  final String? alimentosHierro;
  final String? fatiga;
  final String? alimentacionBalanceada;
  final String? palidez;
  final String? disminucionRendimiento;
  final String? evaluacionAnemia;
  
  // Campo para asociar con el usuario
  final String? usuarioId;
  
  // Campo para la foto de la conjuntiva
  final String? fotoConjuntivaUrl;
  
  // Campos para el diagnóstico de anemia
  final String? diagnosticoAnemiaRiesgo; // 'alto', 'medio', 'bajo'
  final double? diagnosticoAnemiaScore; // 0-100
  final DateTime? diagnosticoAnemiaFecha;

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
    this.anemia,
    this.alimentosHierro,
    this.fatiga,
    this.alimentacionBalanceada,
    this.palidez,
    this.disminucionRendimiento,
    this.evaluacionAnemia,
    this.usuarioId,
    this.fotoConjuntivaUrl,
    this.diagnosticoAnemiaRiesgo,
    this.diagnosticoAnemiaScore,
    this.diagnosticoAnemiaFecha,
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
      fechaRegistro: map['fechaRegistro'] != null 
          ? (map['fechaRegistro'] as Timestamp).toDate()
          : DateTime.now(),
      activo: map['activo'] ?? true,
      anemia: map['anemia'],
      alimentosHierro: map['alimentosHierro'],
      fatiga: map['fatiga'],
      alimentacionBalanceada: map['alimentacionBalanceada'],
      palidez: map['palidez'],
      disminucionRendimiento: map['disminucionRendimiento'],
      evaluacionAnemia: map['evaluacionAnemia'],
      usuarioId: map['usuarioId'],
      fotoConjuntivaUrl: map['fotoConjuntivaUrl'],
      diagnosticoAnemiaRiesgo: map['diagnosticoAnemiaRiesgo'],
      diagnosticoAnemiaScore: map['diagnosticoAnemiaScore']?.toDouble(),
      diagnosticoAnemiaFecha: map['diagnosticoAnemiaFecha'] != null
          ? (map['diagnosticoAnemiaFecha'] as Timestamp).toDate()
          : null,
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
      'anemia': anemia,
      'alimentosHierro': alimentosHierro,
      'fatiga': fatiga,
      'alimentacionBalanceada': alimentacionBalanceada,
      'palidez': palidez,
      'disminucionRendimiento': disminucionRendimiento,
      'evaluacionAnemia': evaluacionAnemia,
      'usuarioId': usuarioId,
      'fotoConjuntivaUrl': fotoConjuntivaUrl,
      'diagnosticoAnemiaRiesgo': diagnosticoAnemiaRiesgo,
      'diagnosticoAnemiaScore': diagnosticoAnemiaScore,
      'diagnosticoAnemiaFecha': diagnosticoAnemiaFecha != null
          ? Timestamp.fromDate(diagnosticoAnemiaFecha!)
          : null,
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
    String? anemia,
    String? alimentosHierro,
    String? fatiga,
    String? alimentacionBalanceada,
    String? palidez,
    String? disminucionRendimiento,
    String? evaluacionAnemia,
    String? usuarioId,
    String? fotoConjuntivaUrl,
    String? diagnosticoAnemiaRiesgo,
    double? diagnosticoAnemiaScore,
    DateTime? diagnosticoAnemiaFecha,
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
      anemia: anemia ?? this.anemia,
      alimentosHierro: alimentosHierro ?? this.alimentosHierro,
      fatiga: fatiga ?? this.fatiga,
      alimentacionBalanceada: alimentacionBalanceada ?? this.alimentacionBalanceada,
      palidez: palidez ?? this.palidez,
      disminucionRendimiento: disminucionRendimiento ?? this.disminucionRendimiento,
      evaluacionAnemia: evaluacionAnemia ?? this.evaluacionAnemia,
      usuarioId: usuarioId ?? this.usuarioId,
      fotoConjuntivaUrl: fotoConjuntivaUrl ?? this.fotoConjuntivaUrl,
      diagnosticoAnemiaRiesgo: diagnosticoAnemiaRiesgo ?? this.diagnosticoAnemiaRiesgo,
      diagnosticoAnemiaScore: diagnosticoAnemiaScore ?? this.diagnosticoAnemiaScore,
      diagnosticoAnemiaFecha: diagnosticoAnemiaFecha ?? this.diagnosticoAnemiaFecha,
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

