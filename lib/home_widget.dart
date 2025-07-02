import 'package:home_widget/home_widget.dart' as hw;
import 'package:weekly_task_planner/models/task.dart';

class HomeWidget {
  static const String widgetName = 'TaskWidget';

  static Future<void> updateWidget(List<Task> tasks) async {
    final todayTasks = tasks.where((task) {
      final now = DateTime.now();
      return task.date.year == now.year &&
          task.date.month == now.month &&
          task.date.day == now.day;
    }).toList();

    await hw.HomeWidget.saveWidgetData<String>('tasks', todayTasks.map((task) => task.title).join(', '));
    await hw.HomeWidget.updateWidget();
  }
}