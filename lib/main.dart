// 🌟 WasiApp - Aplicación de Control Nutricional Infantil
// Punto de entrada principal de la aplicación

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Controladores (manejan la lógica de negocio)
import 'controllers/auth_controller.dart';
import 'controllers/nino_controller.dart';

// Vistas (las pantallas que ve el usuario)
import 'views/splash_view.dart';

// Configuración de rutas
import 'core/routes/rutas_app.dart';

// Proveedor de Inteligencia Artificial
import 'providers/ml_provider.dart';

// Función principal - aquí comienza todo
Future<void> main() async {
  // Preparar Flutter antes de iniciar
  WidgetsFlutterBinding.ensureInitialized();
  
  debugPrint('🚀 Iniciando aplicación...');
  
  try {
    // Conectar con Firebase (base de datos en la nube)
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
    // MultiProvider: Permite que todas las pantallas accedan a los controladores
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()), // Control de usuarios
        ChangeNotifierProvider(create: (_) => NinoController()), // Control de niños
        ChangeNotifierProvider(create: (_) => MLProvider(), lazy: true), // IA (se carga solo cuando se necesita)
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
