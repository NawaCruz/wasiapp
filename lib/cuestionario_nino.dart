import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home.dart'; // Importación correcta de MainHomeScreen

class CuestionarioNinoScreen extends StatefulWidget {
  final Map<String, dynamic> datosNino;

  const CuestionarioNinoScreen({
    super.key,
    required this.datosNino,
  });

  @override
  State<CuestionarioNinoScreen> createState() => _CuestionarioNinoScreenState();
}

class _CuestionarioNinoScreenState extends State<CuestionarioNinoScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // Variables para las respuestas del cuestionario
  String? _tipoParto;
  int? _semanasGestacion;
  double? _pesoNacimiento;
  double? _tallaNacimiento;
  String? _alimentacionActual;
  bool? _vacunasCompletas;
  String? _enfermedadesCronicas;
  String? _alergias;
  String? _medicamentos;
  String? _observaciones;

  final List<String> _opcionesParto = [
    'Seleccionar',
    'Parto natural',
    'Cesárea',
    'Parto inducido',
    'Otro'
  ];

  final List<String> _opcionesAlimentacion = [
    'Seleccionar',
    'Lactancia materna exclusiva',
    'Lactancia mixta',
    'Fórmula infantil',
    'Alimentación complementaria',
    'Dieta familiar'
  ];

  Future<void> _guardarCuestionario() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Combinar datos del niño con el cuestionario
        Map<String, dynamic> datosCompletos = {
          ...widget.datosNino,
          'cuestionarioSalud': {
            'tipoParto': _tipoParto,
            'semanasGestacion': _semanasGestacion,
            'pesoNacimiento': _pesoNacimiento,
            'tallaNacimiento': _tallaNacimiento,
            'alimentacionActual': _alimentacionActual,
            'vacunasCompletas': _vacunasCompletas,
            'enfermedadesCronicas': _enfermedadesCronicas,
            'alergias': _alergias,
            'medicamentos': _medicamentos,
            'observaciones': _observaciones,
            'fechaCuestionario': FieldValue.serverTimestamp(),
          },
          'estadoRegistro': 'completo',
          'fechaRegistroCompleto': FieldValue.serverTimestamp(),
        };

        // Guardar en Firestore
        await FirebaseFirestore.instance.collection('ninos').add(datosCompletos);

        if (mounted) {
          // Mostrar éxito y regresar al home
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${widget.datosNino['nombres']} registrado exitosamente'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
            ),
          );

          // Navegar al home - CORREGIDO
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (context) => const MainHomeScreen()),
            (route) => false,
          );
        }
      } catch (e) {
        debugPrint('Error al guardar cuestionario: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error al guardar: $e'),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  void _omitirCuestionario() {
    _guardarDatosBasicos();
  }

  Future<void> _guardarDatosBasicos() async {
    setState(() {
      _isLoading = true;
    });

    try {
      Map<String, dynamic> datosBasicos = {
        ...widget.datosNino,
        'estadoRegistro': 'basico',
        'fechaRegistroBasico': FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('ninos').add(datosBasicos);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.datosNino['nombres']} registrado (sin cuestionario)'),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 3),
          ),
        );

        // Navegación corregida
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainHomeScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      debugPrint('Error al guardar datos básicos: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al guardar: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  String _calcularEdad() {
    try {
      if (widget.datosNino['fechaNacimiento'] != null) {
        Timestamp fechaNacimientoTimestamp = widget.datosNino['fechaNacimiento'] as Timestamp;
        DateTime fechaNacimiento = fechaNacimientoTimestamp.toDate();
        DateTime ahora = DateTime.now();
        
        int meses = (ahora.year - fechaNacimiento.year) * 12 +
                    ahora.month - fechaNacimiento.month;
        
        if (ahora.day < fechaNacimiento.day) {
          meses--;
        }
        
        return meses >= 0 ? meses.toString() : '0';
      }
    } catch (e) {
      debugPrint('Error calculando edad: $e');
    }
    return 'N/A';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuestionario de Salud'),
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
                    // Información del niño
                    Card(
                      elevation: 2,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Datos del Niño:',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text('Nombre: ${widget.datosNino['nombres']} ${widget.datosNino['apellidos']}'),
                            Text('DNI: ${widget.datosNino['dniNino']}'),
                            Text('Edad: ${_calcularEdad()} meses'),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    const Text(
                      'Cuestionario de Salud',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Complete la información de salud del niño (opcional)',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Tipo de parto
                    DropdownButtonFormField<String>(
                      value: _tipoParto,
                      decoration: InputDecoration(
                        labelText: 'Tipo de parto',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _opcionesParto.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value == 'Seleccionar' ? null : value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _tipoParto = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Semanas de gestación
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Semanas de gestación (opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        suffixText: 'semanas',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _semanasGestacion = int.tryParse(value);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Peso al nacer
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Peso al nacer (opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        suffixText: 'kg',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _pesoNacimiento = double.tryParse(value);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Talla al nacer
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Talla al nacer (opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        suffixText: 'cm',
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        if (value.isNotEmpty) {
                          _tallaNacimiento = double.tryParse(value);
                        }
                      },
                    ),
                    const SizedBox(height: 20),

                    // Alimentación actual
                    DropdownButtonFormField<String>(
                      value: _alimentacionActual,
                      decoration: InputDecoration(
                        labelText: 'Alimentación actual (opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      items: _opcionesAlimentacion.map((String value) {
                        return DropdownMenuItem<String>(
                          value: value == 'Seleccionar' ? null : value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _alimentacionActual = newValue;
                        });
                      },
                    ),
                    const SizedBox(height: 20),

                    // Vacunas completas
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.grey.shade50,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            '¿Vacunas completas para su edad?',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Radio<bool>(
                                value: true,
                                groupValue: _vacunasCompletas,
                                onChanged: (value) {
                                  setState(() {
                                    _vacunasCompletas = value;
                                  });
                                },
                              ),
                              const Text('Sí'),
                              const SizedBox(width: 20),
                              Radio<bool>(
                                value: false,
                                groupValue: _vacunasCompletas,
                                onChanged: (value) {
                                  setState(() {
                                    _vacunasCompletas = value;
                                  });
                                },
                              ),
                              const Text('No'),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Enfermedades crónicas
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Enfermedades crónicas (opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        _enfermedadesCronicas = value.isEmpty ? null : value;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Alergias
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Alergias conocidas (opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        _alergias = value.isEmpty ? null : value;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Medicamentos
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Medicamentos actuales (opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: 2,
                      onChanged: (value) {
                        _medicamentos = value.isEmpty ? null : value;
                      },
                    ),
                    const SizedBox(height: 20),

                    // Observaciones
                    TextFormField(
                      decoration: InputDecoration(
                        labelText: 'Observaciones adicionales (opcional)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: 3,
                      onChanged: (value) {
                        _observaciones = value.isEmpty ? null : value;
                      },
                    ),
                    const SizedBox(height: 40),

                    // Botón Guardar Completo
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _guardarCuestionario,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade700,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
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
                                'Guardar Cuestionario Completo',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Botón Omitir
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton(
                        onPressed: _isLoading ? null : _omitirCuestionario,
                        style: OutlinedButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          side: BorderSide(color: Colors.grey.shade400),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Omitir Cuestionario',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
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
}