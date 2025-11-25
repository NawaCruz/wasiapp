// 📊 Calculadora de IMC - WasiApp
// Calcula el Índice de Masa Corporal y lo clasifica según edad

class IMCCalculator {
  // Calcular IMC: peso / (talla × talla)
  // Ejemplo: 15kg / (1.0m × 1.0m) = 15
  static double calcularIMC(double peso, double talla) {
    if (talla <= 0) return 0; // Evitar división por cero
    return peso / (talla * talla);
  }

  // Clasificar IMC para adultos (18+ años)
  static String clasificarIMCAdultos(double imc) {
    if (imc < 18.5) {
      return 'Bajo peso';
    } else if (imc >= 18.5 && imc < 25) {
      return 'Peso normal';
    } else if (imc >= 25 && imc < 30) {
      return 'Sobrepeso';
    } else if (imc >= 30 && imc < 35) {
      return 'Obesidad grado I';
    } else if (imc >= 35 && imc < 40) {
      return 'Obesidad grado II';
    } else {
      return 'Obesidad grado III';
    }
  }

  // Clasificar IMC para niños (0-18 años)
  // NOTA: Esta es una versión simplificada
  // Un sistema profesional usaría las tablas oficiales de percentiles de la OMS
  static String clasificarIMCNinos(double imc, int edad, String sexo) {

    if (edad <= 2) {
      if (imc < 14) return 'Bajo peso';
      if (imc <= 18) return 'Peso normal';
      if (imc <= 20) return 'Sobrepeso';
      return 'Obesidad';
    } else if (edad <= 5) {
      if (imc < 13.5) return 'Bajo peso';
      if (imc <= 17) return 'Peso normal';
      if (imc <= 19) return 'Sobrepeso';
      return 'Obesidad';
    } else if (edad <= 10) {
      if (imc < 14) return 'Bajo peso';
      if (imc <= 19) return 'Peso normal';
      if (imc <= 22) return 'Sobrepeso';
      return 'Obesidad';
    } else {
      // Para adolescentes, usar clasificación similar a adultos con ajustes
      if (imc < 16) return 'Bajo peso';
      if (imc <= 23) return 'Peso normal';
      if (imc <= 27) return 'Sobrepeso';
      return 'Obesidad';
    }
  }

  // Obtener color según clasificación
  static String obtenerColorIMC(String clasificacion) {
    switch (clasificacion.toLowerCase()) {
      case 'bajo peso':
        return '#3498db'; // Azul
      case 'peso normal':
        return '#2ecc71'; // Verde
      case 'sobrepeso':
        return '#f39c12'; // Naranja
      case 'obesidad':
      case 'obesidad grado i':
      case 'obesidad grado ii':
      case 'obesidad grado iii':
        return '#e74c3c'; // Rojo
      default:
        return '#95a5a6'; // Gris
    }
  }

  // Obtener recomendación según clasificación
  static String obtenerRecomendacion(String clasificacion) {
    switch (clasificacion.toLowerCase()) {
      case 'bajo peso':
        return 'Se recomienda consultar con un nutricionista para evaluar la dieta y posibles causas del bajo peso.';
      case 'peso normal':
        return 'Mantener hábitos alimentarios saludables y actividad física regular.';
      case 'sobrepeso':
        return 'Se recomienda adoptar una dieta balanceada y aumentar la actividad física. Considerar consulta médica.';
      case 'obesidad':
      case 'obesidad grado i':
      case 'obesidad grado ii':
      case 'obesidad grado iii':
        return 'Es importante consultar con un médico para un plan de pérdida de peso supervisado y evaluación de riesgos para la salud.';
      default:
        return 'Consultar con un profesional de la salud para una evaluación completa.';
    }
  }
}
