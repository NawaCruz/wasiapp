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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.purple.shade50,
            Colors.white,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          // Selector de niño
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.purple.shade200),
              boxShadow: [
                BoxShadow(
                  color: Colors.purple.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.child_care, color: Colors.purple.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Niño:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: DropdownButton<NinoModel>(
                    value: _selectedChild,
                    isExpanded: true,
                    underline: const SizedBox(),
                    hint: Text(
                      'Selecciona un niño',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    items: ninos.map((nino) {
                      return DropdownMenuItem<NinoModel>(
                        value: nino,
                        child: Row(
                          children: [
                            Icon(
                              nino.sexo == 'Masculino' ? Icons.boy : Icons.girl,
                              size: 18,
                              color: nino.sexo == 'Masculino' ? Colors.blue : Colors.pink,
                            ),
                            const SizedBox(width: 8),
                            Text(nino.nombreCompleto),
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
          ),
          const SizedBox(height: 16),

          // Selector de tipo de gráfico con chips
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.analytics, color: Colors.purple.shade700, size: 18),
              ),
              const SizedBox(width: 12),
              const Text(
                'Gráfico:',
                style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _chartTypes.map((type) {
                      final isSelected = _selectedChart == type;
                      IconData icon;
                      Color color;
                      
                      switch (type) {
                        case 'Peso':
                          icon = Icons.monitor_weight;
                          color = Colors.blue;
                          break;
                        case 'Talla':
                          icon = Icons.height;
                          color = Colors.green;
                          break;
                        case 'Riesgo':
                          icon = Icons.health_and_safety;
                          color = Colors.orange;
                          break;
                        default:
                          icon = Icons.analytics;
                          color = Colors.purple;
                      }

                      return Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: FilterChip(
                          selected: isSelected,
                          label: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                icon,
                                size: 16,
                                color: isSelected ? Colors.white : color,
                              ),
                              const SizedBox(width: 6),
                              Text(type),
                            ],
                          ),
                          backgroundColor: Colors.white,
                          selectedColor: color,
                          checkmarkColor: Colors.white,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.grey.shade700,
                            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                          ),
                          side: BorderSide(
                            color: isSelected ? color : Colors.grey.shade300,
                          ),
                          onSelected: (selected) {
                            setState(() {
                              _selectedChart = type;
                            });
                          },
                        ),
                      );
                    }).toList(),
                  ),
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: nino.sexo == 'Masculino'
                    ? [Colors.blue.shade100, Colors.blue.shade200]
                    : [Colors.pink.shade100, Colors.pink.shade200],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (nino.sexo == 'Masculino' ? Colors.blue : Colors.pink)
                      .withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: CircleAvatar(
              radius: 28,
              backgroundColor: nino.sexo == 'Masculino'
                  ? Colors.blue.shade50
                  : Colors.pink.shade50,
              child: Icon(
                nino.sexo == 'Masculino' ? Icons.boy : Icons.girl,
                color: nino.sexo == 'Masculino' ? Colors.blue.shade700 : Colors.pink.shade700,
                size: 32,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  nino.nombreCompleto,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.cake, size: 14, color: Colors.grey.shade600),
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
                    Icon(Icons.monitor_weight, size: 14, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        nino.clasificacionIMC ?? "Sin clasificación",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
                if (nino.evaluacionAnemia != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getRiskColor(nino.evaluacionAnemia!).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: _getRiskColor(nino.evaluacionAnemia!).withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.health_and_safety,
                          size: 14,
                          color: _getRiskColor(nino.evaluacionAnemia!),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          nino.evaluacionAnemia!,
                          style: TextStyle(
                            fontSize: 12,
                            color: _getRiskColor(nino.evaluacionAnemia!),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.blue.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.blue.shade400, Colors.blue.shade600],
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
                  child: const Icon(Icons.monitor_weight, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  '📊 Evolución de Peso (kg)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.green.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.green.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.green.shade400, Colors.green.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.height, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  '📈 Evolución de Talla (cm)',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
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
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.orange.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.orange.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.deepOrange.shade600],
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
                  child: const Icon(Icons.health_and_safety, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  '🩺 Evolución del Riesgo de Anemia',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.orange,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildBarChart(data),
            ),
            const SizedBox(height: 12),
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
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
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
                    color: Colors.purple.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.table_chart, color: Colors.purple.shade700, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  '📋 Datos de Progreso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: WidgetStateProperty.all(Colors.purple.shade50),
                columns: [
                  DataColumn(
                    label: Text(
                      'Fecha',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Peso (kg)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Talla (cm)',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                  ),
                  DataColumn(
                    label: Text(
                      'Riesgo',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.purple.shade800,
                      ),
                    ),
                  ),
                ],
                rows: data.map((item) {
                  return DataRow(cells: [
                    DataCell(Text(
                      item.date,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    )),
                    DataCell(Text(
                      item.weight.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    )),
                    DataCell(Text(
                      item.height.toStringAsFixed(1),
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    )),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getRiskColorFromLevel(item.riskLevel).withValues(alpha: 0.2),
                              _getRiskColorFromLevel(item.riskLevel).withValues(alpha: 0.1),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getRiskColorFromLevel(item.riskLevel).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Text(
                          _getRiskDescription(item.riskLevel),
                          style: TextStyle(
                            color: _getRiskColorFromLevel(item.riskLevel),
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
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

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Colors.purple.shade50, Colors.white],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.purple.shade200, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.purple.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, 8),
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
                      colors: [Colors.purple.shade400, Colors.purple.shade600],
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.purple.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.trending_up, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                const Text(
                  '📈 Resumen del Progreso',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                _buildSummaryItem(
                  'Peso',
                  '${weightChange >= 0 ? '+' : ''}${weightChange.toStringAsFixed(1)} kg',
                  weightChange >= 0 ? Colors.green : Colors.red,
                  weightChange >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                ),
                _buildSummaryItem(
                  'Talla',
                  '+${heightChange.toStringAsFixed(1)} cm',
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
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.purple.shade100),
              ),
              child: Row(
                children: [
                  Icon(Icons.calendar_month, size: 16, color: Colors.purple.shade700),
                  const SizedBox(width: 8),
                  Text(
                    'Período: ${firstData.date} - ${lastData.date}',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.purple.shade700,
                      fontWeight: FontWeight.w600,
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

  Widget _buildSummaryItem(
      String title, String value, Color color, IconData icon) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3), width: 2),
          boxShadow: [
            BoxShadow(
              color: color.withValues(alpha: 0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    color.withValues(alpha: 0.2),
                    color.withValues(alpha: 0.1),
                  ],
                ),
                shape: BoxShape.circle,
                border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
                letterSpacing: 0.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
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
      child: Container(
        margin: const EdgeInsets.all(40),
        padding: const EdgeInsets.all(40),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.purple.shade50,
              Colors.white,
            ],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.1),
              blurRadius: 20,
              offset: const Offset(0, 8),
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
                    Colors.purple.shade100,
                    Colors.purple.shade50,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.2),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Icon(
                Icons.analytics_rounded,
                size: 80,
                color: Colors.purple.shade700,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              '📊 Gráficos de Progreso',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Selecciona un niño arriba para ver\nsus gráficos de evolución',
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
                color: Colors.purple.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.purple.shade200,
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 18,
                    color: Colors.purple.shade700,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'Monitorea peso, talla y riesgo',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.purple.shade700,
                        fontWeight: FontWeight.w500,
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
              Colors.purple.shade50,
              Colors.white,
              Colors.purple.shade50,
            ],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: Colors.purple.shade200,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.15),
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
                    Colors.purple.shade100,
                    Colors.purple.shade200,
                  ],
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.25),
                    blurRadius: 20,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Icon(
                Icons.analytics_outlined,
                size: 90,
                color: Colors.purple.shade800,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              '¡Sin Datos de Progreso!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.purple.shade900,
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
              'Registra un niño primero para ver\nsus gráficos de evolución',
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
                    Colors.purple.shade500,
                    Colors.purple.shade700,
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.add_circle_outline,
                    color: Colors.white,
                    size: 22,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Ve a "Inicio" para registrar',
                    style: TextStyle(
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
