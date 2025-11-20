class ConstantesApp {
  // Colores de la aplicación
  static const String colorPrimario = '#1976D2';    // Azul principal
  static const String colorSecundario = '#4CAF50';  // Verde éxito
  static const String colorError = '#E53935';       // Rojo error
  static const String colorAdvertencia = '#FF9800'; // Naranja advertencia
  
  // Tamaños y espaciado
  static const double espaciadoPorDefecto = 16.0;
  static const double radioEsquinasBoton = 12.0;
  static const double alturaBoton = 56.0;
  
  // Información de la aplicación
  static const String nombreApp = 'WasiApp - Registro de Niños';
  static const String versionApp = '1.0.0';
  static const String descripcionApp = 'Control de crecimiento infantil';
  
  // Límites de validación
  static const int longitudMinimaClave = 6;
  static const int longitudDNI = 8;
  static const double pesoMaximo = 50.0;      // kg
  static const double tallaMaxima = 150.0;    // cm
  static const int edadMaximaMeses = 72;      // 6 años
}

class ConstantesFirebase {
  static const String coleccionUsuarios = 'usuarios';
  static const String coleccionNinos = 'ninos';
  static const String coleccionEstadisticas = 'estadisticas';
  
  // Campos de la base de datos
  static const String campoDNI = 'dniNino';
  static const String campoNombres = 'nombres';
  static const String campoApellidos = 'apellidos';
  static const String campoFechaNacimiento = 'fechaNacimiento';
  static const String campoSexo = 'sexo';
  static const String campoPeso = 'peso';
  static const String campoTalla = 'talla';
}

class Rutas {
  static const String inicio = '/';
  static const String iniciarSesion = '/iniciar-sesion';
  static const String registrarse = '/registrarse';
  static const String principal = '/principal';
  static const String registrarNino = '/registrar-nino';
  static const String listaNinos = '/lista-ninos';
  static const String estadisticas = '/estadisticas';
  static const String perfil = '/perfil';
  static const String configuracion = '/configuracion';
  static const String registroFlow = '/registro_flow';
}

class MensajesValidacion {
  // Mensajes de campos requeridos
  static const String campoObligatorio = 'Este campo es obligatorio';
  static const String emailInvalido = 'Ingrese un email válido';
  static const String claveCorta = 'La contraseña debe tener al menos 6 caracteres';
  static const String clavesNoCoinciden = 'Las contraseñas no coinciden';
  static const String dniInvalido = 'El DNI debe tener exactamente 8 dígitos';
  static const String valorNumericoInvalido = 'Ingrese un número válido';

  // Mensajes específicos para niños
  static const String nombreInvalido = 'Ingrese un nombre válido (solo letras)';
  static const String edadInvalida = 'La edad debe estar entre 0 y 72 meses';
  static const String pesoInvalido = 'El peso debe estar entre 1 y 50 kg';
  static const String tallaInvalida = 'La talla debe estar entre 30 y 150 cm';
  static const String selectOption = 'Debe seleccionar una opción';
  static const String selectDate = 'Debe seleccionar una fecha';
}