// services/notification_service.dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

// Clase personalizada para representar la hora
class TimeOfDay24 {
  final int hour;
  final int minute;
  final int second;

  const TimeOfDay24(this.hour, this.minute, [this.second = 0]);
}

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Inicializar timezone
    tz_data.initializeTimeZones();
    const AndroidInitializationSettings androidSettings = 
        AndroidInitializationSettings('@mipmap/ic_launcher');
    
    const DarwinInitializationSettings iosSettings = 
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );
    
    final InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notifications.initialize(settings);
  }

  // Programar recordatorio de plan alimenticio
  Future<void> scheduleFoodPlanReminder(String childName, TimeOfDay24 time, List<int> days) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'food_reminders',
      'Recordatorios de Alimentación',
      channelDescription: 'Recordatorios para cumplir con el plan alimenticio',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    for (final day in days) {
      await _notifications.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + day,
        '🍎 Plan Alimenticio - $childName',
        'Es hora de seguir el plan nutricional. ¡Mantén una alimentación saludable!',
        _nextInstanceOfTime(time, day),
        details,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  // Programar recordatorio general de alimentación
  Future<void> scheduleGeneralFoodReminders() async {
    // Desayuno
    await _scheduleSingleReminder(
      const TimeOfDay24(7, 0, 0),
      '🍳 Hora del Desayuno',
      '¡No olvides el desayuno! Es la comida más importante del día.',
      [1, 2, 3, 4, 5, 6, 7], // Todos los días
    );

    // Almuerzo
    await _scheduleSingleReminder(
      const TimeOfDay24(13, 0, 0),
      '🍲 Hora del Almuerzo',
      'Es hora del almuerzo. Recuerda incluir proteínas y verduras.',
      [1, 2, 3, 4, 5, 6, 7],
    );

    // Cena
    await _scheduleSingleReminder(
      const TimeOfDay24(19, 0, 0),
      '🍽️ Hora de la Cena',
      'Hora de cenar. Una cena ligera ayuda a un buen descanso.',
      [1, 2, 3, 4, 5, 6, 7],
    );

    // Recordatorio de alimentos ricos en hierro (Lunes, Miércoles, Viernes)
    await _scheduleSingleReminder(
      const TimeOfDay24(11, 0, 0),
      '💪 Alimentos con Hierro',
      'Recuerda incluir alimentos ricos en hierro en la comida.',
      [1, 3, 5], // Lunes, Miércoles, Viernes
    );
  }

  Future<void> _scheduleSingleReminder(TimeOfDay24 time, String title, String body, List<int> days) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'food_reminders',
      'Recordatorios de Alimentación',
      channelDescription: 'Recordatorios para cumplir con el plan alimenticio',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    for (final day in days) {
      await _notifications.zonedSchedule(
        DateTime.now().millisecondsSinceEpoch ~/ 1000 + day,
        title,
        body,
        _nextInstanceOfTime(time, day),
        details,
        uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfTime(TimeOfDay24 time, int day) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );
    
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }
    
    return scheduledDate;
  }

  // Cancelar todos los recordatorios
  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  // Probar notificación inmediata
  Future<void> testNotification() async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'food_reminders',
      'Recordatorios de Alimentación',
      channelDescription: 'Recordatorios para cumplir con el plan alimenticio',
      importance: Importance.high,
      priority: Priority.high,
    );
    
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails();
    
    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );
    
    await _notifications.show(
      0,
      '🍎 Recordatorio de Prueba',
      '¡Tu plan alimenticio está activo!',
      details,
    );
  }
}