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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Seleccionar Niño:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 8),
          DropdownButtonFormField<NinoModel>(
            value: _selectedChild,
            decoration: InputDecoration(
              hintText: 'Selecciona un niño',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
            ),
            items: ninos.map((nino) {
              return DropdownMenuItem<NinoModel>(
                value: nino,
                child: Row(
                  children: [
                    Icon(
                      nino.sexo == 'Masculino' ? Icons.boy : Icons.girl,
                      color: nino.sexo == 'Masculino' ? Colors.blue : Colors.pink,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      nino.nombreCompleto,
                      style: const TextStyle(fontSize: 14),
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
        ],
      ),
    );
  }

  Widget _buildSelectChildPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Selecciona un niño para ver su plan nutricional',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionalPlan(NinoModel nino) {
    final riesgoAnemia = nino.evaluacionAnemia ?? 'Riesgo bajo de anemia';
    
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
            margin: const EdgeInsets.symmetric(vertical: 16),
            child: ElevatedButton.icon(
              onPressed: _isGeneratingPDF ? null : () => _downloadPlanAsPDF(nino),
              icon: _isGeneratingPDF
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.download),
              label: Text(
                _isGeneratingPDF ? 'Generando PDF...' : 'Descargar Plan en PDF',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                disabledBackgroundColor: Colors.grey,
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
  }

  Future<void> _downloadPlanAsPDF(NinoModel nino) async {
    try {
      setState(() {
        _isGeneratingPDF = true;
      });

      // Obtener datos del plan según el riesgo
      final planData = _getPlanDataForPDF(nino.evaluacionAnemia ?? 'Riesgo bajo de anemia');
      
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
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [riskColor.withOpacity(0.1), riskColor.withOpacity(0.05)],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: riskColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: nino.sexo == 'Masculino' ? Colors.blue.shade100 : Colors.pink.shade100,
                child: Icon(
                  nino.sexo == 'Masculino' ? Icons.boy : Icons.girl,
                  color: nino.sexo == 'Masculino' ? Colors.blue : Colors.pink,
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
                      '${nino.edad} años • ${nino.clasificacionIMC ?? "Sin clasificación"}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: riskColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              riesgoAnemia,
              style: TextStyle(
                color: riskColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanByRisk(String riesgoAnemia, NinoModel nino) {
    if (riesgoAnemia.contains('Alta Probabilidad')) {
      return _buildHighRiskPlan(nino);
    } else if (riesgoAnemia.contains('Riesgo moderado')) {
      return _buildMediumRiskPlan(nino);
    } else {
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
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            content,
          ],
        ),
      ),
    );
  }

  Widget _buildPlanSection(String title, List<String> items) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => Padding(
            padding: const EdgeInsets.symmetric(vertical: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• ', style: TextStyle(fontSize: 16)),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 14, height: 1.4),
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
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 Recomendaciones Generales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildRecommendationItem(
              'Comer en horarios regulares',
              'Mantener 3 comidas principales y 2 snacks',
            ),
            _buildRecommendationItem(
              'Hidratación adecuada',
              '6-8 vasos de agua al día, evitar bebidas azucaradas',
            ),
            _buildRecommendationItem(
              'Comer despacio y masticar bien',
              'Facilita la digestión y absorción de nutrientes',
            ),
            _buildRecommendationItem(
              'Comer en familia',
              'Fomenta hábitos saludables y ambiente positivo',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIronRichFoods() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🥩 Alimentos Ricos en Hierro',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildFoodChip('Hígado', Colors.red),
                _buildFoodChip('Carne roja', Colors.red),
                _buildFoodChip('Pollo', Colors.orange),
                _buildFoodChip('Pescado', Colors.blue),
                _buildFoodChip('Lentejas', Colors.brown),
                _buildFoodChip('Espinacas', Colors.green),
                _buildFoodChip('Frijoles', Colors.brown),
                _buildFoodChip('Nueces', Colors.amber),
                _buildFoodChip('Pasas', Colors.purple),
                _buildFoodChip('Yema de huevo', Colors.yellow),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              '💡 Tip: Combina con vitamina C (cítricos) para mejor absorción',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationItem(String title, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
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
  }

  Widget _buildFoodChip(String food, Color color) {
    return Chip(
      label: Text(
        food,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
      labelStyle: TextStyle(color: color),
      side: BorderSide(color: color.withOpacity(0.3)),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.child_care, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'No hay niños registrados',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            'Registra un niño para ver su plan nutricional',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Color _getRiskColor(String riesgoAnemia) {
    if (riesgoAnemia.contains('Alta Probabilidad')) {
      return Colors.red;
    } else if (riesgoAnemia.contains('Riesgo moderado')) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
}