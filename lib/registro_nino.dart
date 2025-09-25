import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistrarNinoScreen extends StatefulWidget {
  const RegistrarNinoScreen({super.key});

  @override
  State<RegistrarNinoScreen> createState() => _RegistrarNinoScreenState();
}

class _RegistrarNinoScreenState extends State<RegistrarNinoScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _dniNinoController = TextEditingController();
  final _residenciaController = TextEditingController();
  final _nombreTutorController = TextEditingController();
  final _dniPadreController = TextEditingController();
  final _pesoController = TextEditingController();
  final _tallaController = TextEditingController();
  
  DateTime? _fechaNacimiento;
  String? _sexoSeleccionado;
  bool _isLoading = false;
  double? _imcCalculado;
  String? _clasificacionIMC;
  
  final List<String> _opcionesSexo = ['Seleccionar', 'Masculino', 'Femenino'];

  Future<void> _seleccionarFecha() async {
    final DateTime? fechaSeleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (fechaSeleccionada != null) {
      setState(() {
        _fechaNacimiento = fechaSeleccionada;
      });
    }
  }

  void _calcularIMC() {
    if (_pesoController.text.isNotEmpty && _tallaController.text.isNotEmpty) {
      try {
        final peso = double.parse(_pesoController.text);
        final tallaCm = double.parse(_tallaController.text);
        final tallaM = tallaCm / 100; // Convertir cm a metros
        
        if (peso > 0 && tallaM > 0) {
          final imc = peso / (tallaM * tallaM);
          
          setState(() {
            _imcCalculado = double.parse(imc.toStringAsFixed(2));
            _clasificacionIMC = _clasificarIMC(_imcCalculado!, _fechaNacimiento, _sexoSeleccionado);
          });
        }
      } catch (e) {
        setState(() {
          _imcCalculado = null;
          _clasificacionIMC = null;
        });
      }
    } else {
      setState(() {
        _imcCalculado = null;
        _clasificacionIMC = null;
      });
    }
  }

  String _clasificarIMC(double imc, DateTime? fechaNacimiento, String? sexo) {
    if (fechaNacimiento == null) return 'Sin clasificar';
    
    // Calcular edad en meses
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fechaNacimiento);
    final edadEnMeses = (diferencia.inDays / 30.44).round();
    
    // Clasificación básica por rangos de edad
    if (edadEnMeses < 24) {
      // Menores de 2 años
      if (imc < 14.0) return 'Bajo peso';
      if (imc < 18.0) return 'Peso normal';
      if (imc < 20.0) return 'Sobrepeso';
      return 'Obesidad';
    } else if (edadEnMeses < 60) {
      // 2-5 años
      if (imc < 13.5) return 'Bajo peso';
      if (imc < 16.5) return 'Peso normal';
      if (imc < 18.5) return 'Sobrepeso';
      return 'Obesidad';
    } else {
      // Mayores de 5 años
      if (imc < 16.0) return 'Bajo peso';
      if (imc < 18.5) return 'Peso normal';
      if (imc < 25.0) return 'Sobrepeso';
      return 'Obesidad';
    }
  }

  Future<void> _siguiente() async {
    if (_formKey.currentState!.validate()) {
      if (_fechaNacimiento == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor seleccione la fecha de nacimiento'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (_sexoSeleccionado == null || _sexoSeleccionado == 'Seleccionar') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Por favor seleccione el sexo'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      setState(() {
        _isLoading = true;
      });

      // Guardar en Firestore
      final resultado = await _guardarEnFirestore();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        if (resultado['success'] == true) {
          // Mostrar diálogo de éxito con opciones
          _mostrarDialogoExito(resultado['ninoId'], resultado['ninoData']);
        }
      }
    }
  }

  Future<Map<String, dynamic>> _guardarEnFirestore() async {
    try {
      Map<String, dynamic> datosNino = {
        'nombres': _nombresController.text.trim(),
        'apellidos': _apellidosController.text.trim(),
        'dniNino': _dniNinoController.text.trim(),
        'fechaNacimiento': _fechaNacimiento,
        'fechaNacimientoTimestamp': Timestamp.fromDate(_fechaNacimiento!),
        'sexo': _sexoSeleccionado,
        'residencia': _residenciaController.text.trim(),
        'nombreTutor': _nombreTutorController.text.trim(),
        'dniPadre': _dniPadreController.text.trim(),
        'fechaRegistro': FieldValue.serverTimestamp(),
        'creadoEl': Timestamp.now(),
      };

      // Agregar datos de peso y talla si están disponibles
      if (_pesoController.text.isNotEmpty) {
        datosNino['peso'] = double.parse(_pesoController.text);
      }
      
      if (_tallaController.text.isNotEmpty) {
        datosNino['talla'] = double.parse(_tallaController.text);
      }
      
      if (_imcCalculado != null) {
        datosNino['imc'] = _imcCalculado;
        datosNino['clasificacionIMC'] = _clasificacionIMC;
        datosNino['fechaMedicion'] = Timestamp.now();
        
        // Calcular edad en meses para la clasificación
        final ahora = DateTime.now();
        final diferencia = ahora.difference(_fechaNacimiento!);
        final edadEnMeses = (diferencia.inDays / 30.44).round();
        datosNino['edadEnMeses'] = edadEnMeses;
      }

      // Guardar historial de mediciones
      if (_pesoController.text.isNotEmpty || _tallaController.text.isNotEmpty) {
        Map<String, dynamic> medicion = {
          'fecha': Timestamp.now(),
          'peso': _pesoController.text.isNotEmpty ? double.parse(_pesoController.text) : null,
          'talla': _tallaController.text.isNotEmpty ? double.parse(_tallaController.text) : null,
          'imc': _imcCalculado,
          'clasificacion': _clasificacionIMC,
        };
        
        datosNino['ultimaMedicion'] = medicion;
        datosNino['historialMediciones'] = [medicion];
      }

      final docRef = await FirebaseFirestore.instance.collection('ninos').add(datosNino);

      debugPrint('✅ Niño registrado exitosamente en Firestore');
      return {
        'success': true,
        'ninoId': docRef.id,
        'ninoData': datosNino,
      };
    } catch (e) {
      debugPrint('❌ Error al guardar en Firestore: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
      }
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  void _mostrarDialogoExito(String ninoId, Map<String, dynamic> ninoData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('¡Registro Exitoso!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                '${_nombresController.text} ${_apellidosController.text} ha sido registrado exitosamente.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _limpiarFormulario();
              },
              child: const Text('Registrar Otro'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // AQUÍ ES DONDE IRÍA TU CÓDIGO DE NAVEGACIÓN
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => VerEditarNinoScreen(
                      ninoData: ninoData,
                      ninoId: ninoId,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ver/Editar'),
            ),
          ],
        );
      },
    );
  }

  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    setState(() {
      _fechaNacimiento = null;
      _sexoSeleccionado = null;
      _imcCalculado = null;
      _clasificacionIMC = null;
    });
    _nombresController.clear();
    _apellidosController.clear();
    _dniNinoController.clear();
    _residenciaController.clear();
    _nombreTutorController.clear();
    _dniPadreController.clear();
    _pesoController.clear();
    _tallaController.clear();
  }

  String? _validarCampoRequerido(String? value, String nombreCampo) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese $nombreCampo';
    }
    if (value.length < 2) {
      return '$nombreCampo debe tener al menos 2 caracteres';
    }
    return null;
  }

  String? _validarDNI(String? value) {
    if (value == null || value.isEmpty) {
      return 'Por favor ingrese el DNI';
    }
    if (value.length != 8) {
      return 'El DNI debe tener 8 dígitos';
    }
    if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
      return 'El DNI solo debe contener números';
    }
    return null;
  }

  String? _validarPeso(String? value) {
    if (value == null || value.isEmpty) {
      return null; 
    }
    try {
      final peso = double.parse(value);
      if (peso <= 0 || peso > 200) {
        return 'Ingrese un peso válido (0-200 kg)';
      }
    } catch (e) {
      return 'Ingrese un número válido';
    }
    return null;
  }

  String? _validarTalla(String? value) {
    if (value == null || value.isEmpty) {
      return null; // Campo opcional
    }
    try {
      final talla = double.parse(value);
      if (talla <= 0 || talla > 250) {
        return 'Ingrese una talla válida (0-250 cm)';
      }
    } catch (e) {
      return 'Ingrese un número válido';
    }
    return null;
  }

  Color _getColorByClasificacion(String? clasificacion) {
    switch (clasificacion?.toLowerCase()) {
      case 'bajo peso':
        return Colors.orange.shade50;
      case 'peso normal':
        return Colors.green.shade50;
      case 'sobrepeso':
        return Colors.yellow.shade50;
      case 'obesidad':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getBorderColorByClasificacion(String? clasificacion) {
    switch (clasificacion?.toLowerCase()) {
      case 'bajo peso':
        return Colors.orange;
      case 'peso normal':
        return Colors.green;
      case 'sobrepeso':
        return Colors.yellow.shade700;
      case 'obesidad':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Niño'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Guardando información...'),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Título
                    const Text(
                      'Registrar Niño',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Complete la información del niño',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Nombres
                    TextFormField(
                      controller: _nombresController,
                      decoration: InputDecoration(
                        labelText: 'Nombres del niño',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) => _validarCampoRequerido(value, 'los nombres'),
                    ),
                    const SizedBox(height: 20),

                    // Apellidos
                    TextFormField(
                      controller: _apellidosController,
                      decoration: InputDecoration(
                        labelText: 'Apellidos del niño',
                        prefixIcon: const Icon(Icons.person_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) => _validarCampoRequerido(value, 'los apellidos'),
                    ),
                    const SizedBox(height: 20),

                    // DNI del niño
                    TextFormField(
                      controller: _dniNinoController,
                      decoration: InputDecoration(
                        labelText: 'DNI del niño',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      validator: _validarDNI,
                    ),
                    const SizedBox(height: 20),

                    // Fecha de nacimiento
                    InkWell(
                      onTap: _isLoading ? null : _seleccionarFecha,
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Fecha de nacimiento',
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _fechaNacimiento != null
                                  ? DateFormat('dd/MM/yyyy').format(_fechaNacimiento!)
                                  : 'dd/mm/aaaa',
                              style: TextStyle(
                                color: _fechaNacimiento != null 
                                    ? Colors.black87 
                                    : Colors.grey.shade600,
                              ),
                            ),
                            Icon(Icons.arrow_drop_down, color: Colors.grey.shade600),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Sexo
                    DropdownButtonFormField<String>(
                      value: _sexoSeleccionado,
                      decoration: InputDecoration(
                        labelText: 'Sexo',
                        prefixIcon: const Icon(Icons.people_outline),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _opcionesSexo.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: _isLoading 
                          ? null 
                          : (String? newValue) {
                              setState(() {
                                _sexoSeleccionado = newValue;
                              });
                            },
                      validator: (value) {
                        if (value == null || value == 'Seleccionar') {
                          return 'Por favor seleccione el sexo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Residencia
                    TextFormField(
                      controller: _residenciaController,
                      decoration: InputDecoration(
                        labelText: 'Residencia',
                        prefixIcon: const Icon(Icons.home_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) => _validarCampoRequerido(value, 'la residencia'),
                    ),
                    const SizedBox(height: 20),

                    // Nombre del tutor
                    TextFormField(
                      controller: _nombreTutorController,
                      decoration: InputDecoration(
                        labelText: 'Nombre del tutor',
                        prefixIcon: const Icon(Icons.supervised_user_circle_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      validator: (value) => _validarCampoRequerido(value, 'el nombre del tutor'),
                    ),
                    const SizedBox(height: 20),

                    // DNI del padre
                    TextFormField(
                      controller: _dniPadreController,
                      decoration: InputDecoration(
                        labelText: 'DNI del padre/tutor',
                        prefixIcon: const Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      keyboardType: TextInputType.number,
                      maxLength: 8,
                      validator: _validarDNI,
                    ),
                    const SizedBox(height: 20),

                    // Título para mediciones
                    const Text(
                      'Mediciones',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Peso y Talla en una fila
                    Row(
                      children: [
                        // Peso
                        Expanded(
                          child: TextFormField(
                            controller: _pesoController,
                            decoration: InputDecoration(
                              labelText: 'Peso (kg)',
                              prefixIcon: const Icon(Icons.monitor_weight_outlined),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              hintText: 'Ej: 15.5',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: _validarPeso,
                            onChanged: (value) => _calcularIMC(),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Talla
                        Expanded(
                          child: TextFormField(
                            controller: _tallaController,
                            decoration: InputDecoration(
                              labelText: 'Talla (cm)',
                              prefixIcon: const Icon(Icons.height),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.grey.shade50,
                              hintText: 'Ej: 105',
                            ),
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            validator: _validarTalla,
                            onChanged: (value) => _calcularIMC(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Mostrar resultado del IMC si está calculado
                    if (_imcCalculado != null) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: _getColorByClasificacion(_clasificacionIMC),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: _getBorderColorByClasificacion(_clasificacionIMC),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.analytics_outlined,
                                  color: _getBorderColorByClasificacion(_clasificacionIMC),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Resultado del IMC',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'IMC: ${_imcCalculado!.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Clasificación: $_clasificacionIMC',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: _getBorderColorByClasificacion(_clasificacionIMC),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],

                    const SizedBox(height: 20),

                    // Botón Siguiente
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _siguiente,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Registrar Niño',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _dniNinoController.dispose();
    _residenciaController.dispose();
    _nombreTutorController.dispose();
    _dniPadreController.dispose();
    _pesoController.dispose();
    _tallaController.dispose();
    super.dispose();
  }
}

// Clase temporal para que no haya error - DEBES CREARLA
class VerEditarNinoScreen extends StatefulWidget {
  final Map<String, dynamic> ninoData;
  final String ninoId;

  const VerEditarNinoScreen({
    super.key,
    required this.ninoData,
    required this.ninoId,
  });

  @override
  State<VerEditarNinoScreen> createState() => _VerEditarNinoScreenState();
}

class _VerEditarNinoScreenState extends State<VerEditarNinoScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombresController;
  late TextEditingController _apellidosController;
  late TextEditingController _dniNinoController;
  late TextEditingController _residenciaController;
  late TextEditingController _nombreTutorController;
  late TextEditingController _dniPadreController;
  late TextEditingController _pesoController;
  late TextEditingController _tallaController;
  
  DateTime? _fechaNacimiento;
  String? _sexoSeleccionado;
  bool _isLoading = false;
  bool _modoEdicion = false;
  double? _imcCalculado;
  String? _clasificacionIMC;
  
  final List<String> _opcionesSexo = ['Seleccionar', 'Masculino', 'Femenino'];

  @override
  void initState() {
    super.initState();
    _inicializarControladores();
  }

  void _inicializarControladores() {
    _nombresController = TextEditingController(text: widget.ninoData['nombres'] ?? '');
    _apellidosController = TextEditingController(text: widget.ninoData['apellidos'] ?? '');
    _dniNinoController = TextEditingController(text: widget.ninoData['dniNino'] ?? '');
    _residenciaController = TextEditingController(text: widget.ninoData['residencia'] ?? '');
    _nombreTutorController = TextEditingController(text: widget.ninoData['nombreTutor'] ?? '');
    _dniPadreController = TextEditingController(text: widget.ninoData['dniPadre'] ?? '');
    
    // Datos de peso y talla
    _pesoController = TextEditingController(
      text: widget.ninoData['peso']?.toString() ?? ''
    );
    _tallaController = TextEditingController(
      text: widget.ninoData['talla']?.toString() ?? ''
    );
    
    // Fecha de nacimiento
    if (widget.ninoData['fechaNacimiento'] != null) {
      if (widget.ninoData['fechaNacimiento'] is Timestamp) {
        _fechaNacimiento = (widget.ninoData['fechaNacimiento'] as Timestamp).toDate();
      } else if (widget.ninoData['fechaNacimiento'] is DateTime) {
        _fechaNacimiento = widget.ninoData['fechaNacimiento'];
      }
    }
    
    _sexoSeleccionado = widget.ninoData['sexo'];
    _imcCalculado = widget.ninoData['imc']?.toDouble();
    _clasificacionIMC = widget.ninoData['clasificacionIMC'];
  }

  void _calcularIMC() {
    if (_pesoController.text.isNotEmpty && _tallaController.text.isNotEmpty) {
      try {
        final peso = double.parse(_pesoController.text);
        final tallaCm = double.parse(_tallaController.text);
        final tallaM = tallaCm / 100;
        
        if (peso > 0 && tallaM > 0) {
          final imc = peso / (tallaM * tallaM);
          
          setState(() {
            _imcCalculado = double.parse(imc.toStringAsFixed(2));
            _clasificacionIMC = _clasificarIMC(_imcCalculado!, _fechaNacimiento, _sexoSeleccionado);
          });
        }
      } catch (e) {
        setState(() {
          _imcCalculado = null;
          _clasificacionIMC = null;
        });
      }
    }
  }

  String _clasificarIMC(double imc, DateTime? fechaNacimiento, String? sexo) {
    if (fechaNacimiento == null) return 'Sin clasificar';
    
    final ahora = DateTime.now();
    final diferencia = ahora.difference(fechaNacimiento);
    final edadEnMeses = (diferencia.inDays / 30.44).round();
    
    if (edadEnMeses < 24) {
      if (imc < 14.0) return 'Bajo peso';
      if (imc < 18.0) return 'Peso normal';
      if (imc < 20.0) return 'Sobrepeso';
      return 'Obesidad';
    } else if (edadEnMeses < 60) {
      if (imc < 13.5) return 'Bajo peso';
      if (imc < 16.5) return 'Peso normal';
      if (imc < 18.5) return 'Sobrepeso';
      return 'Obesidad';
    } else {
      if (imc < 16.0) return 'Bajo peso';
      if (imc < 18.5) return 'Peso normal';
      if (imc < 25.0) return 'Sobrepeso';
      return 'Obesidad';
    }
  }

  Color _getColorByClasificacion(String? clasificacion) {
    switch (clasificacion?.toLowerCase()) {
      case 'bajo peso':
        return Colors.orange.shade50;
      case 'peso normal':
        return Colors.green.shade50;
      case 'sobrepeso':
        return Colors.yellow.shade50;
      case 'obesidad':
        return Colors.red.shade50;
      default:
        return Colors.grey.shade50;
    }
  }

  Color _getBorderColorByClasificacion(String? clasificacion) {
    switch (clasificacion?.toLowerCase()) {
      case 'bajo peso':
        return Colors.orange;
      case 'peso normal':
        return Colors.green;
      case 'sobrepeso':
        return Colors.yellow.shade700;
      case 'obesidad':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _actualizarDatos() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> datosActualizados = {
        'nombres': _nombresController.text.trim(),
        'apellidos': _apellidosController.text.trim(),
        'dniNino': _dniNinoController.text.trim(),
        'fechaNacimiento': _fechaNacimiento,
        'sexo': _sexoSeleccionado,
        'residencia': _residenciaController.text.trim(),
        'nombreTutor': _nombreTutorController.text.trim(),
        'dniPadre': _dniPadreController.text.trim(),
        'fechaActualizacion': FieldValue.serverTimestamp(),
      };

      if (_pesoController.text.isNotEmpty) {
        datosActualizados['peso'] = double.parse(_pesoController.text);
      }
      
      if (_tallaController.text.isNotEmpty) {
        datosActualizados['talla'] = double.parse(_tallaController.text);
      }
      
      if (_imcCalculado != null) {
        datosActualizados['imc'] = _imcCalculado;
        datosActualizados['clasificacionIMC'] = _clasificacionIMC;
        datosActualizados['fechaMedicion'] = Timestamp.now();
      }

      await FirebaseFirestore.instance
          .collection('ninos')
          .doc(widget.ninoId)
          .update(datosActualizados);

      if (mounted) {
        setState(() {
          _isLoading = false;
          _modoEdicion = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Datos actualizados exitosamente'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al actualizar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_modoEdicion ? 'Editar Niño' : 'Ver Datos del Niño'),
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
        actions: [
          if (!_modoEdicion)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                setState(() {
                  _modoEdicion = true;
                });
              },
            ),
          if (_modoEdicion) ...[
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: _isLoading ? null : _actualizarDatos,
            ),
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                setState(() {
                  _modoEdicion = false;
                  _inicializarControladores(); // Restaurar valores originales
                });
              },
            ),
          ],
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Información del niño
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.child_care, color: Colors.blue.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'Información Personal',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Nombres
                            TextFormField(
                              controller: _nombresController,
                              enabled: _modoEdicion,
                              decoration: InputDecoration(
                                labelText: 'Nombres',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Apellidos
                            TextFormField(
                              controller: _apellidosController,
                              enabled: _modoEdicion,
                              decoration: InputDecoration(
                                labelText: 'Apellidos',
                                prefixIcon: const Icon(Icons.person_outline),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // DNI y Sexo en una fila
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _dniNinoController,
                                    enabled: _modoEdicion,
                                    decoration: InputDecoration(
                                      labelText: 'DNI',
                                      prefixIcon: const Icon(Icons.badge_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: DropdownButtonFormField<String>(
                                    value: _sexoSeleccionado,
                                    decoration: InputDecoration(
                                      labelText: 'Sexo',
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    items: _opcionesSexo.map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: _modoEdicion 
                                        ? (String? newValue) {
                                            setState(() {
                                              _sexoSeleccionado = newValue;
                                              _calcularIMC();
                                            });
                                          }
                                        : null,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            // Fecha de nacimiento
                            InkWell(
                              onTap: _modoEdicion 
                                  ? () async {
                                      final fecha = await showDatePicker(
                                        context: context,
                                        initialDate: _fechaNacimiento ?? DateTime.now(),
                                        firstDate: DateTime(2000),
                                        lastDate: DateTime.now(),
                                      );
                                      if (fecha != null) {
                                        setState(() {
                                          _fechaNacimiento = fecha;
                                          _calcularIMC();
                                        });
                                      }
                                    }
                                  : null,
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Fecha de nacimiento',
                                  prefixIcon: const Icon(Icons.calendar_today),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                child: Text(
                                  _fechaNacimiento != null
                                      ? DateFormat('dd/MM/yyyy').format(_fechaNacimiento!)
                                      : 'No especificado',
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Información del tutor
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.family_restroom, color: Colors.green.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'Información del Tutor',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            TextFormField(
                              controller: _nombreTutorController,
                              enabled: _modoEdicion,
                              decoration: InputDecoration(
                                labelText: 'Nombre del tutor',
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _dniPadreController,
                                    enabled: _modoEdicion,
                                    decoration: InputDecoration(
                                      labelText: 'DNI del tutor',
                                      prefixIcon: const Icon(Icons.badge),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _residenciaController,
                                    enabled: _modoEdicion,
                                    decoration: InputDecoration(
                                      labelText: 'Residencia',
                                      prefixIcon: const Icon(Icons.home),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Mediciones
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.analytics, color: Colors.purple.shade700),
                                const SizedBox(width: 8),
                                const Text(
                                  'Mediciones Antropométricas',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            
                            Row(
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    controller: _pesoController,
                                    enabled: _modoEdicion,
                                    decoration: InputDecoration(
                                      labelText: 'Peso (kg)',
                                      prefixIcon: const Icon(Icons.monitor_weight_outlined),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      hintText: 'Ej: 15.5',
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: _modoEdicion ? (value) => _calcularIMC() : null,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: TextFormField(
                                    controller: _tallaController,
                                    enabled: _modoEdicion,
                                    decoration: InputDecoration(
                                      labelText: 'Talla (cm)',
                                      prefixIcon: const Icon(Icons.height),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      hintText: 'Ej: 105',
                                    ),
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    onChanged: _modoEdicion ? (value) => _calcularIMC() : null,
                                  ),
                                ),
                              ],
                            ),
                            
                            if (_imcCalculado != null) ...[
                              const SizedBox(height: 16),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: _getColorByClasificacion(_clasificacionIMC),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: _getBorderColorByClasificacion(_clasificacionIMC),
                                    width: 2,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Text(
                                      'IMC: ${_imcCalculado!.toStringAsFixed(2)}',
                                      style: const TextStyle(
                                        fontSize: 24,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(
                                      _clasificacionIMC ?? 'Sin clasificar',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: _getBorderColorByClasificacion(_clasificacionIMC),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _nombresController.dispose();
    _apellidosController.dispose();
    _dniNinoController.dispose();
    _residenciaController.dispose();
    _nombreTutorController.dispose();
    _dniPadreController.dispose();
    _pesoController.dispose();
    _tallaController.dispose();
    super.dispose();
  }
}