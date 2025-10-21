import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CampoTextoPersonalizado extends StatelessWidget {
  final String etiqueta;
  final String? pista;
  final TextEditingController controlador;
  final String? Function(String?)? validador;
  final TextInputType tipoTeclado;
  final bool textoOculto;
  final bool habilitado;
  final int lineasMaximas;
  final List<TextInputFormatter>? formateadores;
  final Widget? iconoPrefijo;
  final Widget? iconoSufijo;
  final void Function(String)? alCambiar;
  final void Function()? alTocar;
  final bool soloLectura;

  const CampoTextoPersonalizado({
    Key? key,
    required this.etiqueta,
    this.pista,
    required this.controlador,
    this.validador,
    this.tipoTeclado = TextInputType.text,
    this.textoOculto = false,
    this.habilitado = true,
    this.lineasMaximas = 1,
    this.formateadores,
    this.iconoPrefijo,
    this.iconoSufijo,
    this.alCambiar,
    this.alTocar,
    this.soloLectura = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          etiqueta,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controlador,
          validator: validador,
          keyboardType: tipoTeclado,
          obscureText: textoOculto,
          enabled: habilitado,
          maxLines: lineasMaximas,
          inputFormatters: formateadores,
          onChanged: alCambiar,
          onTap: alTocar,
          readOnly: soloLectura,
          decoration: InputDecoration(
            hintText: pista,
            prefixIcon: iconoPrefijo,
            suffixIcon: iconoSufijo,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Theme.of(context).primaryColor,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.grey, width: 0.5),
            ),
            filled: true,
            fillColor: habilitado 
                ? Colors.grey[50] 
                : Colors.grey[200],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
      ],
    );
  }
}