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

  // Cargar niños por usuario
  Future<void> cargarNinosPorUsuario(String usuarioId) async {
    debugPrint('🔄 Controller: Iniciando carga para usuario: $usuarioId');
    
    // NO MOSTRAR LOADING - cargar en background
    _clearError();
    _ninos = [];
    _ninosFiltrados = [];
    notifyListeners(); // Limpiar UI primero

    try {
      debugPrint('⏳ Controller: Llamando a NinoService...');
      // Usar NinoService que ya tiene cache-first strategy
      _ninos = await NinoService.obtenerNinosPorUsuario(usuarioId)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              debugPrint('⏱️ Controller: Timeout alcanzado');
              return [];
            },
          );
      
      _ninosFiltrados = List.from(_ninos);
      
      debugPrint('✅ Controller: ${_ninos.length} niños cargados');
      debugPrint('📋 Controller: Lista actualizada en memoria');
      notifyListeners();
      
    } catch (e) {
      debugPrint('❌ Controller: Error capturado: $e');
      debugPrint('❌ Controller: Tipo de error: ${e.runtimeType}');
      _ninos = [];
      _ninosFiltrados = [];
      _setError('Error al cargar datos: ${e.toString().substring(0, 50)}...');
      notifyListeners();
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
    required String usuarioId,
    String? anemia,
    String? alimentosHierro,
    String? fatiga,
    String? alimentacionBalanceada,
    String? palidez,
    String? disminucionRendimiento,
    String? evaluacionAnemia,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Verificar si ya existe el DNI para este usuario
      debugPrint('DEBUG: Verificando DNI $dniNino para usuario $usuarioId');
      final existe = await NinoService.existeDNIParaUsuario(dniNino, usuarioId);
      if (existe) {
        _setError('Ya tienes un niño registrado con este DNI');
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
        usuarioId: usuarioId,
        anemia: anemia,
        alimentosHierro: alimentosHierro,
        fatiga: fatiga,
        alimentacionBalanceada: alimentacionBalanceada,
        palidez: palidez,
        disminucionRendimiento: disminucionRendimiento,
        evaluacionAnemia: evaluacionAnemia,
      );

      debugPrint(
          'DEBUG: Creando niño $nombres $apellidos para usuario $usuarioId');
      await NinoService.crearNino(nuevoNino);
      debugPrint('DEBUG: Niño creado exitosamente, recargando lista...');
      await cargarNinosPorUsuario(
          usuarioId); // Recargar solo los niños del usuario
      return true;
    } catch (e) {
      _setError('Error al crear registro: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar niño
  Future<bool> actualizarNino(NinoModel nino, {String? usuarioId}) async {
    try {
      _setLoading(true);
      _clearError();

      // Recalcular IMC si cambió peso o talla
      final imc = IMCCalculator.calcularIMC(nino.peso, nino.talla);
      final edad =
          DateTime.now().difference(nino.fechaNacimiento).inDays ~/ 365;
      final clasificacion =
          IMCCalculator.clasificarIMCNinos(imc, edad, nino.sexo);

      final ninoActualizado = nino.copyWith(
        imc: imc,
        clasificacionIMC: clasificacion,
      );

      await NinoService.actualizarNino(ninoActualizado);

      // Recargar datos del usuario
      if (usuarioId != null && usuarioId.isNotEmpty) {
        await cargarNinosPorUsuario(usuarioId);
      }

      return true;
    } catch (e) {
      _setError('Error al actualizar registro: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Eliminar niño
  Future<bool> eliminarNino(String id, {String? usuarioId}) async {
    try {
      _setLoading(true);
      _clearError();

      await NinoService.eliminarNino(id);

      // Recargar datos del usuario
      if (usuarioId != null && usuarioId.isNotEmpty) {
        await cargarNinosPorUsuario(usuarioId);
      }

      return true;
    } catch (e) {
      _setError('Error al eliminar registro: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cargar estadísticas por usuario
  Future<void> cargarEstadisticasUsuario(String usuarioId) async {
    try {
      debugPrint('📊 Controller: Calculando estadísticas desde memoria...');
      
      // Calcular estadísticas desde los datos ya cargados (SIN consulta a Firebase)
      final totalNinos = _ninos.length;
      final masculinos = _ninos.where((n) => n.sexo == 'Masculino').length;
      final femeninos = _ninos.where((n) => n.sexo == 'Femenino').length;
      
      final hoy = DateTime.now();
      final registrosHoy = _ninos.where((n) {
        return n.fechaRegistro.year == hoy.year &&
            n.fechaRegistro.month == hoy.month &&
            n.fechaRegistro.day == hoy.day;
      }).length;
      
      _estadisticas = {
        'totalNinos': totalNinos,
        'masculinos': masculinos,
        'femeninos': femeninos,
        'registrosHoy': registrosHoy,
      };
      
      debugPrint('✅ Controller: Estadísticas calculadas - Total: $totalNinos, M: $masculinos, F: $femeninos');
      notifyListeners();
    } catch (e) {
      debugPrint('❌ Controller: Error estadísticas: $e');
      _estadisticas = {};
      notifyListeners();
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

  // DEBUG: Método para verificar todos los datos en Firestore
  Future<void> debugTodosLosDatos() async {
    try {
      debugPrint('DEBUG Controller: Iniciando debug de todos los datos...');
      final todosLosNinos = await NinoService.obtenerTodosLosNinos();
      debugPrint(
          'DEBUG Controller: Total niños en Firestore: ${todosLosNinos.length}');

      for (var nino in todosLosNinos) {
        debugPrint('DEBUG Controller: - ${nino.nombres} ${nino.apellidos}');
        debugPrint('  ID: ${nino.id}');
        debugPrint('  Usuario ID: ${nino.usuarioId}');
        debugPrint('  Activo: ${nino.activo}');
        debugPrint('  ---');
      }
    } catch (e) {
      debugPrint('DEBUG Controller: Error en debug: $e');
    }
  }
}
