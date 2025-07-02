import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weekly_task_planner/models/task.dart';
import 'package:weekly_task_planner/home_widget.dart';
import 'package:timezone/timezone.dart' as tz;

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  late Box<Task> _taskBox;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  int _notificationMinutesBefore = 10; // Настройка времени уведомления

  List<Task> get tasks => _tasks;
  int get notificationMinutesBefore => _notificationMinutesBefore;

  TaskProvider() {
    _initializeNotifications();
    _initHive();
  }

  Future<void> _initHive() async {
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(TaskAdapter());
    }
    _taskBox = await Hive.openBox<Task>('tasks');
    _tasks = _taskBox.values.toList();
    notifyListeners();
  }

  Future<void> _initializeNotifications() async {
    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(android: androidInit, iOS: iosInit);
    await _notifications.initialize(initSettings);
    await _notifications
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> _saveTasks() async {
    await _taskBox.clear();
    await _taskBox.addAll(_tasks);
  }

  void setNotificationMinutesBefore(int minutes) {
    _notificationMinutesBefore = minutes;
    notifyListeners();
  }

  void addTask(Task task) {
    _tasks.add(task);
    _saveTasks();
    _scheduleNotification(task);
    HomeWidget.updateWidget(_tasks);
    notifyListeners();
  }

  void updateTask(Task updatedTask) {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _saveTasks();
      HomeWidget.updateWidget(_tasks);
      notifyListeners();
    }
  }

  void deleteTask(Task task) {
    _tasks.removeWhere((t) => t.id == task.id);
    _saveTasks();
    HomeWidget.updateWidget(_tasks);
    notifyListeners();
  }

  void toggleTaskCompletion(Task task) {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _tasks[index].isCompleted = !_tasks[index].isCompleted;
      _saveTasks();
      HomeWidget.updateWidget(_tasks);
      notifyListeners();
    }
  }

  Future<void> _scheduleNotification(Task task) async {
    final notificationTime = tz.TZDateTime.from(task.date, tz.local)
        .subtract(Duration(minutes: _notificationMinutesBefore));
    await _notifications.zonedSchedule(
      task.id.hashCode,
      task.title,
      task.description.isNotEmpty
          ? task.description
          : 'Задача на ${task.date.day}.${task.date.month}',
      notificationTime,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tasks_channel',
          'Tasks',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }
}