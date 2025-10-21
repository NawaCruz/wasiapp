import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

// Controladores
import 'controllers/auth_controller.dart';
import 'controllers/nino_controller.dart'; // <-- agregado

// Vistas
import 'views/login_view.dart';
import 'views/home_view.dart';

// Configuración
import 'firebase_options.dart';
import 'core/constants/app_constants.dart';
import 'core/routes/rutas_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Registramos los controllers globalmente en la raíz del app
  // Usar MultiProvider para que HomeView (y otras rutas) puedan acceder a NinoController
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthController()),
        ChangeNotifierProvider(create: (_) => NinoController()), // <-- agregado
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
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

      // 🔹 Pantalla inicial: Login o Home según sesión
      home: Consumer<AuthController>(
        builder: (context, auth, _) {
          // Si hay sesión, ir al Home
          if (auth.isLoggedIn) {
            return const HomeView();
          }
          // Si no hay sesión, mostrar Login
          return const LoginView();
        },
      ),

      // Si tienes rutas definidas, puedes mantenerlas
      onGenerateRoute: RutasApp.alGenerarRuta,
    );
  }
}
