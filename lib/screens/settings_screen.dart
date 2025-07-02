import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:weekly_task_planner/l10n/app_localizations.dart';
import 'package:weekly_task_planner/providers/task_provider.dart';
import 'package:google_fonts/google_fonts.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          localizations.appTitle,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.notificationSettings,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: taskProvider.notificationMinutesBefore,
              decoration: InputDecoration(
                labelText: localizations.notifyBefore,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceContainer,
              ),
              items: [0, 5, 10, 15, 30, 60].map((minutes) {
                return DropdownMenuItem(
                  value: minutes,
                  child: Text('$minutes минут'),
                );
              }).toList(),
              onChanged: (value) {
                taskProvider.setNotificationMinutesBefore(value!);
              },
            ),
          ],
        ),
      ),
    );
  }
}