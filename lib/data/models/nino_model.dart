import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/nino.dart';

class NinoModel extends Nino {
  NinoModel({
    super.id,
    required super.nombres,
    required super.apellidos,
    required super.dniNino,
    required super.fechaNacimiento,
    required super.sexo,
    required super.residencia,
    required super.nombreTutor,
    required super.dniPadre,
    required super.anemia,
    required super.alimentosHierro,
    required super.fatiga,
    required super.alimentacionBalanceada,
    required super.peso,
    required super.talla,
    required super.imc,
    required super.clasificacionIMC,
    required super.fechaRegistro,
  });

  /// Convierte el modelo a un Map para Firestore
  Map<String, dynamic> toMap() {
    return {
      'nombres': nombres,
      'apellidos': apellidos,
      'dniNino': dniNino,
      'fechaNacimiento': fechaNacimiento,
      'sexo': sexo,
      'residencia': residencia,
      'nombreTutor': nombreTutor,
      'dniPadre': dniPadre,
      'anemia': anemia,
      'alimentosHierro': alimentosHierro,
      'fatiga': fatiga,
      'alimentacionBalanceada': alimentacionBalanceada,
      'peso': peso,
      'talla': talla,
      'imc': imc,
      'clasificacionIMC': clasificacionIMC,
      'fechaRegistro': FieldValue.serverTimestamp(),
    };
  }

  /// Crea un modelo desde un Map de Firestore
  factory NinoModel.fromMap(Map<String, dynamic> map) {
    return NinoModel(
      nombres: map['nombres'] ?? '',
      apellidos: map['apellidos'] ?? '',
      dniNino: map['dniNino'] ?? '',
      fechaNacimiento: (map['fechaNacimiento'] as Timestamp).toDate(),
      sexo: map['sexo'] ?? '',
      residencia: map['residencia'] ?? '',
      nombreTutor: map['nombreTutor'] ?? '',
      dniPadre: map['dniPadre'] ?? '',
      anemia: map['anemia'] ?? '',
      alimentosHierro: map['alimentosHierro'] ?? '',
      fatiga: map['fatiga'] ?? '',
      alimentacionBalanceada: map['alimentacionBalanceada'] ?? '',
      peso: (map['peso'] ?? 0.0).toDouble(),
      talla: (map['talla'] ?? 0.0).toDouble(),
      imc: (map['imc'] ?? 0.0).toDouble(),
      clasificacionIMC: map['clasificacionIMC'] ?? '',
      fechaRegistro: (map['fechaRegistro'] as Timestamp).toDate(),
    );
  }

  /// Crea un modelo desde un DocumentSnapshot de Firestore
  factory NinoModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return NinoModel.fromMap(data).copyWith(id: doc.id);
  }

  /// Convierte de Entity a Model
  factory NinoModel.fromEntity(Nino nino) {
    return NinoModel(
      id: nino.id,
      nombres: nino.nombres,
      apellidos: nino.apellidos,
      dniNino: nino.dniNino,
      fechaNacimiento: nino.fechaNacimiento,
      sexo: nino.sexo,
      residencia: nino.residencia,
      nombreTutor: nino.nombreTutor,
      dniPadre: nino.dniPadre,
      anemia: nino.anemia,
      alimentosHierro: nino.alimentosHierro,
      fatiga: nino.fatiga,
      alimentacionBalanceada: nino.alimentacionBalanceada,
      peso: nino.peso,
      talla: nino.talla,
      imc: nino.imc,
      clasificacionIMC: nino.clasificacionIMC,
      fechaRegistro: nino.fechaRegistro,
    );
  }

  @override
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
    String? anemia,
    String? alimentosHierro,
    String? fatiga,
    String? alimentacionBalanceada,
    double? peso,
    double? talla,
    double? imc,
    String? clasificacionIMC,
    DateTime? fechaRegistro,
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
      anemia: anemia ?? this.anemia,
      alimentosHierro: alimentosHierro ?? this.alimentosHierro,
      fatiga: fatiga ?? this.fatiga,
      alimentacionBalanceada: alimentacionBalanceada ?? this.alimentacionBalanceada,
      peso: peso ?? this.peso,
      talla: talla ?? this.talla,
      imc: imc ?? this.imc,
      clasificacionIMC: clasificacionIMC ?? this.clasificacionIMC,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }
}