import 'dart:io';
import 'dart:typed_data';
import 'package:firebase_ml_model_downloader/firebase_ml_model_downloader.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class MLServices {
  static const String modelName = 'tu_modelo'; // EXACTO como en Firebase
  Interpreter? _interpreter;

  Future<void> loadInterpreter() async {
    final model = await FirebaseModelDownloader.instance.getModel(
      modelName,
      FirebaseModelDownloadType.localModelUpdateInBackground,
      FirebaseModelDownloadConditions(
        // ← sin const
        iosAllowsCellularAccess: false,
        iosAllowsBackgroundDownloading: true,
        androidChargingRequired: false,
        androidWifiRequired: false,
        androidDeviceIdleRequired: false,
      ),
    );

    // En tu versión, file NO es null
    final File file = model.file;

    if (!file.existsSync()) {
      throw Exception('El archivo del modelo no existe en: ${file.path}');
    }

    // Cierra si ya había uno
    _interpreter?.close();

    // Opcional: afina hilos
    final options = InterpreterOptions()..threads = 2;

    // ¡Sin await!
    _interpreter = Interpreter.fromFile(file, options: options);
  }

  bool get isReady => _interpreter != null;

  /// Inferencia con Float32, shapes explícitos.
  List<double> runFloat(
    Float32List input,
    List<int> inputShape,
    List<int> outputShape,
  ) {
    final it = _interpreter;
    if (it == null) {
      throw StateError('Interpreter no cargado');
    }

    // Ajusta shape de entrada y prepara tensores
    it.resizeInputTensor(0, inputShape);
    it.allocateTensors();

    // Salida plana
    final outputSize = outputShape.reduce((a, b) => a * b);
    final output = Float32List(outputSize);

    // Corre
    it.run(input, output);

    // Devuelve como List<double>
    return output.map((e) => e.toDouble()).toList();
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
  }

  // ---------------------------------------------------------------------------
  // Ejecución para modelos cuantizados (uint8)
  // ---------------------------------------------------------------------------
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
