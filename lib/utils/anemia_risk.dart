// 🩺 Motor de Evaluación de Riesgo de Anemia - WasiApp
// Calcula el riesgo de anemia combinando IMC, síntomas y análisis de imagen

import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

// Niveles de riesgo posibles
enum RiskLevel { bajo, medio, alto }

// Datos necesarios para evaluar el riesgo
class AnemiaRiskInput {
  final int edadMeses;
  final String sexo;
  final double pesoKg;
  final double tallaM;
  final bool palidez;
  final bool fatiga;
  final bool apetitoBajo;
  final bool infeccionesFrecuentes;
  final bool bajaIngestaHierro;
  final double? imagePalenessScore;

  const AnemiaRiskInput({
    required this.edadMeses,
    required this.sexo,
    required this.pesoKg,
    required this.tallaM,
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
  // Calcular el riesgo de anemia basándose en múltiples factores
  // Devuelve un puntaje de 0-100 y clasifica como bajo/medio/alto
  static AnemiaRiskResult estimate(AnemiaRiskInput i) {
    double score = 0; // Puntaje total
    final factores = <String>[]; // Lista de factores detectados

    // FACTOR 1: IMC (peso vs altura)
    final imc = _imc(i.pesoKg, i.tallaM);
    if (imc <= 14) {
      score += 20; // IMC muy bajo = mayor riesgo
      factores.add('IMC bajo (${imc.toStringAsFixed(1)})');
    } else if (imc <= 17) {
      score += 10; // IMC ligeramente bajo
      factores.add('IMC ligeramente bajo (${imc.toStringAsFixed(1)})');
    } else {
      score += 5; // IMC normal
      factores.add('IMC en rango (${imc.toStringAsFixed(1)})');
    }

    // 3) Cuestionario
    final qFlags = [
      i.palidez,
      i.fatiga,
      i.apetitoBajo,
      i.infeccionesFrecuentes,
      i.bajaIngestaHierro
    ];
    final qScore = qFlags.where((f) => f).length * 6.0;
    score += qScore;
    if (qScore > 0) factores.add('Síntomas/dieta: +${qScore.toInt()} pts');

    // 4) Imagen (palidez de conjuntiva)
    if (i.imagePalenessScore != null) {
      final imgPts = (i.imagePalenessScore!.clamp(0, 1) * 25);
      score += imgPts;
      factores.add('Indicador de palidez por imagen: +${imgPts.toInt()} pts');
    }

    // Normalizar y clasificar
    score = score.clamp(0, 100);
    final level = score >= 60
        ? RiskLevel.alto
        : (score >= 35 ? RiskLevel.medio : RiskLevel.bajo);

    return AnemiaRiskResult(score: score, level: level, factores: factores);
  }

  // ==============================
  // === DETECCIÓN DE PALEZ HSV ===
  // ==============================

  // CONSTANTES ÚNICAS - Eliminadas las duplicadas
  static const double hMin = 8.0;
  static const double hMax = 22.0;
  static const double sMin = 0.22;
  static const double sMax = 0.55;
  static const double vMin = 0.65;
  static const double vMax = 0.95;

  // === CONSTANTES Y RANGOS HSV ===
  static const hsvRanges = {
    'HEALTHY': {
      'hRange': [350.0, 15.0], // rojo-rosado saludable
      'sRange': [0.45, 0.75], // buena saturación
      'vRange': [0.65, 0.85] // brillante pero no excesivo
    },
    'PALE': {
      'hRange': [10.0, 25.0], // más amarillento/pálido
      'sRange': [0.20, 0.40], // menos saturado
      'vRange': [0.75, 0.95] // más brillante/pálido
    }
  };

  /// Conversión RGB → HSV unificada (H en grados, S y V en 0..1)
  static List<double> _rgbToHsv(double r, double g, double b) {
    // Normalizar RGB a 0..1 si viene en 0..255
    if (r > 1.0 || g > 1.0 || b > 1.0) {
      r /= 255.0;
      g /= 255.0;
      b /= 255.0;
    }

    final cMax = max(r, max(g, b));
    final cMin = min(r, min(g, b));
    final delta = cMax - cMin;

    // Calcular matiz (H)
    double h = 0.0;
    if (delta > 0) {
      if (cMax == r) {
        h = 60.0 * (((g - b) / delta) % 6);
      } else if (cMax == g) {
        h = 60.0 * (((b - r) / delta) + 2);
      } else {
        h = 60.0 * (((r - g) / delta) + 4);
      }
    }
    if (h < 0) h += 360.0;

    // Calcular saturación (S) y valor (V)
    final s = cMax == 0 ? 0.0 : delta / cMax;
    final v = cMax;

    return [h, s, v];
  }

  /// Determina si un píxel pertenece a la conjuntiva con rangos mejorados
  static bool _isConjunctivalPixel(List<double> hsv) {
    final h = hsv[0], s = hsv[1], v = hsv[2];

    // Filtros básicos
    if (v < 0.15 || v > 0.95) return false; // muy oscuro o muy brillante
    if (s < 0.15) return false; // muy desaturado (grises)

    // Normalizar hue para el wrap-around en rojos
    final hue = h >= 350 ? h - 360 : h;

    // Rango expandido para conjuntiva (incluye tonos rojizos y rosados)
    return (hue >= -10 && hue <= 25) &&
        (s >= 0.15 && s <= 0.85) &&
        (v >= 0.25 && v <= 0.95);
  }

  /// Analiza la palidez de la conjuntiva con procesamiento mejorado
  static Map<String, dynamic> analyzeConjunctivalPaleness(File file) {
    try {
      final bytes = file.readAsBytesSync();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return _defaultResponse();

      List<List<double>> conjPixels = [];

      // Optimizar muestreo para imágenes grandes
      final step = max(1, (decoded.width * decoded.height) ~/ 100000);

      // Recolectar píxeles válidos
      for (int y = 0; y < decoded.height; y += step) {
        for (int x = 0; x < decoded.width; x += step) {
          final px = decoded.getPixel(x, y);
          final hsv =
              _rgbToHsv(px.r.toDouble(), px.g.toDouble(), px.b.toDouble());

          if (_isConjunctivalPixel(hsv)) {
            conjPixels.add(hsv);
          }
        }
      }

      if (conjPixels.isEmpty) return _defaultResponse();

      // 2. Calcular estadísticas robustas
      final stats = _calculateRobustStats(conjPixels);

      // 3. Calcular similitud con perfiles de referencia
      final healthyScore = _calculateProfileSimilarity(stats['hMedian']!,
          stats['sMedian']!, stats['vMedian']!, hsvRanges['HEALTHY']!);

      final paleScore = _calculateProfileSimilarity(stats['hMedian']!,
          stats['sMedian']!, stats['vMedian']!, hsvRanges['PALE']!);

      // 4. Normalizar scores
      final total = healthyScore + paleScore;
      final normalizedHealthy = healthyScore / total;
      final normalizedPale = paleScore / total;

      return {
        "label":
            normalizedHealthy > normalizedPale ? "sin_anemia" : "con_anemia",
        "scores": {
          "sin_anemia": double.parse(normalizedHealthy.toStringAsFixed(3)),
          "con_anemia": double.parse(normalizedPale.toStringAsFixed(3))
        },
        "hsv_stats": {
          "H_mean": stats['hMedian'],
          "S_mean": stats['sMedian'],
          "V_mean": stats['vMedian']
        }
      };
    } catch (_) {
      return _defaultResponse();
    }
  }

  /// Calcula estadísticas robustas (medianas) de los píxeles
  static Map<String, double> _calculateRobustStats(List<List<double>> pixels) {
    final hValues = pixels.map((p) => p[0]).toList()..sort();
    final sValues = pixels.map((p) => p[1]).toList()..sort();
    final vValues = pixels.map((p) => p[2]).toList()..sort();

    return {
      'hMedian': _median(hValues),
      'sMedian': _median(sValues),
      'vMedian': _median(vValues)
    };
  }

  /// Calcula similitud con un perfil de referencia
  static double _calculateProfileSimilarity(
      double h, double s, double v, Map<String, List<double>> profile) {
    // Pesos relativos para cada componente
    const wH = 0.5, wS = 0.3, wV = 0.2;

    // Calcular distancias normalizadas
    final dH =
        _hueDistance(h, (profile['hRange']![0] + profile['hRange']![1]) / 2);
    final dS = (s - (profile['sRange']![0] + profile['sRange']![1]) / 2).abs();
    final dV = (v - (profile['vRange']![0] + profile['vRange']![1]) / 2).abs();

    // Convertir distancia a similitud
    return exp(-(wH * dH * dH + wS * dS * dS + wV * dV * dV));
  }

  /// Calcula distancia circular para el matiz
  static double _hueDistance(double h1, double h2) {
    final diff = (h1 - h2).abs();
    return min(diff, 360 - diff) / 180.0;
  }

  /// Calcula la mediana de una lista ordenada
  static double _median(List<double> sorted) {
    final mid = sorted.length ~/ 2;
    return sorted.length.isOdd
        ? sorted[mid]
        : (sorted[mid - 1] + sorted[mid]) / 2;
  }

  static Map<String, dynamic> _defaultResponse() => {
        "label": "sin_anemia",
        "scores": {"sin_anemia": 0.0, "con_anemia": 0.0},
        "hsv_stats": {"H_mean": 0.0, "S_mean": 0.0, "V_mean": 0.0}
      };

  /// Calcula palidez por análisis de color (HSV).
  /// 1.0 = muy pálido / 0.0 = saludable (rojizo).
  static double? imagePalenessFromFile(File file) {
    try {
      final bytes = file.readAsBytesSync();
      final decoded = img.decodeImage(bytes);
      if (decoded == null) return null;

      final step = max(1, (decoded.width * decoded.height) ~/ 50000);
      int conjCount = 0, total = 0;
      double scoreHue = 0, scoreSat = 0, scoreVal = 0;

      const hC = 15.0, sC = 0.35, vC = 0.80;

      for (int y = 0; y < decoded.height; y += step) {
        for (int x = 0; x < decoded.width; x += step) {
          final px = decoded.getPixel(x, y);
          final r = px.r.toDouble(), g = px.g.toDouble(), b = px.b.toDouble();
          total++;
          if (r < 50 && g < 50 && b < 50) continue;

          // CORREGIDO: usar double directamente
          final hsv = _rgbToHsv(r, g, b);
          final h = hsv[0], s = hsv[1], v = hsv[2];

          final bool isConj = (h >= hMin && h <= hMax) &&
              (s >= sMin && s <= sMax) &&
              (v >= vMin && v <= vMax);

          if (isConj) {
            conjCount++;
            final hDist =
                ((h - hC).abs() / ((hMax - hMin) / 2)).clamp(0.0, 1.0);
            final sDist =
                ((s - sC).abs() / ((sMax - sMin) / 2)).clamp(0.0, 1.0);
            final vDist =
                ((v - vC).abs() / ((vMax - vMin) / 2)).clamp(0.0, 1.0);
            scoreHue += (1.0 - hDist);
            scoreSat += (1.0 - sDist);
            scoreVal += (1.0 - vDist);
          }
        }
      }

      if (conjCount == 0 || total == 0) return 0.7;

      final meanHue = scoreHue / conjCount;
      final meanSat = scoreSat / conjCount;
      final meanVal = scoreVal / conjCount;
      final conjRatio = (conjCount / total).clamp(0.0, 1.0);

      // Cuánto se parece al color saludable (0..1)
      final healthyScore = (meanHue * 0.40) +
          (meanSat * 0.30) +
          (meanVal * 0.20) +
          (conjRatio * 0.10);

      // Palidez inversa
      final paleness = 1.0 - healthyScore.clamp(0.0, 1.0);
      return paleness;
    } catch (_) {
      return null;
    }
  }

  // ==============================

  static double _imc(double pesoKg, double tallaM) {
    if (tallaM <= 0) return 0;
    return pesoKg / (tallaM * tallaM);
  }
}
