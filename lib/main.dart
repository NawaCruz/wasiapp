import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Controladores
import 'controllers/auth_controller.dart';
import 'controllers/nino_controller.dart';

// Vistas
import 'views/splash_view.dart';

// Configuración
import 'core/routes/rutas_app.dart';

// ML Provider
import 'providers/ml_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('🚀 Iniciando aplicación...');
  
  try {
    // Configuración manual para Android
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyDZLhoqC4yiDs5BNzi5rsTk5qck65Q3T7s',
        appId: '1:66148375593:android:8fa0c5daed85bd06811038',
        messagingSenderId: '66148375593',
        projectId: 'wasiapp-66023',
        storageBucket: 'wasiapp-66023.firebasestorage.app',
      ),
    );
    debugPrint('✅ Firebase inicializado correctamente');
  } catch (e) {
    debugPrint('❌ Error al inicializar Firebase: $e');
  }

  debugPrint('📱 Lanzando app...');
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => NinoController()),
        // MLProvider se carga LAZY - solo cuando se usa diagnóstico
        ChangeNotifierProvider(create: (_) => MLProvider(), lazy: true),
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
      title: 'WasiApp',
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
