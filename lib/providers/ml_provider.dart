// lib/providers/ml_provider.dart
import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:image/image.dart' as img;

import '../services/ml_service.dart'; // MLServices

class MLProvider extends ChangeNotifier {
  final MLServices _ml = MLServices();

  bool _loading = false;
  bool _ready = false;
  String? _error;
  List<String> _labels = [];

  // Config de tu modelo (ajusta si no es 224x224x3)
  static const int _inputW = 224;
  static const int _inputH = 224;
  static const int _inputC = 3;

  // Pon esto en true si tu modelo es cuantizado uint8
  final bool quantized = false;

  bool get loading => _loading;
  bool get ready => _ready;
  String? get error => _error;
  List<String> get labels => _labels;

  Future<void> init() async {
    _loading = true;
    _error = null;
    notifyListeners();
    try {
      // 1) Carga etiquetas
      final raw = await rootBundle.loadString('assets/labels.txt');
      _labels = raw
          .split('\n')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      // 2) Descarga/carga intérprete
      await _ml.loadInterpreter();
      _ready = _ml.isReady;
    } catch (e) {
      _error = e.toString();
      _ready = false;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  /// Predicción top-1 desde un archivo de imagen
  Future<Map<String, dynamic>> predictFromImage(File imageFile) async {
    if (!_ready) return {'error': 'Modelo no listo'};

    // 1) Decodifica
    final bytes = await imageFile.readAsBytes();
    img.Image? image = img.decodeImage(bytes);
    if (image == null) return {'error': 'Imagen inválida'};

    // 2) Resize al tamaño de entrada del modelo
    image = img.copyResize(image, width: _inputW, height: _inputH);

    // 3) Empaquetado de entrada según el tipo de modelo
    final inputSize = 1 * _inputW * _inputH * _inputC;

    List<double> logits;
    if (!quantized) {
      // float32: normaliza a [0,1] (ajusta a [-1,1] si tu entrenamiento lo pide)
      final input = Float32List(inputSize);
      int i = 0;
      for (int y = 0; y < _inputH; y++) {
        for (int x = 0; x < _inputW; x++) {
          final pixel = image.getPixel(x, y);
          input[i++] = pixel.r / 255.0;
          input[i++] = pixel.g / 255.0;
          input[i++] = pixel.b / 255.0;
        }
      }
      logits = _ml.runFloat(
        input,
        [1, _inputH, _inputW, _inputC],
        [1, _labels.length],
      );
    } else {
      // uint8: sin normalizar (0..255)
      final input = Uint8List(inputSize);
      int i = 0;
      for (int y = 0; y < _inputH; y++) {
        for (int x = 0; x < _inputW; x++) {
          final pixel = image.getPixel(x, y); // img.Pixel (r,g,b son num)
          input[i++] = pixel.r.clamp(0, 255).toInt(); // <- cast a int
          input[i++] = pixel.g.clamp(0, 255).toInt();
          input[i++] = pixel.b.clamp(0, 255).toInt();
        }
      }
      // Requiere método runUint8 en tu MLServices (lo dejo abajo)
      logits = _ml.runUint8(
        input,
        [1, _inputH, _inputW, _inputC],
        [1, _labels.length],
      );
    }

    // 4) Si tu modelo devuelve logits, aplicamos softmax; si ya devuelve probs, puedes saltarte esto
    final probs = _softmax(logits);

    // 5) Top-1
    int bestIdx = 0;
    double bestVal = probs[0];
    for (int j = 1; j < probs.length; j++) {
      if (probs[j] > bestVal) {
        bestVal = probs[j];
        bestIdx = j;
      }
    }

    final label = bestIdx < _labels.length ? _labels[bestIdx] : 'desconocido';
    return {
      'index': bestIdx,
      'label': label,
      'score': bestVal,
    };
  }

  List<double> _softmax(List<double> x) {
    final maxX = x.reduce(math.max);
    final exps = x.map((v) => math.exp(v - maxX)).toList();
    final sum = exps.fold<double>(0, (a, b) => a + b);
    return exps.map((e) => e / (sum == 0 ? 1 : sum)).toList();
  }

  @override
  void dispose() {
    _ml.dispose();
    super.dispose();
  }
}
