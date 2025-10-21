import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../../presentation/pages/pagina_principal.dart';
import '../../presentation/pages/pagina_registrar_nino.dart';
// TODO: Importar cuando estén listas
// import '../../presentation/pages/lista_ninos_page.dart';
// import '../../presentation/pages/estadisticas_page.dart';

class RutasApp {
  /// Mapa de rutas estáticas
  static Map<String, WidgetBuilder> get rutas => {
    Rutas.inicio: (context) => const PaginaPrincipal(),
    Rutas.registrarNino: (context) => const PaginaRegistrarNino(),
    // TODO: Agregar cuando estén listas
    // Rutas.listaNinos: (context) => const ListaNinosPage(),
    // Rutas.estadisticas: (context) => const EstadisticasPage(),
  };

  /// Generador dinámico de rutas
  static Route<dynamic>? alGenerarRuta(RouteSettings configuracion) {
    switch (configuracion.name) {
      case Rutas.inicio:
        return _crearRuta(const PaginaPrincipal());
        
      case Rutas.registrarNino:
        return _crearRuta(const PaginaRegistrarNino());
        
      // TODO: Descomentar cuando estén listas las páginas
      // case Rutas.listaNinos:
      //   return _crearRuta(const ListaNinosPage());
        
      // case Rutas.estadisticas:
      //   return _crearRuta(const EstadisticasPage());
        
      default:
        return _crearRuta(_paginaNoEncontrada());
    }
  }

  /// Crea una ruta con animación personalizada
  static PageRouteBuilder _crearRuta(Widget pagina) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => pagina,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
    );
  }

  /// Página de error cuando no se encuentra la ruta
  static Widget _paginaNoEncontrada() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Página no encontrada'),
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red,
            ),
            SizedBox(height: 20),
            Text(
              '¡Oops! Página no encontrada',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              'La página que buscas no existe o fue movida.',
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  /// Navegación programática con nombres de rutas
  static Future<T?> navegarA<T extends Object?>(
    BuildContext context, 
    String rutaNombre, {
    Object? argumentos,
  }) {
    return Navigator.pushNamed<T>(
      context, 
      rutaNombre, 
      arguments: argumentos,
    );
  }

  /// Navegar y reemplazar la ruta actual
  static Future<T?> navegarYReemplazar<T extends Object?, TO extends Object?>(
    BuildContext context, 
    String rutaNombre, {
    Object? argumentos,
    TO? resultado,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context, 
      rutaNombre, 
      arguments: argumentos,
      result: resultado,
    );
  }

  /// Navegar y limpiar todo el stack de navegación
  static Future<T?> navegarYLimpiar<T extends Object?>(
    BuildContext context, 
    String rutaNombre, {
    Object? argumentos,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context, 
      rutaNombre, 
      (route) => false,
      arguments: argumentos,
    );
  }
}