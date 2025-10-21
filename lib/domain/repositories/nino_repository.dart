import '../entities/nino.dart';

abstract class NinoRepository {
  Future<bool> registrarNino(Nino nino);
  Future<List<Nino>> obtenerTodosLosNinos();
  Future<Nino?> obtenerNinoPorId(String id);
  Future<bool> actualizarNino(String id, Nino nino);
  Future<bool> eliminarNino(String id);
  Future<List<Nino>> buscarPorDNI(String dni);
  Future<List<Nino>> buscarPorNombre(String nombre);
  Future<Map<String, int>> obtenerEstadisticas();
}