import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/nino_model.dart';

class NinoService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'ninos';

  // Crear nuevo registro de niño
  static Future<String> crearNino(NinoModel nino) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(nino.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear registro del niño: $e');
    }
  }

  // Obtener niño por ID
  static Future<NinoModel?> obtenerNinoPorId(String id) async {
    try {
      final doc = await _firestore
          .collection(_collection)
          .doc(id)
          .get();

      if (doc.exists && doc.data() != null) {
        return NinoModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al obtener niño: $e');
    }
  }

  // Obtener todos los niños activos
  static Future<List<NinoModel>> obtenerNinosActivos() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('activo', isEqualTo: true)
          .orderBy('fechaRegistro', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NinoModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al obtener niños: $e');
    }
  }

  // Buscar niños por DNI
  static Future<List<NinoModel>> buscarPorDNI(String dni) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('dniNino', isEqualTo: dni)
          .where('activo', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NinoModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar por DNI: $e');
    }
  }

  // Buscar niños por nombre
  static Future<List<NinoModel>> buscarPorNombre(String nombre) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('nombres', isGreaterThanOrEqualTo: nombre)
          .where('nombres', isLessThanOrEqualTo: nombre + '\uf8ff')
          .where('activo', isEqualTo: true)
          .get();

      return querySnapshot.docs
          .map((doc) => NinoModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Error al buscar por nombre: $e');
    }
  }

  // Actualizar niño
  static Future<void> actualizarNino(NinoModel nino) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(nino.id)
          .update(nino.toMap());
    } catch (e) {
      throw Exception('Error al actualizar niño: $e');
    }
  }

  // Eliminar niño (soft delete)
  static Future<void> eliminarNino(String id) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(id)
          .update({'activo': false});
    } catch (e) {
      throw Exception('Error al eliminar niño: $e');
    }
  }

  // Obtener estadísticas básicas
  static Future<Map<String, dynamic>> obtenerEstadisticas() async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('activo', isEqualTo: true)
          .get();

      final ninos = querySnapshot.docs
          .map((doc) => NinoModel.fromMap(doc.data(), doc.id))
          .toList();

      int totalNinos = ninos.length;
      int masculinos = ninos.where((n) => n.sexo == 'Masculino').length;
      int femeninos = ninos.where((n) => n.sexo == 'Femenino').length;

      return {
        'totalNinos': totalNinos,
        'masculinos': masculinos,
        'femeninos': femeninos,
        'registrosHoy': ninos.where((n) {
          final hoy = DateTime.now();
          return n.fechaRegistro.year == hoy.year &&
                 n.fechaRegistro.month == hoy.month &&
                 n.fechaRegistro.day == hoy.day;
        }).length,
      };
    } catch (e) {
      throw Exception('Error al obtener estadísticas: $e');
    }
  }

  // Verificar si existe DNI
  static Future<bool> existeDNI(String dni) async {
    try {
      final ninos = await buscarPorDNI(dni);
      return ninos.isNotEmpty;
    } catch (e) {
      throw Exception('Error al verificar DNI: $e');
    }
  }
}