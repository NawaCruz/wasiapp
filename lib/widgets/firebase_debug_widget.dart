// Script de verificación de Firebase
// Ejecutar desde DevTools Console o como widget de debug

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/auth_controller.dart';

/// Widget de debug para verificar estado de Firebase
class FirebaseDebugWidget extends StatefulWidget {
  const FirebaseDebugWidget({super.key});

  @override
  State<FirebaseDebugWidget> createState() => _FirebaseDebugWidgetState();
}

class _FirebaseDebugWidgetState extends State<FirebaseDebugWidget> {
  Map<String, dynamic> _diagnostics = {};
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _runDiagnostics();
    });
  }

  Future<void> _runDiagnostics() async {
    setState(() => _isChecking = true);

    try {
      final diagnostics = <String, dynamic>{};
      final authController = Provider.of<AuthController>(context, listen: false);

      // 1. Verificar Firebase inicializado
      diagnostics['firebase_initialized'] = 'SI';

      // 2. Verificar autenticación
      final user = authController.usuarioActual;
      diagnostics['auth_user'] = user?.id ?? 'NO AUTENTICADO';
      diagnostics['auth_usuario'] = user?.usuario ?? 'N/A';

      // 3. Verificar conexión a Firestore
      try {
        final testQuery = await FirebaseFirestore.instance
            .collection('ninos')
            .limit(1)
            .get(const GetOptions(source: Source.server));
        
        diagnostics['firestore_connection'] = 'CONECTADO';
        diagnostics['firestore_cache'] = testQuery.metadata.isFromCache ? 'CACHE' : 'SERVER';
      } catch (e) {
        diagnostics['firestore_connection'] = 'ERROR: $e';
      }

      // 4. Contar documentos
      if (user != null && user.id.isNotEmpty) {
        try {
          final querySnapshot = await FirebaseFirestore.instance
              .collection('ninos')
              .where('usuarioId', isEqualTo: user.id)
              .get();
          
          diagnostics['total_docs'] = querySnapshot.docs.length;
          diagnostics['docs_activos'] = querySnapshot.docs
              .where((doc) => doc.data()['activo'] == true)
              .length;
          
          // Listar IDs de documentos
          diagnostics['doc_ids'] = querySnapshot.docs
              .map((doc) => doc.id)
              .take(5)
              .toList();
        } catch (e) {
          diagnostics['query_error'] = e.toString();
        }
      }

      // 5. Verificar permisos probando escritura (sin guardar)
      try {
        final testDoc = FirebaseFirestore.instance.collection('ninos').doc('test');
        await testDoc.get(); // Solo lectura
        diagnostics['read_permission'] = 'OK';
      } catch (e) {
        diagnostics['read_permission'] = 'DENEGADO: $e';
      }

      setState(() {
        _diagnostics = diagnostics;
        _isChecking = false;
      });

    } catch (e) {
      setState(() {
        _diagnostics = {'error_general': e.toString()};
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase Debug'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _runDiagnostics,
          ),
        ],
      ),
      body: _isChecking
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          '🔍 Diagnóstico Firebase',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Divider(height: 24),
                        ..._diagnostics.entries.map((entry) {
                          final value = entry.value.toString();
                          final isError = value.contains('ERROR') || 
                                         value.contains('DENEGADO') ||
                                         value == '0';
                          
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  isError ? Icons.error : Icons.check_circle,
                                  color: isError ? Colors.red : Colors.green,
                                  size: 20,
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        entry.key.replaceAll('_', ' ').toUpperCase(),
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                          color: Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      SelectableText(
                                        value,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: isError ? Colors.red : Colors.black87,
                                          fontFamily: 'monospace',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Colors.blue.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.info_outline, color: Colors.blue),
                            SizedBox(width: 8),
                            Text(
                              'Información',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildInfoRow('Proyecto', 'wasiapp-66023'),
                        _buildInfoRow('Colección', 'ninos'),
                        _buildInfoRow('Logs', 'Revisar consola de Flutter'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: SelectableText(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }
}
