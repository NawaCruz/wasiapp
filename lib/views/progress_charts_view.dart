// views/progress_charts_view.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/nino_controller.dart';
import '../models/nino_model.dart';

class ProgressChartsView extends StatefulWidget {
  const ProgressChartsView({super.key});

  @override
  State<ProgressChartsView> createState() => _ProgressChartsViewState();
}

class _ProgressChartsViewState extends State<ProgressChartsView> {
  NinoModel? _selectedChild;
  String _selectedChart = 'Peso';
  final List<String> _chartTypes = ['Peso', 'Talla', 'Riesgo'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso y Gráficos'),
        backgroundColor: Colors.purple.shade700,
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
              // Selector de niño y tipo de gráfico
              _buildControls(ninos),
              
              // Gráficos
              Expanded(
                child: _selectedChild != null 
                    ? _buildCharts(_selectedChild!)
                    : _buildSelectChildPrompt(),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildControls(List<NinoModel> ninos) {
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
        children: [
          // Selector de niño
          Row(
            children: [
              const Icon(Icons.child_care, color: Colors.purple),
              const SizedBox(width: 8),
              const Text(
                'Niño:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<NinoModel>(
                  value: _selectedChild,
                  isExpanded: true,
                  hint: const Text('Selecciona un niño'),
                  items: ninos.map((nino) {
                    return DropdownMenuItem<NinoModel>(
                      value: nino,
                      child: Text(nino.nombreCompleto),
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
          const SizedBox(height: 12),
          
          // Selector de tipo de gráfico
          Row(
            children: [
              const Icon(Icons.analytics, color: Colors.purple, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Gráfico:',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButton<String>(
                  value: _selectedChart,
                  isExpanded: true,
                  items: _chartTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type,
                      child: Text(type),
                    );
                  }).toList(),
                  onChanged: (type) {
                    setState(() {
                      _selectedChart = type!;
                    });
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCharts(NinoModel nino) {
    final progressData = _generateSampleData(nino);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Header informativo
          _buildChildHeader(nino),
          const SizedBox(height: 20),
          
          // Gráfico seleccionado
          _buildSelectedChart(progressData),
          const SizedBox(height: 20),
          
          // Tabla de datos
          _buildDataTable(progressData),
          const SizedBox(height: 20),
          
          // Resumen de progreso
          _buildProgressSummary(nino, progressData),
        ],
      ),
    );
  }

  Widget _buildChildHeader(NinoModel nino) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.purple.shade50, Colors.purple.shade100],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.purple.shade200),
      ),
      child: Row(
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
                    color: Colors.purple,
                  ),
                ),
                Text(
                  '${nino.edad} años • ${nino.clasificacionIMC ?? "Sin clasificación"}',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                if (nino.evaluacionAnemia != null)
                  Text(
                    'Riesgo de anemia: ${nino.evaluacionAnemia}',
                    style: TextStyle(
                      fontSize: 12,
                      color: _getRiskColor(nino.evaluacionAnemia!),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectedChart(List<ProgressData> data) {
    switch (_selectedChart) {
      case 'Peso':
        return _buildWeightChart(data);
      case 'Talla':
        return _buildHeightChart(data);
      case 'Riesgo':
        return _buildRiskChart(data);
      default:
        return _buildWeightChart(data);
    }
  }

  Widget _buildWeightChart(List<ProgressData> data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.monitor_weight, color: Colors.blue),
                SizedBox(width: 8),
                Text(
                  '📊 Evolución de Peso (kg)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildLineChart(
                data,
                (d) => d.weight,
                'kg',
                Colors.blue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightChart(List<ProgressData> data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.height, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  '📈 Evolución de Talla (cm)',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildLineChart(
                data,
                (d) => d.height,
                'cm',
                Colors.green,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskChart(List<ProgressData> data) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.health_and_safety, color: Colors.orange),
                SizedBox(width: 8),
                Text(
                  '🩺 Evolución del Riesgo de Anemia',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: _buildBarChart(data),
            ),
            const SizedBox(height: 8),
            _buildRiskLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(
    List<ProgressData> data,
    double Function(ProgressData) valueGetter,
    String unit,
    Color color,
  ) {
    final maxValue = data.map(valueGetter).reduce((a, b) => a > b ? a : b);
    final minValue = data.map(valueGetter).reduce((a, b) => a < b ? a : b);
    
    return Stack(
      children: [
        // Línea de fondo
        Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade300),
              left: BorderSide(color: Colors.grey.shade300),
            ),
          ),
        ),
        
        // Línea del gráfico
        CustomPaint(
          size: const Size(double.infinity, 200),
          painter: _LineChartPainter(
            data: data,
            valueGetter: valueGetter,
            maxValue: maxValue,
            minValue: minValue,
            color: color,
            unit: unit,
          ),
        ),
      ],
    );
  }

  Widget _buildBarChart(List<ProgressData> data) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: data.length,
      itemBuilder: (context, index) {
        final item = data[index];
        final riskColor = _getRiskColorFromLevel(item.riskLevel);
        final height = (item.riskLevel / 10) * 150; // Escala 0-10 a altura
        
        return Container(
          width: 60,
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                _getRiskDescription(item.riskLevel),
                style: const TextStyle(fontSize: 10),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Container(
                height: height,
                width: 40,
                decoration: BoxDecoration(
                  color: riskColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    item.riskLevel.toStringAsFixed(1),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.date,
                style: const TextStyle(fontSize: 10),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDataTable(List<ProgressData> data) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 Datos de Progreso',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                columns: const [
                  DataColumn(label: Text('Fecha')),
                  DataColumn(label: Text('Peso (kg)')),
                  DataColumn(label: Text('Talla (cm)')),
                  DataColumn(label: Text('Riesgo')),
                ],
                rows: data.map((item) {
                  return DataRow(cells: [
                    DataCell(Text(item.date)),
                    DataCell(Text(item.weight.toStringAsFixed(1))),
                    DataCell(Text(item.height.toStringAsFixed(1))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getRiskColorFromLevel(item.riskLevel).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getRiskDescription(item.riskLevel),
                          style: TextStyle(
                            color: _getRiskColorFromLevel(item.riskLevel),
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressSummary(NinoModel nino, List<ProgressData> data) {
    if (data.length < 2) return const SizedBox();
    
    final firstData = data.first;
    final lastData = data.last;
    final weightChange = lastData.weight - firstData.weight;
    final heightChange = lastData.height - firstData.height;
    final riskChange = lastData.riskLevel - firstData.riskLevel;

    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📈 Resumen del Progreso',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.purple,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _buildSummaryItem(
                  'Peso',
                  '${weightChange.toStringAsFixed(1)} kg',
                  weightChange >= 0 ? Colors.green : Colors.red,
                  weightChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                ),
                _buildSummaryItem(
                  'Talla',
                  '${heightChange.toStringAsFixed(1)} cm',
                  Colors.green,
                  Icons.arrow_upward,
                ),
                _buildSummaryItem(
                  'Riesgo',
                  riskChange < 0 ? 'Mejoró' : 'Aumentó',
                  riskChange < 0 ? Colors.green : Colors.orange,
                  riskChange < 0 ? Icons.arrow_downward : Icons.arrow_upward,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              'Período: ${firstData.date} - ${lastData.date}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRiskLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _buildLegendItem('Bajo (1-3)', Colors.green),
        _buildLegendItem('Moderado (4-7)', Colors.orange),
        _buildLegendItem('Alto (8-10)', Colors.red),
      ],
    );
  }

  Widget _buildLegendItem(String text, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(
          text,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildSelectChildPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text(
            'Selecciona un niño para ver sus gráficos de progreso',
            style: TextStyle(fontSize: 16, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
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
            'Registra un niño para ver sus gráficos de progreso',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // Métodos auxiliares
  List<ProgressData> _generateSampleData(NinoModel nino) {
    return [
      ProgressData('Ene', nino.peso - 1.5, nino.talla - 3, 7),
      ProgressData('Feb', nino.peso - 1.0, nino.talla - 2, 6),
      ProgressData('Mar', nino.peso - 0.5, nino.talla - 1, 5),
      ProgressData('Abr', nino.peso, nino.talla, 4),
      ProgressData('May', nino.peso + 0.3, nino.talla + 0.5, 3),
      ProgressData('Jun', nino.peso + 0.8, nino.talla + 1.2, 2),
    ];
  }

  Color _getRiskColor(String riskLevel) {
    if (riskLevel.contains('Alta Probabilidad')) return Colors.red;
    if (riskLevel.contains('Riesgo moderado')) return Colors.orange;
    return Colors.green;
  }

  Color _getRiskColorFromLevel(double riskLevel) {
    if (riskLevel >= 8) return Colors.red;
    if (riskLevel >= 4) return Colors.orange;
    return Colors.green;
  }

  String _getRiskDescription(double riskLevel) {
    if (riskLevel >= 8) return 'Alto';
    if (riskLevel >= 4) return 'Moderado';
    return 'Bajo';
  }
}

// Painter para el gráfico de líneas
class _LineChartPainter extends CustomPainter {
  final List<ProgressData> data;
  final double Function(ProgressData) valueGetter;
  final double maxValue;
  final double minValue;
  final Color color;
  final String unit;

  _LineChartPainter({
    required this.data,
    required this.valueGetter,
    required this.maxValue,
    required this.minValue,
    required this.color,
    required this.unit,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final dotPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final textStyle = TextStyle(
      color: Colors.grey.shade700,
      fontSize: 10,
    );

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    if (data.length < 2) return;

    final range = maxValue - minValue;
    final heightRatio = size.height / (range == 0 ? 1 : range);

    // Dibujar línea
    final path = Path();
    for (int i = 0; i < data.length; i++) {
      final x = (i / (data.length - 1)) * size.width;
      final value = valueGetter(data[i]);
      final y = size.height - ((value - minValue) * heightRatio);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      // Dibujar puntos
      canvas.drawCircle(Offset(x, y), 4, dotPaint);

      // Dibujar etiquetas
      final text = '${value.toStringAsFixed(1)}$unit';
      textPainter.text = TextSpan(text: text, style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - 20),
      );

      // Dibujar fechas
      final dateText = data[i].date;
      textPainter.text = TextSpan(text: dateText, style: textStyle);
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height - 15),
      );
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Modelo para datos de progreso
class ProgressData {
  final String date;
  final double weight;
  final double height;
  final double riskLevel;

  ProgressData(this.date, this.weight, this.height, this.riskLevel);
}