// services/notification_manager.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'notification_service.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final NotificationService _notificationService = NotificationService();

  Future<void> initialize() async {
    await _notificationService.initialize();
    await _notificationService.configureNotificationChannels();
    await _setupDefaultNotifications();
  }

  // Configurar notificaciones por defecto
  Future<void> _setupDefaultNotifications() async {
    // Recordatorio de evaluación mensual (todos los meses día 1 a las 9 AM)
    await _notificationService.scheduleNotification(
      title: '📋 Evaluación Mensual',
      body: 'Es tiempo de realizar la evaluación mensual de los niños',
      scheduledTime: _nextFirstOfMonthAt9AM(),
    );

    // Recordatorio de plan nutricional (Lunes y Jueves a las 8 AM)
    await _notificationService.scheduleRecurringNotification(
      title: '🍎 Revisar Plan Nutricional',
      body: 'Recuerda revisar y ajustar el plan nutricional de los niños',
      time: const Time(8, 0, 0),
      days: [1, 4], // Lunes y Jueves
    );

    // Recordatorio de fotos de conjuntiva (Miércoles a las 10 AM)
    await _notificationService.scheduleRecurringNotification(
      title: '📸 Foto de Conjuntiva',
      body: 'Toma fotos de conjuntiva para el diagnóstico de anemia',
      time: const Time(10, 0, 0),
      days: [3], // Miércoles
    );
  }

  DateTime _nextFirstOfMonthAt9AM() {
    final now = DateTime.now();
    DateTime nextMonth;
    
    if (now.day == 1 && now.hour < 9) {
      nextMonth = now;
    } else {
      nextMonth = DateTime(now.year, now.month + 1, 1);
    }
    
    return DateTime(nextMonth.year, nextMonth.month, nextMonth.day, 9, 0);
  }

  // Alertas basadas en riesgo de anemia
  Future<void> scheduleAnemiaAlerts(String childName, String riskLevel) async {
    if (riskLevel.contains('Alta Probabilidad')) {
      await _notificationService.scheduleRecurringNotification(
        title: '🚨 Alerta de Anemia - $childName',
        body: 'Niño con alto riesgo de anemia. Revisar plan nutricional urgente.',
        time: const Time(9, 0, 0),
        days: [1, 3, 5], // Lunes, Miércoles, Viernes
      );
    } else if (riskLevel.contains('Riesgo moderado')) {
      await _notificationService.scheduleRecurringNotification(
        title: '⚠️ Recordatorio - $childName',
        body: 'Niño con riesgo moderado de anemia. Seguir plan preventivo.',
        time: const Time(9, 0, 0),
        days: [2, 5], // Martes, Viernes
      );
    }
  }

  // Notificación de progreso semanal
  Future<void> showWeeklyProgressNotification() async {
    await _notificationService.showInstantNotification(
      title: '📈 Resumen Semanal',
      body: 'Revisa el progreso de peso y talla de los niños esta semana',
    );
  }

  // Notificación de recordatorio de medición
  Future<void> scheduleMeasurementReminder(String childName) async {
    await _notificationService.scheduleNotification(
      title: '📏 Recordatorio de Medición',
      body: 'Es hora de medir el peso y talla de $childName',
      scheduledTime: DateTime.now().add(const Duration(days: 30)),
    );
  }

  // Alertas de bajo peso
  Future<void> showUnderweightAlert(String childName, double weight) async {
    await _notificationService.showInstantNotification(
      title: '⚖️ Alerta de Bajo Peso',
      body: '$childName tiene bajo peso ($weight kg). Revisar alimentación.',
    );
  }

  // Recordatorio de suplementos
  Future<void> scheduleSupplementReminder(String childName, String supplement) async {
    await _notificationService.scheduleRecurringNotification(
      title: '💊 Suplemento - $childName',
      body: 'Hora de administrar $supplement a $childName',
      time: const Time(8, 0, 0),
      days: [1, 2, 3, 4, 5, 6, 7], // Todos los días
    );
  }

  // Cancelar alertas específicas de un niño
  Future<void> cancelChildAlerts(String childName) async {
    // En una implementación real, llevarías un registro de los IDs de notificación
    // por niño para poder cancelarlos específicamente
    print('Alertas canceladas para: $childName');
  }
}