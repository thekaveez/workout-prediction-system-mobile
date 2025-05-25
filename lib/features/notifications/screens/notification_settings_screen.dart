import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workout_prediction_system_mobile/core/services/notification_service.dart';

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  TimeOfDay _exerciseReminderTime = const TimeOfDay(hour: 8, minute: 0);
  TimeOfDay _waterReminderTime = const TimeOfDay(hour: 10, minute: 0);
  bool _exerciseReminderEnabled = true;
  bool _waterReminderEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notification Settings')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Exercise Reminder Section
            Text(
              'Exercise Reminders',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            SwitchListTile(
              title: const Text('Enable Exercise Reminders'),
              value: _exerciseReminderEnabled,
              onChanged: (value) {
                setState(() {
                  _exerciseReminderEnabled = value;
                });
              },
            ),
            ListTile(
              title: const Text('Reminder Time'),
              trailing: Text(
                _exerciseReminderTime.format(context),
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () async {
                final TimeOfDay? newTime = await showTimePicker(
                  context: context,
                  initialTime: _exerciseReminderTime,
                );
                if (newTime != null) {
                  setState(() {
                    _exerciseReminderTime = newTime;
                  });
                  _scheduleExerciseReminder();
                }
              },
            ),
            SizedBox(height: 24.h),

            // Water Reminder Section
            Text(
              'Water Balance Reminders',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            SwitchListTile(
              title: const Text('Enable Water Reminders'),
              value: _waterReminderEnabled,
              onChanged: (value) {
                setState(() {
                  _waterReminderEnabled = value;
                });
              },
            ),
            ListTile(
              title: const Text('Reminder Time'),
              trailing: Text(
                _waterReminderTime.format(context),
                style: TextStyle(fontSize: 16.sp),
              ),
              onTap: () async {
                final TimeOfDay? newTime = await showTimePicker(
                  context: context,
                  initialTime: _waterReminderTime,
                );
                if (newTime != null) {
                  setState(() {
                    _waterReminderTime = newTime;
                  });
                  _scheduleWaterReminder();
                }
              },
            ),
            SizedBox(height: 32.h),

            // Test Notifications Section
            Text(
              'Test Notifications',
              style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16.h),
            ElevatedButton(
              onPressed: () {
                ref.read(notificationServiceProvider).showTestNotification();
              },
              child: const Text('Send Test Notification'),
            ),
          ],
        ),
      ),
    );
  }

  void _scheduleExerciseReminder() {
    if (!_exerciseReminderEnabled) return;

    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _exerciseReminderTime.hour,
      _exerciseReminderTime.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    ref
        .read(notificationServiceProvider)
        .scheduleExerciseReminder(
          title: 'Time to Exercise!',
          body: 'Don\'t forget your daily workout routine.',
          scheduledTime: scheduledTime,
        );
  }

  void _scheduleWaterReminder() {
    if (!_waterReminderEnabled) return;

    final now = DateTime.now();
    var scheduledTime = DateTime(
      now.year,
      now.month,
      now.day,
      _waterReminderTime.hour,
      _waterReminderTime.minute,
    );

    // If the time has already passed today, schedule for tomorrow
    if (scheduledTime.isBefore(now)) {
      scheduledTime = scheduledTime.add(const Duration(days: 1));
    }

    ref
        .read(notificationServiceProvider)
        .scheduleWaterReminder(
          title: 'Stay Hydrated!',
          body: 'Time to drink some water.',
          scheduledTime: scheduledTime,
        );
  }
}
