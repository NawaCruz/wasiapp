// ignore_for_file: deprecated_member_use
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../controllers/nino_controller.dart';
import '../models/nino_model.dart';
import '../utils/anemia_risk.dart';

class AnemiaDiagnosticoView extends StatefulWidget {
  const AnemiaDiagnosticoView({super.key});

  @override
  State<AnemiaDiagnosticoView> createState() => _AnemiaDiagnosticoViewState();
}

class _AnemiaDiagnosticoViewState extends State<AnemiaDiagnosticoView> {
  final _formKey = GlobalKey<FormState>();

  // Datos
  int _edadMeses = 60; // default 5 años
  String _sexo = 'Masculino';
  double _peso = 15;
  double _talla = 1.0;
  double? _hemoglobina;

  // Cuestionario
  bool _palidez = false;
  bool _fatiga = false;
  bool _apetitoBajo = false;
  bool _infecciones = false;
  bool _bajaIngestaHierro = false;

  // Imagen
  final _picker = ImagePicker();
  File? _image;
  double? _imgScore;

  AnemiaRiskResult? _resultado;

  @override
  void initState() {
    super.initState();
    // Intentar prefijar con datos del primer niño disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ninos = context.read<NinoController>().ninos;
      if (ninos.isNotEmpty) _prefillFromChild(ninos.first);
    });
  }

  void _prefillFromChild(NinoModel n) {
    final edadAnios = n.edad;
    setState(() {
      _edadMeses = (edadAnios * 12).clamp(0, 180);
      _sexo = n.sexo.isNotEmpty ? n.sexo : 'Masculino';
      _peso = n.peso;
      _talla = n.talla > 3 ? n.talla / 100.0 : n.talla; // acepta cm o m
    });
  }

  Future<void> _pickImage() async {
    final x = await _picker.pickImage(source: ImageSource.camera, imageQuality: 85, maxWidth: 1024, maxHeight: 1024);
    if (x == null) return;
    final f = File(x.path);
    final score = AnemiaRiskEngine.imagePalenessFromFile(f);
    setState(() {
      _image = f;
      _imgScore = score;
    });
  }

  void _calcular() {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    final input = AnemiaRiskInput(
      edadMeses: _edadMeses,
      sexo: _sexo,
      pesoKg: _peso,
      tallaM: _talla,
      hemoglobina: _hemoglobina,
      palidez: _palidez,
      fatiga: _fatiga,
      apetitoBajo: _apetitoBajo,
      infeccionesFrecuentes: _infecciones,
      bajaIngestaHierro: _bajaIngestaHierro,
      imagePalenessScore: _imgScore,
    );
    final r = AnemiaRiskEngine.estimate(input);
    setState(() => _resultado = r);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Diagnóstico de Anemia', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor: Colors.red[600],
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header con gradiente
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.red[600]!, Colors.red[400]!],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.bloodtype, size: 40, color: Colors.white),
                        const SizedBox(height: 8),
                        const Text(
                          'Evaluación de Riesgo de Anemia',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Código: RF-05',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            // Contenido principal
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info card
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue[50],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(Icons.info_outline, color: Colors.blue[600]),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Text(
                              'Este resultado es orientativo y combina cuestionario, datos antropométricos y análisis visual de palidez.',
                              style: TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Datos antropométricos
                        _buildSectionCard(
                          title: 'Datos del Paciente',
                          icon: Icons.person,
                          color: Colors.blue,
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: _numberField(
                                      label: 'Edad (meses)',
                                      initial: _edadMeses.toString(),
                                      onSaved: (v) => _edadMeses = int.tryParse(v ?? '') ?? _edadMeses,
                                      min: 0,
                                      max: 180,
                                      icon: Icons.calendar_today,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _dropdown(
                                      label: 'Sexo',
                                      value: _sexo,
                                      items: const ['Masculino', 'Femenino'],
                                      onChanged: (v) => setState(() => _sexo = v ?? 'Masculino'),
                                      icon: Icons.wc,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Row(
                                children: [
                                  Expanded(
                                    child: _numberField(
                                      label: 'Peso (kg)',
                                      initial: _peso.toStringAsFixed(1),
                                      onSaved: (v) => _peso = double.tryParse(v ?? '') ?? _peso,
                                      min: 3,
                                      max: 80,
                                      icon: Icons.monitor_weight,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _numberField(
                                      label: 'Talla (m)',
                                      initial: _talla.toStringAsFixed(2),
                                      onSaved: (v) => _talla = double.tryParse(v ?? '') ?? _talla,
                                      min: 0.5,
                                      max: 2.0,
                                      step: 0.01,
                                      icon: Icons.height,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _numberField(
                                label: 'Hemoglobina (g/dL) - Opcional',
                                initial: _hemoglobina?.toStringAsFixed(1) ?? '',
                                onSaved: (v) => _hemoglobina = (v?.isEmpty ?? true) ? null : double.tryParse(v!),
                                min: 5,
                                max: 18,
                                step: 0.1,
                                icon: Icons.water_drop,
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Cuestionario
                        _buildSectionCard(
                          title: 'Síntomas y Factores de Riesgo',
                          icon: Icons.quiz,
                          color: Colors.orange,
                          child: Column(
                            children: [
                              _modernCheckbox('Palidez visible', _palidez, Icons.face, (v) => setState(() => _palidez = v ?? false)),
                              _modernCheckbox('Fatiga o decaimiento', _fatiga, Icons.battery_1_bar, (v) => setState(() => _fatiga = v ?? false)),
                              _modernCheckbox('Apetito bajo', _apetitoBajo, Icons.restaurant_menu, (v) => setState(() => _apetitoBajo = v ?? false)),
                              _modernCheckbox('Infecciones frecuentes', _infecciones, Icons.sick, (v) => setState(() => _infecciones = v ?? false)),
                              _modernCheckbox('Baja ingesta de hierro', _bajaIngestaHierro, Icons.dining, (v) => setState(() => _bajaIngestaHierro = v ?? false)),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Análisis de imagen
                        _buildSectionCard(
                          title: 'Análisis Visual',
                          icon: Icons.camera_alt,
                          color: Colors.purple,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Captura una foto para análisis de palidez (opcional)',
                                style: TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      onPressed: _pickImage,
                                      icon: const Icon(Icons.camera_alt),
                                      label: const Text('Tomar foto'),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.purple[100],
                                        foregroundColor: Colors.purple[800],
                                        padding: const EdgeInsets.symmetric(vertical: 12),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (_imgScore != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.purple[50],
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: Colors.purple[200]!),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.analytics, color: Colors.purple[600], size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Indicador de palidez: ${(_imgScore! * 100).toStringAsFixed(0)}%',
                                        style: TextStyle(color: Colors.purple[800], fontWeight: FontWeight.w500),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (_image != null) ...[
                                const SizedBox(height: 12),
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.file(
                                    _image!, 
                                    height: 180, 
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),

                        const SizedBox(height: 24),

                        // Botón de calcular
                        Container(
                          width: double.infinity,
                          height: 50,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [Colors.red[600]!, Colors.red[400]!],
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: _calcular,
                            icon: const Icon(Icons.calculate, color: Colors.white),
                            label: const Text(
                              'Evaluar Riesgo de Anemia',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ),

                        if (_resultado != null) ...[
                          const SizedBox(height: 20),
                          _buildResultado(_resultado!),
                        ],
                      ],
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

  Widget _numberField({
    required String label,
    required String initial,
    required void Function(String?) onSaved,
    required num min,
    required num max,
    double step = 1,
    IconData? icon,
  }) {
    return TextFormField(
      initialValue: initial,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      validator: (v) {
        if (v == null || v.isEmpty) return null;
        final x = double.tryParse(v);
        if (x == null) return 'Número inválido';
        if (x < min || x > max) return 'Fuera de rango ($min - $max)';
        return null;
      },
      onSaved: onSaved,
    );
  }

  Widget _dropdown({
    required String label,
    required String value,
    required List<String> items,
    required void Function(String?) onChanged,
    IconData? icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: icon != null ? Icon(icon, color: Colors.grey[600]) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.red[400]!, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      items: items
          .map((e) => DropdownMenuItem<String>(
                value: e, 
                child: Text(e, overflow: TextOverflow.ellipsis)
              ))
          .toList(),
      onChanged: onChanged,
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required MaterialColor color,
    required Widget child,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
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
                    color: color[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color[600], size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: color[800],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _modernCheckbox(String label, bool value, IconData icon, void Function(bool?) onChanged) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: value ? Colors.orange[50] : Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? Colors.orange[300]! : Colors.grey[300]!,
          width: 1,
        ),
      ),
      child: CheckboxListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        value: value,
        onChanged: onChanged,
        title: Row(
          children: [
            Icon(icon, size: 18, color: value ? Colors.orange[600] : Colors.grey[600]),
            const SizedBox(width: 8),
            Expanded(child: Text(label, style: const TextStyle(fontSize: 14))),
          ],
        ),
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: Colors.orange[600],
        checkColor: Colors.white,
        dense: true,
      ),
    );
  }

  Widget _buildResultado(AnemiaRiskResult r) {
    MaterialColor color;
    String titulo;
    IconData iconResult;
    
    switch (r.level) {
      case RiskLevel.alto:
        color = Colors.red; 
        titulo = 'Riesgo Alto';
        iconResult = Icons.warning;
        break;
      case RiskLevel.medio:
        color = Colors.orange; 
        titulo = 'Riesgo Medio';
        iconResult = Icons.info;
        break;
      case RiskLevel.bajo:
        color = Colors.green; 
        titulo = 'Riesgo Bajo';
        iconResult = Icons.check_circle;
        break;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [color.withOpacity(0.1), color.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header del resultado
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(iconResult, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: color[800],
                        ),
                      ),
                      Text(
                        'Puntuación: ${r.score.toStringAsFixed(0)}/100',
                        style: TextStyle(
                          fontSize: 14,
                          color: color[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                // Indicador visual de score
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      '${r.score.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: color[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Factores considerados
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[200]!),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.list_alt, color: Colors.grey[600], size: 18),
                    const SizedBox(width: 8),
                    const Text(
                      'Factores evaluados:',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ...r.factores.map((f) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 2),
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.green[100],
                              shape: BoxShape.circle,
                            ),
                            child: Icon(Icons.check, size: 12, color: Colors.green[700]),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              f,
                              style: const TextStyle(fontSize: 13, color: Colors.black87),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Disclaimer
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.amber[50],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.amber[200]!),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline, size: 16, color: Colors.amber[700]),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Aviso médico: Este resultado es orientativo y no sustituye una evaluación clínica profesional. Consulte con un especialista para un diagnóstico definitivo.',
                    style: TextStyle(fontSize: 11, color: Colors.black87),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
