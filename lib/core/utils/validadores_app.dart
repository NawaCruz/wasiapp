import '../constants/app_constants.dart';

class ValidadoresApp {
  /// Valida que un campo no esté vacío
  static String? validarCampoRequerido(String? valor) {
    if (valor == null || valor.trim().isEmpty) {
      return MensajesValidacion.campoObligatorio;
    }
    return null;
  }

  /// Valida formato de email
  static String? validarEmail(String? email) {
    if (email == null || email.trim().isEmpty) {
      return MensajesValidacion.campoObligatorio;
    }
    
    final RegExp emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    
    if (!emailRegex.hasMatch(email.trim())) {
      return MensajesValidacion.emailInvalido;
    }
    return null;
  }

  /// Valida DNI peruano (8 dígitos)
  static String? validarDNI(String? dni) {
    if (dni == null || dni.trim().isEmpty) {
      return MensajesValidacion.campoObligatorio;
    }
    
    if (dni.trim().length != ConstantesApp.longitudDNI || 
        !RegExp(r'^\d{8}$').hasMatch(dni.trim())) {
      return MensajesValidacion.dniInvalido;
    }
    return null;
  }

  /// Valida nombres (solo letras y espacios)
  static String? validarNombre(String? nombre) {
    if (nombre == null || nombre.trim().isEmpty) {
      return MensajesValidacion.campoObligatorio;
    }
    
    if (!RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$').hasMatch(nombre.trim())) {
      return MensajesValidacion.nombreInvalido;
    }
    return null;
  }

  /// Valida edad en meses (0-72 meses = 0-6 años)
  static String? validarEdadMeses(String? edad) {
    if (edad == null || edad.trim().isEmpty) {
      return MensajesValidacion.campoObligatorio;
    }
    
    final int? edadMeses = int.tryParse(edad.trim());
    if (edadMeses == null) {
      return MensajesValidacion.valorNumericoInvalido;
    }
    
    if (edadMeses < 0 || edadMeses > ConstantesApp.edadMaximaMeses) {
      return MensajesValidacion.edadInvalida;
    }
    return null;
  }

  /// Valida peso (1-50 kg)
  static String? validarPeso(String? peso) {
    if (peso == null || peso.trim().isEmpty) {
      return MensajesValidacion.campoObligatorio;
    }
    
    final double? pesoDouble = double.tryParse(peso.trim());
    if (pesoDouble == null) {
      return MensajesValidacion.valorNumericoInvalido;
    }
    
    if (pesoDouble < 1.0 || pesoDouble > ConstantesApp.pesoMaximo) {
      return MensajesValidacion.pesoInvalido;
    }
    return null;
  }

  /// Valida talla (30-150 cm)
  static String? validarTalla(String? talla) {
    if (talla == null || talla.trim().isEmpty) {
      return MensajesValidacion.campoObligatorio;
    }
    
    final double? tallaDouble = double.tryParse(talla.trim());
    if (tallaDouble == null) {
      return MensajesValidacion.valorNumericoInvalido;
    }
    
    if (tallaDouble < 30.0 || tallaDouble > ConstantesApp.tallaMaxima) {
      return MensajesValidacion.tallaInvalida;
    }
    return null;
  }

  /// Valida hemoglobina (5-20 g/dL)
  static String? validarHemoglobina(String? hemoglobina) {
    if (hemoglobina == null || hemoglobina.trim().isEmpty) {
      return MensajesValidacion.campoObligatorio;
    }
    
    final double? hemoDouble = double.tryParse(hemoglobina.trim());
    if (hemoDouble == null) {
      return MensajesValidacion.valorNumericoInvalido;
    }
    
    if (hemoDouble < 5.0 || hemoDouble > 20.0) {
      return MensajesValidacion.hemoglobinaInvalida;
    }
    return null;
  }

  /// Valida contraseña
  static String? validarClave(String? clave) {
    if (clave == null || clave.isEmpty) {
      return MensajesValidacion.campoObligatorio;
    }
    
    if (clave.length < ConstantesApp.longitudMinimaClave) {
      return MensajesValidacion.claveCorta;
    }
    return null;
  }
}

class UtilidadesApp {
  /// Muestra un mensaje de carga
  static String mensajeCargando = 'Cargando...';
  
  /// Muestra un mensaje de éxito
  static String mensajeExito = '¡Operación exitosa!';
  
  /// Muestra un mensaje de error genérico
  static String mensajeErrorGenerico = 'Ha ocurrido un error. Intente nuevamente.';
  
  /// Formatea la fecha para mostrar
  static String formatearFecha(DateTime fecha) {
    return '${fecha.day.toString().padLeft(2, '0')}/'
           '${fecha.month.toString().padLeft(2, '0')}/'
           '${fecha.year}';
  }
  
  /// Convierte la edad de meses a años y meses
  static String formatearEdad(int meses) {
    if (meses < 12) {
      return '$meses ${meses == 1 ? 'mes' : 'meses'}';
    }
    
    final anos = meses ~/ 12;
    final mesesRestantes = meses % 12;
    
    String resultado = '$anos ${anos == 1 ? 'ano' : 'anos'}';
    if (mesesRestantes > 0) {
      resultado += ' y $mesesRestantes ${mesesRestantes == 1 ? 'mes' : 'meses'}';
    }
    
    return resultado;
  }
  
  /// Determina el estado nutricional
  static String obtenerEstadoNutricional(double peso, double talla, int edadMeses) {
    // Lógica simplificada - en producción usar tablas OMS
    final double imc = peso / ((talla / 100) * (talla / 100));
    
    if (imc < 15.0) return 'Desnutrición severa';
    if (imc < 18.5) return 'Bajo peso';
    if (imc <= 25.0) return 'Normal';
    return 'Sobrepeso';
  }
}