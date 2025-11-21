import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/nino_model.dart';

class NinoService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'ninos';

  // Crear nuevo registro de niño
  static Future<String> crearNino(NinoModel nino) async {
    try {
      final docRef = await _firestore.collection(_collection).add(nino.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Error al crear registro del niño: $e');
    }
  }

  // Obtener niño por ID
  static Future<NinoModel?> obtenerNinoPorId(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();

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

  // Obtener niños activos por usuario
  static Future<List<NinoModel>> obtenerNinosPorUsuario(
      String usuarioId) async {
    debugPrint('═══════════════════════════════════');
    debugPrint('🔍 Service: CONSULTANDO FIREBASE');
    debugPrint('🔍 Usuario ID: $usuarioId');
    debugPrint('🔍 Colección: $_collection');
    debugPrint('═══════════════════════════════════');
    
    try {
      debugPrint('📡 Ejecutando query a Firestore...');
      
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('usuarioId', isEqualTo: usuarioId)
          .get();

      debugPrint('📦 Respuesta recibida: ${querySnapshot.docs.length} documentos');

      if (querySnapshot.docs.isEmpty) {
        debugPrint('⚠️ NO HAY DOCUMENTOS para este usuario');
        debugPrint('Verifica que:');
        debugPrint('  1. El usuario tiene niños registrados');
        debugPrint('  2. El campo "usuarioId" coincide');
        debugPrint('  3. Las reglas de Firestore permiten lectura');
        return [];
      }

      final ninos = <NinoModel>[];
      
      for (var doc in querySnapshot.docs) {
        try {
          final data = doc.data();
          debugPrint('📄 Doc ${doc.id}:');
          debugPrint('   - Usuario: ${data['usuarioId']}');
          debugPrint('   - Activo: ${data['activo']}');
          debugPrint('   - Nombre: ${data['nombres']} ${data['apellidos']}');
          
          if (data['activo'] == true) {
            ninos.add(NinoModel.fromMap(data, doc.id));
            debugPrint('   ✅ Agregado');
          } else {
            debugPrint('   ⏭️ Inactivo - omitido');
          }
        } catch (e) {
          debugPrint('   ❌ Error al parsear: $e');
        }
      }

      ninos.sort((a, b) => b.fechaRegistro.compareTo(a.fechaRegistro));

      debugPrint('═══════════════════════════════════');
      debugPrint('✅ RESULTADO FINAL: ${ninos.length} niños válidos');
      debugPrint('═══════════════════════════════════');
      
      return ninos;
    } catch (e, stackTrace) {
      debugPrint('═══════════════════════════════════');
      debugPrint('❌ ERROR EN FIREBASE SERVICE');
      debugPrint('Error: $e');
      debugPrint('Stack: ${stackTrace.toString().split('\n').take(5).join('\n')}');
      debugPrint('═══════════════════════════════════');
      return [];
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
          .where('nombres', isLessThanOrEqualTo: '$nombre\uf8ff')
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

  // Verificar si existe DNI para un usuario específico
  static Future<bool> existeDNIParaUsuario(String dni, String usuarioId) async {
    try {
      // Simplificamos la consulta para evitar problemas de índices
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('usuarioId', isEqualTo: usuarioId)
          .get();

      // Filtrar por DNI y activo en código
      final exists = querySnapshot.docs.any((doc) {
        final data = doc.data();
        return data['dniNino'] == dni && (data['activo'] ?? true);
      });

      return exists;
    } catch (e) {
      throw Exception('Error al verificar DNI: $e');
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

      final totalNinos = ninos.length;
      final masculinos = ninos.where((n) => n.sexo == 'Masculino').length;
      final femeninos = ninos.where((n) => n.sexo == 'Femenino').length;

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

  // Obtener estadísticas por usuario
  static Future<Map<String, dynamic>> obtenerEstadisticasUsuario(
      String usuarioId) async {
    try {
      final ninos = await obtenerNinosPorUsuario(usuarioId);

      final totalNinos = ninos.length;
      final masculinos = ninos.where((n) => n.sexo == 'Masculino').length;
      final femeninos = ninos.where((n) => n.sexo == 'Femenino').length;

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
      throw Exception('Error al obtener estadísticas del usuario: $e');
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

  // DEBUG: Obtener todos los niños sin filtros (para debugging)
  static Future<List<NinoModel>> obtenerTodosLosNinos() async {
    try {
      final querySnapshot = await _firestore.collection(_collection).get();

      debugPrint(
          'DEBUG Service: Total documentos en Firestore: ${querySnapshot.docs.length}');

      final ninos = querySnapshot.docs.map((doc) {
        final data = doc.data();
        debugPrint('DEBUG Service: Documento ${doc.id}: $data');
        return NinoModel.fromMap(data, doc.id);
      }).toList();

      debugPrint('DEBUG Service: Niños parseados: ${ninos.length}');
      return ninos;
    } catch (e) {
      debugPrint('DEBUG Service: Error obteniendo todos los niños: $e');
      throw Exception('Error al obtener todos los niños: $e');
    }
  }
}
