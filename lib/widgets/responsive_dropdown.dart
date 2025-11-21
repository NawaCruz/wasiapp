import 'package:flutter/material.dart';

class ResponsiveDropdown<T> extends StatelessWidget {
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final void Function(T?)? onChanged;
  final String labelText;
  final String? hintText;
  final String? Function(T?)? validator;
  final Widget? prefixIcon;
  final MaterialColor? primaryColor;
  final double? maxWidth;
  final bool isRequired;

  const ResponsiveDropdown({
    super.key,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.labelText,
    this.hintText,
    this.validator,
    this.prefixIcon,
    this.primaryColor,
    this.maxWidth,
    this.isRequired = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Determinar si es una pantalla pequeña
    final isSmallScreen = screenWidth < 600;
    final isMediumScreen = screenWidth >= 600 && screenWidth < 1024;

    // Ajustar dimensiones según el tamaño de pantalla
    final containerMaxWidth = maxWidth ??
        (isSmallScreen
            ? screenWidth * 0.9
            : isMediumScreen
                ? screenWidth * 0.7
                : screenWidth * 0.5);

    final fontSize = isSmallScreen ? 12.0 : 14.0;
    final iconSize = isSmallScreen ? 16.0 : 20.0;

    return Container(
      constraints: BoxConstraints(
        maxWidth: containerMaxWidth,
        minHeight: isSmallScreen ? 50 : 60,
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
          boxShadow: [
            BoxShadow(
              color: (primaryColor ?? Colors.green).withValues(alpha: 0.1),
              blurRadius: isSmallScreen ? 4 : 8,
              offset: Offset(0, isSmallScreen ? 2 : 4),
            ),
          ],
        ),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isSmallScreen ? 12 : 16),
            border: Border.all(
              color: (primaryColor ?? Colors.green).shade200,
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<T>(
            initialValue: value,
            items: items,
            onChanged: onChanged,
            validator: validator,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: labelText,
              hintText: hintText,
              labelStyle: TextStyle(
                color: (primaryColor ?? Colors.green).shade700,
                fontWeight: FontWeight.w600,
                fontSize: fontSize,
              ),
              hintStyle: TextStyle(
                color: Colors.grey[500],
                fontSize: fontSize * 0.9,
              ),
              prefixIcon: prefixIcon != null
                  ? _buildResponsivePrefixIcon(
                      prefixIcon!,
                      isSmallScreen,
                      primaryColor ?? Colors.green,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: isSmallScreen ? 12 : 16,
                vertical: isSmallScreen ? 8 : 12,
              ),
              suffixIcon: Icon(
                Icons.arrow_drop_down,
                color: (primaryColor ?? Colors.green).shade600,
                size: iconSize + 4,
              ),
            ),
            dropdownColor: Colors.white,
            style: TextStyle(
              color: Colors.black87,
              fontSize: fontSize,
            ),
            icon: const SizedBox.shrink(), // Ocultar el icono por defecto
            menuMaxHeight:
                screenHeight * 0.4, // Máximo 40% de la altura de pantalla
          ),
        ),
      ),
    );
  }

  Widget _buildResponsivePrefixIcon(
      Widget icon, bool isSmallScreen, MaterialColor primaryColor) {
    return Container(
      margin: EdgeInsets.all(isSmallScreen ? 8 : 12),
      padding: EdgeInsets.all(isSmallScreen ? 6 : 10),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [primaryColor.shade400, primaryColor.shade600],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isSmallScreen ? 8 : 12),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: isSmallScreen ? 3 : 6,
            offset: Offset(0, isSmallScreen ? 1 : 2),
          ),
        ],
      ),
      child: icon,
    );
  }
}

class ResponsivePatientSelector extends StatelessWidget {
  final dynamic selectedPatient;
  final List<dynamic> patients;
  final void Function(dynamic)? onChanged;
  final String? Function(dynamic)? validator;

  const ResponsivePatientSelector({
    super.key,
    required this.selectedPatient,
    required this.patients,
    required this.onChanged,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 600;

    return ResponsiveDropdown<dynamic>(
      value: selectedPatient,
      labelText: 'Selecciona un paciente',
      hintText: 'Toca aquí para elegir un paciente',
      primaryColor: Colors.green,
      isRequired: true,
      prefixIcon: Icon(
        Icons.child_care,
        color: Colors.white,
        size: isSmallScreen ? 16 : 20,
      ),
      items: patients.map<DropdownMenuItem<dynamic>>((patient) {
        return DropdownMenuItem<dynamic>(
          value: patient,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: screenWidth * (isSmallScreen ? 0.7 : 0.8),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: isSmallScreen ? 16 : 20,
                  backgroundColor: patient.sexo == 'Masculino'
                      ? Colors.blue.shade100
                      : Colors.pink.shade100,
                  child: Icon(
                    patient.sexo == 'Masculino' ? Icons.boy : Icons.girl,
                    color: patient.sexo == 'Masculino'
                        ? Colors.blue.shade700
                        : Colors.pink.shade700,
                    size: isSmallScreen ? 16 : 20,
                  ),
                ),
                SizedBox(width: isSmallScreen ? 8 : 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        patient.nombreCompleto,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 12 : 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                      if (!isSmallScreen || screenWidth > 400) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${patient.edad} años • DNI: ${patient.dniNino}',
                          style: TextStyle(
                            fontSize: isSmallScreen ? 10 : 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
      onChanged: onChanged,
      validator: validator,
    );
  }
}
