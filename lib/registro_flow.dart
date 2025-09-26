import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegistroNinoFlow extends StatefulWidget {
  const RegistroNinoFlow({super.key});

  @override
  State<RegistroNinoFlow> createState() => _RegistroNinoFlowState();
}

class _RegistroNinoFlowState extends State<RegistroNinoFlow> {
  final PageController _pageController = PageController();
  int _currentStep = 0;
  
  // Controladores para datos básicos
  final _formKey1 = GlobalKey<FormState>();
  final _nombresController = TextEditingController();
  final _apellidosController = TextEditingController();
  final _dniNinoController = TextEditingController();
  final _residenciaController = TextEditingController();
  final _nombreTutorController = TextEditingController();
  final _dniPadreController = TextEditingController();
  
  DateTime? _fechaNacimiento;
  String? _sexoSeleccionado;
  
  // Controladores para cuestionario de salud
  final _formKey2 = GlobalKey<FormState>();
  String? _anemia;
  String? _alimentosHierro;
  String? _fatiga;
  String? _alimentacionBalanceada;
  String? _residenciaSeleccionada;
  
  // Controladores para medidas antropométricas
  final _formKey3 = GlobalKey<FormState>();
  final _pesoController = TextEditingController();
  final _tallaController = TextEditingController();
  
  double? _imcCalculado;
  String? _clasificacionIMC;
  bool _isLoading = false;
  
