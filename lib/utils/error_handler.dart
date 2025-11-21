import 'package:flutter/material.dart';

class ErrorHandler {
  // Códigos de error específicos
  static const String networkError = 'NET_001';
  static const String authenticationError = 'AUTH_002';
  static const String validationError = 'VAL_003';
  static const String databaseError = 'DB_004';
  static const String permissionError = 'PERM_005';
  static const String duplicateError = 'DUP_006';
  static const String notFoundError = 'NF_007';
  static const String serverError = 'SRV_008';

  // Mensajes de error detallados con sugerencias
  static Map<String, ErrorInfo> get errorCatalog => {
        networkError: ErrorInfo(
          title: 'Sin conexión a internet',
          message: 'No se pudo conectar al servidor',
          suggestion: 'Verifica tu conexión a internet y vuelve a intentar',
          icon: Icons.wifi_off,
          color: Colors.orange,
          actions: ['Reintentar', 'Verificar conexión'],
        ),
        authenticationError: ErrorInfo(
          title: 'Error de autenticación',
          message: 'Usuario o contraseña incorrectos',
          suggestion: 'Verifica tus credenciales o restablece tu contraseña',
          icon: Icons.lock_outline,
          color: Colors.red,
          actions: ['Reintentar', 'Olvidé mi contraseña'],
        ),
        validationError: ErrorInfo(
          title: 'Datos incorrectos',
          message: 'Algunos campos contienen información inválida',
          suggestion:
              'Revisa los campos marcados en rojo y corrige la información',
          icon: Icons.error_outline,
          color: Colors.amber,
          actions: ['Revisar campos'],
        ),
        databaseError: ErrorInfo(
          title: 'Error en la base de datos',
          message: 'No se pudo guardar la información',
          suggestion:
              'El servidor está experimentando problemas. Intenta más tarde',
          icon: Icons.storage,
          color: Colors.red,
          actions: ['Reintentar', 'Contactar soporte'],
        ),
        duplicateError: ErrorInfo(
          title: 'Información duplicada',
          message: 'Ya existe un registro con estos datos',
          suggestion: 'Verifica si el niño ya fue registrado anteriormente',
          icon: Icons.content_copy,
          color: Colors.orange,
          actions: ['Buscar registro', 'Modificar datos'],
        ),
        notFoundError: ErrorInfo(
          title: 'Registro no encontrado',
          message: 'No se encontró la información solicitada',
          suggestion: 'El registro puede haber sido eliminado o no existe',
          icon: Icons.search_off,
          color: Colors.grey,
          actions: ['Actualizar lista', 'Crear nuevo'],
        ),
      };

