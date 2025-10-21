import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/validadores_app.dart';
import '../../domain/entities/nino.dart';
import '../widgets/boton_personalizado.dart';
import '../widgets/campo_texto_personalizado.dart';

class PaginaRegistrarNino extends StatefulWidget {
  const PaginaRegistrarNino({Key? key}) : super(key: key);

  @override
  State<PaginaRegistrarNino> createState() => _PaginaRegistrarNinoState();
}

class _PaginaRegistrarNinoState extends State<PaginaRegistrarNino> {
  final _claveFormulario = GlobalKey<FormState>();
  final _controladorDNI = TextEditingController();
  final _controladorNombres = TextEditingController();
  final _controladorApellidos = TextEditingController();
  final _controladorEdadMeses = TextEditingController();
  final _controladorPeso = TextEditingController();
  final _controladorTalla = TextEditingController();
  final _controladorHemoglobina = TextEditingController();
  
  String _sexo = 'M';
  bool _estaCargando = false;

  @override
  void dispose() {
    _controladorDNI.dispose();
    _controladorNombres.dispose();
    _controladorApellidos.dispose();
    _controladorEdadMeses.dispose();
    _controladorPeso.dispose();
    _controladorTalla.dispose();
    _controladorHemoglobina.dispose();
    super.dispose();
  }

