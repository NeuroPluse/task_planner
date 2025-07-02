import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:weekly_task_planner/providers/theme_provider.dart';
import 'package:weekly_task_planner/main.dart';
import 'package:weekly_task_planner/providers/task_provider.dart';
import 'package:weekly_task_planner/models/task.dart';
import 'package:weekly_task_planner/l10n/app_localizations.dart';

void main() {
  testWidgets('App builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const WeeklyPlannerApp(),
      ),
    );
    expect(find.text('Планировщик задач'), findsOneWidget);
  });

  testWidgets('Add task test', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => TaskProvider()),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const WeeklyPlannerApp(),
      ),
    );

    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Новая задача');
    await tester.tap(find.text('Создать задачу'));
    await tester.pumpAndSettle();

    expect(find.text('Новая задача'), findsOneWidget);
  });

  testWidgets('Toggle task completion test', (WidgetTester tester) async {
    final taskProvider = TaskProvider();
    final task = Task(
      id: '1',
      title: 'Тестовая задача',
      date: DateTime.now(),
      priority: 1,
    );
    taskProvider.addTask(task);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: taskProvider),
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ],
        child: const WeeklyPlannerApp(),
      ),
    );

    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();

    expect(taskProvider.tasks.first.isCompleted, true);
  });
}