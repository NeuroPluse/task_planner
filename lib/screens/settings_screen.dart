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
          localizations.settings,
          style: GoogleFonts.inter(
            fontWeight: FontWeight.w700,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.surface,
              Theme.of(context).colorScheme.surfaceContainer.withOpacity(0.95),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                localizations.notificationSettings,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: DropdownButtonFormField<int>(
                    value: taskProvider.notificationMinutesBefore,
                    decoration: InputDecoration(
                      labelText: localizations.notifyBefore,
                      prefixIcon: Icon(
                        Icons.notifications_rounded,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Theme.of(context).colorScheme.surfaceContainer,
                    ),
                    items: [0, 5, 10, 15, 30, 60].map((minutes) {
                      return DropdownMenuItem(
                        value: minutes,
                        child: Text(localizations.getNotificationTimeText(minutes)),
                      );
                    }).toList(),
                    onChanged: (value) {
                      taskProvider.setNotificationMinutesBefore(value!);
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}