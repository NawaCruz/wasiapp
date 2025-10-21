class Nino {
  final String? id;
  final String nombres;
  final String apellidos;
  final String dniNino;
  final DateTime fechaNacimiento;
  final String sexo;
  final String residencia;
  final String nombreTutor;
  final String dniPadre;
  final String anemia;
  final String alimentosHierro;
  final String fatiga;
  final String alimentacionBalanceada;
  final double peso;
  final double talla;
  final double imc;
  final String clasificacionIMC;
  final DateTime fechaRegistro;

  Nino({
    this.id,
    required this.nombres,
    required this.apellidos,
    required this.dniNino,
    required this.fechaNacimiento,
    required this.sexo,
    required this.residencia,
    required this.nombreTutor,
    required this.dniPadre,
    required this.anemia,
    required this.alimentosHierro,
    required this.fatiga,
    required this.alimentacionBalanceada,
    required this.peso,
    required this.talla,
    required this.imc,
    required this.clasificacionIMC,
    required this.fechaRegistro,
  });

  String get nombreCompleto => '$nombres $apellidos';
  
  int get edad {
    DateTime now = DateTime.now();
    int age = now.year - fechaNacimiento.year;
    if (now.month < fechaNacimiento.month ||
        (now.month == fechaNacimiento.month && now.day < fechaNacimiento.day)) {
      age--;
    }
    return age;
  }

  bool get tieneAnemia => anemia.toLowerCase() == 'sí';
  bool get consumeAlimentosHierro => alimentosHierro.toLowerCase() == 'sí';
  bool get presentaFatiga => fatiga.toLowerCase() == 'sí';
  bool get tieneAlimentacionBalanceada => alimentacionBalanceada.toLowerCase() == 'sí';

  Nino copyWith({
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
    return Nino(
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