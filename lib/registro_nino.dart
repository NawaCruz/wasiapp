import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'cuestionario_nino.dart'; // Importación añadida

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
  
  DateTime? _fechaNacimiento;
  String? _sexoSeleccionado;
  bool _isLoading = false;
  
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

      // Preparar datos del niño para pasar al cuestionario
      Map<String, dynamic> datosNino = {
        'nombres': _nombresController.text.trim(),
        'apellidos': _apellidosController.text.trim(),
        'dniNino': _dniNinoController.text.trim(),
        'fechaNacimiento': Timestamp.fromDate(_fechaNacimiento!),
        'sexo': _sexoSeleccionado,
        'residencia': _residenciaController.text.trim(),
        'nombreTutor': _nombreTutorController.text.trim(),
        'dniPadre': _dniPadreController.text.trim(),
      };

      // Navegar al cuestionario en lugar de guardar directamente
      if (mounted) {
        setState(() {
          _isLoading = false;
        });

        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => CuestionarioNinoScreen(datosNino: datosNino),
          ),
        );
      }
    }
  }

  void _limpiarFormulario() {
    _formKey.currentState?.reset();
    setState(() {
      _fechaNacimiento = null;
      _sexoSeleccionado = null;
    });
    _nombresController.clear();
    _apellidosController.clear();
    _dniNinoController.clear();
    _residenciaController.clear();
    _nombreTutorController.clear();
    _dniPadreController.clear();
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
                    const SizedBox(height: 40),

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
                                'Siguiente',
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
    super.dispose();
  }
}
