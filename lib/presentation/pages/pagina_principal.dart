import 'package:flutter/material.dart';
import '../widgets/boton_personalizado.dart';
import '../widgets/tarjeta_estadistica.dart';
import '../../core/constants/app_constants.dart';

class PaginaPrincipal extends StatefulWidget {
  const PaginaPrincipal({Key? key}) : super(key: key);

  @override
  State<PaginaPrincipal> createState() => _PaginaPrincipalState();
}

class _PaginaPrincipalState extends State<PaginaPrincipal> {
  // Estadísticas simuladas - en producción vendrían del backend
  int totalNinos = 0;
  int ninosConAnemia = 0;
  int ninosDesnutridos = 0;
  bool cargandoEstadisticas = true;

  @override
  void initState() {
    super.initState();
    _cargarEstadisticas();
  }

  Future<void> _cargarEstadisticas() async {
    // TODO: Implementar carga real de estadísticas
    // final estadisticasUseCase = sl<ObtenerEstadisticasUseCase>();
    // final stats = await estadisticasUseCase.call();
    
    // Simulación temporal
    await Future.delayed(const Duration(seconds: 2));
    
    if (mounted) {
      setState(() {
        totalNinos = 45;
        ninosConAnemia = 12;
        ninosDesnutridos = 8;
        cargandoEstadisticas = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(ConstantesApp.nombreApp),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Bienvenida
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.blue.shade400, Colors.blue.shade600],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: const Column(
                children: [
                  Icon(
                    Icons.child_care,
                    size: 50,
                    color: Colors.white,
                  ),
                  SizedBox(height: 15),
                  Text(
                    '¡Bienvenido a WasiApp!',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sistema de registro y monitoreo del crecimiento infantil',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white70,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),

            // Estadísticas
            const Text(
              'Resumen General',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            if (cargandoEstadisticas)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(40),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: TarjetaEstadistica(
                      titulo: 'Total Niños',
                      valor: totalNinos.toString(),
                      icono: Icons.groups,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TarjetaEstadistica(
                      titulo: 'Con Anemia',
                      valor: ninosConAnemia.toString(),
                      icono: Icons.warning,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: TarjetaEstadistica(
                      titulo: 'Desnutridos',
                      valor: ninosDesnutridos.toString(),
                      icono: Icons.health_and_safety,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),

            const SizedBox(height: 30),

            // Opciones principales
            const Text(
              'Opciones Principales',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 15),

            // Botón registrar niño
            BotonPersonalizado(
              texto: 'Registrar Nuevo Niño',
              icono: Icons.person_add,
              colorFondo: Colors.green,
              alPresionar: () {
                Navigator.pushNamed(context, Rutas.registrarNino);
              },
            ),
            
            const SizedBox(height: 15),

            // Botón ver lista
            BotonPersonalizado(
              texto: 'Ver Lista de Niños',
              icono: Icons.list,
              colorFondo: Colors.blue,
              alPresionar: () {
                Navigator.pushNamed(context, Rutas.listaNinos);
              },
            ),
            
            const SizedBox(height: 15),

            // Botón estadísticas
            BotonPersonalizado(
              texto: 'Ver Estadísticas Detalladas',
              icono: Icons.analytics,
              colorFondo: Colors.purple,
              alPresionar: () {
                Navigator.pushNamed(context, Rutas.estadisticas);
              },
            ),

            const SizedBox(height: 30),

            // Información adicional
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: Colors.blue.shade600,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Esta aplicación te ayuda a llevar un control detallado del crecimiento y desarrollo de los niños.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.black87,
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
}