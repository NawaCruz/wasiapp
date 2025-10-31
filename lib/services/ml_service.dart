import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:image/image.dart' as img;

class MLService {
  static const String _modelName = "nutricion_model";
  Interpreter? _interpreter;
  bool _isModelLoaded = false;
  List<String> _labels = [];

  // Inicializar modelo con manejo de errores mejorado
  Future<bool> initializeModel() async {
    try {
      if (kDebugMode) {
        print('🔄 Iniciando descarga del modelo...');
      }

      // ✅ getModel() SIEMPRE retorna FirebaseCustomModel, no null
      // Pero puede lanzar excepción si hay error
      final FirebaseCustomModel firebaseModel =
          await FirebaseModelDownloader.instance.getModel(
        _modelName,
        FirebaseModelDownloadType.localModelUpdateInBackground,
      );

      if (kDebugMode) {
        print('✅ Modelo descargado: ${firebaseModel.file.path}');
      }

      // Cargar modelo en TFLite
      final File modelFile = File(firebaseModel.file.path);
      _interpreter = Interpreter.fromFile(modelFile);

      // Cargar etiquetas
      await _loadLabels();

      _isModelLoaded = true;
      if (kDebugMode) {
        print('🎉 Modelo inicializado correctamente');
      }
      return true;

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error crítico inicializando modelo: $e');
        print('📋 Stack trace: $stackTrace');
      }
      return false;
    }
  }

  // Cargar etiquetas con manejo de errores
  Future<void> _loadLabels() async {
    try {
      final String labelData = await rootBundle.loadString('assets/labels.txt');
      _labels = labelData.split('\n')
          .where((label) => label.trim().isNotEmpty)
          .map((label) => label.trim())
          .toList();
      if (kDebugMode) {
        print('🏷️ Etiquetas cargadas: $_labels');
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ No se pudieron cargar las etiquetas, usando defaults');
      }
      _labels = ['Normal', 'Riesgo_Nutricional', 'Desnutricion'];
    }
  }

  // Preprocesar imagen de forma segura
  List<List<List<List<double>>>>? _preprocessImage(img.Image image) {
    try {
      // Redimensionar a 224x224
      img.Image resizedImage = img.copyResize(image, width: 224, height: 224);

      var input = List.generate(
        1, // batch size
        (_) => List.generate(
          224, // height
          (h) => List.generate(
            224, // width
            (w) => List.generate(
              3, // channels (RGB)
              (c) {
                final pixel = resizedImage.getPixel(w, h);
                return c == 0 ? (pixel.r / 255.0) :
                      c == 1 ? (pixel.g / 255.0) :
                                (pixel.b / 255.0);
              },
            ),
          ),
        ),
      );

      return input;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error en preprocesamiento: $e');
      }
      return null;
    }
  }

  // Realizar predicción con mejor manejo de errores
  Future<Map<String, dynamic>> predict(File imageFile) async {
    if (!_isModelLoaded || _interpreter == null) {
      final success = await initializeModel();
      if (!success) {
        return {'error': 'No se pudo cargar el modelo'};
      }
    }

    try {
      if (kDebugMode) {
        print('🔍 Procesando imagen...');
      }

      // Leer imagen
      final bytes = await imageFile.readAsBytes();
      final image = img.decodeImage(bytes);

      if (image == null) {
        return {'error': 'No se pudo decodificar la imagen'};
      }

      // Preprocesar
      final input = _preprocessImage(image);
      if (input == null) {
        return {'error': 'Error en preprocesamiento de imagen'};
      }

      // Preparar output
      final outputTensor = _interpreter!.getOutputTensors()[0];
      final outputShape = outputTensor.shape;
      final outputSize = outputShape.reduce((a, b) => a * b);
      var output = List.filled(outputSize, 0.0).reshape(outputShape);

      // Ejecutar modelo
      _interpreter!.run(input, output);

      // Interpretar resultados
      return _interpretResults(output);

    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('❌ Error en predicción: $e');
        print('📋 Stack trace: $stackTrace');
      }
      return {'error': 'Error durante la predicción: $e'};
    }
  }

  // Interpretar resultados de forma segura
  Map<String, dynamic> _interpretResults(List<dynamic> output) {
    try {
      if (output is List<List<double>> && output.isNotEmpty) {
        final predictions = output[0];

        if (predictions.isEmpty) {
          return {'error': 'El modelo no devolvió predicciones'};
        }

        // Encontrar la predicción con mayor confianza
        double maxConfidence = predictions[0];
        int maxIndex = 0;

        for (int i = 1; i < predictions.length; i++) {
          if (predictions[i] > maxConfidence) {
            maxConfidence = predictions[i];
            maxIndex = i;
          }
        }

        String label = maxIndex < _labels.length ? _labels[maxIndex] : 'Clase $maxIndex';

        final confidencePercent = (maxConfidence * 100).toStringAsFixed(2);

        return {
          'prediction': label,
          'confidence': '$confidencePercent%',
          'confidence_value': maxConfidence,
          'class_index': maxIndex,
        };
      }

      return {'error': 'Formato de salida no reconocido'};

    } catch (e) {
      return {'error': 'Error interpretando resultados: $e'};
    }
  }

  bool get isModelLoaded => _isModelLoaded;
  List<String> get labels => _labels;
}