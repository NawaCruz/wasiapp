import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/ml_service.dart';

class MLProvider with ChangeNotifier {
  final MLService _mlService = MLService();
  bool _isLoading = false;
  String _predictionResult = '';
  double _confidence = 0.0;
  String? _error;
  File? _selectedImage;
  bool _modelReady = false;

  bool get isLoading => _isLoading;
  String get predictionResult => _predictionResult;
  double get confidence => _confidence;
  String? get error => _error;
  File? get selectedImage => _selectedImage;
  bool get modelReady => _modelReady;

  // Inicializar modelo al crear el provider
  MLProvider() {
    _initializeModel();
  }

  Future<void> _initializeModel() async {
    try {
      _modelReady = await _mlService.initializeModel();
      if (!_modelReady) {
        _error = 'No se pudo cargar el modelo de ML';
      }
      notifyListeners();
    } catch (e) {
      _error = 'Error inicializando modelo: $e';
      notifyListeners();
    }
  }

  Future<void> predictFromCamera() async {
    if (!_modelReady) {
      _error = 'Modelo no está listo';
      notifyListeners();
      return;
    }

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        await _predictImage(File(image.path));
      }
    } catch (e) {
      _error = 'Error con la cámara: $e';
      notifyListeners();
    }
  }

  Future<void> predictFromGallery() async {
    if (!_modelReady) {
      _error = 'Modelo no está listo';
      notifyListeners();
      return;
    }

    try {
      final picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (image != null) {
        await _predictImage(File(image.path));
      }
    } catch (e) {
      _error = 'Error con la galería: $e';
      notifyListeners();
    }
  }

  Future<void> _predictImage(File imageFile) async {
    try {
      _isLoading = true;
      _error = null;
      _selectedImage = imageFile;
      notifyListeners();

      final results = await _mlService.predict(imageFile);
      
      if (results.containsKey('error')) {
        _error = results['error'];
        _predictionResult = '';
        _confidence = 0.0;
      } else {
        _predictionResult = results['prediction'] ?? 'Desconocido';
        _confidence = results['confidence_value'] ?? 0.0;
      }

    } catch (e) {
      _error = 'Error procesando imagen: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearResults() {
    _predictionResult = '';
    _confidence = 0.0;
    _error = null;
    _selectedImage = null;
    notifyListeners();
  }
}