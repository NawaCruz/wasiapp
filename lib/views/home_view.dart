// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
// import 'package:image_picker/image_picker.dart';
// import 'dart:io';
import 'anemia_diagnostico_view.dart';
import 'registro_flow.dart';
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
  // Campos de la versión mock de Anemia eliminados

  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales por usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(context, listen: false);
      final ninoController = Provider.of<NinoController>(context, listen: false);
      final usuarioId = authController.usuarioActual?.id;
      
      print('DEBUG HomeView: Usuario ID = $usuarioId');
      print('DEBUG HomeView: Usuario actual = ${authController.usuarioActual?.nombre}');
      
      if (usuarioId != null) {
        print('DEBUG HomeView: Cargando niños para usuario $usuarioId');
        ninoController.cargarNinosPorUsuario(usuarioId);
        ninoController.cargarEstadisticasUsuario(usuarioId);
      } else {
        print('DEBUG HomeView: Usuario ID es null, no se pueden cargar niños');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'WASI App - Inicio',
      'Plan Nutricional',
      'Evaluación',
      'Anemia',
      'Perfil',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  onPressed: () async {
                    final authController = Provider.of<AuthController>(context, listen: false);
                    final ninoController = Provider.of<NinoController>(context, listen: false);
                    final usuarioId = authController.usuarioActual?.id;
                    
                    if (usuarioId != null) {
                      await ninoController.cargarNinosPorUsuario(usuarioId);
                      await ninoController.cargarEstadisticasUsuario(usuarioId);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Datos actualizados'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.refresh),
                  tooltip: 'Actualizar datos',
                ),
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

            // 3: Anemia (nuevo diagnóstico RF-05)
            const AnemiaDiagnosticoView(),


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

  Color _getIMCColor(String? clasificacion) {
    if (clasificacion == null) return Colors.grey.shade100;
    switch (clasificacion.toLowerCase()) {
      case 'bajo peso':
        return Colors.blue.shade100;
      case 'peso normal':
      case 'normal':
        return Colors.green.shade100;
      case 'sobrepeso':
        return Colors.orange.shade100;
      case 'obesidad':
        return Colors.red.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getIMCTextColor(String? clasificacion) {
    if (clasificacion == null) return Colors.grey;
    switch (clasificacion.toLowerCase()) {
      case 'bajo peso':
        return Colors.orange;
      case 'peso normal':
      case 'normal':
        return Colors.green;
      case 'sobrepeso':
        return Colors.orange;
      case 'obesidad':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  void _handleLogout() {
    showDialog<void>(
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
                MaterialPageRoute<void>(builder: (_) => const LoginView()),
              );
            },
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }

  void _navigateToRegisterChild() {
    Navigator.of(context).pushNamed('/registro_flow');
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
    showDialog(
      context: context,
      builder: (context) => _buildChildDetailsDialog(nino),
    );
  }

  Widget _buildChildDetailsDialog(dynamic nino) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 600),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.blue.shade100,
                  child: Icon(
                    nino.sexo == 'Masculino' ? Icons.boy : Icons.girl,
                    color: Colors.blue.shade700,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nino.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'DNI: ${nino.dniNino}',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(height: 20),
            
            // Información básica
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('Información Personal', [
                      _buildDetailRow('Edad', '${nino.edad} años'),
                      _buildDetailRow('Sexo', nino.sexo),
                      _buildDetailRow('Fecha de nacimiento', DateFormat('dd/MM/yyyy').format(nino.fechaNacimiento)),
                      _buildDetailRow('Residencia', nino.residencia),
                    ]),
                    
                    _buildDetailSection('Tutor/Responsable', [
                      _buildDetailRow('Nombre del tutor', nino.nombreTutor),
                      _buildDetailRow('DNI del tutor', nino.dniPadre),
                    ]),
                    
                    _buildDetailSection('Medidas Antropométricas', [
                      _buildDetailRow('Peso', '${nino.peso} kg'),
                      _buildDetailRow('Talla', '${nino.talla} cm'),
                      _buildDetailRow('IMC', nino.imc?.toStringAsFixed(2) ?? 'N/A'),
                      _buildDetailRow(
                        'Clasificación IMC', 
                        nino.clasificacionIMC ?? 'N/A',
                        color: _getIMCTextColor(nino.clasificacionIMC),
                      ),
                    ]),
                    
                    if (nino.anemia != null || nino.fatiga != null) ...[
                      _buildDetailSection('Cuestionario de Salud', [
                        if (nino.anemia != null) _buildDetailRow('Anemia previa', nino.anemia!),
                        if (nino.alimentosHierro != null) _buildDetailRow('Alimentos con hierro', nino.alimentosHierro!),
                        if (nino.fatiga != null) _buildDetailRow('Fatiga frecuente', nino.fatiga!),
                        if (nino.alimentacionBalanceada != null) _buildDetailRow('Alimentación balanceada', nino.alimentacionBalanceada!),
                        if (nino.palidez != null) _buildDetailRow('Palidez', nino.palidez!),
                        if (nino.disminucionRendimiento != null) _buildDetailRow('Disminución del rendimiento', nino.disminucionRendimiento!),
                      ]),
                    ],
                    
                    if (nino.evaluacionAnemia != null) ...[
                      _buildDetailSection('Evaluación de Anemia', [
                        _buildDetailRow(
                          'Riesgo', 
                          nino.evaluacionAnemia!,
                          color: _getAnemiaRiskColor(nino.evaluacionAnemia!),
                        ),
                      ]),
                    ],
                    
                    _buildDetailSection('Registro', [
                      _buildDetailRow('Fecha de registro', DateFormat('dd/MM/yyyy HH:mm').format(nino.fechaRegistro)),
                    ]),
                  ],
                ),
              ),
            ),
            
            // Botones de acción
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RegistroNinoFlow(ninoAEditar: nino),
                      ),
                    );
                  },
                  icon: Icon(Icons.edit, color: Colors.blue.shade700),
                  label: Text(
                    'Editar',
                    style: TextStyle(color: Colors.blue.shade700),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cerrar'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1976D2),
          ),
        ),
        const SizedBox(height: 8),
        ...children,
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: color ?? Colors.black87,
                fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }



  Color _getAnemiaRiskColor(String riesgo) {
    if (riesgo.contains('Alta')) return Colors.red;
    if (riesgo.contains('moderado')) return Colors.orange;
    return Colors.green;
  }

  // Flujo mock anterior de Anemia eliminado (sustituido por AnemiaDiagnosticoView)
}