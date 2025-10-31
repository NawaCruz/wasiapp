import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../views/login_view.dart';

class OnboardingService {
  static const String _hasSeenOnboardingKey = 'has_seen_onboarding';
  static const String _tooltipDisabledKey = 'tooltips_disabled';

  // Verificar si el usuario ya vio el onboarding
  static Future<bool> hasSeenOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_hasSeenOnboardingKey) ?? false;
  }

  // Marcar onboarding como completado
  static Future<void> markOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_hasSeenOnboardingKey, true);
  }

  // Verificar si los tooltips están habilitados
  static Future<bool> areTooltipsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return !(prefs.getBool(_tooltipDisabledKey) ?? false);
  }

  // Alternar tooltips
  static Future<void> toggleTooltips() async {
    final prefs = await SharedPreferences.getInstance();
    final current = prefs.getBool(_tooltipDisabledKey) ?? false;
    await prefs.setBool(_tooltipDisabledKey, !current);
  }
}

class OnboardingView extends StatefulWidget {
  const OnboardingView({super.key});

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: '¡Bienvenido a WasiApp!',
      description: 'La aplicación para el control y seguimiento del crecimiento nutricional infantil.',
      icon: Icons.child_care,
      color: Colors.blue,
      features: [
        '📊 Registro antropométrico completo',
        '📈 Seguimiento del crecimiento',
        '🩺 Evaluación de anemia',
        '📱 Interfaz fácil de usar',
      ],
    ),
    OnboardingPage(
      title: 'Registro Simplificado',
      description: 'Registra información de niños de manera rápida y eficiente.',
      icon: Icons.assignment_add,
      color: Colors.green,
      features: [
        '✏️ Formularios intuitivos',
        '🔍 Validación automática',
        '💾 Guardado seguro en la nube',
        '📋 Historial completo',
      ],
    ),
    OnboardingPage(
      title: 'Estadísticas y Reportes',
      description: 'Visualiza el progreso y obtén insights valiosos.',
      icon: Icons.analytics,
      color: Colors.purple,
      features: [
        '📊 Gráficos interactivos',
        '📈 Tendencias de crecimiento',
        '⚠️ Alertas nutricionales',
        '📄 Reportes exportables',
      ],
    ),
    OnboardingPage(
      title: '¡Comencemos!',
      description: 'Todo listo para empezar a registrar y monitorear el crecimiento infantil.',
      icon: Icons.rocket_launch,
      color: Colors.orange,
      features: [
        '🚀 Configuración automática',
        '📚 Ayuda contextual disponible',
        '🔄 Sincronización automática',
        '🎯 Tutorial interactivo',
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              _pages[_currentPage].color.withValues(alpha: 0.1),
              _pages[_currentPage].color.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header con botón de saltar
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'WasiApp',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _pages[_currentPage].color,
                      ),
                    ),
                    if (_currentPage < _pages.length - 1)
                      TextButton(
                        onPressed: _skipOnboarding,
                        child: Text(
                          'Saltar',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ),
                  ],
                ),
              ),

              // Contenido principal
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() => _currentPage = index);
                  },
                  itemCount: _pages.length,
                  itemBuilder: (context, index) {
                    return _buildOnboardingPage(_pages[index]);
                  },
                ),
              ),

              // Indicadores y navegación
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    // Indicadores de página
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.symmetric(horizontal: 4),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? _pages[_currentPage].color
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Botones de navegación
                    Row(
                      children: [
                        if (_currentPage > 0)
                          Expanded(
                            child: OutlinedButton(
                              onPressed: _previousPage,
                              style: OutlinedButton.styleFrom(
                                side: BorderSide(color: _pages[_currentPage].color),
                                padding: const EdgeInsets.all(16),
                              ),
                              child: Text(
                                'Anterior',
                                style: TextStyle(color: _pages[_currentPage].color),
                              ),
                            ),
                          ),
                        if (_currentPage > 0) const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _currentPage == _pages.length - 1
                                ? _completeOnboarding
                                : _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _pages[_currentPage].color,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.all(16),
                            ),
                            child: Text(
                              _currentPage == _pages.length - 1
                                  ? 'Comenzar'
                                  : 'Siguiente',
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOnboardingPage(OnboardingPage page) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icono principal
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: page.color.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              page.icon,
              size: 60,
              color: page.color,
            ),
          ),

          const SizedBox(height: 32),

          // Título
          Text(
            page.title,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: page.color,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 16),

          // Descripción
          Text(
            page.description,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 32),

          // Características
          ...page.features.map((feature) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              children: [
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: page.color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    feature,
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  void _nextPage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  void _completeOnboarding() async {
    await OnboardingService.markOnboardingComplete();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const LoginView()),
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}

class OnboardingPage {
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final List<String> features;

  OnboardingPage({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.features = const [],
  });
}

// Sistema de ayuda contextual
class HelpSystem {
  static void showFeatureTour(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FeatureTourDialog(),
    );
  }

  static void showQuickHelp(BuildContext context, String feature) {
    final helpInfo = _getHelpInfo(feature);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(helpInfo.icon, color: Colors.blue),
            const SizedBox(width: 8),
            Text(helpInfo.title),
          ],
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(helpInfo.description),
            const SizedBox(height: 16),
            ...helpInfo.steps.map((step) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: Colors.blue.shade100,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${helpInfo.steps.indexOf(step) + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(step, style: const TextStyle(fontSize: 13))),
                ],
              ),
            )),
          ],
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

  static HelpInfo _getHelpInfo(String feature) {
    switch (feature) {
      case 'registro':
        return HelpInfo(
          title: 'Registrar Niño',
          description: 'Aprende a registrar un nuevo niño en el sistema',
          icon: Icons.add_circle,
          steps: [
            'Toca el botón "+" en la pantalla principal',
            'Completa los datos personales del niño',
            'Ingresa las medidas antropométricas',
            'Responde el cuestionario de salud',
            'Revisa y confirma la información',
          ],
        );
      case 'estadisticas':
        return HelpInfo(
          title: 'Ver Estadísticas',
          description: 'Cómo interpretar las estadísticas y gráficos',
          icon: Icons.analytics,
          steps: [
            'Ve a la sección "Resumen" en el inicio',
            'Los números muestran totales por género',
            'Los colores indican el estado nutricional',
            'Verde = Normal, Naranja = Alerta, Rojo = Crítico',
          ],
        );
      case 'actualizacion':
        return HelpInfo(
          title: 'Actualizar Datos',
          description: 'Mantén la información actualizada',
          icon: Icons.refresh,
          steps: [
            'Desliza hacia abajo en cualquier lista',
            'O toca el ícono de actualizar en el menú',
            'Los datos se sincronizarán automáticamente',
            'Verás una confirmación cuando termine',
          ],
        );
      default:
        return HelpInfo(
          title: 'Ayuda General',
          description: 'Información básica sobre la aplicación',
          icon: Icons.help,
          steps: [
            'Usa el menú de navegación inferior',
            'Toca cualquier elemento para ver detalles',
            'Los iconos de ayuda (?) muestran información adicional',
          ],
        );
    }
  }
}

