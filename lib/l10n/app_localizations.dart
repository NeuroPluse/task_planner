import 'package:flutter/material.dart';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  // Основные строки приложения
  String get appTitle => locale.languageCode == 'ru' ? 'Планировщик задач' : 'Task Planner';
  String get newTask => locale.languageCode == 'ru' ? 'Новая задача' : 'New Task';
  String get editTask => locale.languageCode == 'ru' ? 'Редактировать задачу' : 'Edit Task';
  String get taskDeleted => locale.languageCode == 'ru' ? 'Задача удалена' : 'Task deleted';
  String get undo => locale.languageCode == 'ru' ? 'Отменить' : 'Undo';
  String get createTask => locale.languageCode == 'ru' ? 'Создать задачу' : 'Create Task';
  String get save => locale.languageCode == 'ru' ? 'Сохранить' : 'Save';
  String get close => locale.languageCode == 'ru' ? 'Закрыть' : 'Close';
  String get cancel => locale.languageCode == 'ru' ? 'Отмена' : 'Cancel';
  String get delete => locale.languageCode == 'ru' ? 'Удалить' : 'Delete';
  String get edit => locale.languageCode == 'ru' ? 'Редактировать' : 'Edit';

  // Статистика
  String get weekStats => locale.languageCode == 'ru' ? 'Статистика недели' : 'Week Statistics';
  String get totalTasks => locale.languageCode == 'ru' ? 'Всего задач' : 'Total Tasks';
  String get completed => locale.languageCode == 'ru' ? 'Выполнено' : 'Completed';
  String get pending => locale.languageCode == 'ru' ? 'Осталось' : 'Pending';
  String get highPriority => locale.languageCode == 'ru' ? 'Высокий приоритет' : 'High Priority';
  String get progress => locale.languageCode == 'ru' ? 'Прогресс недели' : 'Week Progress';
  String get noTasks => locale.languageCode == 'ru' ? 'Нет задач на эту неделю' : 'No tasks for this week';
  String get progressText => locale.languageCode == 'ru' ? 'Прогресс' : 'Progress';

  // Форма задачи
  String get taskName => locale.languageCode == 'ru' ? 'Название задачи' : 'Task Name';
  String get description => locale.languageCode == 'ru' ? 'Описание (необязательно)' : 'Description (optional)';
  String get priority => locale.languageCode == 'ru' ? 'Приоритет' : 'Priority';
  String get tasks => locale.languageCode == 'ru' ? 'задач' : 'tasks';
  String get task => locale.languageCode == 'ru' ? 'задача' : 'task';
  String get taskRequired => locale.languageCode == 'ru' ? 'Название задачи обязательно' : 'Task name is required';

  // Настройки
  String get settings => locale.languageCode == 'ru' ? 'Настройки' : 'Settings';
  String get notificationSettings => locale.languageCode == 'ru' ? 'Настройки уведомлений' : 'Notification Settings';
  String get notifyBefore => locale.languageCode == 'ru' ? 'Уведомлять за' : 'Notify before';
  String get themeSettings => locale.languageCode == 'ru' ? 'Настройки темы' : 'Theme Settings';
  String get selectTheme => locale.languageCode == 'ru' ? 'Выбрать тему' : 'Select Theme';
  String get systemTheme => locale.languageCode == 'ru' ? 'Системная' : 'System';
  String get lightTheme => locale.languageCode == 'ru' ? 'Светлая' : 'Light';
  String get darkTheme => locale.languageCode == 'ru' ? 'Темная' : 'Dark';

  // Уведомления
  String get minutes => locale.languageCode == 'ru' ? 'минут' : 'minutes';
  String get minute => locale.languageCode == 'ru' ? 'минута' : 'minute';
  String get notificationTitle => locale.languageCode == 'ru' ? 'Напоминание о задаче' : 'Task Reminder';

  // Действия
  String get swipeToComplete => locale.languageCode == 'ru' ? 'Проведите влево чтобы выполнить' : 'Swipe left to complete';
  String get swipeToDelete => locale.languageCode == 'ru' ? 'Проведите вправо чтобы удалить' : 'Swipe right to delete';
  String get taskCompleted => locale.languageCode == 'ru' ? 'Задача выполнена' : 'Task completed';
  String get allTasksCompleted => locale.languageCode == 'ru' ? 'Все задачи выполнены!' : 'All tasks completed!';
  String get congratulations => locale.languageCode == 'ru' ? 'Поздравляем!' : 'Congratulations!';

  // Дни недели
  String getDayName(int weekday) {
    const daysRu = [
      'Понедельник', 'Вторник', 'Среда', 'Четверг', 'Пятница', 'Суббота', 'Воскресенье'
    ];
    const daysEn = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];
    return locale.languageCode == 'ru' ? daysRu[weekday - 1] : daysEn[weekday - 1];
  }

  String getDayNameShort(int weekday) {
    const daysRu = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    const daysEn = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return locale.languageCode == 'ru' ? daysRu[weekday - 1] : daysEn[weekday - 1];
  }

  // Приоритеты
  String getPriorityText(int priority) {
    const prioritiesRu = ['Низкий', 'Средний', 'Высокий'];
    const prioritiesEn = ['Low', 'Medium', 'High'];
    return locale.languageCode == 'ru' ? prioritiesRu[priority] : prioritiesEn[priority];
  }

  // Форматирование времени уведомлений
  String getNotificationTimeText(int minutes) {
    if (minutes == 0) {
      return locale.languageCode == 'ru' ? 'В момент события' : 'At the time of event';
    }
    return '$minutes ${_getMinutesText(minutes)}';
  }

  String _getMinutesText(int minutes) {
    if (locale.languageCode == 'ru') {
      if (minutes == 1) return 'минуту';
      if (minutes < 5) return 'минуты';
      return 'минут';
    } else {
      return minutes == 1 ? 'minute' : 'minutes';
    }
  }

  // Получение текста для количества задач
  String getTasksCountText(int count) {
    if (locale.languageCode == 'ru') {
      if (count % 10 == 1 && count % 100 != 11) return '$count задача';
      if (count % 10 >= 2 && count % 10 <= 4 && (count % 100 < 10 || count % 100 >= 20)) return '$count задачи';
      return '$count задач';
    } else {
      return count == 1 ? '$count task' : '$count tasks';
    }
  }

  String getCategoryText(String category) {
    if (locale.languageCode == 'ru') {
      switch (category) {
        case 'General':
          return 'Общее';
        case 'Work':
          return 'Работа';
        case 'Personal':
          return 'Личное';
        case 'Study':
          return 'Учеба';
        default:
          return category;
      }
    }
    return category;
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ru', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}