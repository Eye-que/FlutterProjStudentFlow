import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'dart:async';
import 'dart:io';

/// Notification Service
/// Handles scheduling and canceling local notifications for task deadlines
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  static const MethodChannel _channel = MethodChannel('notification_permissions');

  /// Initialize notification service
  Future<void> initialize() async {
    if (_initialized) {
      debugPrint('Notification service already initialized');
      return;
    }

    debugPrint('Initializing notification service...');

    // Initialize timezone data
    tz_data.initializeTimeZones();
    debugPrint('Timezone data initialized');

    // Android initialization settings
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
        );

    // Initialize plugin
    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    final initialized = await _notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    debugPrint('Notification plugin initialized: $initialized');

    // Request permissions and create channel for Android
    await _requestPermissions();
    
    // Request battery optimization exemption for Android
    if (Platform.isAndroid) {
      await requestBatteryOptimizationExemption();
    }

    // Check permissions status
    final hasPermissions = await arePermissionsGranted();
    debugPrint('Notification permissions status: $hasPermissions');

    _initialized = true;
    debugPrint('Notification service initialization complete');
  }

  /// Request notification permissions
  Future<void> _requestPermissions() async {
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        // Request notification permission (Android 13+)
        final granted = await androidImplementation
            .requestNotificationsPermission();
        debugPrint('Notification permission granted: $granted');

        // Create notification channel (required for Android 8.0+)
        await androidImplementation.createNotificationChannel(
          const AndroidNotificationChannel(
            'task_reminders',
            'Task Reminders',
            description: 'Notifications for task deadlines',
            importance: Importance.high,
            playSound: true,
            enableVibration: true,
            enableLights: true,
            showBadge: true,
          ),
        );
        debugPrint('Notification channel created successfully');
        
        // Request exact alarm permission for Android 12+ (if not already granted)
        if (Platform.isAndroid) {
          try {
            // Check if exact alarm permission is available
            final canScheduleExactAlarms = await androidImplementation
                .canScheduleExactNotifications();
            debugPrint('Can schedule exact alarms: $canScheduleExactAlarms');
            
            if (canScheduleExactAlarms == false) {
              debugPrint('⚠️ Exact alarm permission not granted. Requesting permission...');
              // Request exact alarm permission
              try {
                await androidImplementation.requestExactAlarmsPermission();
                debugPrint('✅ Requested exact alarm permission');
              } catch (e) {
                debugPrint('⚠️ Could not request exact alarm permission: $e');
                debugPrint('   User needs to grant "Schedule exact alarms" permission in app settings.');
              }
            } else {
              debugPrint('✅ Exact alarm permission already granted');
            }
          } catch (e) {
            debugPrint('Could not check exact alarm permission: $e');
          }
        }
      }
    }
  }

  /// Request battery optimization exemption
  /// This is critical for notifications to work on real devices
  Future<void> requestBatteryOptimizationExemption() async {
    if (!Platform.isAndroid) return;
    
    try {
      final result = await _channel.invokeMethod<bool>('requestBatteryOptimizationExemption');
      if (result == true) {
        debugPrint('✅ Battery optimization exemption granted');
      } else {
        debugPrint('⚠️ Battery optimization exemption not granted. Notifications may not work when app is closed.');
        debugPrint('   User should disable battery optimization for this app in system settings.');
      }
    } catch (e) {
      debugPrint('⚠️ Could not request battery optimization exemption: $e');
      debugPrint('   This is normal if the method channel is not implemented.');
    }
  }

  /// Check if notification permissions are granted
  Future<bool> arePermissionsGranted() async {
    if (Platform.isAndroid) {
      final androidImplementation = _notificationsPlugin
          .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin
          >();

      if (androidImplementation != null) {
        final granted = await androidImplementation.areNotificationsEnabled();
        debugPrint('Notifications enabled: $granted');
        return granted ?? false;
      }
    }
    return true; // iOS/other platforms
  }

  /// Handle notification tap
  void _onNotificationTapped(NotificationResponse response) {
    // Handle notification tap if needed
    debugPrint('Notification tapped: ${response.id}');
  }

  /// Check if notifications are enabled
  Future<bool> areNotificationsEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('notifications_enabled') ?? true;
  }

  /// Set notifications enabled/disabled
  Future<void> setNotificationsEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', enabled);
  }

  /// Schedule notifications for a task (1 hour and 30 minutes before deadline)
  /// This will work from anywhere - dashboard, home, or any screen
  /// Notifications are scheduled in the system and will fire even if app is closed
  Future<void> scheduleTaskNotifications({
    required int taskId,
    required String taskTitle,
    required DateTime deadline,
  }) async {
    // Check if notifications are enabled
    if (!await areNotificationsEnabled()) {
      debugPrint('🔔 Notifications are disabled in settings');
      return;
    }

    final now = DateTime.now();

    // Don't schedule if deadline is in the past
    if (deadline.isBefore(now)) {
      debugPrint('🔔 Deadline is in the past, skipping notification scheduling for task "$taskTitle"');
      return;
    }

    // Calculate notification times
    final oneHourBefore = deadline.subtract(const Duration(hours: 1));
    final thirtyMinutesBefore = deadline.subtract(const Duration(minutes: 30));
    final timeUntilDeadline = deadline.difference(now);
    final timeUntilOneHour = oneHourBefore.difference(now);
    final timeUntilThirtyMin = thirtyMinutesBefore.difference(now);

    debugPrint('🔔 Scheduling notifications for task "$taskTitle"');
    debugPrint('   Task ID: $taskId');
    debugPrint('   Deadline: ${deadline.toString()}');
    debugPrint('   Current time: ${now.toString()}');
    debugPrint('   Time until deadline: ${timeUntilDeadline.inMinutes} minutes (${timeUntilDeadline.inHours} hours)');
    debugPrint('   Time until 1-hour notification: ${timeUntilOneHour.inMinutes} minutes');
    debugPrint('   Time until 30-minute notification: ${timeUntilThirtyMin.inMinutes} minutes');

    // Schedule 1 hour before notification
    // Schedule if deadline is more than 30 minutes away (to avoid overlap with 30-min notification)
    if (timeUntilDeadline.inMinutes > 30) {
      final minutesUntilNotification = timeUntilOneHour.inMinutes;
      DateTime notificationTime = oneHourBefore;
      
      // If the 1-hour-before time is exactly now or very close (within 1 minute),
      // show the notification immediately
      if (minutesUntilNotification <= 1 && minutesUntilNotification >= -1) {
        debugPrint(
          '🔔 1-hour notification time is now (or very close), showing immediately',
        );
        await showImmediateNotification(
          title: 'Task Reminder',
          body: 'You have 1 hour left to complete "$taskTitle"',
        );
      }
      // If the 1-hour-before time is in the past (more than 1 minute ago) or very close (1-2 minutes),
      // schedule it for 2 minutes from now to ensure it fires
      // This handles the case where periodic rescheduling catches a missed notification
      else if (minutesUntilNotification < 2 && minutesUntilNotification > -5) {
        // Only schedule if it's not too far in the past (within 5 minutes)
        notificationTime = now.add(const Duration(minutes: 2));
        debugPrint(
          '⚠️ 1-hour notification time would be in ${minutesUntilNotification < 0 ? "the past" : "$minutesUntilNotification minutes"}, scheduling for 2 minutes from now instead',
        );
        
        await _scheduleNotification(
          id: taskId * 10 + 1, // Unique ID for 1-hour notification
          title: 'Task Reminder',
          body: 'You have 1 hour left to complete "$taskTitle"',
          scheduledDate: notificationTime,
        );
      }
      // Normal case: schedule for exactly 1 hour before
      else if (notificationTime.isAfter(now)) {
        debugPrint(
          '🔔 Scheduling 1-hour notification for: ${notificationTime.toString()}',
        );
        debugPrint('   (${notificationTime.difference(now).inMinutes} minutes from now)');
        
        await _scheduleNotification(
          id: taskId * 10 + 1, // Unique ID for 1-hour notification
          title: 'Task Reminder',
          body: 'You have 1 hour left to complete "$taskTitle"',
          scheduledDate: notificationTime,
        );
      } else {
        debugPrint(
          '⏭️ Skipping 1-hour notification: notification time is too far in the past (${minutesUntilNotification} minutes ago)',
        );
      }
    } else {
      debugPrint(
        '⏭️ Skipping 1-hour notification: deadline is only ${timeUntilDeadline.inMinutes} minutes away (need more than 30 minutes)',
      );
    }

    // Schedule 30 minutes before notification
    // Schedule if deadline is 30 minutes or more away
    if (timeUntilDeadline.inMinutes >= 30) {
      final minutesUntilNotification = timeUntilThirtyMin.inMinutes;
      DateTime notificationTime = thirtyMinutesBefore;
      
      // If the 30-minute-before time is exactly now or very close (within 1 minute),
      // show the notification immediately
      if (minutesUntilNotification <= 1 && minutesUntilNotification >= -1) {
        debugPrint(
          '🔔 30-minute notification time is now (or very close), showing immediately',
        );
        await showImmediateNotification(
          title: 'Task Reminder',
          body: 'You have 30 minutes left to complete "$taskTitle"',
        );
      }
      // If the 30-minute-before time is in the past (more than 1 minute ago) or very close (1-2 minutes),
      // schedule it for 2 minutes from now to ensure it fires
      else if (minutesUntilNotification < 2) {
        notificationTime = now.add(const Duration(minutes: 2));
        debugPrint(
          '⚠️ 30-minute notification time would be in ${minutesUntilNotification < 0 ? "the past" : "$minutesUntilNotification minutes"}, scheduling for 2 minutes from now instead',
        );
        
        await _scheduleNotification(
          id: taskId * 10 + 2, // Unique ID for 30-minute notification
          title: 'Task Reminder',
          body: 'You have 30 minutes left to complete "$taskTitle"',
          scheduledDate: notificationTime,
        );
      }
      // Normal case: schedule for exactly 30 minutes before
      else if (notificationTime.isAfter(now)) {
        debugPrint(
          '🔔 Scheduling 30-minute notification for: ${notificationTime.toString()}',
        );
        debugPrint('   (${notificationTime.difference(now).inMinutes} minutes from now)');
        
        await _scheduleNotification(
          id: taskId * 10 + 2, // Unique ID for 30-minute notification
          title: 'Task Reminder',
          body: 'You have 30 minutes left to complete "$taskTitle"',
          scheduledDate: notificationTime,
        );
      } else {
        debugPrint(
          '❌ Cannot schedule 30-minute notification: notification time is in the past',
        );
      }
    } else {
      debugPrint(
        '⏭️ Skipping 30-minute notification: deadline is only ${timeUntilDeadline.inMinutes} minutes away (need at least 30 minutes)',
      );
    }

    debugPrint('✅ Notification scheduling complete for task "$taskTitle"');
  }

  /// Schedule a single notification
  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
  }) async {
    // Ensure service is initialized
    if (!_initialized) {
      debugPrint('Notification service not initialized, initializing now...');
      await initialize();
    }

    // Check permissions
    final hasPermissions = await arePermissionsGranted();
    if (!hasPermissions) {
      debugPrint('WARNING: Notification permissions not granted!');
      debugPrint(
        'For emulator: Go to Settings > Apps > Your App > Notifications > Enable',
      );
    }

    final now = DateTime.now();
    final duration = scheduledDate.difference(now);

    debugPrint('Attempting to schedule notification:');
    debugPrint('  ID: $id');
    debugPrint('  Title: $title');
    debugPrint('  Scheduled for: ${scheduledDate.toString()}');
    debugPrint('  Current time: ${now.toString()}');
    debugPrint(
      '  Time until: ${duration.inMinutes} minutes (${duration.inSeconds} seconds)',
    );

    // If the scheduled time is in the past, don't schedule
    if (duration.isNegative) {
      debugPrint(
        'ERROR: Cannot schedule notification in the past: $scheduledDate',
      );
      return;
    }

    // For very short durations (less than 1 minute), use immediate notification
    if (duration.inSeconds < 60) {
      debugPrint(
        'Notification is less than 1 minute away, showing immediately',
      );
      await showImmediateNotification(title: title, body: body);
      return;
    }

    // Android notification details
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for task deadlines',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
          enableVibration: true,
          playSound: true,
          enableLights: true,
          ongoing: false,
          autoCancel: true,
          visibility: NotificationVisibility.public,
        );

    // iOS notification details
    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    // Convert DateTime to TZDateTime using local timezone
    final scheduledTZ = tz.TZDateTime.from(scheduledDate, tz.local);
    debugPrint('TZDateTime: ${scheduledTZ.toString()}');

    try {
      // Check if exact alarms are allowed
      bool useExactAlarm = true;
      if (Platform.isAndroid) {
        final androidImplementation = _notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
        if (androidImplementation != null) {
          final canScheduleExact = await androidImplementation.canScheduleExactNotifications();
          useExactAlarm = canScheduleExact ?? false;
          if (!useExactAlarm) {
            debugPrint('⚠️ Exact alarms not available, using inexact scheduling');
          }
        }
      }
      
      // Try to schedule with exact alarm first (Android 12+)
      await _notificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledTZ,
        notificationDetails,
        androidScheduleMode: useExactAlarm 
            ? AndroidScheduleMode.exactAllowWhileIdle
            : AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );

      debugPrint(
        '✅ Scheduled ${useExactAlarm ? "exact" : "inexact"} notification $id for ${scheduledDate.toString()} (in ${duration.inMinutes} minutes)',
      );
    } catch (e) {
      // If exact alarm permission is not granted, fall back to inexact scheduling
      if (e.toString().contains('exact_alarm_not_permitted') ||
          e.toString().contains('SCHEDULE_EXACT_ALARM')) {
        debugPrint(
          '⚠️ Exact alarm permission not granted, using inexact scheduling: $e',
        );

        try {
          // Fall back to inexact scheduling (doesn't require permission)
          await _notificationsPlugin.zonedSchedule(
            id,
            title,
            body,
            scheduledTZ,
            notificationDetails,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            matchDateTimeComponents: DateTimeComponents.time,
          );

          debugPrint(
            '✅ Scheduled inexact notification $id for ${scheduledDate.toString()} (in ${duration.inMinutes} minutes)',
          );
        } catch (fallbackError) {
          debugPrint(
            '❌ Failed to schedule notification (both exact and inexact): $fallbackError',
          );

          // As a last resort, try showing immediately for testing
          debugPrint(
            'Attempting to show notification immediately as fallback...',
          );
          try {
            await showImmediateNotification(title: title, body: body);
          } catch (immediateError) {
            debugPrint(
              '❌ Failed to show immediate notification: $immediateError',
            );
          }
        }
      } else {
        debugPrint('❌ Error scheduling notification: $e');
        // Try immediate notification as fallback
        try {
          await showImmediateNotification(title: title, body: body);
          debugPrint('Showed notification immediately as fallback');
        } catch (immediateError) {
          debugPrint(
            '❌ Failed to show immediate notification: $immediateError',
          );
        }
      }
    }
  }

  /// Cancel all notifications for a task
  Future<void> cancelTaskNotifications(int taskId) async {
    // Cancel all notifications (1 hour and 30 minutes)
    await _notificationsPlugin.cancel(taskId * 10 + 1); // 1-hour notification
    await _notificationsPlugin.cancel(taskId * 10 + 2); // 30-minute notification
    debugPrint('🗑️ Cancelled all notifications for task $taskId');
  }

  /// Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  /// Show immediate notification (for testing)
  Future<void> showImmediateNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          'task_reminders',
          'Task Reminders',
          channelDescription: 'Notifications for task deadlines',
          importance: Importance.high,
          priority: Priority.high,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      DateTime.now().millisecondsSinceEpoch % 100000,
      title,
      body,
      notificationDetails,
    );
  }
}
