import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weekly_task_planner/models/task.dart';
import 'package:weekly_task_planner/home_widget.dart';
import 'package:timezone/timezone.dart' as tz;

class TaskProvider with ChangeNotifier {
  List<Task> _tasks = [];
  late Box<Task> _taskBox;
  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  int _notificationMinutesBefore = 10;
  bool _isLoading = true;
  String? _error;
  String _selectedCategory = 'All';

  List<Task> get tasks => _selectedCategory == 'All'
      ? _tasks
      : _tasks.where((task) => task.category == _selectedCategory).toList();
  int get notificationMinutesBefore => _notificationMinutesBefore;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get selectedCategory => _selectedCategory;
  List<String> get categories => ['All', 'General', 'Work', 'Personal', 'Study'];

  TaskProvider() {
    _initializeProvider();
  }

  Future<void> _initializeProvider() async {
    try {
      await _initializeNotifications();
      await _initHive();
      await _loadNotificationSettings();
      _scheduleRecurringTasks();
    } catch (e) {
      _error = 'Ошибка инициализации: ${e.toString()}';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _initHive() async {
    try {
      await Hive.initFlutter();
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(TaskAdapter());
      }
      _taskBox = await Hive.openBox<Task>('tasks');
      _tasks = _taskBox.values.toList();
      _sortTasks();
    } catch (e) {
      _error = 'Ошибка загрузки данных: ${e.toString()}';
      _tasks = [];
    }
  }

  Future<void> _initializeNotifications() async {
    try {
      const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
      const iosInit = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );
      const initSettings = InitializationSettings(
        android: androidInit,
        iOS: iosInit,
      );

      await _notifications.initialize(initSettings);

      await _notifications
          .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(alert: true, badge: true, sound: true);

      await _notifications
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    } catch (e) {
      debugPrint('Ошибка инициализации уведомлений: $e');
    }
  }

