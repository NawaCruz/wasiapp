import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';
import '../controllers/nino_controller.dart';
import 'login_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('WASI App - Inicio'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
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
        ],
      ),
      body: Consumer2<AuthController, NinoController>(
        builder: (context, authController, ninoController, child) {
          if (ninoController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
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
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _navigateToRegisterChild,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Registrar Niño'),
      ),
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
}