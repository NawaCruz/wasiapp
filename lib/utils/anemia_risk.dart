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
  /// Estimar riesgo combinando IMC, cuestionario e imagen.
  static AnemiaRiskResult estimate(AnemiaRiskInput i) {
    double score = 0;
    final factores = <String>[];

    // 1) IMC (bajo peso aumenta riesgo)
    final imc = _imc(i.pesoKg, i.tallaM);
    if (imc <= 14) {
      score += 20; factores.add('IMC bajo (${imc.toStringAsFixed(1)})');
    } else if (imc <= 17) {
      score += 10; factores.add('IMC ligeramente bajo (${imc.toStringAsFixed(1)})');
    } else {
      score += 5; factores.add('IMC en rango (${imc.toStringAsFixed(1)})');
    }

    // 2) Cuestionario (cada indicador suma)
    final qFlags = [i.palidez, i.fatiga, i.apetitoBajo, i.infeccionesFrecuentes, i.bajaIngestaHierro];
    final qScore = qFlags.where((f) => f).length * 6.0; // hasta 30 pts
    score += qScore;
    if (qScore > 0) factores.add('Síntomas/dieta: +${qScore.toInt()} pts');

    // 3) Imagen (análisis de palidez de conjuntiva) - score [0..1] mapea hasta 25 pts
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
  /// Detecta zonas rojizas (conjuntiva) y evalúa su saturación, intensidad y dominancia.
  /// Valores bajos indican palidez (posible anemia).
  /// 
  /// Criterios de detección basados en análisis clínico:
  /// - SALUDABLE: R >> G y R >> B (diferencia ~100+ puntos), saturación alta (0.55-0.65)
  /// - ANEMIA: R ≈ G ≈ B (diferencia ~15-20 puntos), saturación baja (0.10-0.20)
  static double? imagePalenessFromFile(File file) {
    try {
      final bytes = file.readAsBytesSync();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;
      
      // Muestreo optimizado para velocidad
      final step = max(1, (decoded.width * decoded.height) ~/ 50000);
      
      double redSum = 0.0;
      double saturationSum = 0.0;
      double redDominanceSum = 0.0; // Nueva métrica: dominancia del rojo
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
          // Umbral aumentado: R debe ser significativo (>120 en lugar de >80)
          // Esto filtra píxeles muy oscuros que no son conjuntiva
          if (r > g && r > b && r > 120) {
            // Calcular saturación del rojo
            final maxVal = max(r, max(g, b));
            final minVal = min(r, min(g, b));
            final saturation = maxVal > 0 ? (maxVal - minVal) / maxVal : 0.0;
            
            // Calcular intensidad del rojo normalizada
            final redIntensity = r / 255.0;
            
            // Calcular dominancia del rojo (qué tan mayor es R respecto a G y B)
            // Valores altos indican conjuntiva saludable
            final avgOthers = (g + b) / 2;
            final redDominance = avgOthers > 0 ? (r - avgOthers) / 255.0 : 0.0;
            
            // Filtrar píxeles con suficiente saturación (umbral aumentado de 0.15 a 0.25)
            // Esto descarta más píxeles grisáceos/pálidos característicos de anemia
            if (saturation > 0.25) {
              redSum += redIntensity;
              saturationSum += saturation;
              redDominanceSum += redDominance.clamp(0.0, 1.0);
              redPixelCount++;
            }
          }
        }
      }
      
      if (redPixelCount == 0 || totalSamples == 0) {
        // No se detectaron zonas rojizas suficientes
        // Esto indica palidez severa o foto inadecuada
        return 0.8; // Valor alto de palidez (posible anemia)
      }
      
      // Calcular métricas promedio
      final avgRedIntensity = redSum / redPixelCount;
      final avgSaturation = saturationSum / redPixelCount;
      final avgRedDominance = redDominanceSum / redPixelCount;
      final redPixelRatio = redPixelCount / totalSamples;
      
      // Score de "rojez" saludable (0-1, donde 1 es muy rojo/saludable)
      // Pesos ajustados para dar más importancia a la dominancia del rojo
      final healthyRedScore = 
        (avgRedIntensity * 0.35) +      // 35% peso: intensidad roja
        (avgSaturation * 0.25) +        // 25% peso: saturación
        (avgRedDominance * 0.30) +      // 30% peso: dominancia R sobre G y B (NUEVO)
        (redPixelRatio * 20 * 0.10);    // 10% peso: proporción de área roja
      
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
}
