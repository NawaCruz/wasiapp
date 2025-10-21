import 'package:flutter/material.dart';

class AppValidators {
  static String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese un email';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Email inválido';
    }
    return null;
  }

  static String? validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Ingrese una contraseña';
    }
    if (value.length < 6) {
      return 'Mínimo 6 caracteres';
    }
    return null;
  }

  static String? validateDNI(String? value) {
    if (value == null || value.isEmpty) {
      return 'El DNI es obligatorio';
    }
    if (value.length != 8) {
      return 'El DNI debe tener 8 dígitos';
    }
    if (!RegExp(r'^\d+$').hasMatch(value)) {
      return 'El DNI solo debe contener números';
    }
    return null;
  }

  static String? validateRequired(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return '$fieldName es obligatorio';
    }
    return null;
  }

  static String? validateNumeric(String? value, String fieldName, {double? max}) {
    if (value == null || value.isEmpty) {
      return '$fieldName es obligatorio';
    }
    
    String cleanValue = value.trim().replaceAll(',', '.');
    double? numValue = double.tryParse(cleanValue);
    
    if (numValue == null || numValue <= 0) {
      return 'Ingrese un $fieldName válido (solo números)';
    }
    
    if (max != null && numValue > max) {
      return 'El $fieldName parece demasiado alto';
    }
    
    return null;
  }

  static String? validateDropdown(String? value, String fieldName) {
    if (value == null || value == 'Seleccionar') {
      return 'Debe seleccionar $fieldName';
    }
    return null;
  }
}

class AppUtils {
  static void showSnackBar(BuildContext context, String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error : Icons.check_circle,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFE53935) : const Color(0xFF4CAF50),
        duration: Duration(seconds: isError ? 5 : 3),
      ),
    );
  }

  static String cleanNumericInput(String input) {
    return input.replaceAll(RegExp(r'[^0-9.]'), '');
  }

  static int calculateAge(DateTime birthDate) {
    DateTime now = DateTime.now();
    int age = now.year - birthDate.year;
    
    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }
    
    return age;
  }

  static String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}