import 'package:flutter/material.dart';
import '../models/nino_model.dart';
import '../services/nino_service.dart';
import '../utils/imc_calculator.dart';

class NinoController extends ChangeNotifier {
  List<NinoModel> _ninos = [];
  List<NinoModel> _ninosFiltrados = [];
  NinoModel? _ninoSeleccionado;
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, dynamic> _estadisticas = {};

  // Getters
  List<NinoModel> get ninos => _ninosFiltrados;
  NinoModel? get ninoSeleccionado => _ninoSeleccionado;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, dynamic> get estadisticas => _estadisticas;

  // Cargar todos los niños
  Future<void> cargarNinos() async {
    try {
      _setLoading(true);
      _clearError();

      _ninos = await NinoService.obtenerNinosActivos();
      _ninosFiltrados = List.from(_ninos);
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar niños: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Crear nuevo niño
  Future<bool> crearNino({
    required String nombres,
    required String apellidos,
    required String dniNino,
    required DateTime fechaNacimiento,
    required String sexo,
    required String residencia,
    required String nombreTutor,
    required String dniPadre,
    required double peso,
    required double talla,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Verificar si ya existe el DNI
      final existe = await NinoService.existeDNI(dniNino);
      if (existe) {
        _setError('Ya existe un niño registrado con este DNI');
        return false;
      }

      // Calcular IMC y clasificación
      final imc = IMCCalculator.calcularIMC(peso, talla);
      final edad = DateTime.now().difference(fechaNacimiento).inDays ~/ 365;
      final clasificacion = IMCCalculator.clasificarIMCNinos(imc, edad, sexo);

      final nuevoNino = NinoModel(
        id: '', // Se asignará automáticamente
        nombres: nombres,
        apellidos: apellidos,
        dniNino: dniNino,
        fechaNacimiento: fechaNacimiento,
        sexo: sexo,
        residencia: residencia,
        nombreTutor: nombreTutor,
        dniPadre: dniPadre,
        peso: peso,
        talla: talla,
        imc: imc,
        clasificacionIMC: clasificacion,
        fechaRegistro: DateTime.now(),
      );

      await NinoService.crearNino(nuevoNino);
      await cargarNinos(); // Recargar la lista
      return true;
    } catch (e) {
      _setError('Error al crear registro: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar niño
  Future<bool> actualizarNino(NinoModel nino) async {
    try {
      _setLoading(true);
      _clearError();

      // Recalcular IMC si cambió peso o talla
      final imc = IMCCalculator.calcularIMC(nino.peso, nino.talla);
      final edad = DateTime.now().difference(nino.fechaNacimiento).inDays ~/ 365;
      final clasificacion = IMCCalculator.clasificarIMCNinos(imc, edad, nino.sexo);

      final ninoActualizado = nino.copyWith(
        imc: imc,
        clasificacionIMC: clasificacion,
      );

      await NinoService.actualizarNino(ninoActualizado);
      await cargarNinos(); // Recargar la lista
      return true;
    } catch (e) {
      _setError('Error al actualizar registro: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar niño
  Future<bool> eliminarNino(String id) async {
    try {
      _setLoading(true);
      _clearError();

      await NinoService.eliminarNino(id);
      await cargarNinos(); // Recargar la lista
      return true;
    } catch (e) {
      _setError('Error al eliminar registro: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Buscar niños
  Future<void> buscarNinos(String termino) async {
    if (termino.isEmpty) {
      _ninosFiltrados = List.from(_ninos);
      notifyListeners();
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      // Buscar por DNI si el término es numérico
      if (RegExp(r'^\d+$').hasMatch(termino)) {
        _ninosFiltrados = await NinoService.buscarPorDNI(termino);
      } else {
        // Buscar por nombre
        _ninosFiltrados = await NinoService.buscarPorNombre(termino);
      }

      notifyListeners();
    } catch (e) {
      _setError('Error en la búsqueda: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Filtrar por sexo
  void filtrarPorSexo(String? sexo) {
    if (sexo == null || sexo.isEmpty || sexo == 'Todos') {
      _ninosFiltrados = List.from(_ninos);
    } else {
      _ninosFiltrados = _ninos.where((nino) => nino.sexo == sexo).toList();
    }
    notifyListeners();
  }

  // Filtrar por clasificación IMC
  void filtrarPorIMC(String? clasificacion) {
    if (clasificacion == null || clasificacion.isEmpty || clasificacion == 'Todas') {
      _ninosFiltrados = List.from(_ninos);
    } else {
      _ninosFiltrados = _ninos.where((nino) => nino.clasificacionIMC == clasificacion).toList();
    }
    notifyListeners();
  }

  // Cargar estadísticas
  Future<void> cargarEstadisticas() async {
    try {
      _setLoading(true);
      _clearError();

      _estadisticas = await NinoService.obtenerEstadisticas();
      notifyListeners();
    } catch (e) {
      _setError('Error al cargar estadísticas: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  // Seleccionar niño
  void seleccionarNino(NinoModel nino) {
    _ninoSeleccionado = nino;
    notifyListeners();
  }

  void deseleccionarNino() {
    _ninoSeleccionado = null;
    notifyListeners();
  }

  // Obtener niño por ID
  Future<NinoModel?> obtenerNinoPorId(String id) async {
    try {
      return await NinoService.obtenerNinoPorId(id);
    } catch (e) {
      _setError('Error al obtener niño: ${e.toString()}');
      return null;
    }
  }

  // Métodos privados para manejo de estado
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Limpiar errores manualmente
  void clearError() {
    _clearError();
  }

  // Limpiar filtros
  void limpiarFiltros() {
    _ninosFiltrados = List.from(_ninos);
    notifyListeners();
  }
}