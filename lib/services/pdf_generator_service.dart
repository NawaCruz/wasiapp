// services/pdf_generator_service.dart
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

class PdfGeneratorService {
  static Future<File> generateNutritionalPlanPDF({
    required String childName,
    required String age,
    required String riskLevel,
    required String classification,
    required String planType,
    required List<String> immediateActions,
    required List<String> dailyFoods,
    required List<String> menuExample,
    required List<String> supplements,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        theme: pw.ThemeData.withFont(
          base: pw.Font.courier(),
          bold: pw.Font.courierBold(),
        ),
        build: (context) => [
          _buildHeader(childName, age, riskLevel, classification),
          pw.SizedBox(height: 20),
          _buildRiskSection(riskLevel, planType),
          pw.SizedBox(height: 15),
          _buildPlanSections(immediateActions, dailyFoods, menuExample, supplements),
          pw.SizedBox(height: 20),
          _buildFooter(),
        ],
      ),
    );

    return _savePDF(pdf, childName);
  }

  static pw.Widget _buildHeader(
    String childName,
    String age,
    String riskLevel,
    String classification,
  ) {
    final riskColor = _getRiskColor(riskLevel);
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Container(
              width: 60,
              height: 60,
              decoration: pw.BoxDecoration(
                color: PdfColors.blue100,
                shape: pw.BoxShape.circle,
              ),
              child: pw.Center(
                child: pw.Text(
                  '👶',
                  style: pw.TextStyle(fontSize: 20),
                ),
              ),
            ),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text(
                    'PLAN NUTRICIONAL PERSONALIZADO',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    ),
                  ),
                  pw.Text(
                    'WasiApp - Control Nutricional Infantil',
                    style: pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        pw.Divider(thickness: 2, color: PdfColors.blue400),
        pw.SizedBox(height: 10),
        pw.Row(
          children: [
            pw.Container(
              width: 40,
              height: 40,
              decoration: pw.BoxDecoration(
                color: PdfColors.blue50,
                shape: pw.BoxShape.circle,
              ),
              child: pw.Center(
                child: pw.Text(
                  '👦',
                  style: pw.TextStyle(fontSize: 16),
                ),
              ),
            ),
            pw.SizedBox(width: 10),
            pw.Expanded(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    childName,
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.Text(
                    '$age años • $classification',
                    style: pw.TextStyle(
                      fontSize: 12,
                      color: PdfColors.grey600,
                    ),
                  ),
                ],
              ),
            ),
            pw.Container(
              padding: const pw.EdgeInsets.all(8),
              decoration: pw.BoxDecoration(
                color: _getRiskBackgroundColor(riskLevel),
                borderRadius: pw.BorderRadius.circular(20),
                border: pw.Border.all(color: riskColor),
              ),
              child: pw.Text(
                riskLevel,
                style: pw.TextStyle(
                  fontSize: 10,
                  color: riskColor,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildRiskSection(String riskLevel, String planType) {
    final riskColor = _getRiskColor(riskLevel);
    
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: _getRiskBackgroundColor(riskLevel),
        borderRadius: pw.BorderRadius.circular(10),
        border: pw.Border.all(color: riskColor),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Tipo de Plan: $planType',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: riskColor,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            _getRiskDescription(riskLevel),
            style: pw.TextStyle(
              fontSize: 10,
              color: PdfColors.grey700,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildPlanSections(
    List<String> immediateActions,
    List<String> dailyFoods,
    List<String> menuExample,
    List<String> supplements,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        if (immediateActions.isNotEmpty)
          _buildSection('🚨 Acciones Inmediatas', immediateActions),
        
        _buildSection('🍽️ Alimentación Diaria Recomendada', dailyFoods),
        
        _buildSection('📅 Menú de Ejemplo', menuExample),
        
        if (supplements.isNotEmpty)
          _buildSection('💊 Suplementos Recomendados', supplements),
        
        _buildSection('📋 Recomendaciones Generales', [
          'Mantener horarios regulares de comida',
          'Beber 6-8 vasos de agua al día',
          'Comer despacio y masticar bien los alimentos',
          'Incluir variedad de colores en cada comida',
          'Realizar actividad física diaria',
          'Dormir 8-10 horas diarias',
        ]),
        
        _buildSection('🥩 Alimentos Ricos en Hierro', [
          'Carnes rojas magras',
          'Hígado de res/pollo',
          'Pescado y mariscos',
          'Lentejas, frijoles, garbanzos',
          'Espinacas, acelgas, brócoli',
          'Nueces y almendras',
          'Yema de huevo',
          'Cereales fortificados',
        ]),
      ],
    );
  }

  static pw.Widget _buildSection(String title, List<String> items) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 15),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            title,
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 8),
          ...items.map((item) => pw.Padding(
            padding: const pw.EdgeInsets.only(bottom: 4),
            child: pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('• ', style: pw.TextStyle(fontSize: 10)),
                pw.Expanded(
                  child: pw.Text(
                    item,
                    style: pw.TextStyle(fontSize: 10, lineSpacing: 1.2),
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter() {
    return pw.Container(
      width: double.infinity,
      padding: const pw.EdgeInsets.all(15),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: pw.BorderRadius.circular(10),
      ),
      child: pw.Column(
        children: [
          pw.Text(
            '💡 Recomendaciones Importantes',
            style: pw.TextStyle(
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.blue800,
            ),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            'Este plan es una guía general. Consulte siempre con su pediatra o nutricionista '
            'para ajustes específicos según las necesidades individuales del niño. '
            'La suplementación con hierro debe ser supervisada por un profesional de la salud.',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey600,
              lineSpacing: 1.3,
            ),
            textAlign: pw.TextAlign.center,
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            'Generado por WasiApp - ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}',
            style: pw.TextStyle(
              fontSize: 8,
              color: PdfColors.grey500,
            ),
          ),
        ],
      ),
    );
  }

  static PdfColor _getRiskColor(String riskLevel) {
    if (riskLevel.contains('Alta Probabilidad')) {
      return PdfColors.red;
    } else if (riskLevel.contains('Riesgo moderado')) {
      return PdfColors.orange;
    } else {
      return PdfColors.green;
    }
  }

  static PdfColor _getRiskBackgroundColor(String riskLevel) {
    if (riskLevel.contains('Alta Probabilidad')) {
      return PdfColors.red50; // Color claro para fondo
    } else if (riskLevel.contains('Riesgo moderado')) {
      return PdfColors.orange50;
    } else {
      return PdfColors.green50;
    }
  }

  static String _getRiskDescription(String riskLevel) {
    if (riskLevel.contains('Alta Probabilidad')) {
      return 'Plan de intervención inmediata con enfoque en recuperación de niveles de hierro';
    } else if (riskLevel.contains('Riesgo moderado')) {
      return 'Plan preventivo para evitar el desarrollo de anemia y mejorar reservas';
    } else {
      return 'Plan de mantenimiento para conservar estado nutricional óptimo';
    }
  }

  static Future<File> _savePDF(pw.Document pdf, String childName) async {
    final directory = await getApplicationDocumentsDirectory();
    final fileName = 'plan_nutricional_${childName.replaceAll(' ', '_').toLowerCase()}.pdf';
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());
    return file;
  }
}