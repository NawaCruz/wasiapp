import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // FirebaseFirestore y FieldValue

class CreateFirestoreUserScreen extends StatefulWidget {
  const CreateFirestoreUserScreen({super.key});

  @override
  State<CreateFirestoreUserScreen> createState() =>
      _CreateFirestoreUserScreenState();
}

class _CreateFirestoreUserScreenState extends State<CreateFirestoreUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _password2 = TextEditingController();
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _password2.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.isEmpty) return 'Ingrese un email';
    final ok = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v);
    return ok ? null : 'Email inválido';
  }

  String? _validatePass(String? v) {
    if (v == null || v.isEmpty) return 'Ingrese una contraseña';
    if (v.length < 6) return 'Mínimo 6 caracteres';
    return null;
  }

  Future<void> _crearUsuario() async {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text.trim() != _password2.text.trim()) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final email = _email.text.trim();
      final pass = _password.text.trim();

      // Verificar si ya existe
      final dup = await FirebaseFirestore.instance
          .collection('usuario')
          .where('usuario', isEqualTo: email)
          .limit(1)
          .get();

      if (dup.docs.isNotEmpty) {
        setState(() => _error = 'El correo ya está registrado');
        return;
      }

      // Crear documento
      await FirebaseFirestore.instance.collection('usuario').add({
        'usuario': email,
        'contraseña': pass, // Plano por ahora (en producción: usar Firebase Auth o hash)
        'creado_en': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Usuario creado exitosamente')),
      );

      // Limpiar y volver al login
      _email.clear();
      _password.clear();
      _password2.clear();
      Navigator.pop(context);
    } catch (e) {
      setState(() => _error = 'No se pudo crear el usuario. Intente otra vez.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ===================== UI CON ESTILO =====================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _AppColors.bg,
      body: Stack(
        children: [
          // Header morado con diagonal
          ClipPath(
            clipper: _DiagonalClipper(),
            child: Container(
              height: 260,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_AppColors.purpleDark, _AppColors.purple],
                ),
              ),
            ),
          ),

          // Logo circular que flota
          Positioned(
            top: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    )
                  ],
                ),
                child: const Center(
                  child: Text(
                    'WASI',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      fontSize: 18,
                      color: _AppColors.purpleDark,
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Tarjeta blanca con el formulario
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 180, 20, 24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: Container(
                  padding: const EdgeInsets.fromLTRB(22, 24, 22, 26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 18,
                        offset: Offset(0, 10),
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tabs SIGN IN / SIGN UP (solo UI)
                        Row(
                          children: const [
                            Opacity(
                              opacity: .4,
                              child: Text(
                                'SIGN IN',
                                style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Text('  /  '),
                            Text(
                              'SIGN UP',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: _AppColors.purple,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 22),

                        _RoundedField(
                          controller: _email,
                          label: 'Email',
                          icon: Icons.mail_outline,
                          keyboardType: TextInputType.emailAddress,
                          validator: _validateEmail,
                        ),
                        const SizedBox(height: 14),

                        _RoundedField(
                          controller: _password,
                          label: 'Contraseña',
                          icon: Icons.lock_outline,
                          obscureText: true,
                          validator: _validatePass,
                        ),
                        const SizedBox(height: 14),

                        _RoundedField(
                          controller: _password2,
                          label: 'Repetir contraseña',
                          icon: Icons.lock_reset_outlined,
                          obscureText: true,
                          validator: _validatePass,
                          onFieldSubmitted: (_) => _crearUsuario(),
                        ),
                        const SizedBox(height: 16),

                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Text(
                              _error!,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _crearUsuario,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _AppColors.purple,
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: _isLoading
                                ? const SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2.2,
                                      valueColor:
                                          AlwaysStoppedAnimation(Colors.white),
                                    ),
                                  )
                                : const Text(
                                    'SIGN UP',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: .4,
                                    ),
                                  ),
                          ),
                        ),

                        const SizedBox(height: 8),

                        Center(
                          child: TextButton(
                            onPressed:
                                _isLoading ? null : () => Navigator.pop(context),
                            child: const Text(
                              '¿Ya tienes cuenta? Inicia sesión',
                              style: TextStyle(color: _AppColors.purple),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ===================== HELPERS =====================

class _DiagonalClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final p = Path();
    p.lineTo(0, size.height * .70);
    p.lineTo(size.width * .64, size.height * .50);
    p.lineTo(size.width, size.height * .68);
    p.lineTo(size.width, 0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}

class _RoundedField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final bool obscureText;
  final void Function(String)? onFieldSubmitted;

  const _RoundedField({
    Key? key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.validator,
    this.obscureText = false,
    this.onFieldSubmitted,
  }): super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      obscureText: obscureText,
      keyboardType: keyboardType,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(fontWeight: FontWeight.w600),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: _AppColors.purple),
        filled: true,
        fillColor: _AppColors.field,
        contentPadding:
            const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(28),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _AppColors {
  static const bg = Color(0xFF5C2DB5); // fondo morado
  static const purpleDark = Color(0xFF45239A);
  static const purple = Color(0xFF6C33D8);
  static const field = Color(0xFFF2E9FF);
}
