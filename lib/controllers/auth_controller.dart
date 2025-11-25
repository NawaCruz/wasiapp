// 🔐 Controlador de Autenticación - WasiApp
// Maneja el inicio de sesión, registro y perfil del usuario

import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';

class AuthController extends ChangeNotifier {
  UsuarioModel? _usuarioActual; // El usuario que está usando la app ahora
  bool _isLoading = false; // Si estamos procesando algo (mostrar loading)
  String? _errorMessage; // Mensaje de error para mostrar al usuario

  // Información que otras partes de la app pueden consultar
  UsuarioModel? get usuarioActual => _usuarioActual;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isLoggedIn => _usuarioActual != null; // ¿Hay alguien usando la app?

  // Iniciar sesión con usuario y contraseña
  Future<bool> login(String usuario, String contrasena) async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('🔑 AUTH: Verificando credenciales para: $usuario');
      
      final isValid =
          await UsuarioService.verificarCredenciales(usuario, contrasena);
          
      debugPrint('🔑 AUTH: Credenciales válidas: $isValid');
      
      if (isValid) {
        _usuarioActual = await UsuarioService.buscarPorUsuario(usuario);
        debugPrint('🔑 AUTH: Usuario cargado: ${_usuarioActual?.usuario} (ID: ${_usuarioActual?.id})');
        notifyListeners();
        return true;
      } else {
        _setError('Usuario o contraseña incorrectos');
        return false;
      }
    } catch (e) {
      debugPrint('❌ AUTH: Error en login: $e');
      _setError('Error de conexión. Intente nuevamente.');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cerrar sesión (salir de la app)
  void logout() {
    _usuarioActual = null;
    _clearError();
    notifyListeners();
  }

  // Registrar un usuario nuevo
  Future<bool> crearUsuario({
    required String usuario,
    required String contrasena,
    String? nombre,
    String? apellido,
    String? email,
  }) async {
    try {
      _setLoading(true);
      _clearError();

      // Verificar si el usuario ya existe
      final existe = await UsuarioService.existeUsuario(usuario);
      if (existe) {
        _setError('El usuario ya existe');
        return false;
      }

      final nuevoUsuario = UsuarioModel(
        id: '', // Se asignará automáticamente
        usuario: usuario,
        contrasena: contrasena,
        nombre: nombre,
        apellido: apellido,
        email: email,
        fechaCreacion: DateTime.now(),
        ultimoAcceso: DateTime.now(),
        activo: true,
      );

      final userId = await UsuarioService.crearUsuario(nuevoUsuario);
      // Actualizar el usuario con el ID asignado y establecerlo como usuario actual
      _usuarioActual = nuevoUsuario.copyWith(id: userId);
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al crear usuario: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Actualizar perfil del usuario actual
  Future<bool> actualizarPerfil({
    String? nombre,
    String? apellido,
    String? email,
  }) async {
    if (_usuarioActual == null) return false;

    try {
      _setLoading(true);
      _clearError();

      final usuarioActualizado = _usuarioActual!.copyWith(
        nombre: nombre,
        apellido: apellido,
        email: email,
      );

      await UsuarioService.actualizarUsuario(usuarioActualizado);
      _usuarioActual = usuarioActualizado;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al actualizar perfil: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  // Cambiar contraseña
  Future<bool> cambiarContrasena(
      String contrasenaActual, String nuevaContrasena) async {
    if (_usuarioActual == null) return false;

    try {
      _setLoading(true);
      _clearError();

      // Verificar contraseña actual
      if (_usuarioActual!.contrasena != contrasenaActual) {
        _setError('La contraseña actual es incorrecta');
        return false;
      }

      final usuarioActualizado = _usuarioActual!.copyWith(
        contrasena: nuevaContrasena,
      );

      await UsuarioService.actualizarUsuario(usuarioActualizado);
      _usuarioActual = usuarioActualizado;
      notifyListeners();
      return true;
    } catch (e) {
      _setError('Error al cambiar contraseña: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
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
}
