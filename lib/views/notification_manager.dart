// services/notification_manager.dart
import '../services/notification_service.dart';

class NotificationManager {
  static final NotificationManager _instance = NotificationManager._internal();
  factory NotificationManager() => _instance;
  NotificationManager._internal();

  final NotificationService _notificationService = NotificationService();

  Future<void> initialize() async {
    await _notificationService.initialize();
    await _setupDefaultNotifications();
  }

  // Configurar notificaciones por defecto
  Future<void> _setupDefaultNotifications() async {
    // Configurar recordatorios generales de alimentación
    await _notificationService.scheduleGeneralFoodReminders();

    // Notificación de prueba
    await _notificationService.testNotification();
  }

  // Alertas basadas en riesgo de anemia
  Future<void> scheduleAnemiaAlerts(String childName, String riskLevel) async {
    if (riskLevel.contains('Alta Probabilidad')) {
      await _notificationService.scheduleFoodPlanReminder(
        childName,
        const TimeOfDay24(9, 0, 0),
        [1, 3, 5], // Lunes, Miércoles, Viernes
      );
    } else if (riskLevel.contains('Riesgo moderado')) {
      await _notificationService.scheduleFoodPlanReminder(
        childName,
        const TimeOfDay24(9, 0, 0),
        [2, 5], // Martes, Viernes
      );
    }
  }

  // Notificación de progreso semanal
  Future<void> showWeeklyProgressNotification() async {
    await _notificationService.testNotification();
  }

  // Notificación de recordatorio de medición
  Future<void> scheduleMeasurementReminder(String childName) async {
    await _notificationService.testNotification();
  }

  // Alertas de bajo peso
  Future<void> showUnderweightAlert(String childName, double weight) async {
    await _notificationService.testNotification();
  }

  // Recordatorio de suplementos
  Future<void> scheduleSupplementReminder(String childName, String supplement) async {
    await _notificationService.scheduleFoodPlanReminder(
      childName,
      const TimeOfDay24(8, 0, 0),
      [1, 2, 3, 4, 5, 6, 7], // Todos los días
    );
  }

  // Cancelar alertas específicas de un niño
  Future<void> cancelChildAlerts(String childName) async {
    await _notificationService.cancelAllReminders();
  }
}