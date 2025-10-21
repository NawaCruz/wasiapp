import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/rutas_app.dart';
import 'presentation/pages/pagina_principal.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // TODO: Inicializar inyección de dependencias cuando esté lista
  // await inicializarDependencias();
  
  runApp(const AplicacionWasi());
}

class AplicacionWasi extends StatelessWidget {
  const AplicacionWasi({super.key});
  
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: ConstantesApp.nombreApp,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        primaryColor: Colors.blue,
        fontFamily: 'Roboto',
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 2,
          titleTextStyle: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
      home: const PaginaPrincipal(),
      onGenerateRoute: RutasApp.alGenerarRuta,
      // TODO: Agregar rutas cuando estén todas las páginas listas
      // routes: RutasApp.rutas,
    );
  }
}
