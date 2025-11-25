// 👶 Modelo de Niño - WasiApp
// Define toda la información que se guarda de cada niño en la base de datos

import 'package:cloud_firestore/cloud_firestore.dart';

class NinoModel {
  // === DATOS PERSONALES ===
  final String id; // ID único en Firebase
  final String nombres;
  final String apellidos;
  final String dniNino; // DNI del niño
  final DateTime fechaNacimiento;
  final String sexo; // "Masculino" o "Femenino"
  final String residencia; // Ciudad donde vive
  final String nombreTutor; // Nombre del papá/mamá/tutor
  final String dniPadre; // DNI del tutor
  
  // === MEDIDAS ===
  final double peso; // En kilogramos
  final double talla; // En metros
  final double? imc; // Índice de Masa Corporal (calculado automáticamente)
  final String? clasificacionIMC; // "Bajo peso", "Normal", "Sobrepeso", etc.
  
  // === CONTROL ===
  final DateTime fechaRegistro; // Cuándo se registró el niño
  final bool activo; // Si está activo o fue eliminado

  // === CUESTIONARIO DE SALUD ===
  final String? anemia; // ¿Ha tenido anemia? (Sí/No)
  final String? alimentosHierro; // ¿Come alimentos con hierro? (Sí/No)
  final String? fatiga; // ¿Se cansa fácilmente? (Sí/No)
  final String? alimentacionBalanceada; // ¿Come balanceado? (Sí/No)
  final String? palidez; // ¿Se ve pálido? (Sí/No)
  final String? disminucionRendimiento; // ¿Bajo rendimiento? (Sí/No)
  final String? evaluacionAnemia; // Evaluación general

  // === RELACIÓN CON USUARIO ===
  final String? usuarioId; // ID del usuario dueño de este registro

  // === FOTO DE CONJUNTIVA ===
  final String? fotoConjuntivaUrl; // Ruta de la foto del ojo (para IA)

  // === DIAGNÓSTICO DE ANEMIA ===
  final String? diagnosticoAnemiaRiesgo; // "alto", "medio", "bajo"
  final double? diagnosticoAnemiaScore; // Puntaje de 0 a 100
  final DateTime? diagnosticoAnemiaFecha; // Cuándo se hizo el diagnóstico

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

  // Convertir datos de Firebase a un objeto NinoModel
  // (Firebase guarda todo como Map, esto lo convierte a un objeto que podemos usar)
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
      alimentacionBalanceada:
          alimentacionBalanceada ?? this.alimentacionBalanceada,
      palidez: palidez ?? this.palidez,
      disminucionRendimiento:
          disminucionRendimiento ?? this.disminucionRendimiento,
      evaluacionAnemia: evaluacionAnemia ?? this.evaluacionAnemia,
      usuarioId: usuarioId ?? this.usuarioId,
      fotoConjuntivaUrl: fotoConjuntivaUrl ?? this.fotoConjuntivaUrl,
      diagnosticoAnemiaRiesgo:
          diagnosticoAnemiaRiesgo ?? this.diagnosticoAnemiaRiesgo,
      diagnosticoAnemiaScore:
          diagnosticoAnemiaScore ?? this.diagnosticoAnemiaScore,
      diagnosticoAnemiaFecha:
          diagnosticoAnemiaFecha ?? this.diagnosticoAnemiaFecha,
    );
  }

  // Calcular edad en años
  int get edad {
    final ahora = DateTime.now();
    int edad = ahora.year - fechaNacimiento.year;
    if (ahora.month < fechaNacimiento.month ||
        (ahora.month == fechaNacimiento.month &&
            ahora.day < fechaNacimiento.day)) {
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
      other is NinoModel && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