  // Crear mensaje de error mejorado
  static Widget buildErrorMessage({
    required String errorCode,
    required String customMessage,
    required BuildContext context,
    List<VoidCallback>? actionCallbacks,
  }) {
    final errorInfo = errorCatalog[errorCode] ?? _getDefaultError();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: errorInfo.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: errorInfo.color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del error
          Row(
            children: [
              Icon(
                errorInfo.icon,
                color: errorInfo.color,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      errorInfo.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: errorInfo.color,
                      ),
                    ),
                    Text(
                      'Código: $errorCode',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Mensaje detallado
          Text(
            customMessage.isNotEmpty ? customMessage : errorInfo.message,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade800,
            ),
          ),

          const SizedBox(height: 8),

          // Sugerencia
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  size: 16,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    errorInfo.suggestion,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Botones de acción
          if (errorInfo.actions.isNotEmpty) ...[
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              children: errorInfo.actions.asMap().entries.map((entry) {
                final index = entry.key;
                final action = entry.value;

                return ElevatedButton.icon(
                  onPressed:
                      actionCallbacks != null && index < actionCallbacks.length
                          ? actionCallbacks[index]
                          : null,
                  icon: _getActionIcon(action),
                  label: Text(action),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        index == 0 ? errorInfo.color : Colors.grey.shade600,
                    foregroundColor: Colors.white,
                    textStyle: const TextStyle(fontSize: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  // Mostrar error como SnackBar mejorado
  static void showErrorSnackBar({
    required BuildContext context,
    required String errorCode,
    required String message,
    VoidCallback? onRetry,
  }) {
    final errorInfo = errorCatalog[errorCode] ?? _getDefaultError();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(errorInfo.icon, color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    errorInfo.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: errorInfo.color,
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Reintentar',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  // Mostrar diálogo de error completo
  static void showErrorDialog({
    required BuildContext context,
    required String errorCode,
    required String message,
    List<ErrorAction>? actions,
  }) {
    final errorInfo = errorCatalog[errorCode] ?? _getDefaultError();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            Icon(errorInfo.icon, color: errorInfo.color),
            const SizedBox(width: 8),
            Text(errorInfo.title),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.lightbulb_outline,
                            size: 16, color: Colors.blue.shade600),
                        const SizedBox(width: 8),
                        Text(
                          'Sugerencia:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      errorInfo.suggestion,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Código de error: $errorCode',
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey.shade600,
                  fontFamily: 'monospace',
                ),
              ),
            ],
          ),
        ),
        actions: [
          if (actions != null)
            ...actions.map((action) => TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    action.onPressed?.call();
                  },
                  icon: Icon(action.icon),
                  label: Text(action.label),
                )),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  static ErrorInfo _getDefaultError() {
    return ErrorInfo(
      title: 'Error desconocido',
      message: 'Ha ocurrido un error inesperado',
      suggestion: 'Contacta al soporte técnico si el problema persiste',
      icon: Icons.error_outline,
      color: Colors.grey,
      actions: ['Cerrar'],
    );
  }

  static Icon _getActionIcon(String action) {
    switch (action.toLowerCase()) {
      case 'reintentar':
        return const Icon(Icons.refresh, size: 16);
      case 'verificar conexión':
        return const Icon(Icons.wifi, size: 16);
      case 'olvidé mi contraseña':
        return const Icon(Icons.help_outline, size: 16);
      case 'contactar soporte':
        return const Icon(Icons.support_agent, size: 16);
      case 'buscar registro':
        return const Icon(Icons.search, size: 16);
      case 'crear nuevo':
        return const Icon(Icons.add, size: 16);
      case 'actualizar lista':
        return const Icon(Icons.refresh, size: 16);
      default:
        return const Icon(Icons.info_outline, size: 16);
    }
  }
}

// Clase para información de errores
class ErrorInfo {
  final String title;
  final String message;
  final String suggestion;
  final IconData icon;
  final Color color;
  final List<String> actions;

  ErrorInfo({
    required this.title,
    required this.message,
    required this.suggestion,
    required this.icon,
    required this.color,
    this.actions = const [],
  });
}

// Clase para acciones de error
class ErrorAction {
  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  ErrorAction({
    required this.label,
    required this.icon,
    this.onPressed,
  });
}

// Mixin para usar en controllers
mixin ErrorHandlerMixin {
  String? _errorMessage;
  String? _errorCode;

  String? get errorMessage => _errorMessage;
  String? get errorCode => _errorCode;

  void setError(String code, String message) {
    _errorCode = code;
    _errorMessage = message;
  }

  void clearError() {
    _errorCode = null;
    _errorMessage = null;
  }

  // Mapeo de excepciones a códigos de error
  void handleException(Exception e) {
    if (e.toString().contains('network') ||
        e.toString().contains('internet') ||
        e.toString().contains('connection')) {
      setError(ErrorHandler.networkError, 'Sin conexión a internet');
    } else if (e.toString().contains('permission') ||
        e.toString().contains('unauthorized')) {
      setError(ErrorHandler.permissionError,
          'Sin permisos para realizar esta acción');
    } else if (e.toString().contains('not-found') ||
        e.toString().contains('does not exist')) {
      setError(ErrorHandler.notFoundError, 'Registro no encontrado');
    } else if (e.toString().contains('duplicate') ||
        e.toString().contains('already exists')) {
      setError(
          ErrorHandler.duplicateError, 'Ya existe un registro con estos datos');
    } else {
      setError(ErrorHandler.serverError, 'Error del servidor: ${e.toString()}');
    }
  }
}
