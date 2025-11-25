import 'package:flutter/material.dart';
import '../../views/home_view.dart';
import '../../views/registro_flow.dart'; // <- contiene class RegistroNinoFlow

// Constantes de rutas
class Rutas {
  static const String inicio = '/';
  static const String registrarNino = '/registrar-nino';
  static const String registroFlow = '/registro_flow';
}

class RutasApp {
  /// Mapa de rutas estáticas
  static Map<String, WidgetBuilder> get rutas => {
        Rutas.inicio: (context) => const HomeView(),
        Rutas.registrarNino: (context) => const RegistroNinoFlow(),
        Rutas.registroFlow: (context) =>
            const RegistroNinoFlow(), // <- usa la clase REAL
      };

  /// Generador dinámico (opcional) con animación
  static Route<dynamic>? alGenerarRuta(RouteSettings configuracion) {
    switch (configuracion.name) {
      case Rutas.inicio:
        return _crearRuta(const HomeView());
      case Rutas.registrarNino:
        return _crearRuta(const RegistroNinoFlow());
      case Rutas.registroFlow:
        return _crearRuta(const RegistroNinoFlow()); // <- idem
      default:
        return _crearRuta(_paginaNoEncontrada());
    }
  }

  /// Ruta con transición deslizante
  static PageRouteBuilder<void> _crearRuta(Widget pagina) {
    return PageRouteBuilder<void>(
      pageBuilder: (context, animation, secondaryAnimation) => pagina,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1, 0);
        const end = Offset.zero;
        final tween =
            Tween(begin: begin, end: end).chain(CurveTween(curve: Curves.ease));
        return SlideTransition(position: animation.drive(tween), child: child);
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