  Future<void> _registrarNino() async {
    if (!_claveFormulario.currentState!.validate()) return;

    setState(() => _estaCargando = true);

    try {
      final peso = double.parse(_controladorPeso.text);
      final talla = double.parse(_controladorTalla.text);
      final hemoglobina = double.parse(_controladorHemoglobina.text);
      final imc = _calcularIMC(peso, talla);
      
      final nino = Nino(
        dniNino: _controladorDNI.text.trim(),
        nombres: _controladorNombres.text.trim(),
        apellidos: _controladorApellidos.text.trim(),
        fechaNacimiento: _calcularFechaNacimiento(),
        sexo: _sexo,
        peso: peso,
        talla: talla,
        imc: imc,
        clasificacionIMC: _clasificarIMC(imc),
        residencia: 'Por definir', // Valor temporal
        nombreTutor: 'Por definir', // Valor temporal
        dniPadre: '00000000', // Valor temporal
        anemia: hemoglobina < 11.0 ? 'Sí' : 'No',
        alimentosHierro: 'Por definir', // Valor temporal
        fatiga: 'Por definir', // Valor temporal
        alimentacionBalanceada: 'Por definir', // Valor temporal
        fechaRegistro: DateTime.now(),
      );

      // TODO: Implementar use case cuando esté disponible
      // final registrarUseCase = sl<RegistrarNinoUseCase>();
      // final exito = await registrarUseCase.call(nino);

      // Simulación temporal - usar el objeto nino creado
      print('Registrando niño: ${nino.nombreCompleto}');
      await Future.delayed(const Duration(seconds: 2));
      const exito = true;

      if (exito && mounted) {
        _mostrarDialogoExito();
      } else if (mounted) {
        _mostrarDialogoError('Error al registrar el niño. Intente nuevamente.');
      }
    } catch (e) {
      if (mounted) {
        _mostrarDialogoError('Error: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _estaCargando = false);
      }
    }
  }

  DateTime _calcularFechaNacimiento() {
    final ahora = DateTime.now();
    final meses = int.parse(_controladorEdadMeses.text);
    return DateTime(ahora.year, ahora.month - meses, ahora.day);
  }

  double _calcularIMC(double peso, double talla) {
    // IMC = peso (kg) / (talla (m))²
    final tallaEnMetros = talla / 100;
    return peso / (tallaEnMetros * tallaEnMetros);
  }

  String _clasificarIMC(double imc) {
    if (imc < 15.0) return 'Desnutrición severa';
    if (imc < 18.5) return 'Bajo peso';
    if (imc <= 25.0) return 'Normal';
    if (imc <= 30.0) return 'Sobrepeso';
    return 'Obesidad';
  }

  void _mostrarDialogoExito() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green, size: 28),
            SizedBox(width: 10),
            Text('¡Éxito!'),
          ],
        ),
        content: const Text('El niño ha sido registrado correctamente en el sistema.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _limpiarFormulario();
            },
            child: const Text('Registrar otro niño'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: const Text('Volver al inicio'),
          ),
        ],
      ),
    );
  }

  void _mostrarDialogoError(String mensaje) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.error, color: Colors.red, size: 28),
            SizedBox(width: 10),
            Text('Error'),
          ],
        ),
        content: Text(mensaje),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _limpiarFormulario() {
    _claveFormulario.currentState?.reset();
    _controladorDNI.clear();
    _controladorNombres.clear();
    _controladorApellidos.clear();
    _controladorEdadMeses.clear();
    _controladorPeso.clear();
    _controladorTalla.clear();
    _controladorHemoglobina.clear();
    setState(() => _sexo = 'M');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registrar Nuevo Niño'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _claveFormulario,
          child: Column(
            children: [
              // Encabezado informativo
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Complete todos los campos para registrar al niño en el sistema.',
                        style: TextStyle(color: Colors.blue),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // DNI
              CampoTextoPersonalizado(
                etiqueta: 'DNI del Niño',
                pista: 'Ingrese los 8 dígitos del DNI',
                controlador: _controladorDNI,
                tipoTeclado: TextInputType.number,
                formateadores: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(8),
                ],
                validador: ValidadoresApp.validarDNI,
                iconoPrefijo: const Icon(Icons.credit_card),
              ),
              const SizedBox(height: 20),

              // Nombres
              CampoTextoPersonalizado(
                etiqueta: 'Nombres',
                pista: 'Ingrese los nombres del niño',
                controlador: _controladorNombres,
                tipoTeclado: TextInputType.name,
                validador: ValidadoresApp.validarNombre,
                iconoPrefijo: const Icon(Icons.person),
              ),
              const SizedBox(height: 20),

              // Apellidos
              CampoTextoPersonalizado(
                etiqueta: 'Apellidos',
                pista: 'Ingrese los apellidos del niño',
                controlador: _controladorApellidos,
                tipoTeclado: TextInputType.name,
                validador: ValidadoresApp.validarNombre,
                iconoPrefijo: const Icon(Icons.person_outline),
              ),
              const SizedBox(height: 20),

              // Edad en meses
              CampoTextoPersonalizado(
                etiqueta: 'Edad (en meses)',
                pista: 'De 0 a 72 meses (6 años)',
                controlador: _controladorEdadMeses,
                tipoTeclado: TextInputType.number,
                formateadores: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(2),
                ],
                validador: ValidadoresApp.validarEdadMeses,
                iconoPrefijo: const Icon(Icons.calendar_today),
              ),
              const SizedBox(height: 20),

              // Selección de sexo
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Sexo del Niño',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.grey[50],
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Masculino'),
                            value: 'M',
                            groupValue: _sexo,
                            onChanged: (valor) => setState(() => _sexo = valor!),
                            activeColor: Colors.blue,
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Femenino'),
                            value: 'F',
                            groupValue: _sexo,
                            onChanged: (valor) => setState(() => _sexo = valor!),
                            activeColor: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Peso
              CampoTextoPersonalizado(
                etiqueta: 'Peso (kilogramos)',
                pista: 'Ejemplo: 12.5',
                controlador: _controladorPeso,
                tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                validador: ValidadoresApp.validarPeso,
                iconoPrefijo: const Icon(Icons.monitor_weight),
              ),
              const SizedBox(height: 20),

              // Talla
              CampoTextoPersonalizado(
                etiqueta: 'Talla (centímetros)',
                pista: 'Ejemplo: 85.5',
                controlador: _controladorTalla,
                tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                validador: ValidadoresApp.validarTalla,
                iconoPrefijo: const Icon(Icons.height),
              ),
              const SizedBox(height: 20),

              // Hemoglobina
              CampoTextoPersonalizado(
                etiqueta: 'Hemoglobina (g/dL)',
                pista: 'Ejemplo: 11.2',
                controlador: _controladorHemoglobina,
                tipoTeclado: const TextInputType.numberWithOptions(decimal: true),
                validador: ValidadoresApp.validarHemoglobina,
                iconoPrefijo: const Icon(Icons.bloodtype),
              ),
              const SizedBox(height: 30),

              // Botones de acción
              Row(
                children: [
                  Expanded(
                    child: BotonPersonalizado(
                      texto: 'Limpiar Todo',
                      alPresionar: _limpiarFormulario,
                      colorFondo: Colors.grey.shade600,
                      icono: Icons.clear_all,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: BotonPersonalizado(
                      texto: 'Registrar Niño',
                      alPresionar: _registrarNino,
                      colorFondo: Colors.green,
                      icono: Icons.save,
                      estaCargando: _estaCargando,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Información adicional
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.yellow.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.yellow.shade300),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.lightbulb_outline, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Asegúrese de que todos los datos sean correctos antes de registrar.',
                        style: TextStyle(fontSize: 12, color: Colors.black87),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}