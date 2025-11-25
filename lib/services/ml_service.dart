// 🤖 Servicio de Inteligencia Artificial - WasiApp
// Usa TensorFlow Lite para predecir el riesgo de anemia en los niños

import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class MLServices {
  static const String modelName = 'tu_modelo'; // Nombre del modelo en Firebase (debe coincidir exactamente)
  Interpreter? _interpreter; // El "cerebro" que hace las predicciones

  // Descargar y preparar el modelo de IA desde Firebase
  Future<void> loadInterpreter() async {
    // Descargar el modelo desde Firebase con estas condiciones:
    final model = await FirebaseModelDownloader.instance.getModel(
      modelName,
      FirebaseModelDownloadType.localModelUpdateInBackground,
      FirebaseModelDownloadConditions(
        iosAllowsCellularAccess: false, // iOS: No usar datos móviles
        iosAllowsBackgroundDownloading: true, // iOS: Puede descargar en segundo plano
        androidChargingRequired: false, // Android: No necesita estar cargando
        androidWifiRequired: false, // Android: Puede usar datos móviles
        androidDeviceIdleRequired: false, // Android: No necesita estar inactivo
      ),
    );

    // Obtener el archivo del modelo descargado
    final File file = model.file;

    // Verificar que el archivo realmente exista
    if (!file.existsSync()) {
      throw Exception('El archivo del modelo no existe en: ${file.path}');
    }

    // Si ya había un modelo cargado, cerrarlo primero
    _interpreter?.close();

    // Configurar el intérprete para usar 2 hilos (más rápido)
    final options = InterpreterOptions()..threads = 2;

    // Cargar el modelo en memoria
    _interpreter = Interpreter.fromFile(file, options: options);
  }

  // Verificar si el modelo está listo para hacer predicciones
  bool get isReady => _interpreter != null;

  // Hacer una predicción con números decimales (Float32)
  List<double> runFloat(
    Float32List input,
    List<int> inputShape,
    List<int> outputShape,
  ) {
    final it = _interpreter;
    if (it == null) {
      throw StateError('Modelo no cargado. Llama primero a loadInterpreter()');
    }

    // Preparar el modelo con el tamaño de datos que vamos a enviar
    it.resizeInputTensor(0, inputShape);
    it.allocateTensors();

    // Preparar el espacio para recibir el resultado
    final outputSize = outputShape.reduce((a, b) => a * b);
    final output = Float32List(outputSize);

    // ¡Aquí es donde el modelo hace la magia! 🎯
    it.run(input, output);

    // Convertir el resultado a una lista normal de números
    return output.map((e) => e.toDouble()).toList();
  }

  // Limpiar la memoria cuando ya no necesitemos el modelo
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }

  // Hacer una predicción con números enteros pequeños (Uint8)
  // Útil para modelos más pequeños y rápidos
  List<double> runUint8(
    Uint8List input,
    List<int> inputShape,
    List<int> outputShape,
  ) {
    final it = _interpreter;
    if (it == null) {
      throw StateError('Interpreter no cargado');
    }

    // Valida tamaño de entrada
    final expectedInputSize = inputShape.reduce((a, b) => a * b);
    if (input.length != expectedInputSize) {
      throw ArgumentError(
        'Tamaño de entrada ${input.length} no coincide con inputShape ($expectedInputSize)',
      );
    }

    // Ajusta forma y reserva tensores
    it.resizeInputTensor(0, inputShape);
    it.allocateTensors();

    // La salida suele ser float32 incluso con entrada uint8
    final outputSize = outputShape.reduce((a, b) => a * b);
    final output = Float32List(outputSize);

    // Corre inferencia (Uint8List -> Float32List)
    it.run(input, output);

    // Devuelve como List<double>
    return output.map((e) => e.toDouble()).toList();
  }
}