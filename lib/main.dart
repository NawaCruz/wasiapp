import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Controladores
import 'controllers/auth_controller.dart';
import 'controllers/nino_controller.dart';

// Vistas
import 'views/splash_view.dart';

// Configuración
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/rutas_app.dart';

// ML Provider
import 'providers/ml_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('🚀 Iniciando aplicación...');
  
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    debugPrint('✅ Firebase inicializado');
  } catch (e) {
    debugPrint('❌ Error Firebase: $e');
  }

  debugPrint('📱 Lanzando app...');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => NinoController()),
        ChangeNotifierProvider(create: (_) => MLProvider()),
      ],
      child: const AplicacionWasi(),
    ),
  );
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
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),

      // 🔹 Pantalla inicial: Splash screen que maneja la navegación automáticamente
      home: const SplashView(),

      // Si tienes rutas definidas, puedes mantenerlas
      onGenerateRoute: RutasApp.alGenerarRuta,
    );
  }
}
