import 'package:flutter/material.dart';

class BotonPersonalizado extends StatelessWidget {
  final String texto;
  final VoidCallback alPresionar;
  final IconData? icono;
  final Color? colorFondo;
  final Color? colorTexto;
  final double? ancho;
  final double? alto;
  final bool estaCargando;
  final bool estaHabilitado;

  const BotonPersonalizado({
    Key? key,
    required this.texto,
    required this.alPresionar,
    this.icono,
    this.colorFondo,
    this.colorTexto,
    this.ancho,
    this.alto = 50,
    this.estaCargando = false,
    this.estaHabilitado = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ancho ?? double.infinity,
      height: alto,
      child: ElevatedButton(
        onPressed: estaHabilitado && !estaCargando ? alPresionar : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: colorFondo ?? Theme.of(context).primaryColor,
          foregroundColor: colorTexto ?? Colors.white,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        ),
        child: estaCargando
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (icono != null) ...[
                    Icon(icono, size: 22),
                    const SizedBox(width: 10),
                  ],
                  Flexible(
                    child: Text(
                      texto,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}