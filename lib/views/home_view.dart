// ignore_for_file: deprecated_member_use, use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'anemia_diagnostico_view.dart';
import 'registro_flow.dart';
import '../controllers/auth_controller.dart';
import '../controllers/nino_controller.dart';
import '../utils/anemia_risk.dart';
import 'login_view.dart';
import 'nutritional_plan_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late TabController _tabController;
  bool _isLoadingRefresh = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Cargar datos iniciales por usuario
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(context, listen: false);
      final ninoController = Provider.of<NinoController>(context, listen: false);
      
      final usuarioId = authController.usuarioActual?.id;
      
      if (usuarioId != null) {
        ninoController.cargarNinosPorUsuario(usuarioId);
        ninoController.cargarEstadisticasUsuario(usuarioId);
      } else {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _cargarDatos() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final ninoController = Provider.of<NinoController>(context, listen: false);
    final usuarioId = authController.usuarioActual?.id;
    
    if (usuarioId != null) {
      await ninoController.cargarNinosPorUsuario(usuarioId);
      await ninoController.cargarEstadisticasUsuario(usuarioId);
    }
  }

  Future<void> _refrescarDatos() async {
    setState(() => _isLoadingRefresh = true);
    await _cargarDatos();
    setState(() => _isLoadingRefresh = false);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              SizedBox(width: 8),
              Text('Datos actualizados correctamente'),
            ],
          ),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final titles = [
      'WasiApp',
      'Plan Nutricional',
      'Evaluación',
      'Diagnóstico',
      'Perfil',
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(titles[_selectedIndex]),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: _selectedIndex == 0
            ? [
                IconButton(
                  onPressed: _isLoadingRefresh ? null : _refrescarDatos,
                  icon: _isLoadingRefresh 
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.refresh),
                  tooltip: 'Actualizar datos',
                ),
                _buildHelpButton(),
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
                          Icon(Icons.logout, color: Colors.red),
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
            // 0: Inicio - Simplificado
            Consumer2<AuthController, NinoController>(
              builder: (context, authController, ninoController, child) {
                return _buildHomeContent(authController, ninoController);
              },
            ),

            // 1: Plan Nutricional
            const NutritionalPlanView(),

            // 2: Evaluación
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
                        Navigator.of(context).pushNamed('/registro_flow');
                      },
                      child: const Text('Ir a Evaluación'),
                    ),
                  ],
                ),
              ),
            ),

            // 3: Anemia
            const AnemiaDiagnosticoView(),

            // 4: Perfil - Simplificado
            _buildPerfilSimplificado(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue.shade700,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 2) {
            Navigator.of(context).pushNamed('/registro_flow');
            return;
          }
          setState(() => _selectedIndex = index);
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant), label: 'Plan'),
          BottomNavigationBarItem(icon: Icon(Icons.add_circle), label: 'Registrar'),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: 'Diagnóstico'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: () => Navigator.of(context).pushNamed('/registro_flow'),
              backgroundColor: Colors.blue.shade700,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  // DISEÑO SIMPLIFICADO DEL HOME
  Widget _buildHomeContent(AuthController authController, NinoController ninoController) {
    if (ninoController.isLoading && ninoController.ninos.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refrescarDatos,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header simplificado
            _buildWelcomeHeader(authController),
            const SizedBox(height: 20),

            // Estadísticas compactas
            _buildCompactStats(ninoController),
            const SizedBox(height: 20),

            // Registros recientes simplificados
            _buildSimpleRegistrosList(ninoController),
          ],
        ),
      ),
    );
  }

  // Header de bienvenida más simple
  Widget _buildWelcomeHeader(AuthController authController) {
    final usuario = authController.usuarioActual;
    final nombreMostrar = usuario?.nombre ?? usuario?.usuario ?? 'Usuario';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: Icon(
              Icons.person,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Hola, $nombreMostrar',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Control nutricional infantil',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Estadísticas más compactas
  Widget _buildCompactStats(NinoController ninoController) {
    final stats = ninoController.estadisticas;
    
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Resumen',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSimpleStatItem(
                  'Total',
                  '${stats['totalNinos'] ?? 0}',
                  Icons.child_care,
                  Colors.blue,
                ),
                _buildSimpleStatItem(
                  'Niños',
                  '${stats['masculinos'] ?? 0}',
                  Icons.boy,
                  Colors.green,
                ),
                _buildSimpleStatItem(
                  'Niñas',
                  '${stats['femeninos'] ?? 0}',
                  Icons.girl,
                  Colors.pink,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSimpleStatItem(String label, String value, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
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
          ),
        ],
      ),
    );
  }

  // Lista de registros simplificada
  Widget _buildSimpleRegistrosList(NinoController ninoController) {
    final ninos = ninoController.ninos.take(5).toList();

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Registros Recientes',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (ninos.isNotEmpty)
                  TextButton(
                    onPressed: () => _showAllRegistros(ninoController.ninos),
                    child: const Text('Ver todos'),
                  ),
              ],
            ),
            const SizedBox(height: 8),
            
            if (ninos.isEmpty)
              _buildEmptyState()
            else
              ...ninos.map((nino) => _buildSimpleRegistroCard(nino)),
          ],
        ),
      ),
    );
  }

  // Card de registro simplificada
  Widget _buildSimpleRegistroCard(dynamic nino) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      leading: CircleAvatar(
        backgroundColor: nino.sexo == 'Masculino' 
            ? Colors.blue.shade100 
            : Colors.pink.shade100,
        radius: 20,
        child: Icon(
          nino.sexo == 'Masculino' ? Icons.boy : Icons.girl,
          color: nino.sexo == 'Masculino' 
              ? Colors.blue.shade700 
              : Colors.pink.shade700,
          size: 20,
        ),
      ),
      title: Text(
        nino.nombreCompleto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        '${nino.edad} años${nino.clasificacionIMC != null ? ' • ${nino.clasificacionIMC}' : ''}',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade600,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: () => _viewChildDetails(nino),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.child_care,
            size: 48,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 12),
          Text(
            'No hay registros aún',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Toca el botón + para comenzar',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  // BOTÓN DE AYUDA
  Widget _buildHelpButton() {
    return IconButton(
      onPressed: () => _showHelpDialog(),
      icon: const Icon(Icons.help_outline),
      tooltip: 'Ayuda y tutorial',
    );
  }

  void _showHelpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.help_outline, color: Colors.blue),
            SizedBox(width: 8),
            Text('Ayuda'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHelpSection('🏠 Inicio', 'Visualiza tus estadísticas y registros recientes'),
              _buildHelpSection('➕ Registrar', 'Agrega un nuevo niño al sistema'),
              _buildHelpSection('👤 Perfil', 'Gestiona tu información personal'),
              _buildHelpSection('🔄 Actualizar', 'Desliza hacia abajo o toca el ícono de actualizar'),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  '💡 Consejo: Mantén presionado cualquier elemento para ver más opciones',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Widget _buildHelpSection(String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  void _showAllRegistros(List<dynamic> ninos) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => _AllRegistrosView(ninos: ninos),
      ),
    );
  }

  // Métodos existentes simplificados
  void _viewChildDetails(dynamic nino) {
    showDialog(
      context: context,
      builder: (context) => _buildSimpleDetailsDialog(nino),
    );
  }

  Widget _buildSimpleDetailsDialog(dynamic nino) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 500),
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header simple
            Row(
              children: [
                CircleAvatar(
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        nino.nombreCompleto,
                        style: const TextStyle(
                          fontSize: 16,
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
            
            const Divider(height: 24),
            
            // Información básica
            Expanded(
              child: ListView(
                children: [
                  _buildDetailRow('Edad', '${nino.edad} años'),
                  _buildDetailRow('Sexo', nino.sexo),
                  _buildDetailRow('Peso', '${nino.peso} kg'),
                  _buildDetailRow('Talla', '${nino.talla} cm'),
                  if (nino.clasificacionIMC != null)
                    _buildDetailRow('IMC', nino.clasificacionIMC!, 
                        color: _getIMCTextColor(nino.clasificacionIMC!)),
                  
                  // Historial Clínico - Foto de Conjuntiva
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 8),
                  
                  // Título de la sección con botón para tomar foto
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.medical_information, color: Colors.blue.shade700, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            'Historial Clínico',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      // Botón para tomar/actualizar foto
                      IconButton(
                        onPressed: () => _tomarFotoConjuntiva(nino),
                        icon: Icon(
                          nino.fotoConjuntivaUrl != null && nino.fotoConjuntivaUrl!.isNotEmpty
                              ? Icons.refresh
                              : Icons.add_a_photo,
                          color: Colors.purple.shade600,
                          size: 20,
                        ),
                        tooltip: nino.fotoConjuntivaUrl != null && nino.fotoConjuntivaUrl!.isNotEmpty
                            ? 'Actualizar foto'
                            : 'Tomar foto',
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  
                  // Contenedor de la foto o mensaje para tomar foto
                  if (nino.fotoConjuntivaUrl != null && nino.fotoConjuntivaUrl!.isNotEmpty) ...[
                    // Contenedor de la foto
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.blue.shade200, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.1),
                            blurRadius: 6,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.camera_alt, size: 14, color: Colors.blue.shade700),
                                const SizedBox(width: 6),
                                Text(
                                  'Foto de Conjuntiva',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.blue.shade700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          
                          // Foto
                          Padding(
                            padding: const EdgeInsets.all(10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Container(
                                width: double.infinity,
                                height: 180,
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  border: Border.all(color: Colors.grey[300]!),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Image.file(
                                  File(nino.fotoConjuntivaUrl!),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Center(
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.image_not_supported, size: 40, color: Colors.grey[400]),
                                          const SizedBox(height: 6),
                                          Text(
                                            'Imagen no disponible',
                                            style: TextStyle(color: Colors.grey[600], fontSize: 11),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                          
                          // Footer
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            child: Row(
                              children: [
                                Icon(Icons.info_outline, size: 14, color: Colors.green.shade700),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    'Última foto de diagnóstico',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Mensaje cuando no hay foto
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.purple.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.purple.shade200, width: 2, style: BorderStyle.solid),
                      ),
                      child: Column(
                        children: [
                          Icon(Icons.add_a_photo, size: 48, color: Colors.purple.shade300),
                          const SizedBox(height: 12),
                          Text(
                            'Sin foto de conjuntiva',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.purple.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            // Botones
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _editarNino(nino);
                  },
                  icon: Icon(Icons.edit, color: Colors.blue.shade700),
                  label: Text('Editar', style: TextStyle(color: Colors.blue.shade700)),
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

  Widget _buildDetailRow(String label, String value, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
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

  Color _getIMCTextColor(String clasificacion) {
    switch (clasificacion.toLowerCase()) {
      case 'bajo peso':
        return Colors.orange.shade700;
      case 'peso normal':
      case 'normal':
        return Colors.green.shade700;
      case 'sobrepeso':
        return Colors.orange.shade700;
      case 'obesidad':
        return Colors.red.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  // Función para tomar/actualizar foto de conjuntiva
  Future<void> _tomarFotoConjuntiva(dynamic nino) async {
    final ImagePicker picker = ImagePicker();
    
    try {
      // Mostrar diálogo con instrucciones y opciones
      final ImageSource? imageSource = await showDialog<ImageSource>(
        context: context,
        builder: (context) => AlertDialog(
          title: Row(
            children: [
              Icon(Icons.camera_alt, color: Colors.purple.shade600),
              const SizedBox(width: 8),
              const Text('Análisis Visual de Conjuntiva'),
            ],
          ),
          content: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.purple.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.purple.shade600, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Instrucciones para la foto:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _buildInstruccion('1', 'Baje suavemente el párpado inferior'),
                _buildInstruccion('2', 'Exponga la conjuntiva (parte interna rosada del ojo)'),
                _buildInstruccion('3', 'Tome la foto en un lugar bien iluminado'),
                _buildInstruccion('4', 'Mantenga la cámara estable y enfocada'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, null),
              child: const Text('Cancelar'),
            ),
            const SizedBox(width: 8),
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.gallery),
              icon: const Icon(Icons.photo_library),
              label: const Text('Galería'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.purple.shade600,
                side: BorderSide(color: Colors.purple.shade600),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context, ImageSource.camera),
              icon: const Icon(Icons.camera_alt),
              label: const Text('Cámara'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      );
      
      if (imageSource == null) return;
      
      // Tomar la foto o seleccionar de galería
      final XFile? foto = await picker.pickImage(
        source: imageSource,
        imageQuality: 85,
        maxWidth: 1024,
        maxHeight: 1024,
      );
      
      if (foto == null) return;
      
      // Mostrar indicador de carga
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }
      
      final File fotoFile = File(foto.path);
      
      // Calcular score de palidez
      final score = AnemiaRiskEngine.imagePalenessFromFile(fotoFile);
      
      // Actualizar el niño con la nueva foto
      final ninoActualizado = nino.copyWith(
        fotoConjuntivaUrl: fotoFile.path,
      );
      
      final ninoController = context.read<NinoController>();
      final exitoso = await ninoController.actualizarNino(
        ninoActualizado,
        usuarioId: nino.usuarioId,
      );
      
      // Cerrar indicador de carga
      if (mounted) Navigator.pop(context);
      
      if (exitoso) {
        // Mostrar resultado
        if (mounted) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green.shade600),
                  const SizedBox(width: 8),
                  const Text('Foto guardada'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (score != null)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: _getPalenessColor(score).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: _getPalenessColor(score), width: 2),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Análisis de conjuntiva: ${_getPalenessLevel(score)}',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: _getPalenessColor(score),
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Score de palidez: ${(score * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    const Text('Foto guardada correctamente'),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Cerrar diálogo de resultado
                    Navigator.pop(context); // Cerrar diálogo de detalles del niño
                    _refrescarDatos(); // Recargar datos
                  },
                  child: const Text('Aceptar'),
                ),
              ],
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error al guardar la foto'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      // Cerrar indicador de carga si está abierto
      if (mounted && Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildInstruccion(String numero, String texto) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.purple.shade600,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                numero,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              texto,
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getPalenessLevel(double score) {
    if (score < 0.3) return 'Normal (buena coloración)';
    if (score < 0.6) return 'Palidez leve';
    if (score < 0.8) return 'Palidez moderada';
    return 'Palidez severa';
  }

  Color _getPalenessColor(double score) {
    if (score < 0.3) return Colors.green;
    if (score < 0.6) return Colors.yellow.shade700;
    if (score < 0.8) return Colors.orange;
    return Colors.red;
  }

  void _editarNino(dynamic nino) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroNinoFlow(ninoAEditar: nino),
      ),
    ).then((_) => _refrescarDatos());
  }

  // Perfil simplificado
  Widget _buildPerfilSimplificado() {
    return Consumer<AuthController>(
      builder: (context, authController, child) {
        final usuario = authController.usuarioActual;
        final nombre = usuario?.nombre ?? '';
        final apellido = usuario?.apellido ?? '';
        final usuarioName = usuario?.usuario ?? 'Usuario';

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              // Avatar
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade700],
                  ),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Información
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      _buildProfileField('Usuario', usuarioName, Icons.account_circle),
                      const SizedBox(height: 12),
                      _buildProfileField('Nombres', nombre.isNotEmpty ? nombre : 'No especificado', Icons.person),
                      const SizedBox(height: 12),
                      _buildProfileField('Apellidos', apellido.isNotEmpty ? apellido : 'No especificado', Icons.person_outline),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Botón logout
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _handleLogout,
                  icon: const Icon(Icons.logout, color: Colors.red),
                  label: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.all(16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProfileField(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: Colors.blue.shade700, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _handleLogout() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Provider.of<AuthController>(context, listen: false).logout();
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute<void>(builder: (_) => const LoginView()),
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}

// Vista separada para mostrar todos los registros
class _AllRegistrosView extends StatelessWidget {
  final List<dynamic> ninos;

  const _AllRegistrosView({required this.ninos});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todos los Registros'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: ninos.length,
        itemBuilder: (context, index) {
          final nino = ninos[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 8),
            child: ListTile(
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
              subtitle: Text('${nino.edad} años • DNI: ${nino.dniNino}'),
              trailing: Text(
                DateFormat('dd/MM/yy').format(nino.fechaRegistro),
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              onTap: () {
                // Mostrar detalles o navegar a edición
              },
            ),
          );
        },
      ),
    );
  }
}