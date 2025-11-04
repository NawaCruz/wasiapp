import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

/// Nivel de riesgo categórico
enum RiskLevel { bajo, medio, alto }

/// Entrada para estimar riesgo de anemia
class AnemiaRiskInput {
  final int edadMeses; // edad en meses para umbrales OMS más simples
  final String sexo; // 'Masculino' | 'Femenino'
  final double pesoKg;
  final double tallaM; // en metros
  final double? hemoglobina; // g/dL opcional

  // Cuestionario (0/1)
  final bool palidez;
  final bool fatiga;
  final bool apetitoBajo;
  final bool infeccionesFrecuentes;
  final bool bajaIngestaHierro;

  // Score de imagen [0..1] - 1 indica muy pálido (alto riesgo)
  final double? imagePalenessScore;

  const AnemiaRiskInput({
    required this.edadMeses,
    required this.sexo,
    required this.pesoKg,
    required this.tallaM,
    this.hemoglobina,
    required this.palidez,
    required this.fatiga,
    required this.apetitoBajo,
    required this.infeccionesFrecuentes,
    required this.bajaIngestaHierro,
    this.imagePalenessScore,
  });
}

/// Resultado de riesgo con explicación
class AnemiaRiskResult {
  final double score; // 0..100
  final RiskLevel level;
  final List<String> factores;

  const AnemiaRiskResult({
    required this.score,
    required this.level,
    required this.factores,
  });
}

class AnemiaRiskEngine {
  /// Estimar riesgo combinando hemoglobina (si hay), IMC, cuestionario e imagen.
  static AnemiaRiskResult estimate(AnemiaRiskInput i) {
    double score = 0;
    final factores = <String>[];

    // 1) Hemoglobina (peso alto si está disponible)
    if (i.hemoglobina != null) {
      final umbral = _umbralHbOMS(i.edadMeses);
      if (i.hemoglobina! < umbral - 1.0) {
        score += 45; // anemia clara
        factores.add('Hemoglobina baja (< ${umbral.toStringAsFixed(1)} g/dL)');
      } else if (i.hemoglobina! < umbral) {
        score += 30; // cerca al límite
        factores.add('Hemoglobina en el límite (≈ ${umbral.toStringAsFixed(1)} g/dL)');
      } else {
        score += 10; // normal
        factores.add('Hemoglobina en rango');
      }
    } else {
      // Sin hemoglobina: depender más de otros factores
      score += 5; // incertidumbre
      factores.add('Hemoglobina no disponible');
    }

    // 2) IMC (bajo peso aumenta riesgo)
    final imc = _imc(i.pesoKg, i.tallaM);
    if (imc <= 14) {
      score += 20; factores.add('IMC bajo (${imc.toStringAsFixed(1)})');
    } else if (imc <= 17) {
      score += 10; factores.add('IMC ligeramente bajo (${imc.toStringAsFixed(1)})');
    } else {
      score += 5; factores.add('IMC en rango (${imc.toStringAsFixed(1)})');
    }

    // 3) Cuestionario (cada indicador suma)
    final qFlags = [i.palidez, i.fatiga, i.apetitoBajo, i.infeccionesFrecuentes, i.bajaIngestaHierro];
    final qScore = qFlags.where((f) => f).length * 6.0; // hasta 30 pts
    score += qScore;
    if (qScore > 0) factores.add('Síntomas/dieta: +${qScore.toInt()} pts');

    // 4) Imagen (brillo → palidez) - score [0..1] mapea hasta 25 pts
    if (i.imagePalenessScore != null) {
      final imgPts = (i.imagePalenessScore!.clamp(0, 1) * 25);
      score += imgPts;
      factores.add('Indicador de palidez por imagen: +${imgPts.toInt()} pts');
    }

    // Normalizar a 0..100
    score = score.clamp(0, 100);
    final level = score >= 60
        ? RiskLevel.alto
        : (score >= 35 ? RiskLevel.medio : RiskLevel.bajo);

    return AnemiaRiskResult(score: score, level: level, factores: factores);
  }

  /// Calcula una heurística de palidez analizando el color rojo de la conjuntiva.
  /// Detecta zonas rojizas (conjuntiva) y evalúa su saturación e intensidad.
  /// Valores bajos indican palidez (posible anemia).
  static double? imagePalenessFromFile(File file) {
    try {
      final bytes = file.readAsBytesSync();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      
      // Muestreo optimizado para velocidad
      final step = max(1, (decoded.width * decoded.height) ~/ 50000);
      
      double redSum = 0.0;
      double saturationSum = 0.0;
      int redPixelCount = 0;
      int totalSamples = 0;
      
      for (int y = 0; y < decoded.height; y += step.toInt()) {
        for (int x = 0; x < decoded.width; x += step.toInt()) {
          final px = decoded.getPixel(x, y);
          final r = px.r.toDouble();
          final g = px.g.toDouble();
          final b = px.b.toDouble();
          
          totalSamples++;
          
          // Detectar píxeles con componente rojo dominante (conjuntiva)
          // Condiciones: R > G, R > B, y R debe ser significativo
          if (r > g && r > b && r > 80) {
            // Calcular saturación del rojo
            final maxVal = max(r, max(g, b));
            final minVal = min(r, min(g, b));
            final saturation = maxVal > 0 ? (maxVal - minVal) / maxVal : 0.0;
            
            // Calcular intensidad del rojo normalizada
            final redIntensity = r / 255.0;
            
            // Filtrar píxeles con suficiente saturación (no grises)
            if (saturation > 0.15) {
              redSum += redIntensity;
              saturationSum += saturation;
              redPixelCount++;
            }
          }
        }
      }
      
      if (redPixelCount == 0 || totalSamples == 0) {
        // No se detectaron zonas rojizas suficientes
        return 0.7; // Valor medio-alto de palidez (posible problema)
      }
      
      // Calcular métricas promedio
      final avgRedIntensity = redSum / redPixelCount;
      final avgSaturation = saturationSum / redPixelCount;
      final redPixelRatio = redPixelCount / totalSamples;
      
      // Score de "rojez" saludable (0-1, donde 1 es muy rojo/saludable)
      final healthyRedScore = (avgRedIntensity * 0.5) + (avgSaturation * 0.3) + (redPixelRatio * 20 * 0.2);
      
      // Invertir: palidez = falta de color rojo
      // 1.0 = mucha palidez (poco rojo), 0.0 = sin palidez (mucho rojo)
      final palenessScore = 1.0 - healthyRedScore.clamp(0.0, 1.0);
      
      return palenessScore.clamp(0.0, 1.0);
      
    } catch (_) {
      return null;
    }
  }

  static double _imc(double pesoKg, double tallaM) {
    if (tallaM <= 0) return 0;
    return pesoKg / (tallaM * tallaM);
  }

  /// Umbral OMS simplificado por grupos de edad (6–59m, 5–11a, 12–14a)
  static double _umbralHbOMS(int edadMeses) {
    if (edadMeses < 6) return 10.5; // neonatal tardío – aproximación
    if (edadMeses <= 59) return 11.0; // 6–59 meses
    if (edadMeses <= 132) return 11.5; // 5–11 años
    if (edadMeses <= 168) return 12.0; // 12–14 años
    return 12.0; // >= 15 sin considerar sexo/embarazo (simplificado)
  }
}
