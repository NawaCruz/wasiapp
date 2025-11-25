// 🔔 Servicio de Notificaciones - WasiApp
// Maneja recordatorios de comidas para ayudar a los padres

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;

// Clase para representar hora en formato 24h
// Ejemplo: TimeOfDay24(7, 30) = 7:30 AM
class TimeOfDay24 {
  final int hour;
  final int minute;
  final int second;

  const TimeOfDay24(this.hour, this.minute, [this.second = 0]);
}

// Servicio de notificaciones (Singleton - una sola instancia)
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Inicializar el servicio al arrancar la app
  Future<void> initialize() async {
    // Configurar zona horaria de Perú
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('America/Lima'));
    
    // Configuración para Android
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // Configuración para iOS
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
    
    // Solicitar permisos para Android 13+
    await _notifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Programar recordatorio personalizado para un niño
  // Ejemplo: scheduleFoodPlanReminder("María", TimeOfDay24(9, 0), [1, 3, 5])
  Future<void> scheduleFoodPlanReminder(
      String childName, TimeOfDay24 time, List<int> days) async {
    
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
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

    // Crear notificación para cada día
    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      await _notifications.zonedSchedule(
        1000 + i,
        '🍎 Plan Alimenticio - $childName',
        'Es hora de seguir el plan nutricional. ¡Mantén una alimentación saludable!',
        _nextInstanceOfTime(time, day),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  // Programar recordatorios automáticos de comidas
  // 🍳 Desayuno 7AM | 🍲 Almuerzo 1PM | 🍽️ Cena 7PM | 💪 Hierro 11AM (Lun/Mié/Vie)
  Future<void> scheduleGeneralFoodReminders() async {
    
    // Desayuno - 7:00 AM todos los días
    await _scheduleSingleReminder(
      const TimeOfDay24(7, 0, 0),
      '🍳 Hora del Desayuno',
      '¡No olvides el desayuno! Es la comida más importante del día.',
      [1, 2, 3, 4, 5, 6, 7],
    );

    // Almuerzo - 1:00 PM todos los días
    await _scheduleSingleReminder(
      const TimeOfDay24(13, 0, 0),
      '🍲 Hora del Almuerzo',
      'Es hora del almuerzo. Recuerda incluir proteínas y verduras.',
      [1, 2, 3, 4, 5, 6, 7],
    );

    // Cena - 7:00 PM todos los días
    await _scheduleSingleReminder(
      const TimeOfDay24(19, 0, 0),
      '🍽️ Hora de la Cena',
      'Hora de cenar. Una cena ligera ayuda a un buen descanso.',
      [1, 2, 3, 4, 5, 6, 7],
    );

    // Hierro - 11:00 AM (Lunes, Miércoles, Viernes)
    await _scheduleSingleReminder(
      const TimeOfDay24(11, 0, 0),
      '💪 Alimentos con Hierro',
      'Recuerda incluir alimentos ricos en hierro en la comida.',
      [1, 3, 5],
    );
  }

  // Método interno para programar un recordatorio
  Future<void> _scheduleSingleReminder(
      TimeOfDay24 time, String title, String body, List<int> days) async {
    
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
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

    for (int i = 0; i < days.length; i++) {
      final day = days[i];
      
      // Generar ID único: (hora*100 + minutos)*10 + índice
      // Ejemplo: 7:00 AM → 7000, 7001, 7002...
      final notificationId = (time.hour * 100 + time.minute) * 10 + i;
      
      await _notifications.zonedSchedule(
        notificationId,
        title,
        body,
        _nextInstanceOfTime(time, day),
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  // Calcular cuándo debe sonar la próxima notificación
  // Si ya pasó la hora hoy, programa para la próxima semana
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay24 time, int day) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    
    // Crear fecha con la hora deseada
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
      time.second,
    );

    // Buscar el día de la semana correcto
    while (scheduledDate.weekday != day) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // Si ya pasó, programar para la próxima semana
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 7));
    }

    return scheduledDate;
  }

  // Cancelar todos los recordatorios
  Future<void> cancelAllReminders() async {
    await _notifications.cancelAll();
  }

  // Notificación de prueba inmediata
  Future<void> testNotification() async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
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