class HelpInfo {
  final String title;
  final String description;
  final IconData icon;
  final List<String> steps;

  HelpInfo({
    required this.title,
    required this.description,
    required this.icon,
    this.steps = const [],
  });
}

class FeatureTourDialog extends StatefulWidget {
  const FeatureTourDialog({super.key});

  @override
  State<FeatureTourDialog> createState() => _FeatureTourDialogState();
}

class _FeatureTourDialogState extends State<FeatureTourDialog> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<TourStep> _tourSteps = [
    TourStep(
      title: 'Pantalla Principal',
      description: 'Aquí verás un resumen de todos tus registros y estadísticas importantes.',
      icon: Icons.home,
    ),
    TourStep(
      title: 'Registrar Niño',
      description: 'Usa el botón + para agregar un nuevo registro de un niño.',
      icon: Icons.add_circle,
    ),
    TourStep(
      title: 'Ver Detalles',
      description: 'Toca cualquier registro para ver información completa y opciones de edición.',
      icon: Icons.visibility,
    ),
    TourStep(
      title: 'Actualizar',
      description: 'Desliza hacia abajo o usa el ícono de actualizar para obtener los datos más recientes.',
      icon: Icons.refresh,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        height: 400,
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text(
              'Tour de Funciones',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade700,
              ),
            ),
            
            const SizedBox(height: 20),
            
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _tourSteps.length,
                itemBuilder: (context, index) {
                  final step = _tourSteps[index];
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(step.icon, size: 60, color: Colors.blue.shade600),
                      const SizedBox(height: 20),
                      Text(
                        step.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        step.description,
                        style: const TextStyle(fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  );
                },
              ),
            ),
            
            // Indicadores
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _tourSteps.length,
                (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPage == index ? 16 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPage == index ? Colors.blue : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 20),
            
            // Botones
            Row(
              children: [
                if (_currentPage > 0)
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _pageController.previousPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      ),
                      child: const Text('Anterior'),
                    ),
                  ),
                if (_currentPage > 0) const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _currentPage == _tourSteps.length - 1
                        ? () => Navigator.pop(context)
                        : () => _pageController.nextPage(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeInOut,
                          ),
                    child: Text(_currentPage == _tourSteps.length - 1 ? 'Finalizar' : 'Siguiente'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TourStep {
  final String title;
  final String description;
  final IconData icon;

  TourStep({
    required this.title,
    required this.description,
    required this.icon,
  });
}

// Widget de tooltip contextual
class ContextualTooltip extends StatelessWidget {
  final String message;
  final Widget child;
  final bool enabled;

  const ContextualTooltip({
    super.key,
    required this.message,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;
    
    return Tooltip(
      message: message,
      preferBelow: false,
      decoration: BoxDecoration(
        color: Colors.blue.shade700,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 12,
      ),
      child: child,
    );
  }
}