  final List<String> _opcionesSexo = ['Seleccionar', 'Masculino', 'Femenino'];
  final List<String> _opcionesSiNo = ['Seleccionar', 'Sí', 'No'];
  final List<String> _opcionesResidencia = ['Huancayo', 'El Tambo', 'Chilca', 'Pilcomayo', 'Sicaya', 'Otra'];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _getTitleByStep(),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF1976D2),
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      backgroundColor: const Color(0xFFF8F9FA),
      body: Column(
        children: [
          // Indicador de progreso mejorado
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Paso ${_currentStep + 1} de 3',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF666666),
                      ),
                    ),
                    Text(
                      '${(((_currentStep + 1) / 3) * 100).round()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1976D2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / 3,
                    backgroundColor: const Color(0xFFE3F2FD),
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1976D2)),
                    minHeight: 8,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStepIndicator(0, 'Datos\nBásicos'),
                    _buildStepIndicator(1, 'Cuestionario\nSalud'),
                    _buildStepIndicator(2, 'Medidas\nAntropométricas'),
                  ],
                ),
              ],
            ),
          ),
          // Contenido de las páginas
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentStep = index;
                });
              },
              children: [
                _buildRegistroBasico(),
                _buildCuestionarioSalud(),
                _buildMedidasAntropometricas(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator(int step, String label) {
    bool isActive = step <= _currentStep;
    return Column(
      children: [
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? const Color(0xFF1976D2) : const Color(0xFFE0E0E0),
          ),
          child: Center(
            child: isActive
                ? const Icon(Icons.check, color: Colors.white, size: 18)
                : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : const Color(0xFF9E9E9E),
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 10,
            color: isActive ? const Color(0xFF1976D2) : const Color(0xFF9E9E9E),
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _getTitleByStep() {
    switch (_currentStep) {
      case 0:
        return 'Datos Básicos';
      case 1:
        return 'Cuestionario de Salud';
      case 2:
        return 'Medidas Antropométricas';
      default:
        return 'Registro de Niño';
    }
  }

  Widget _buildRegistroBasico() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8F9FA),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Form(
        key: _formKey1,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Información del niño
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
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
                            color: const Color(0xFF1976D2).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.child_care,
                            color: Color(0xFF1976D2),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Información del Niño',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      controller: _nombresController,
                      label: 'Nombres',
                      hint: 'Ingrese los nombres del niño',
                      icon: Icons.person,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Los nombres son obligatorios';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _apellidosController,
                      label: 'Apellidos',
                      hint: 'Ingrese los apellidos del niño',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Los apellidos son obligatorios';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _dniNinoController,
                      label: 'DNI del Niño',
                      hint: 'Ingrese el DNI del niño',
                      icon: Icons.badge,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El DNI es obligatorio';
                        }
                        if (value.length != 8) {
                          return 'El DNI debe tener 8 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    // Fecha de nacimiento
                    InkWell(
                      onTap: () => _selectDate(context),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFE0E0E0)),
                          borderRadius: BorderRadius.circular(12),
                          color: const Color(0xFFFAFAFA),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today, color: Color(0xFF1976D2), size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _fechaNacimiento == null
                                    ? 'Seleccione fecha de nacimiento'
                                    : DateFormat('dd/MM/yyyy').format(_fechaNacimiento!),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: _fechaNacimiento == null 
                                      ? const Color(0xFF9E9E9E) 
                                      : const Color(0xFF333333),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      value: _sexoSeleccionado,
                      label: 'Sexo',
                      hint: 'Seleccione el sexo del niño',
                      icon: Icons.wc,
                      items: _opcionesSexo,
                      onChanged: (value) {
                        setState(() {
                          _sexoSeleccionado = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value == 'Seleccionar') {
                          return 'Debe seleccionar el sexo';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildDropdownField(
                      value: _residenciaSeleccionada,
                      label: 'Distrito de Residencia',
                      hint: 'Seleccione el distrito de residencia',
                      icon: Icons.map,
                      items: _opcionesResidencia,
                      onChanged: (value) {
                        setState(() {
                          _residenciaSeleccionada = value;
                        });
                      },
                      validator: (value) {
                        if (value == null || value == 'Seleccionar') {
                          return 'Debe seleccionar el distrito de residencia';
                        }
                        return null;
                      },
                    )
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Información del tutor
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
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
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.family_restroom,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Información del Tutor',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      controller: _nombreTutorController,
                      label: 'Nombre del Tutor',
                      hint: 'Ingrese el nombre del tutor',
                      icon: Icons.person_add,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El nombre del tutor es obligatorio';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _dniPadreController,
                      label: 'DNI del Tutor',
                      hint: 'Ingrese el DNI del tutor',
                      icon: Icons.badge_outlined,
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El DNI del tutor es obligatorio';
                        }
                        if (value.length != 8) {
                          return 'El DNI debe tener 8 dígitos';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              // Botón siguiente mejorado
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1976D2), Color(0xFF1565C0)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1976D2).withOpacity(0.3),
                      spreadRadius: 0,
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: () {
                    if (_formKey1.currentState!.validate() && _fechaNacimiento != null) {
                      _nextStep();
                    } else if (_fechaNacimiento == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Por favor, seleccione la fecha de nacimiento'),
                          backgroundColor: Color(0xFFE53935),
                        ),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  icon: const Icon(
                    Icons.arrow_forward,
                    color: Colors.white,
                    size: 20,
                  ),
                  label: const Text(
                    'Continuar al Cuestionario de Salud',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
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

  Widget _buildCuestionarioSalud() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8F9FA),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Form(
        key: _formKey2,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
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
                            color: const Color(0xFF4CAF50).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.health_and_safety,
                            color: Color(0xFF4CAF50),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Cuestionario de Salud',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF4CAF50),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildHealthQuestion(
                      '¿El niño/a ha tenido anemia?',
                      Icons.bloodtype,
                      _anemia,
                      (value) {
                        setState(() {
                          _anemia = value;
                        });
                      },
                      'Por favor, seleccione si ha tenido anemia',
                    ),
                    const SizedBox(height: 20),
                    _buildHealthQuestion(
                      '¿Consume alimentos ricos en hierro?',
                      Icons.restaurant,
                      _alimentosHierro,
                      (value) {
                        setState(() {
                          _alimentosHierro = value;
                        });
                      },
                      'Por favor, indique si consume alimentos ricos en hierro',
                    ),
                    const SizedBox(height: 20),
                    _buildHealthQuestion(
                      '¿Presenta fatiga o cansancio frecuente?',
                      Icons.battery_alert,
                      _fatiga,
                      (value) {
                        setState(() {
                          _fatiga = value;
                        });
                      },
                      'Por favor, indique si presenta fatiga frecuente',
                    ),
                    const SizedBox(height: 20),
                    _buildHealthQuestion(
                      '¿Lleva una alimentación balanceada?',
                      Icons.eco,
                      _alimentacionBalanceada,
                      (value) {
                        setState(() {
                          _alimentacionBalanceada = value;
                        });
                      },
                      'Por favor, indique si lleva alimentación balanceada',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _previousStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF666666),
                          size: 20,
                        ),
                        label: const Text(
                          'Anterior',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4CAF50).withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () {
                          if (_formKey2.currentState!.validate()) {
                            _nextStep();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 20,
                        ),
                        label: const Text(
                          'Continuar a Medidas',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
    );
  }

  Widget _buildMedidasAntropometricas() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8F9FA),
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: Form(
        key: _formKey3,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.08),
                      spreadRadius: 0,
                      blurRadius: 20,
                      offset: const Offset(0, 4),
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
                            color: const Color(0xFFFF9800).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.monitor_weight,
                            color: Color(0xFFFF9800),
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Medidas Antropométricas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFFFF9800),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    _buildInputField(
                      controller: _pesoController,
                      label: 'Peso (kg)',
                      hint: 'Ej: 25.5',
                      icon: Icons.monitor_weight,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'El peso es obligatorio';
                        }
                        // Limpiar el valor y verificar que solo contenga números y punto decimal
                        String cleanValue = value.trim().replaceAll(',', '.');
                        double? peso = double.tryParse(cleanValue);
                        if (peso == null || peso <= 0) {
                          return 'Ingrese un peso válido (solo números)';
                        }
                        if (peso > 200) {
                          return 'El peso parece demasiado alto';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Limpiar automáticamente caracteres no válidos
                        String cleanValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
                        if (cleanValue != value) {
                          _pesoController.value = _pesoController.value.copyWith(
                            text: cleanValue,
                            selection: TextSelection.collapsed(offset: cleanValue.length),
                          );
                        }
                        _calcularIMC();
                      },
                    ),
                    const SizedBox(height: 12),
                    _buildInputField(
                      controller: _tallaController,
                      label: 'Talla (cm)',
                      hint: 'Ej: 120',
                      icon: Icons.height,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'La talla es obligatoria';
                        }
                        // Limpiar el valor y verificar que solo contenga números y punto decimal
                        String cleanValue = value.trim().replaceAll(',', '.');
                        double? talla = double.tryParse(cleanValue);
                        if (talla == null || talla <= 0) {
                          return 'Ingrese una talla válida (solo números)';
                        }
                        if (talla > 250) {
                          return 'La talla parece demasiado alta';
                        }
                        return null;
                      },
                      onChanged: (value) {
                        // Limpiar automáticamente caracteres no válidos
                        String cleanValue = value.replaceAll(RegExp(r'[^0-9.]'), '');
                        if (cleanValue != value) {
                          _tallaController.value = _tallaController.value.copyWith(
                            text: cleanValue,
                            selection: TextSelection.collapsed(offset: cleanValue.length),
                          );
                        }
                        _calcularIMC();
                      },
                    ),
                    if (_imcCalculado != null) ...[
                      const SizedBox(height: 24),
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFF1976D2).withOpacity(0.1),
                              const Color(0xFF1976D2).withOpacity(0.05),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF1976D2).withOpacity(0.2),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF1976D2),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.analytics,
                                    color: Colors.white,
                                    size: 18,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Resultados del IMC',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Color(0xFF1976D2),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.1),
                                    spreadRadius: 0,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'IMC: ${_imcCalculado!.toStringAsFixed(2)}',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w700,
                                            color: Color(0xFF333333),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Clasificación: $_clasificacionIMC',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: _getColorClasificacion(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: _getColorClasificacion().withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      _getIconClasificacion(),
                                      color: _getColorClasificacion(),
                                      size: 28,
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
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _previousStep,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF666666),
                          size: 20,
                        ),
                        label: const Text(
                          'Anterior',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF666666),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: _isLoading
                            ? const LinearGradient(
                                colors: [Color(0xFFBDBDBD), Color(0xFF9E9E9E)],
                              )
                            : const LinearGradient(
                                colors: [Color(0xFF4CAF50), Color(0xFF388E3C)],
                              ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: (_isLoading ? const Color(0xFF9E9E9E) : const Color(0xFF4CAF50)).withOpacity(0.3),
                            spreadRadius: 0,
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : _registrarNino,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        icon: _isLoading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(
                                Icons.save,
                                color: Colors.white,
                                size: 20,
                              ),
                        label: Text(
                          _isLoading ? 'Registrando...' : 'Registrar Niño',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
    );
  }

  // Funciones helper para UI mejorada
  Widget _buildInputField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    void Function(String)? onChanged,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1976D2), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
      keyboardType: keyboardType,
      validator: validator,
      onChanged: onChanged,
    );
  }

  Widget _buildDropdownField({
    String? value,
    required String label,
    required String hint,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
    String? Function(String?)? validator,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: const Color(0xFF1976D2), size: 20),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        filled: true,
        fillColor: const Color(0xFFFAFAFA),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        isDense: true,
      ),
      items: items.map((String item) {
        return DropdownMenuItem<String>(
          value: item,
          child: Text(item, style: const TextStyle(fontSize: 14)),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }

  Widget _buildHealthQuestion(
    String question,
    IconData icon,
    String? value,
    void Function(String?) onChanged,
    String validationMessage,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              color: const Color(0xFF4CAF50),
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                question,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(0xFFE0E0E0),
            ),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              hintText: 'Seleccione una opción',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: const Color(0xFFFAFAFA),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              isDense: true,
            ),
            items: _opcionesSiNo.map((String option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(
                  option,
                  style: const TextStyle(
                    fontSize: 14,
                  ),
                ),
              );
            }).toList(),
            onChanged: onChanged,
            validator: (val) {
              if (val == null || val == 'Seleccionar') {
                return validationMessage;
              }
              return null;
            },
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _fechaNacimiento ?? DateTime.now().subtract(const Duration(days: 365 * 5)),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1976D2),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _fechaNacimiento) {
      setState(() {
        _fechaNacimiento = picked;
      });
    }
  }

  void _calcularIMC() {
    if (_pesoController.text.isNotEmpty && _tallaController.text.isNotEmpty) {
      // Limpiar valores antes de convertir
      String pesoText = _pesoController.text.trim().replaceAll(',', '.');
      String tallaText = _tallaController.text.trim().replaceAll(',', '.');
      
      double? peso = double.tryParse(pesoText);
      double? talla = double.tryParse(tallaText);
      
      if (peso != null && talla != null && talla > 0 && peso > 0) {
        double tallaEnMetros = talla / 100;
        double imc = peso / (tallaEnMetros * tallaEnMetros);
        
        setState(() {
          _imcCalculado = imc;
          _clasificacionIMC = _clasificarIMC(imc);
        });
      } else {
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

  String _clasificarIMC(double imc) {
    if (_fechaNacimiento == null) return 'No se puede calcular sin fecha de nacimiento';
    
    int edad = DateTime.now().year - _fechaNacimiento!.year;
    
    if (edad < 2) {
      // Para menores de 2 años, usar percentiles específicos
      if (imc < 14.0) return 'Bajo peso';
      if (imc < 18.0) return 'Normal';
      if (imc < 20.0) return 'Sobrepeso';
      return 'Obesidad';
    } else if (edad <= 5) {
      // Para 2-5 años
      if (imc < 13.0) return 'Bajo peso';
      if (imc < 17.0) return 'Normal';
      if (imc < 19.0) return 'Sobrepeso';
      return 'Obesidad';
    } else if (edad <= 12) {
      // Para 6-12 años
      if (imc < 14.0) return 'Bajo peso';
      if (imc < 19.0) return 'Normal';
      if (imc < 23.0) return 'Sobrepeso';
      return 'Obesidad';
    } else {
      // Para 13-18 años
      if (imc < 16.0) return 'Bajo peso';
      if (imc < 22.0) return 'Normal';
      if (imc < 26.0) return 'Sobrepeso';
      return 'Obesidad';
    }
  }

  Color _getColorClasificacion() {
    switch (_clasificacionIMC) {
      case 'Bajo peso':
        return Colors.orange;
      case 'Normal':
        return Colors.green;
      case 'Sobrepeso':
        return Colors.orange;
      case 'Obesidad':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getIconClasificacion() {
    switch (_clasificacionIMC) {
      case 'Bajo peso':
        return Icons.trending_down;
      case 'Normal':
        return Icons.check_circle;
      case 'Sobrepeso':
        return Icons.trending_up;
      case 'Obesidad':
        return Icons.warning;
      default:
        return Icons.help;
    }
  }

  void _nextStep() {
    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _registrarNino() async {
    if (!_formKey3.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
    });

    try {
      // Limpiar y validar los valores numéricos de forma segura
      String pesoText = _pesoController.text.trim().replaceAll(',', '.');
      String tallaText = _tallaController.text.trim().replaceAll(',', '.');
      
      double? peso = double.tryParse(pesoText);
      double? talla = double.tryParse(tallaText);
      
      if (peso == null || talla == null) {
        throw Exception('Error en los valores numéricos ingresados. Por favor, verifique que solo contengan números.');
      }

      if (peso <= 0 || talla <= 0) {
        throw Exception('Los valores numéricos deben ser mayores a cero.');
      }

      await FirebaseFirestore.instance.collection('ninos').add({
        'nombres': _nombresController.text.trim(),
        'apellidos': _apellidosController.text.trim(),
        'dniNino': _dniNinoController.text.trim(),
        'fechaNacimiento': _fechaNacimiento,
        'sexo': _sexoSeleccionado,
        'residencia': _residenciaController.text.trim(),
        'nombreTutor': _nombreTutorController.text.trim(),
        'dniPadre': _dniPadreController.text.trim(),
        'anemia': _anemia,
        'alimentosHierro': _alimentosHierro,
        'fatiga': _fatiga,
        'alimentacionBalanceada': _alimentacionBalanceada,
        'peso': peso,
        'talla': talla,
        'imc': _imcCalculado,
        'clasificacionIMC': _clasificacionIMC,
        'fechaRegistro': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        // Mostrar pantalla de éxito
        await _mostrarPantallaExito();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(child: Text('Error al registrar: $e')),
              ],
            ),
            backgroundColor: const Color(0xFFE53935),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _mostrarPantallaExito() async {
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Container(
            padding: const EdgeInsets.all(30),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4CAF50),
                  Color(0xFF45A049),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '¡Registro Exitoso!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'El niño ${_nombresController.text.trim()} ${_apellidosController.text.trim()} ha sido registrado correctamente.',
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // Cerrar diálogo
                      Navigator.of(context).pop(); // Cerrar pantalla de registro
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: const Color(0xFF4CAF50),
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continuar',
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
        );
      },
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
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