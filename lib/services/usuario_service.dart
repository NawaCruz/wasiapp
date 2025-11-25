// 👤 Servicio de Usuarios - WasiApp
// Maneja todo lo relacionado con cuentas de usuarios

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/usuario_model.dart';

class UsuarioService {
  // Conexión con la base de datos Firebase
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collection = 'usuario'; // Nombre de la tabla en Firebase

  // Buscar un usuario por su nombre de usuario
  static Future<UsuarioModel?> buscarPorUsuario(String usuario) async {
    try {
      final querySnapshot = await _firestore
          .collection(_collection)
          .where('usuario', isEqualTo: usuario)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final doc = querySnapshot.docs.first;
        return UsuarioModel.fromMap(doc.data(), doc.id);
      }
      return null;
    } catch (e) {
      throw Exception('Error al buscar usuario: $e');
    }
  }

  // Guardar un usuario nuevo en la base de datos
  static Future<String> crearUsuario(UsuarioModel usuario) async {
    try {
      final docRef =
          await _firestore.collection(_collection).add(usuario.toMap());
      return docRef.id; // Devuelve el ID que Firebase le asignó
    } catch (e) {
      throw Exception('Error al crear usuario: $e');
    }
  }

  // Actualizar información de un usuario existente
  static Future<void> actualizarUsuario(UsuarioModel usuario) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(usuario.id)
          .update(usuario.toMap());
    } catch (e) {
      throw Exception('Error al actualizar usuario: $e');
    }
  }

  // Verificar si el usuario y contraseña son correctos al iniciar sesión
  static Future<bool> verificarCredenciales(
      String usuario, String contrasena) async {
    try {
      final usuarioModel = await buscarPorUsuario(usuario);
      if (usuarioModel != null && usuarioModel.contrasena == contrasena) {
        // Actualizar la fecha de último acceso
        final usuarioActualizado = usuarioModel.copyWith(
          ultimoAcceso: DateTime.now(),
        );
        await actualizarUsuario(usuarioActualizado);
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Error al verificar credenciales: $e');
    }
  }

  // Revisar si ya existe un usuario con ese nombre
  static Future<bool> existeUsuario(String usuario) async {
    try {
      final usuarioModel = await buscarPorUsuario(usuario);
      return usuarioModel != null;
    } catch (e) {
      throw Exception('Error al verificar existencia del usuario: $e');
    }
  }
}
