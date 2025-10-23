import 'package:intl/intl.dart';

class Validators {
  // Validar email
  static String? validarEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su email';
    }

    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingrese un email válido';
    }

    return null;
  }

  // Validar contraseña
  static String? validarContrasena(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese su contraseña';
    }

    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }

    return null;
  }

  // Funciones Core eliminadas para evitar duplicación
  static String? validarNombre(String? value, String campo) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese $campo';
    }
    if (value.length < 2) {
      return '$campo debe tener al menos 2 caracteres';
    }
    final nombreRegex = RegExp(r'^[a-zA-ZáéíóúÁÉÍÓÚñÑ\s]+$');
    if (!nombreRegex.hasMatch(value)) {
      return '$campo solo debe contener letras y espacios';
    }
    return null;
  }
  // Funciones Core eliminadas - se mantienen las versiones estándar

  // Validar DNI peruano
  static String? validarDNI(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese el DNI';
    }
    if (value.length != 8) {
      return 'El DNI debe tener 8 dígitos';
    }
    final dniRegex = RegExp(r'^\d{8}$');
    if (!dniRegex.hasMatch(value)) {
      return 'El DNI solo debe contener números';
    }
    return null;
  }
  // Función Core eliminada - se mantiene validarDNI estándar

  // Validar peso
  static String? validarPeso(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese el peso';
    }
    final peso = double.tryParse(value);
    if (peso == null) {
      return 'Ingrese un peso válido';
    }
    if (peso <= 0) {
      return 'El peso debe ser mayor a 0';
    }
    if (peso > 200) {
      return 'El peso no puede ser mayor a 200 kg';
    }
    return null;
  }
  // Función Core eliminada - se mantiene validarPeso estándar

  // Validar talla
  static String? validarTalla(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese la talla';
    }
    final talla = double.tryParse(value);
    if (talla == null) {
      return 'Ingrese una talla válida';
    }
    if (talla <= 0) {
      return 'La talla debe ser mayor a 0';
    }
    if (talla < 0.3 || talla > 2.5) {
      return 'La talla debe estar entre 0.3 y 2.5 metros';
    }
    return null;
  }
  // Funciones Core eliminadas para mantener solo las versiones estándar utilizadas
  static String? validarCampoRequerido(String? value, String campo) {
    if (value == null || value.trim().isEmpty) {
      return 'Por favor ingrese $campo';
    }
    return null;
  }

  // Validar teléfono peruano
  static String? validarTelefono(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese el teléfono';
    }

    final telefonoRegex = RegExp(r'^9\d{8}$');
    if (!telefonoRegex.hasMatch(value)) {
      return 'Ingrese un teléfono válido (9 dígitos empezando por 9)';
    }

    return null;
  }

  // Validar que el campo contenga solo números
  static String? validarSoloNumeros(String? value, String campo) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese $campo';
    }

    final numerosRegex = RegExp(r'^\d+$');
    if (!numerosRegex.hasMatch(value)) {
      return '$campo solo debe contener números';
    }

    return null;
  }
}

class DateTimeUtils {
  // Formatear fecha para mostrar
  static String formatearFecha(DateTime fecha) {
    return DateFormat('dd/MM/yyyy').format(fecha);
  }

  // Formatear fecha y hora
  static String formatearFechaHora(DateTime fechaHora) {
    return DateFormat('dd/MM/yyyy HH:mm').format(fechaHora);
  }

  // Calcular edad en años
  static int calcularEdad(DateTime fechaNacimiento) {
    final ahora = DateTime.now();
    int edad = ahora.year - fechaNacimiento.year;
    if (ahora.month < fechaNacimiento.month ||
        (ahora.month == fechaNacimiento.month && ahora.day < fechaNacimiento.day)) {
      edad--;
    }
    return edad;
  }

  // Formatear duración
  static String formatearDuracion(Duration duracion) {
    if (duracion.inDays > 0) {
      return '${duracion.inDays} días';
    } else if (duracion.inHours > 0) {
      return '${duracion.inHours} horas';
    } else if (duracion.inMinutes > 0) {
      return '${duracion.inMinutes} minutos';
    } else {
      return '${duracion.inSeconds} segundos';
    }
  }
}