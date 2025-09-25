import 'package:flutter/material.dart';
import 'registro_flow.dart'; // Nuevo flujo de registro completo

class MainHomeScreen extends StatefulWidget {
  const MainHomeScreen({super.key});

  @override
  State<MainHomeScreen> createState() => _MainHomeScreenState();
}

class _MainHomeScreenState extends State<MainHomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const InicioScreen(),
    const RegistrarScreen(), // Pantalla que abrirá el flujo de registro
    const EscanearScreen(),
    const HistorialScreen(),
    const PerfilScreen(),
  ];

  void _onTabTapped(int index) {
    if (index == 1) {
      // Si presiona "Registrar", abrir como nueva pantalla
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const RegistroNinoFlow(),
        ),
      );
    } else {
      setState(() => _currentIndex = index);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: _onTabTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.person_add), label: 'Registrar'),
          BottomNavigationBarItem(icon: Icon(Icons.qr_code_scanner), label: 'Escanear'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Historial'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

// Pantallas placeholder
class InicioScreen extends StatelessWidget {
  const InicioScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Inicio')), body: const Center(child: Text('Inicio')));
}

class RegistrarScreen extends StatelessWidget {
  const RegistrarScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Registrar')), body: const Center(child: Text('Presiona el botón Registrar para comenzar')));
}

class EscanearScreen extends StatelessWidget {
  const EscanearScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Escanear')), body: const Center(child: Text('Escanear')));
}

class HistorialScreen extends StatelessWidget {
  const HistorialScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Historial')), body: const Center(child: Text('Historial')));
}

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});
  @override Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Perfil')), body: const Center(child: Text('Perfil')));
}