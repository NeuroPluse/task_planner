import 'package:flutter/material.dart';

class AppLocalizations {
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  String get appTitle => locale.languageCode == 'ru' ? 'Планировщик задач' : 'Task Planner';
  String get newTask => locale.languageCode == 'ru' ? 'Новая задача' : 'New Task';
  String get editTask => locale.languageCode == 'ru' ? 'Редактировать задачу' : 'Edit Task';
  String get taskDeleted => locale.languageCode == 'ru' ? 'Задача удалена' : 'Task deleted';
  String get undo => locale.languageCode == 'ru' ? 'Отменить' : 'Undo';
  String get createTask => locale.languageCode == 'ru' ? 'Создать задачу' : 'Create Task';
  String get save => locale.languageCode == 'ru' ? 'Сохранить' : 'Save';
  String get weekStats => locale.languageCode == 'ru' ? 'Статистика недели' : 'Week Statistics';
  String get totalTasks => locale.languageCode == 'ru' ? 'Всего задач' : 'Total Tasks';
  String get completed => locale.languageCode == 'ru' ? 'Выполнено' : 'Completed';
  String get pending => locale.languageCode == 'ru' ? 'Осталось' : 'Pending';
  String get highPriority => locale.languageCode == 'ru' ? 'Высокий приоритет' : 'High Priority';
  String get close => locale.languageCode == 'ru' ? 'Закрыть' : 'Close';
  String get progress => locale.languageCode == 'ru' ? 'Прогресс недели' : 'Week Progress';
  String get noTasks => locale.languageCode == 'ru' ? 'Нет задач на эту неделю' : 'No tasks for this week';
  String get taskName => locale.languageCode == 'ru' ? 'Название задачи' : 'Task Name';
  String get description => locale.languageCode == 'ru' ? 'Описание (необязательно)' : 'Description (optional)';
  String get priority => locale.languageCode == 'ru' ? 'Приоритет' : 'Priority';
  String get tasks => locale.languageCode == 'ru' ? 'задач' : 'tasks';
  String get notificationSettings => locale.languageCode == 'ru' ? 'Настройки уведомлений' : 'Notification Settings';
  String get notifyBefore => locale.languageCode == 'ru' ? 'Уведомлять за' : 'Notify before';

  String getDayName(int weekday) {
    const daysRu = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье'
    ];
    const daysEn = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    return locale.languageCode == 'ru' ? daysRu[weekday - 1] : daysEn[weekday - 1];
  }

  String getPriorityText(int priority) {
    const prioritiesRu = ['Низкий', 'Средний', 'Высокий'];
    const prioritiesEn = ['Low', 'Medium', 'High'];
    return locale.languageCode == 'ru' ? prioritiesRu[priority] : prioritiesEn[priority];
  }
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['ru', 'en'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async => AppLocalizations(locale);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}