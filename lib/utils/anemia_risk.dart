import 'dart:io';
import 'dart:math';
import 'package:image/image.dart' as img;

/// Nivel de riesgo categórico
enum RiskLevel { bajo, medio, alto }

/// Entrada para estimar riesgo de anemia
class AnemiaRiskInput {
  final int edadMeses;
  final String sexo;
  final double pesoKg;
  final double tallaM;
  final double? hemoglobina;
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
  /// Estima riesgo combinando hemoglobina, IMC, síntomas e imagen.
  static AnemiaRiskResult estimate(AnemiaRiskInput i) {
    double score = 0;
    final factores = <String>[];

    // 1) Hemoglobina
    if (i.hemoglobina != null) {
      final umbral = _umbralHbOMS(i.edadMeses);
      if (i.hemoglobina! < umbral - 1.0) {
        score += 45;
        factores.add('Hemoglobina baja (< ${umbral.toStringAsFixed(1)} g/dL)');
      } else if (i.hemoglobina! < umbral) {
        score += 30;
        factores.add('Hemoglobina en el límite (≈ ${umbral.toStringAsFixed(1)} g/dL)');
      } else {
        score += 10;
        factores.add('Hemoglobina en rango');
      }
    } else {
      score += 5;
      factores.add('Hemoglobina no disponible');
    }

    // 2) IMC
    final imc = _imc(i.pesoKg, i.tallaM);
    if (imc <= 14) {
      score += 20; factores.add('IMC bajo (${imc.toStringAsFixed(1)})');
    } else if (imc <= 17) {
      score += 10; factores.add('IMC ligeramente bajo (${imc.toStringAsFixed(1)})');
    } else {
      score += 5; factores.add('IMC en rango (${imc.toStringAsFixed(1)})');
    }

    // 3) Cuestionario
    final qFlags = [i.palidez, i.fatiga, i.apetitoBajo, i.infeccionesFrecuentes, i.bajaIngestaHierro];
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
  static const double H_MIN = 8.0;
  static const double H_MAX = 22.0;
  static const double S_MIN = 0.22;
  static const double S_MAX = 0.55;
  static const double V_MIN = 0.65;
  static const double V_MAX = 0.95;

  // === CONSTANTES Y RANGOS HSV ===
  static const _HSV_RANGES = {
    'HEALTHY': {
      'H_RANGE': [350.0, 15.0],  // rojo-rosado saludable
      'S_RANGE': [0.45, 0.75],   // buena saturación
      'V_RANGE': [0.65, 0.85]    // brillante pero no excesivo
    },
    'PALE': {
      'H_RANGE': [10.0, 25.0],   // más amarillento/pálido
      'S_RANGE': [0.20, 0.40],   // menos saturado
      'V_RANGE': [0.75, 0.95]    // más brillante/pálido
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
    if (v < 0.15 || v > 0.95) return false;  // muy oscuro o muy brillante
    if (s < 0.15) return false;              // muy desaturado (grises)
    
    // Normalizar hue para el wrap-around en rojos
    final hue = h >= 350 ? h - 360 : h;
    
    // Rango expandido para conjuntiva (incluye tonos rojizos y rosados)
    return (hue >= -10 && hue <= 25) && (s >= 0.15 && s <= 0.85) && (v >= 0.25 && v <= 0.95);
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
          final hsv = _rgbToHsv(px.r.toDouble(), px.g.toDouble(), px.b.toDouble());
          
          if (_isConjunctivalPixel(hsv)) {
            conjPixels.add(hsv);
          }
        }
      }

      if (conjPixels.isEmpty) return _defaultResponse();

      // 2. Calcular estadísticas robustas
      final stats = _calculateRobustStats(conjPixels);
      
      // 3. Calcular similitud con perfiles de referencia
      final healthyScore = _calculateProfileSimilarity(
        stats['H_median']!, stats['S_median']!, stats['V_median']!,
        _HSV_RANGES['HEALTHY']!
      );
      
      final paleScore = _calculateProfileSimilarity(
        stats['H_median']!, stats['S_median']!, stats['V_median']!,
        _HSV_RANGES['PALE']!
      );

      // 4. Normalizar scores
      final total = healthyScore + paleScore;
      final normalizedHealthy = healthyScore / total;
      final normalizedPale = paleScore / total;

      return {
        "label": normalizedHealthy > normalizedPale ? "sin_anemia" : "con_anemia",
        "scores": {
          "sin_anemia": double.parse(normalizedHealthy.toStringAsFixed(3)),
          "con_anemia": double.parse(normalizedPale.toStringAsFixed(3))
        },
        "hsv_stats": {
          "H_mean": stats['H_median'],
          "S_mean": stats['S_median'],
          "V_mean": stats['V_median']
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
      'H_median': _median(hValues),
      'S_median': _median(sValues),
      'V_median': _median(vValues)
    };
  }

  /// Calcula similitud con un perfil de referencia
  static double _calculateProfileSimilarity(
    double h, double s, double v, Map<String, List<double>> profile) {
    // Pesos relativos para cada componente
    const wH = 0.5, wS = 0.3, wV = 0.2;
    
    // Calcular distancias normalizadas
    final dH = _hueDistance(h, (profile['H_RANGE']![0] + profile['H_RANGE']![1]) / 2);
    final dS = (s - (profile['S_RANGE']![0] + profile['S_RANGE']![1]) / 2).abs();
    final dV = (v - (profile['V_RANGE']![0] + profile['V_RANGE']![1]) / 2).abs();
    
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

      const H_C = 15.0, S_C = 0.35, V_C = 0.80;

      for (int y = 0; y < decoded.height; y += step) {
        for (int x = 0; x < decoded.width; x += step) {
          final px = decoded.getPixel(x, y);
          final r = px.r.toDouble(), g = px.g.toDouble(), b = px.b.toDouble();
          total++;
          if (r < 50 && g < 50 && b < 50) continue;

          // CORREGIDO: usar double directamente
          final hsv = _rgbToHsv(r, g, b);
          final h = hsv[0], s = hsv[1], v = hsv[2];

          final bool isConj = (h >= H_MIN && h <= H_MAX) &&
                              (s >= S_MIN && s <= S_MAX) &&
                              (v >= V_MIN && v <= V_MAX);

          if (isConj) {
            conjCount++;
            final hDist = ((h - H_C).abs() / ((H_MAX - H_MIN) / 2)).clamp(0.0, 1.0);
            final sDist = ((s - S_C).abs() / ((S_MAX - S_MIN) / 2)).clamp(0.0, 1.0);
            final vDist = ((v - V_C).abs() / ((V_MAX - V_MIN) / 2)).clamp(0.0, 1.0);
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

  static double _umbralHbOMS(int edadMeses) {
    if (edadMeses < 6) return 10.5;
    if (edadMeses <= 59) return 11.0;
    if (edadMeses <= 132) return 11.5;
    if (edadMeses <= 168) return 12.0;
    return 12.0;
  }
}