  Future<void> _loadNotificationSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationMinutesBefore = prefs.getInt('notification_minutes') ?? 10;
    } catch (e) {
      debugPrint('Ошибка загрузки настроек уведомлений: $e');
    }
  }

  void _sortTasks() {
    _tasks.sort((a, b) {
      final dateComparison = a.date.compareTo(b.date);
      if (dateComparison != 0) return dateComparison;

      final priorityComparison = b.priority.compareTo(a.priority);
      if (priorityComparison != 0) return priorityComparison;

      return a.isCompleted == b.isCompleted ? 0 : (a.isCompleted ? 1 : -1);
    });
  }

  Future<void> _saveTasks() async {
    try {
      await _taskBox.clear();
      await _taskBox.addAll(_tasks);
      await HomeWidget.updateWidget(_tasks);
    } catch (e) {
      _error = 'Ошибка сохранения: ${e.toString()}';
      notifyListeners();
    }
  }

  Future<void> setNotificationMinutesBefore(int minutes) async {
    if (_notificationMinutesBefore == minutes) return;

    _notificationMinutesBefore = minutes;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('notification_minutes', minutes);
      await _rescheduleAllNotifications();
    } catch (e) {
      debugPrint('Ошибка сохранения настроек уведомлений: $e');
    }
  }

  void setCategoryFilter(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  Future<void> _rescheduleAllNotifications() async {
    try {
      await _notifications.cancelAll();
      for (final task in _tasks) {
        if (!task.isCompleted) {
          await _scheduleNotification(task);
        }
      }
    } catch (e) {
      debugPrint('Ошибка пересоздания уведомлений: $e');
    }
  }

  Future<void> addTask(Task task) async {
    _tasks.add(task);
    _sortTasks();
    await _saveTasks();
    await _scheduleNotification(task);
    if (task.recurrence != null) {
      await _createRecurringTasks(task);
    }
    notifyListeners();
  }

  Future<void> updateTask(Task updatedTask) async {
    final index = _tasks.indexWhere((t) => t.id == updatedTask.id);
    if (index != -1) {
      _tasks[index] = updatedTask;
      _sortTasks();
      await _saveTasks();
      await _cancelTaskNotification(updatedTask);
      if (!updatedTask.isCompleted) {
        await _scheduleNotification(updatedTask);
      }
      if (updatedTask.recurrence != null) {
        await _createRecurringTasks(updatedTask);
      }
      notifyListeners();
    }
  }

  Future<void> deleteTask(Task task) async {
    _tasks.removeWhere((t) => t.id == task.id);
    await _saveTasks();
    await _cancelTaskNotification(task);
    notifyListeners();
  }

  Future<void> toggleTaskCompletion(Task task) async {
    final index = _tasks.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      final wasCompleted = _tasks[index].isCompleted;
      _tasks[index].isCompleted = !wasCompleted;

      if (_tasks[index].isCompleted) {
        await _cancelTaskNotification(_tasks[index]);
      } else {
        await _scheduleNotification(_tasks[index]);
      }

      _sortTasks();
      await _saveTasks();
      notifyListeners();
    }
  }

  Future<void> _cancelTaskNotification(Task task) async {
    try {
      await _notifications.cancel(task.id.hashCode);
    } catch (e) {
      debugPrint('Ошибка отмены уведомления: $e');
    }
  }

  Future<void> _scheduleNotification(Task task) async {
    try {
      final notificationTime = tz.TZDateTime.from(task.date, tz.local)
          .subtract(Duration(minutes: _notificationMinutesBefore));

      if (notificationTime.isBefore(tz.TZDateTime.now(tz.local))) {
        return;
      }

      await _notifications.zonedSchedule(
        task.id.hashCode,
        'Напоминание о задаче',
        task.description.isNotEmpty
            ? '${task.title}: ${task.description}'
            : task.title,
        notificationTime,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'tasks_channel',
            'Напоминания о задачах',
            channelDescription: 'Уведомления о предстоящих задачах',
            importance: Importance.high,
            priority: Priority.high,
            showWhen: true,
            enableVibration: true,
            playSound: true,
            icon: '@mipmap/ic_launcher',
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            subtitle: 'Напоминание о задаче',
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (e) {
      debugPrint('Ошибка создания уведомления: $e');
    }
  }

  Future<void> _createRecurringTasks(Task task) async {
    if (task.recurrence == null) return;

    final now = DateTime.now();
    final endDate = now.add(const Duration(days: 30)); // Create tasks for 30 days
    DateTime nextDate = task.date;

    while (nextDate.isBefore(endDate)) {
      nextDate = task.recurrence == 'daily'
          ? nextDate.add(const Duration(days: 1))
          : nextDate.add(const Duration(days: 7));

      if (nextDate.isBefore(endDate)) {
        final recurringTask = Task(
          id: '${task.id}_${nextDate.millisecondsSinceEpoch}',
          title: task.title,
          description: task.description,
          priority: task.priority,
          isCompleted: false,
          date: nextDate,
          category: task.category,
          recurrence: task.recurrence,
        );
        _tasks.add(recurringTask);
        await _scheduleNotification(recurringTask);
      }
    }
    await _saveTasks();
  }

  Future<void> _scheduleRecurringTasks() async {
    final recurringTasks = _tasks.where((task) => task.recurrence != null).toList();
    for (final task in recurringTasks) {
      if (task.date.isBefore(DateTime.now())) {
        await _createRecurringTasks(task);
      }
    }
  }

  List<Task> getTasksForDate(DateTime date) {
    return tasks.where((task) {
      return task.date.year == date.year &&
          task.date.month == date.month &&
          task.date.day == date.day;
    }).toList();
  }

  List<Task> getTasksForWeek(List<DateTime> weekDays) {
    return tasks.where((task) {
      return weekDays.any((day) =>
          task.date.year == day.year &&
          task.date.month == day.month &&
          task.date.day == day.day);
    }).toList();
  }

  double getWeekProgress(List<DateTime> weekDays) {
    final weekTasks = getTasksForWeek(weekDays);
    if (weekTasks.isEmpty) return 0;

    final completedTasks = weekTasks.where((task) => task.isCompleted).length;
    return completedTasks / weekTasks.length;
  }

  Map<String, int> getStatistics(List<DateTime> weekDays) {
    final weekTasks = getTasksForWeek(weekDays);
    return {
      'total': weekTasks.length,
      'completed': weekTasks.where((task) => task.isCompleted).length,
      'pending': weekTasks.where((task) => !task.isCompleted).length,
      'highPriority': weekTasks.where((task) => task.priority == 2).length,
    };
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  List<Map<String, dynamic>> exportTasks() {
    return tasks.map((task) => {
      'id': task.id,
      'title': task.title,
      'description': task.description,
      'priority': task.priority,
      'isCompleted': task.isCompleted,
      'date': task.date.toIso8601String(),
      'category': task.category,
      'recurrence': task.recurrence,
    }).toList();
  }

  @override
  void dispose() {
    _taskBox.close();
    super.dispose();
  }
}