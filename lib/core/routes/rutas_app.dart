import 'package:flutter/material.dart';
import '../constants/app_constants.dart';               // aquí vive `Rutas`
import '../../presentation/pages/pagina_principal.dart';
import '../../presentation/pages/pagina_registrar_nino.dart';
import '../../views/registro_flow.dart';               // <- contiene class RegistroNinoFlow

class RutasApp {
  /// Mapa de rutas estáticas
  static Map<String, WidgetBuilder> get rutas => {
        Rutas.inicio:        (context) => const PaginaPrincipal(),
        Rutas.registrarNino: (context) => const PaginaRegistrarNino(),
        Rutas.registroFlow:  (context) => const RegistroNinoFlow(), // <- usa la clase REAL
      };

  /// Generador dinámico (opcional) con animación
  static Route<dynamic>? alGenerarRuta(RouteSettings configuracion) {
    switch (configuracion.name) {
      case Rutas.inicio:
        return _crearRuta(const PaginaPrincipal());
      case Rutas.registrarNino:
        return _crearRuta(const PaginaRegistrarNino());
      case Rutas.registroFlow:
        return _crearRuta(const RegistroNinoFlow());   // <- idem
      default:
        return _crearRuta(_paginaNoEncontrada());
    }
  }

  /// Ruta con transición deslizante
  static PageRouteBuilder _crearRuta(Widget pagina) {
    return PageRouteBuilder(
      pageBuilder: (_, __, ___) => pagina,
      transitionsBuilder: (_, anim, __, child) {
        const begin = Offset(1, 0);
        const end = Offset.zero;
        final tween = Tween(begin: begin, end: end)
            .chain(CurveTween(curve: Curves.ease));
        return SlideTransition(position: anim.drive(tween), child: child);
      },
    );
  }

  /// Página 404 simple
  static Widget _paginaNoEncontrada() => Scaffold(
        appBar: AppBar(
          title: const Text('Página no encontrada'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 80, color: Colors.red),
              SizedBox(height: 20),
              Text('¡Oops! Página no encontrada',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text('La página que buscas no existe o fue movida.',
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      );

  // Helpers de navegación (útiles)
  static Future<T?> navegarA<T extends Object?>(
    BuildContext context,
    String rutaNombre, {
    Object? argumentos,
  }) =>
      Navigator.pushNamed<T>(context, rutaNombre, arguments: argumentos);

  static Future<T?> navegarYReemplazar<T extends Object?, TO extends Object?>(
    BuildContext context,
    String rutaNombre, {
    Object? argumentos,
    TO? resultado,
  }) =>
      Navigator.pushReplacementNamed<T, TO>(context, rutaNombre,
          arguments: argumentos, result: resultado);

  static Future<T?> navegarYLimpiar<T extends Object?>(
    BuildContext context,
    String rutaNombre, {
    Object? argumentos,
  }) =>
      Navigator.pushNamedAndRemoveUntil<T>(
          context, rutaNombre, (route) => false,
          arguments: argumentos);
}
