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

  // Niño seleccionado
  NinoModel? _ninoSeleccionado;

  AnemiaRiskResult? _resultado;

  @override
  void initState() {
    super.initState();
    // Intentar prefijar con datos del primer niño disponible
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ninos = context.read<NinoController>().ninos;
      if (ninos.isNotEmpty) {
        setState(() {
          _ninoSeleccionado = ninos.first;
        });
        _prefillFromChild(ninos.first);
      }
    });
  }

  void _prefillFromChild(NinoModel n) {
    final edadAnios = n.edad;
    setState(() {
      _edadMeses = (edadAnios * 12).clamp(0, 180);
      _sexo = n.sexo.isNotEmpty ? n.sexo : 'Masculino';
      _peso = n.peso;
      _talla = n.talla > 3 ? n.talla / 100.0 : n.talla; // acepta cm o m
      
      // Usar datos del cuestionario de salud si están disponibles
      _palidez = n.palidez == 'Sí';
      _fatiga = n.fatiga == 'Sí';
      _bajaIngestaHierro = n.alimentosHierro == 'No'; // Invertir lógica
      _apetitoBajo = n.alimentacionBalanceada == 'No'; // Invertir lógica
      
      // Si hay evaluación previa de anemia, considerar para infecciones frecuentes
      _infecciones = n.anemia == 'Sí';
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
      hemoglobina: null, // No necesitamos hemoglobina
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
                        // Selector de niño
                        _buildSectionCard(
                          title: 'Seleccionar Paciente',
                          icon: Icons.child_care,
                          color: Colors.green,
                          child: Consumer<NinoController>(
                            builder: (context, ninoController, child) {
                              final ninos = ninoController.ninos;
                              if (ninos.isEmpty) {
                                return const Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'No hay niños registrados. Registra un niño primero.',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                );
                              }
                              
                              return Column(
                                children: [
                                  // Mejorado: Dropdown con mejor diseño
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(20),
                                      gradient: LinearGradient(
                                        colors: [Colors.green[100]!, Colors.green[50]!],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.green.withOpacity(0.2),
                                          blurRadius: 8,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.green[200]!, width: 1),
                                      ),
                                      child: DropdownButtonFormField<NinoModel>(
                                        value: _ninoSeleccionado,
                                        decoration: InputDecoration(
                                          labelText: 'Selecciona un paciente',
                                          hintText: 'Toca aquí para elegir un paciente',
                                          labelStyle: TextStyle(
                                            color: Colors.green[700],
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                          ),
                                          hintStyle: TextStyle(
                                            color: Colors.grey[500],
                                            fontSize: 13,
                                          ),
                                          prefixIcon: Container(
                                            margin: const EdgeInsets.all(12),
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.green[400]!, Colors.green[600]!],
                                                begin: Alignment.topLeft,
                                                end: Alignment.bottomRight,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.green.withOpacity(0.4),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: const Icon(Icons.person_search, color: Colors.white, size: 18),
                                          ),
                                          suffixIcon: Container(
                                            margin: const EdgeInsets.only(right: 12),
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.green[100],
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                            child: Icon(Icons.expand_more, color: Colors.green[700], size: 20),
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                                        ),
                                      dropdownColor: Colors.white,
                                      items: ninos.map((nino) {
                                        return DropdownMenuItem<NinoModel>(
                                          value: nino,
                                          child: Container(
                                            margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 4),
                                            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                                            decoration: BoxDecoration(
                                              color: Colors.grey[50],
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.grey[200]!),
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                // Avatar del niño con sombra
                                                Container(
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(25),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: (nino.sexo == 'Masculino' ? Colors.blue : Colors.pink).withOpacity(0.3),
                                                        blurRadius: 8,
                                                        offset: const Offset(0, 2),
                                                      ),
                                                    ],
                                                  ),
                                                  child: CircleAvatar(
                                                    radius: 22,
                                                    backgroundColor: nino.sexo == 'Masculino' 
                                                        ? Colors.blue[100] 
                                                        : Colors.pink[100],
                                                    child: Icon(
                                                      nino.sexo == 'Masculino' ? Icons.boy : Icons.girl,
                                                      color: nino.sexo == 'Masculino' 
                                                          ? Colors.blue[700] 
                                                          : Colors.pink[700],
                                                      size: 24,
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(width: 14),
                                                // Información del niño
                                                Flexible(
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        nino.nombreCompleto,
                                                        style: const TextStyle(
                                                          fontWeight: FontWeight.w700,
                                                          fontSize: 15,
                                                          color: Colors.black87,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      Wrap(
                                                        spacing: 6,
                                                        runSpacing: 2,
                                                        children: [
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                            decoration: BoxDecoration(
                                                              color: Colors.blue[50],
                                                              borderRadius: BorderRadius.circular(8),
                                                              border: Border.all(color: Colors.blue[200]!),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(Icons.badge, size: 12, color: Colors.blue[600]),
                                                                const SizedBox(width: 3),
                                                                Text(
                                                                  'DNI: ${nino.dniNino}',
                                                                  style: TextStyle(
                                                                    fontSize: 10,
                                                                    color: Colors.blue[700],
                                                                    fontWeight: FontWeight.w500,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          Container(
                                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                            decoration: BoxDecoration(
                                                              color: Colors.orange[50],
                                                              borderRadius: BorderRadius.circular(8),
                                                              border: Border.all(color: Colors.orange[200]!),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize: MainAxisSize.min,
                                                              children: [
                                                                Icon(Icons.cake, size: 12, color: Colors.orange[600]),
                                                                const SizedBox(width: 3),
                                                                Text(
                                                                  '${nino.edad} años',
                                                                  style: TextStyle(
                                                                    fontSize: 10,
                                                                    color: Colors.orange[700],
                                                                    fontWeight: FontWeight.w500,
                                                                  ),
                                                                ),
                                                              ],
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
                                        );
                                      }).toList(),
                                      onChanged: (nino) {
                                        if (nino != null) {
                                          setState(() {
                                            _ninoSeleccionado = nino;
                                          });
                                          _prefillFromChild(nino);
                                        }
                                      },
                                      validator: (value) {
                                        if (value == null) {
                                          return 'Por favor selecciona un niño';
                                        }
                                        return null;
                                      },
                                      icon: const SizedBox.shrink(), // Ocultar el icono por defecto
                                    ),
                                  ),
                                ),
                                
                                // Mensaje cuando no hay paciente seleccionado
                                if (_ninoSeleccionado == null) ...[
                                  const SizedBox(height: 16),
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [Colors.blue[50]!, Colors.blue[100]!.withOpacity(0.3)],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(color: Colors.blue[200]!, width: 1),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.blue.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 2),
                                        ),
                                      ],
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.blue[500],
                                            borderRadius: BorderRadius.circular(10),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.blue.withOpacity(0.3),
                                                blurRadius: 4,
                                                offset: const Offset(0, 2),
                                              ),
                                            ],
                                          ),
                                          child: const Icon(Icons.info, color: Colors.white, size: 18),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '¡Selecciona un paciente!',
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w600,
                                                  color: Colors.blue[800],
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Para continuar con el diagnóstico, primero selecciona un paciente del menú desplegable.',
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.blue[600],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                                  
                                  // Información del niño seleccionado mejorada
                                  if (_ninoSeleccionado != null) ...[
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.all(18),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          colors: [Colors.green[50]!, Colors.white],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: Colors.green[200]!, width: 1.5),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.green.withOpacity(0.08),
                                            blurRadius: 8,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                      ),
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Container(
                                                padding: const EdgeInsets.all(8),
                                                decoration: BoxDecoration(
                                                  color: Colors.green[500],
                                                  borderRadius: BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                      color: Colors.green.withOpacity(0.3),
                                                      blurRadius: 6,
                                                      offset: const Offset(0, 2),
                                                    ),
                                                  ],
                                                ),
                                                child: const Icon(Icons.check_circle, color: Colors.white, size: 20),
                                              ),
                                              const SizedBox(width: 12),
                                              Text(
                                                'Paciente Seleccionado',
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.w700,
                                                  color: Colors.green[800],
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 16),
                                          Container(
                                            padding: const EdgeInsets.all(16),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.green[100]!),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black.withOpacity(0.05),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Column(
                                              children: [
                                                Row(
                                                  children: [
                                                    // Avatar más grande con efectos
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(30),
                                                        boxShadow: [
                                                          BoxShadow(
                                                            color: (_ninoSeleccionado!.sexo == 'Masculino' ? Colors.blue : Colors.pink).withOpacity(0.3),
                                                            blurRadius: 12,
                                                            offset: const Offset(0, 4),
                                                          ),
                                                        ],
                                                      ),
                                                      child: CircleAvatar(
                                                        radius: 30,
                                                        backgroundColor: _ninoSeleccionado!.sexo == 'Masculino' 
                                                            ? Colors.blue[100] 
                                                            : Colors.pink[100],
                                                        child: Icon(
                                                          _ninoSeleccionado!.sexo == 'Masculino' ? Icons.boy : Icons.girl,
                                                          color: _ninoSeleccionado!.sexo == 'Masculino' 
                                                              ? Colors.blue[700] 
                                                              : Colors.pink[700],
                                                          size: 36,
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 20),
                                                    Expanded(
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            _ninoSeleccionado!.nombreCompleto,
                                                            style: const TextStyle(
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.bold,
                                                              color: Colors.black87,
                                                            ),
                                                            maxLines: 2,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 16),
                                                // Chips de información en fila separada
                                                SingleChildScrollView(
                                                  scrollDirection: Axis.horizontal,
                                                  child: Row(
                                                    children: [
                                                      _buildEnhancedInfoChip(Icons.badge, 'DNI: ${_ninoSeleccionado!.dniNino}', Colors.blue),
                                                      const SizedBox(width: 8),
                                                      _buildEnhancedInfoChip(Icons.cake, '${_ninoSeleccionado!.edad} años', Colors.orange),
                                                      const SizedBox(width: 8),
                                                      _buildEnhancedInfoChip(Icons.wc, _ninoSeleccionado!.sexo, _ninoSeleccionado!.sexo == 'Masculino' ? Colors.blue : Colors.pink),
                                                      const SizedBox(width: 8),
                                                      _buildEnhancedInfoChip(Icons.location_on, _ninoSeleccionado!.residencia, Colors.green),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [Colors.blue[50]!, Colors.blue[100]!.withOpacity(0.3)],
                                                begin: Alignment.centerLeft,
                                                end: Alignment.centerRight,
                                              ),
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(color: Colors.blue[200]!, width: 1),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.blue.withOpacity(0.1),
                                                  blurRadius: 6,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ],
                                            ),
                                            child: Row(
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(6),
                                                  decoration: BoxDecoration(
                                                    color: Colors.blue[500],
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: const Icon(Icons.info, color: Colors.white, size: 16),
                                                ),
                                                const SizedBox(width: 12),
                                                Expanded(
                                                  child: Text(
                                                    'Los datos de este paciente se han cargado automáticamente',
                                                    style: TextStyle(
                                                      fontSize: 12,
                                                      color: Colors.blue[700],
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
                                  ],
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        
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
                                    child: _readOnlyField(
                                      label: 'Edad (meses)',
                                      value: _edadMeses.toString(),
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
                                    child: _readOnlyField(
                                      label: 'Peso (kg)',
                                      value: _peso.toStringAsFixed(1),
                                      icon: Icons.monitor_weight,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: _readOnlyField(
                                      label: 'Talla (m)',
                                      value: _talla.toStringAsFixed(2),
                                      icon: Icons.height,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.blue[200]!),
                                ),
                                child: Row(
                                  children: [
                                    Icon(Icons.info, color: Colors.blue[600], size: 20),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        'Edad calculada automáticamente: ${(_edadMeses / 12).toStringAsFixed(1)} años ($_edadMeses meses). Los datos de peso y talla se toman del registro del niño seleccionado.',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.blue[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, color[25] ?? color[50]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color[200]!, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 10,
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
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [color[400]!, color[600]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.3),
                        blurRadius: 6,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Icon(icon, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: color[800],
                      letterSpacing: 0.5,
                    ),
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
                      r.score.toStringAsFixed(0),
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

  Widget _readOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
        color: Colors.grey[50],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: Colors.grey[600]),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedInfoChip(IconData icon, String text, MaterialColor color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color[200]!, width: 1),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.15),
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              color: color[700],
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
