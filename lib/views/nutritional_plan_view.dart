// nutritional_plan_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:open_file/open_file.dart';
import '../controllers/nino_controller.dart';
import '../models/nino_model.dart';
import '../services/pdf_generator_service.dart';

class NutritionalPlanView extends StatefulWidget {
  const NutritionalPlanView({super.key});

  @override
  State<NutritionalPlanView> createState() => _NutritionalPlanViewState();
}

class _NutritionalPlanViewState extends State<NutritionalPlanView> {
  NinoModel? _selectedChild;
  bool _isGeneratingPDF = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Nutricional'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Consumer<NinoController>(
        builder: (context, ninoController, child) {
          final ninos = ninoController.ninos;

          if (ninos.isEmpty) {
            return _buildEmptyState();
          }

          return Column(
            children: [
              // Selector de niño
              _buildChildSelector(ninos),

              // Plan nutricional basado en riesgo
              Expanded(
                child: _selectedChild != null
                    ? _buildNutritionalPlan(_selectedChild!)
                    : _buildSelectChildPrompt(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChildSelector(List<NinoModel> ninos) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green.shade50,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.green.shade700,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.restaurant_menu,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Plan Personalizado',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2E7D32),
                      ),
                    ),
                    Text(
                      'Selecciona el niño para ver su plan',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF558B2F),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.green.shade200,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: DropdownButtonFormField<NinoModel>(
              initialValue: _selectedChild,
              decoration: InputDecoration(
                hintText: '👶 Selecciona un niño',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 15,
                ),
                prefixIcon: Icon(
                  Icons.child_care,
                  color: Colors.green.shade600,
                  size: 24,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 16,
                ),
              ),
              dropdownColor: Colors.white,
              items: ninos.map((nino) {
                return DropdownMenuItem<NinoModel>(
                  value: nino,
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: nino.sexo == 'Masculino'
                              ? Colors.blue.shade50
                              : Colors.pink.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          nino.sexo == 'Masculino' ? Icons.boy : Icons.girl,
                          color: nino.sexo == 'Masculino'
                              ? Colors.blue.shade700
                              : Colors.pink.shade700,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              nino.nombreCompleto,
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${nino.edad} años',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (nino) {
                setState(() {
                  _selectedChild = nino;
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectChildPrompt() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.green.shade50,
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade100,
                    Colors.green.shade50,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.restaurant_menu_rounded,
                size: 80,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '🍎 Plan Nutricional',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Selecciona un niño arriba para ver\nsu plan nutricional personalizado',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.green.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.green.shade700,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Basado en el diagnóstico de anemia',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w500,
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

  Widget _buildNutritionalPlan(NinoModel nino) {
    try {
      final riesgoAnemia = nino.evaluacionAnemia ?? 'Riesgo bajo de anemia';
      
      debugPrint('🍎 DEBUG Plan: Construyendo plan para ${nino.nombreCompleto}');
      debugPrint('🍎 DEBUG Plan: Riesgo anemia: $riesgoAnemia');
      debugPrint('🍎 DEBUG Plan: Diagnostico riesgo: ${nino.diagnosticoAnemiaRiesgo}');

      return SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header informativo
            _buildPlanHeader(nino, riesgoAnemia),

            // Botón de descarga PDF
            Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 24),
            height: 60,
            decoration: BoxDecoration(
              gradient: _isGeneratingPDF
                  ? LinearGradient(
                      colors: [
                        Colors.grey.shade400,
                        Colors.grey.shade500,
                      ],
                    )
                  : LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.green.shade600,
                        Colors.green.shade700,
                        Colors.green.shade800,
                      ],
                    ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: _isGeneratingPDF
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 6),
                        spreadRadius: 1,
                      ),
                    ],
            ),
            child: ElevatedButton.icon(
              onPressed:
                  _isGeneratingPDF ? null : () => _downloadPlanAsPDF(nino),
              icon: _isGeneratingPDF
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.picture_as_pdf_rounded,
                      size: 26,
                    ),
              label: Text(
                _isGeneratingPDF
                    ? 'Generando PDF...'
                    : '📥 Descargar Plan en PDF',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.white,
                shadowColor: Colors.transparent,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 24,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          // Plan nutricional según riesgo
          _buildPlanByRisk(riesgoAnemia, nino),
          const SizedBox(height: 24),

          // Recomendaciones generales
          _buildGeneralRecommendations(),
          const SizedBox(height: 24),

          // Alimentos ricos en hierro
          _buildIronRichFoods(),
        ],
      ),
    );
    } catch (e, stackTrace) {
      debugPrint('❌ ERROR en _buildNutritionalPlan: $e');
      debugPrint('❌ Stack trace: $stackTrace');
      return Center(
        child: Container(
          margin: const EdgeInsets.all(20),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red.shade200),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, color: Colors.red.shade700, size: 48),
              const SizedBox(height: 16),
              Text(
                'Error al cargar el plan nutricional',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                e.toString(),
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.red.shade600),
              ),
            ],
          ),
        ),
      );
    }
  }

  Future<void> _downloadPlanAsPDF(NinoModel nino) async {
    try {
      setState(() {
        _isGeneratingPDF = true;
      });

      // Obtener datos del plan según el riesgo
      final planData =
          _getPlanDataForPDF(nino.evaluacionAnemia ?? 'Riesgo bajo de anemia');

      // Generar PDF
      final pdfFile = await PdfGeneratorService.generateNutritionalPlanPDF(
        childName: nino.nombreCompleto,
        age: nino.edad.toString(),
        riskLevel: nino.evaluacionAnemia ?? 'Riesgo bajo de anemia',
        classification: nino.clasificacionIMC ?? 'Sin clasificación',
        planType: planData['planType']![0],
        immediateActions: planData['immediateActions']!,
        dailyFoods: planData['dailyFoods']!,
        menuExample: planData['menuExample']!,
        supplements: planData['supplements']!,
      );

      // Abrir el PDF
      await OpenFile.open(pdfFile.path);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('PDF generado exitosamente'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al generar PDF: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isGeneratingPDF = false;
        });
      }
    }
  }

  // Método para obtener datos del plan
  Map<String, List<String>> _getPlanDataForPDF(String riesgoAnemia) {
    if (riesgoAnemia.contains('Alta Probabilidad')) {
      return {
        'planType': ['Plan de Intervención - Prioridad Hierro'],
        'immediateActions': [
          'Consulta inmediata con pediatra para evaluación completa',
          'Exámenes de hemoglobina y ferritina recomendados',
          'Suplementación con hierro bajo supervisión médica',
          'Seguimiento nutricional cada 15 días'
        ],
        'dailyFoods': [
          '2 porciones de carne roja magra (res, hígado)',
          '1 porción de legumbres (lentejas, frijoles)',
          'Verduras de hoja verde en cada comida principal',
          '1 fruta cítrica con cada comida para mejorar absorción',
          'Evitar té, café o lácteos cerca de las comidas con hierro'
        ],
        'menuExample': [
          'Desayuno: Avena con hígado picado + jugo de naranja natural',
          'Almuerzo: Lentejas guisadas con carne molida + ensalada de espinacas',
          'Cena: Pescado al horno con brócoli + kiwi',
          'Snacks: Nueces, pasas, yogurt fortificado con hierro'
        ],
        'supplements': [
          'Hierro quelado o sulfato ferroso (dosis según prescripción médica)',
          'Vitamina C para mejorar la absorción del hierro',
          'Complejo B complementario',
          'Probióticos para mejorar salud intestinal'
        ],
      };
    } else if (riesgoAnemia.contains('Riesgo moderado')) {
      return {
        'planType': ['Plan Preventivo - Fortalecimiento Nutricional'],
        'immediateActions': [
          'Control pediátrico para evaluación inicial',
          'Monitoreo de signos de mejoría o empeoramiento',
          'Implementar cambios dietéticos progresivos'
        ],
        'dailyFoods': [
          '1 porción diaria de proteína animal (carne, pollo, pescado)',
          'Legumbres 4-5 veces por semana en comidas principales',
          'Verduras verdes en almuerzo y cena',
          'Frutos secos como snacks saludables entre comidas',
          'Limitar alimentos que inhiben absorción de hierro'
        ],
        'menuExample': [
          'Desayuno: Huevos revueltos + pan integral + mandarina',
          'Almuerzo: Pollo guisado con espinacas + lentejas',
          'Cena: Atún con brócoli al vapor + fresas',
          'Snacks: Almendras, yogurt natural, galletas integrales'
        ],
        'supplements': [
          'Multivitamínico pediátrico si es recomendado por médico',
          'Suplemento de hierro preventivo en temporada de crecimiento'
        ],
      };
    } else {
      return {
        'planType': ['Plan de Mantenimiento - Salud Óptima'],
        'immediateActions': [
          'Mantener controles pediátricos regulares',
          'Conservar hábitos alimentarios saludables',
          'Promover actividad física y descanso adecuado'
        ],
        'dailyFoods': [
          'Variedad de alimentos de todos los grupos diariamente',
          'Proteínas: 2-3 porciones diarias variadas',
          'Frutas y verduras de diferentes colores',
          'Granos integrales y legumbres regularmente',
          'Lácteos o alternativas fortificadas'
        ],
        'menuExample': [
          'Desayuno: Cereal integral con leche + plátano + nueces',
          'Almuerzo: Pescado a la plancha + arroz integral + ensalada mixta',
          'Cena: Pollo al horno + quinoa + vegetales al vapor',
          'Snacks: Frutas frescas, palitos de zanahoria, queso'
        ],
        'supplements': [],
      };
    }
  }

  Widget _buildPlanHeader(NinoModel nino, String riesgoAnemia) {
    Color riskColor = _getRiskColor(riesgoAnemia);
    IconData riskIcon = _getRiskIcon(riesgoAnemia);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            riskColor.withValues(alpha: 0.15),
            riskColor.withValues(alpha: 0.05),
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: riskColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: riskColor.withValues(alpha: 0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Stack(
        children: [
          // Decoración de fondo
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: riskColor.withValues(alpha: 0.05),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            nino.sexo == 'Masculino'
                                ? Colors.blue.shade400
                                : Colors.pink.shade400,
                            nino.sexo == 'Masculino'
                                ? Colors.blue.shade600
                                : Colors.pink.shade600,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (nino.sexo == 'Masculino'
                                    ? Colors.blue
                                    : Colors.pink)
                                .withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        nino.sexo == 'Masculino' ? Icons.boy : Icons.girl,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            nino.nombreCompleto,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1B5E20),
                              letterSpacing: 0.3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.cake_outlined,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${nino.edad} años',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Icon(
                                Icons.monitor_weight_outlined,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  nino.clasificacionIMC ?? "Sin clasificación",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        riskColor.withValues(alpha: 0.25),
                        riskColor.withValues(alpha: 0.15),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: riskColor.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        riskIcon,
                        color: riskColor,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Flexible(
                        child: Text(
                          riesgoAnemia,
                          style: TextStyle(
                            color: riskColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getRiskIcon(String riesgoAnemia) {
    final riesgoLower = riesgoAnemia.toLowerCase();
    if (riesgoLower.contains('alta') || riesgoLower.contains('alto')) {
      return Icons.warning_rounded;
    } else if (riesgoLower.contains('moderado') || riesgoLower.contains('media') || riesgoLower.contains('medio')) {
      return Icons.info_rounded;
    } else {
      return Icons.check_circle_rounded;
    }
  }

  Widget _buildPlanByRisk(String riesgoAnemia, NinoModel nino) {
    debugPrint('🔍 DEBUG: Evaluando riesgo: "$riesgoAnemia"');
    final riesgoLower = riesgoAnemia.toLowerCase();
    if (riesgoLower.contains('alta') || riesgoLower.contains('alto')) {
      debugPrint('✅ Mostrando plan de ALTO riesgo');
      return _buildHighRiskPlan(nino);
    } else if (riesgoLower.contains('moderado') || riesgoLower.contains('media') || riesgoLower.contains('medio')) {
      debugPrint('✅ Mostrando plan de riesgo MODERADO');
      return _buildMediumRiskPlan(nino);
    } else {
      debugPrint('✅ Mostrando plan de riesgo BAJO');
      return _buildLowRiskPlan(nino);
    }
  }

  Widget _buildHighRiskPlan(NinoModel nino) {
    return _buildPlanCard(
      title: 'Plan Nutricional - Prioridad Hierro',
      color: Colors.red,
      icon: Icons.warning,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanSection(
            '🚨 Acción Inmediata:',
            [
              'Consulta con pediatra para evaluación completa',
              'Exámenes de hemoglobina recomendados',
              'Suplementación bajo supervisión médica'
            ],
          ),
          _buildPlanSection(
            '🍽️ Alimentación Diaria (Estricta):',
            [
              '2 porciones de carne roja magra (res, hígado)',
              '1 porción de legumbres (lentejas, frijoles)',
              'Verduras de hoja verde en cada comida',
              '1 fruta cítrica con cada comida principal',
              'Evitar té/café cerca de las comidas'
            ],
          ),
          _buildPlanSection(
            '📅 Menú Ejemplo:',
            [
              'Desayuno: Avena con hígado + jugo de naranja',
              'Almuerzo: Lentejas con carne + ensalada de espinacas',
              'Cena: Pescado con brócoli + kiwi',
              'Snacks: Nueces, pasas, yogurt fortificado'
            ],
          ),
          _buildPlanSection(
            '💊 Suplementos (bajo prescripción):',
            [
              'Hierro quelado o sulfato ferroso',
              'Vitamina C para mejorar absorción',
              'Complejo B complementario'
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMediumRiskPlan(NinoModel nino) {
    return _buildPlanCard(
      title: 'Plan Nutricional - Prevención Activa',
      color: Colors.orange,
      icon: Icons.health_and_safety,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanSection(
            '🎯 Objetivo Principal:',
            [
              'Prevenir desarrollo de anemia',
              'Mejorar reservas de hierro',
              'Fortalecer sistema inmunológico'
            ],
          ),
          _buildPlanSection(
            '🍽️ Alimentación Diaria:',
            [
              '1 porción diaria de proteína animal',
              'Legumbres 4-5 veces por semana',
              'Verduras verdes en almuerzo y cena',
              'Frutos secos como snacks saludables',
              'Limitar alimentos que inhiben absorción'
            ],
          ),
          _buildPlanSection(
            '📅 Menú Ejemplo:',
            [
              'Desayuno: Huevos + pan integral + mandarina',
              'Almuerzo: Pollo con espinacas + lentejas',
              'Cena: Atún con brócoli + fresas',
              'Snacks: Almendras, yogurt, galletas integrales'
            ],
          ),
          _buildPlanSection(
            '🔍 Monitoreo:',
            [
              'Control de peso y talla mensual',
              'Observar signos de mejoría/palidez',
              'Consulta pediátrica trimestral'
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLowRiskPlan(NinoModel nino) {
    return _buildPlanCard(
      title: 'Plan Nutricional - Mantenimiento Saludable',
      color: Colors.green,
      icon: Icons.thumb_up,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPlanSection(
            '✅ Estado Actual:',
            [
              'Buen estado nutricional',
              'Riesgo bajo de anemia',
              'Mantener hábitos saludables'
            ],
          ),
          _buildPlanSection(
            '🍽️ Alimentación Balanceada:',
            [
              'Variedad de alimentos todos los días',
              'Proteínas: 2-3 porciones diarias',
              'Frutas y verduras de diferentes colores',
              'Granos integrales y legumbres',
              'Lácteos o alternativas fortificadas'
            ],
          ),
          _buildPlanSection(
            '📅 Menú Ejemplo:',
            [
              'Desayuno: Cereal integral + leche + plátano',
              'Almuerzo: Pescado + arroz + ensalada mixta',
              'Cena: Pollo + quinoa + vegetales al vapor',
              'Snacks: Frutas, palitos de zanahoria, queso'
            ],
          ),
          _buildPlanSection(
            '💪 Prevención:',
            [
              'Mantener alimentación variada',
              'Actividad física regular',
              'Controles pediátricos anuales',
              'Educación en hábitos saludables'
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard({
    required String title,
    required Color color,
    required IconData icon,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            color.withValues(alpha: 0.03),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(0, 6),
            spreadRadius: 1,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        color.withValues(alpha: 0.15),
                        color.withValues(alpha: 0.08),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: color.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: color,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSection(String title, List<String> items) {
    final sectionColor = Colors.green.shade700;

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: sectionColor,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 12),
          ...items.asMap().entries.map((entry) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.green.withValues(alpha: 0.04),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.green.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.green.withValues(alpha: 0.2),
                            Colors.green.withValues(alpha: 0.1),
                          ],
                        ),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.green.withValues(alpha: 0.3),
                          width: 1.5,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          '${entry.key + 1}',
                          style: TextStyle(
                            color: sectionColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.5,
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildGeneralRecommendations() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.shade400,
                        Colors.blue.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.lightbulb_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Recomendaciones Generales',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade800,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildRecommendationItem(
              Icons.schedule_rounded,
              'Horarios regulares',
              'Mantener 3 comidas principales y 2 snacks saludables',
              Colors.blue,
            ),
            _buildRecommendationItem(
              Icons.water_drop_rounded,
              'Hidratación adecuada',
              '6-8 vasos de agua al día, evitar bebidas azucaradas',
              Colors.lightBlue,
            ),
            _buildRecommendationItem(
              Icons.restaurant_rounded,
              'Comer despacio',
              'Masticar bien facilita la digestión y absorción de nutrientes',
              Colors.cyan,
            ),
            _buildRecommendationItem(
              Icons.family_restroom_rounded,
              'Comer en familia',
              'Fomenta hábitos saludables y un ambiente positivo',
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIronRichFoods() {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.orange.shade50,
            Colors.white,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.orange.shade200,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.12),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade400,
                        Colors.deepOrange.shade600,
                      ],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.restaurant_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Alimentos Ricos en Hierro',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange.shade900,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _buildFoodChip('🥩 Hígado', Colors.red),
                _buildFoodChip('🍖 Carne roja', Colors.red.shade700),
                _buildFoodChip('🍗 Pollo', Colors.orange),
                _buildFoodChip('🐟 Pescado', Colors.blue),
                _buildFoodChip('🫘 Lentejas', Colors.brown),
                _buildFoodChip('🥬 Espinacas', Colors.green),
                _buildFoodChip('🌰 Frijoles', Colors.brown.shade700),
                _buildFoodChip('🥜 Nueces', Colors.amber.shade800),
                _buildFoodChip('🍇 Pasas', Colors.purple),
                _buildFoodChip('🥚 Huevo', Colors.amber),
                _buildFoodChip('🍞 Pan integral', Colors.brown.shade400),
                _buildFoodChip('🌿 Brócoli', Colors.green.shade700),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.amber.shade300,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.tips_and_updates_rounded,
                    color: Colors.amber.shade700,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Combina con vitamina C (cítricos) para mejorar la absorción de hierro hasta un 300%',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Colors.amber.shade900,
                        height: 1.4,
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

  Widget _buildRecommendationItem(
    IconData icon,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.2),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color.withValues(alpha: 0.15),
                  color.withValues(alpha: 0.08),
                ],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                    color: Colors.grey.shade900,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFoodChip(String food, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 10,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.15),
            color.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: color.withValues(alpha: 0.4),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.1),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        food,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
          letterSpacing: 0.3,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(50),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green.shade50,
              Colors.white,
              Colors.green.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.green.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withValues(alpha: 0.15),
              blurRadius: 25,
              offset: const Offset(0, 10),
              spreadRadius: 3,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade100,
                    Colors.green.shade200,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.no_food_rounded,
                size: 90,
                color: Colors.green.shade800,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              '¡Sin Planes Disponibles!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade900,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'No hay niños registrados en el sistema',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade700,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Registra un niño primero para crear\nplanes nutricionales personalizados',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 14,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade500,
                    Colors.green.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 22,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Ve a "Inicio" para registrar',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
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

  Color _getRiskColor(String riesgoAnemia) {
    final riesgoLower = riesgoAnemia.toLowerCase();
    if (riesgoLower.contains('alta') || riesgoLower.contains('alto')) {
      return Colors.red;
    } else if (riesgoLower.contains('moderado') || riesgoLower.contains('media') || riesgoLower.contains('medio')) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}
