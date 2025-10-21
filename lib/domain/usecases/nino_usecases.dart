import '../entities/nino.dart';
import '../repositories/nino_repository.dart';

class RegistrarNinoUseCase {
  final NinoRepository repository;

  RegistrarNinoUseCase(this.repository);

  Future<bool> execute(Nino nino) async {
    try {
      return await repository.registrarNino(nino);
    } catch (e) {
      throw Exception('Error al registrar niño: $e');
    }
  }
}

class ObtenerNinosUseCase {
  final NinoRepository repository;

  ObtenerNinosUseCase(this.repository);

  Future<List<Nino>> execute() async {
    try {
      return await repository.obtenerTodosLosNinos();
    } catch (e) {
      throw Exception('Error al obtener niños: $e');
    }
  }
}

class BuscarNinosPorDNIUseCase {
  final NinoRepository repository;

  BuscarNinosPorDNIUseCase(this.repository);

  Future<List<Nino>> execute(String dni) async {
    try {
      if (dni.isEmpty) return [];
      return await repository.buscarPorDNI(dni);
    } catch (e) {
      throw Exception('Error al buscar por DNI: $e');
    }
  }
}

class ObtenerEstadisticasUseCase {
  final NinoRepository repository;

  ObtenerEstadisticasUseCase(this.repository);

  Future<Map<String, int>> execute() async {
    try {
      return await repository.obtenerEstadisticas();
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }
}