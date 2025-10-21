import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/auth_controller.dart';
import '../controllers/nino_controller.dart';
import 'login_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  int _selectedIndex = 0;
  File? _selectedImage;
  String? _anemiaResult;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<NinoController>(context, listen: false).cargarNinos();
      Provider.of<NinoController>(context, listen: false).cargarEstadisticas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'WASI App - Inicio',
      'Plan Nutricional',
      'Evaluación',
      'Anemia (Foto)',
      'Perfil',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: _selectedIndex == 0
            ? [
                PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'logout') {
                      _handleLogout();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'logout',
                      child: Row(
                        children: [
                          Icon(Icons.logout),
                          SizedBox(width: 8),
                          Text('Cerrar Sesión'),
                        ],
                      ),
                    ),
                  ],
                ),
              ]
            : null,
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _selectedIndex,
          children: [
            // 0: Inicio (mantengo la UI existente)
            Consumer2<AuthController, NinoController>(
              builder: (context, authController, ninoController, child) {
                if (ninoController.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: _buildHomeContent(authController, ninoController),
                );
              },
            ),

            // 1: Plan Nutricional (placeholder)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.food_bank, size: 72, color: Colors.green),
                    const SizedBox(height: 16),
                    const Text(
                      'Plan Nutricional',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aquí irá la información y recomendaciones del plan nutricional.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // TODO: Navegar a pantalla de plan nutricional detallado
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Ir al plan nutricional (en desarrollo)')),
                        );
                      },
                      child: const Text('Ver Plan'),
                    ),
                  ],
                ),
              ),
            ),

            // 2: Evaluación (navegar al flujo de registro/evaluación)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.assignment_turned_in, size: 72, color: Colors.orange),
                    const SizedBox(height: 16),
                    const Text(
                      'Evaluación',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Accede al flujo de evaluación/registro.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        // Navegar al flujo de evaluación / registro
                        // Asegúrate de tener definida la ruta '/registro_flow' o reemplaza por la pantalla correspondiente
                        Navigator.of(context).pushNamed('/registro_flow');
                      },
                      child: const Text('Ir a Evaluación'),
                    ),
                  ],
                ),
              ),
            ),

            // 3: Anemia (tomar foto + análisis mock)
            SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  const Icon(
                    Icons.camera_alt,
                    size: 72,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Analizar propensión a anemia mediante foto',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Toma una foto del labio o piel (ejemplo) y obtén un resultado indicativo.\n'
                    'Esto es un prototipo; no es diagnóstico médico.',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),

                  // Si ya hay imagen seleccionada
                  if (_selectedImage != null)
                    Column(
                      children: [
                        Image.file(
                          _selectedImage!,
                          height: 200,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _anemiaResult ?? '',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _anemiaResult?.toLowerCase().contains('propenso') == true
                                ? Colors.red
                                : Colors.green,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _selectedImage = null;
                              _anemiaResult = null;
                            });
                          },
                          child: const Text('Tomar otra foto'),
                        ),
                      ],
                    )
                  // Si aún no hay imagen seleccionada
                  else
                    ElevatedButton.icon(
                      onPressed: _pickImageAndAnalyze,
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Tomar Foto'),
                    ),
                ],
              ),
            ),


            // 4: Perfil / Usuario
            Consumer<AuthController>(
              builder: (context, authController, child) {
                final usuario = authController.usuarioActual;
                final nombre = usuario?.nombre ?? usuario?.usuario ?? 'Usuario';
                final email = usuario?.email ?? '';
                return Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.blue.shade100,
                        child: Icon(Icons.person, size: 40, color: Colors.blue.shade700),
                      ),
                      const SizedBox(height: 12),
                      Text(nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      if (email.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(email, style: TextStyle(color: Colors.grey.shade600)),
                      ],
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: _handleLogout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Cerrar Sesión'),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          // Si el usuario pulsa Evaluación (índice 2) navegamos al flujo de registro/evaluación.
          if (index == 2) {
            Navigator.of(context).pushNamed('/registro_flow');
            return;
          }
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.assignment), label: 'Evaluación'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Anemia'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _navigateToRegisterChild,
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Registrar Niño'),
            )
          : null,
    );
  }

  // Nuevo: extraigo el contenido original del Home a un método para mantener orden
  Widget _buildHomeContent(AuthController authController, NinoController ninoController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Bienvenida
        _buildWelcomeCard(authController),
        const SizedBox(height: 16),

        // Estadísticas
        _buildStatisticsCard(ninoController),
        const SizedBox(height: 16),

        // Lista de niños registrados
        _buildRecentChildren(ninoController),
      ],
    );
  }

  Widget _buildWelcomeCard(AuthController authController) {
    final usuario = authController.usuarioActual;
    final nombreMostrar = usuario?.nombre ?? usuario?.usuario ?? 'Usuario';

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blue.shade100,
              child: Icon(
                Icons.person,
                size: 30,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '¡Hola, $nombreMostrar!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bienvenido al sistema de registro nutricional',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsCard(NinoController ninoController) {
    final stats = ninoController.estadisticas;
    
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Estadísticas',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatItem(
                    'Total Niños',
                    '${stats['totalNinos'] ?? 0}',
                    Icons.child_care,
                    Colors.blue,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Masculinos',
                    '${stats['masculinos'] ?? 0}',
                    Icons.boy,
                    Colors.green,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Femeninos',
                    '${stats['femeninos'] ?? 0}',
                    Icons.girl,
                    Colors.pink,
                  ),
                ),
                Expanded(
                  child: _buildStatItem(
                    'Hoy',
                    '${stats['registrosHoy'] ?? 0}',
                    Icons.today,
                    Colors.orange,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRecentChildren(NinoController ninoController) {
    final ninos = ninoController.ninos.take(5).toList(); // Solo mostrar los 5 más recientes

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Registros Recientes',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: _navigateToChildrenList,
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (ninos.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text(
                    'No hay registros aún.\n¡Registra el primer niño!',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              ...ninos.map((nino) => _buildChildListItem(nino)),
          ],
        ),
      ),
    );
  }

  Widget _buildChildListItem(dynamic nino) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: nino.sexo == 'Masculino' 
            ? Colors.blue.shade100 
            : Colors.pink.shade100,
        child: Icon(
          nino.sexo == 'Masculino' ? Icons.boy : Icons.girl,
          color: nino.sexo == 'Masculino' 
              ? Colors.blue.shade700 
              : Colors.pink.shade700,
        ),
      ),
      title: Text(nino.nombreCompleto),
      subtitle: Text('DNI: ${nino.dniNino} • ${nino.edad} años'),
      trailing: nino.clasificacionIMC != null
          ? Chip(
              label: Text(
                nino.clasificacionIMC!,
                style: const TextStyle(fontSize: 10),
              ),
              backgroundColor: _getIMCColor(nino.clasificacionIMC!),
            )
          : null,
      onTap: () => _viewChildDetails(nino),
    );
  }

  Color _getIMCColor(String clasificacion) {
    switch (clasificacion.toLowerCase()) {
      case 'bajo peso':
        return Colors.blue.shade100;
      case 'peso normal':
        return Colors.green.shade100;
      case 'sobrepeso':
        return Colors.orange.shade100;
      case 'obesidad':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  void _handleLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Provider.of<AuthController>(context, listen: false).logout();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginView()),
              );
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _navigateToRegisterChild() {
    // TODO: Implementar navegación al formulario de registro
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad en desarrollo'),
      ),
    );
  }

  void _navigateToChildrenList() {
    // TODO: Implementar navegación a la lista completa
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Funcionalidad en desarrollo'),
      ),
    );
  }

  void _viewChildDetails(dynamic nino) {
    // TODO: Implementar vista de detalles del niño
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ver detalles de ${nino.nombreCompleto}'),
      ),
    );
  }

  // Nueva funcionalidad: seleccionar imagen y análisis mock
  Future<void> _pickImageAndAnalyze() async {
    try {
      final XFile? picked = await _picker.pickImage(source: ImageSource.camera, maxWidth: 1024, maxHeight: 1024, imageQuality: 80);
      if (picked == null) return;

      setState(() {
        _selectedImage = File(picked.path);
        _anemiaResult = 'Analizando...';
      });

      // Heurística mock: para demo rápida no decodificamos la imagen; usar paquetes como 'image' para análisis real.
      // Aquí devolvemos un resultado aleatorio/heurístico:
      await Future.delayed(const Duration(seconds: 1));
      final isPropenso = DateTime.now().millisecondsSinceEpoch % 2 == 0;

      setState(() {
        _anemiaResult = isPropenso ? 'Posible propensión a anemia (resultado indicativo).' : 'Poco propenso a anemia (resultado indicativo).';
      });
    } catch (e) {
      setState(() {
        _anemiaResult = null;
        _selectedImage = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error al tomar la foto: $e')));
    }
  }
}