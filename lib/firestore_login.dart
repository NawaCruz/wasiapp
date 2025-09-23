import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreLoginScreen extends StatefulWidget {
  const FirestoreLoginScreen({super.key});

  @override
  State<FirestoreLoginScreen> createState() => _FirestoreLoginScreenState();
}

class _FirestoreLoginScreenState extends State<FirestoreLoginScreen> {
  final _email = TextEditingController();
  final _pass  = TextEditingController();
  String? _error;

  Future<void> _login() async {
    setState(() => _error = null);
    final email = _email.text.trim();
    final pass  = _pass.text.trim();

    final qs = await FirebaseFirestore.instance
        .collection('usuario')
        .where('usuario', isEqualTo: email)
        .limit(1)
        .get();

    if (qs.docs.isEmpty) {
      setState(() => _error = 'Usuario no encontrado');
      return;
    }

    final data = qs.docs.first.data();
    if ((data['contraseña'] ?? '') != pass) {
      setState(() => _error = 'Contraseña incorrecta');
      return;
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const DemoHome()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _email, decoration: const InputDecoration(labelText: 'Usuario (email)')),
                const SizedBox(height: 12),
                TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Contraseña'), obscureText: true),
                const SizedBox(height: 16),
                ElevatedButton(onPressed: _login, child: const Text('Entrar')),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DemoHome extends StatelessWidget {
  const DemoHome({super.key});
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Login Firestore OK')),
    );
  }
}
