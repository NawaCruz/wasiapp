import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/auth_controller.dart';
import '../controllers/nino_controller.dart';
import 'registro_flow.dart';
import 'login_view.dart';

class CuentaView extends StatefulWidget {
  const CuentaView({super.key});

  @override
  State<CuentaView> createState() => _CuentaViewState();
}

class _CuentaViewState extends State<CuentaView> with TickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingRefresh = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // No cargar datos aquí para evitar setState durante build
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
          content: Text('Datos actualizados'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Cuenta'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
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
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(
              icon: Icon(Icons.person),
              text: 'Perfil',
            ),
            Tab(
              icon: Icon(Icons.child_care),
              text: 'Registros',
            ),
          ],
        ),
      ),
      body: Consumer2<AuthController, NinoController>(
        builder: (context, authController, ninoController, child) {
          return TabBarView(
            controller: _tabController,
            children: [
              // Tab 1: Perfil del usuario
              _buildPerfilTab(authController, ninoController),
              
              // Tab 2: Registros de niños
              _buildRegistrosTab(ninoController),
            ],
          );
        },
      ),
    );
  }

  Widget _buildPerfilTab(AuthController authController, NinoController ninoController) {
    final usuario = authController.usuarioActual;
    final stats = ninoController.estadisticas;

    return RefreshIndicator(
      onRefresh: _refrescarDatos,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Información del usuario
            _buildUserInfoCard(usuario),
            const SizedBox(height: 16),

            // Estadísticas del usuario
            _buildStatsCard(stats),
            const SizedBox(height: 16),

            // Resumen de actividad
            _buildActivitySummaryCard(ninoController),
            const SizedBox(height: 16),

            // Botones de acción
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrosTab(NinoController ninoController) {
    if (ninoController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    final ninos = ninoController.ninos;

    return RefreshIndicator(
      onRefresh: _refrescarDatos,
      child: ninos.isEmpty 
        ? _buildEmptyRegistrosState()
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ninos.length,
            itemBuilder: (context, index) => _buildRegistroCard(ninos[index]),
          ),
    );
  }

  Widget _buildUserInfoCard(dynamic usuario) {
    final nombre = usuario?.nombre ?? usuario?.usuario ?? 'Usuario';
    final email = usuario?.email ?? '';

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.blue.shade100,
                borderRadius: BorderRadius.circular(40),
              ),
              child: Icon(
                Icons.person,
                size: 40,
                color: Colors.blue.shade700,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (email.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      email,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Activo',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w600,
                      ),
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

  Widget _buildStatsCard(Map<String, dynamic> stats) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mis Estadísticas',
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
                    'Este Mes',
                    '${stats['registrosEsteMes'] ?? 0}',
                    Icons.calendar_month,
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
            color: color.withValues(alpha: 0.1),
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

  Widget _buildActivitySummaryCard(NinoController ninoController) {
    final registrosRecientes = ninoController.ninos.take(3).toList();
    
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
                  'Actividad Reciente',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () => _tabController.animateTo(1),
                  child: const Text('Ver todos'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            if (registrosRecientes.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'No hay actividad reciente',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                  ),
                ),
              )
            else
              ...registrosRecientes.map((nino) => ListTile(
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
                subtitle: Text(
                  'Registrado: ${DateFormat('dd/MM/yyyy').format(nino.fechaRegistro)}',
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
                onTap: () => _verDetallesNino(nino),
              )),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pushNamed('/registro_flow'),
            icon: const Icon(Icons.add_circle),
            label: const Text('Registrar Nuevo Niño'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _handleLogout,
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.red,
              side: const BorderSide(color: Colors.red),
              padding: const EdgeInsets.all(16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyRegistrosState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.child_care,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay registros aún',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Comienza registrando el primer niño',
              style: TextStyle(
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.of(context).pushNamed('/registro_flow'),
              icon: const Icon(Icons.add),
              label: const Text('Registrar Niño'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistroCard(dynamic nino) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
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
                        'DNI: ${nino.dniNino} • ${nino.edad} años',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) => _handleRegistroAction(value, nino),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, size: 20),
                          SizedBox(width: 8),
                          Text('Ver detalles'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Editar'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Información resumida
            Row(
              children: [
                _buildInfoChip('Peso: ${nino.peso} kg', Icons.scale),
                const SizedBox(width: 8),
                _buildInfoChip('Talla: ${nino.talla} cm', Icons.height),
              ],
            ),
            const SizedBox(height: 8),
            
            Row(
              children: [
                if (nino.clasificacionIMC != null) ...[
                  _buildIMCChip(nino.clasificacionIMC!),
                  const SizedBox(width: 8),
                ],
                _buildInfoChip(
                  'Reg: ${DateFormat('dd/MM/yyyy').format(nino.fechaRegistro)}',
                  Icons.calendar_today,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey.shade600),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIMCChip(String clasificacion) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _getIMCColor(clasificacion),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        clasificacion,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: _getIMCTextColor(clasificacion),
        ),
      ),
    );
  }

  Color _getIMCColor(String clasificacion) {
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

  Color _getIMCTextColor(String clasificacion) {
    switch (clasificacion.toLowerCase()) {
      case 'bajo peso':
        return Colors.blue.shade700;
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

  void _handleRegistroAction(String action, dynamic nino) {
    switch (action) {
      case 'view':
        _verDetallesNino(nino);
        break;
      case 'edit':
        _editarNino(nino);
        break;
    }
  }

  void _verDetallesNino(dynamic nino) {
    showDialog(
      context: context,
      builder: (context) => _buildDetallesDialog(nino),
    );
  }

  void _editarNino(dynamic nino) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RegistroNinoFlow(ninoAEditar: nino),
      ),
    ).then((_) => _refrescarDatos());
  }

  Widget _buildDetallesDialog(dynamic nino) {
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
            
            // Contenido
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailSection('Información Personal', [
                      _buildDetailRow('Edad', '${nino.edad} años'),
                      _buildDetailRow('Sexo', nino.sexo),
                      _buildDetailRow('Fecha de nacimiento', 
                          DateFormat('dd/MM/yyyy').format(nino.fechaNacimiento)),
                      _buildDetailRow('Residencia', nino.residencia),
                    ]),
                    
                    _buildDetailSection('Tutor/Responsable', [
                      _buildDetailRow('Nombre', nino.nombreTutor),
                      _buildDetailRow('DNI', nino.dniPadre),
                    ]),
                    
                    _buildDetailSection('Medidas Antropométricas', [
                      _buildDetailRow('Peso', '${nino.peso} kg'),
                      _buildDetailRow('Talla', '${nino.talla} cm'),
                      _buildDetailRow('IMC', nino.imc?.toStringAsFixed(2) ?? 'N/A'),
                      if (nino.clasificacionIMC != null)
                        _buildDetailRow('Clasificación IMC', nino.clasificacionIMC!,
                            color: _getIMCTextColor(nino.clasificacionIMC!)),
                    ]),
                    
                    _buildDetailSection('Registro', [
                      _buildDetailRow('Fecha', 
                          DateFormat('dd/MM/yyyy HH:mm').format(nino.fechaRegistro)),
                    ]),
                  ],
                ),
              ),
            ),
            
            // Botones
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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

  Widget _buildDetailSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade700,
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
            width: 100,
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
              Navigator.of(context).pushAndRemoveUntil(
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