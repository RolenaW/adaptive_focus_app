import 'package:adaptive_focus_app/screens/active_session_screen.dart';
import 'package:flutter/material.dart';
import '../data/database_helper.dart';

class InsightsScreen extends StatefulWidget { //InsightsScreen class created. state ful used
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}
class _InsightsScreenState extends State<InsightsScreen> {
  bool _isLoading = true; //tracks whether screen is still loading database data
  int _totalSessions = 0; //stores focus sessions
  int _completedSessions = 0; //counts completed rows
  int _totalDeepWorkMinutes = 0; //adds work duration
  double _averageWorkDuration = 0; //calculates average work duration

  List<Map<String, dynamic>> _sessions = <Map<String, dynamic>>[]; //full session list for update/delete UI

  @override //loading data
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async { //read sessions from SQLite and calculate summary values
    try {
      final List<Map<String, dynamic>> sessions =
          await DatabaseHelper.instance.getAllFocusSessions();

      int completedSessions = 0;
      int totalDeepWorkMinutes = 0;

      for (final Map<String, dynamic> session in sessions) {
        final int workDuration =
            (session['work_duration_minutes'] as int?) ?? 0;
        final int completed = (session['completed'] as int?) ?? 0;

        totalDeepWorkMinutes += workDuration;

        if (completed == 1) {
          completedSessions++;
        }
      }

      final double averageWorkDuration = sessions.isEmpty ? 0 : totalDeepWorkMinutes / sessions.length;
      //calculate average
      if (!mounted) return;

      setState(() {
        _sessions = sessions;
        _totalSessions = sessions.length;
        _completedSessions = completedSessions;
        _totalDeepWorkMinutes = totalDeepWorkMinutes;
        _averageWorkDuration = averageWorkDuration;
        _isLoading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to load insights: $error'), //error mesage
        ),
      );
    }
  }

  String _formatMinutes(int totalMinutes) { //format total minutes into human-readable text
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;

    if (hours == 0) {
      return '${minutes}m';
    }

    return '${hours}h ${minutes}m';
  }

  String _formatSessionDate(String rawDate) { // Convert ISO date → XX/XX/XXXX
    try {
      final DateTime parsedDate = DateTime.parse(rawDate);
      final String month = parsedDate.month.toString().padLeft(2, '0');
      final String day = parsedDate.day.toString().padLeft(2, '0');
      final String year = parsedDate.year.toString();
      return '$month/$day/$year';
    } catch (_) {
      return rawDate;
    }
  }

  Future<void> _deleteSession(int id) async { //delete one session and reload insights
    try {
      await DatabaseHelper.instance.deleteFocusSession(id);
      await _loadInsights();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session deleted successfully.'),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete session: $error'),
        ),
      );
    }
  }

  Future<bool> _confirmDelete(BuildContext context) async { //confirm delete before actually removing row
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Session'),
          content: const Text(
            'Are you sure you want to delete this session?',), //ask before delete
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  Future<void> _showEditSessionDialog(Map<String, dynamic> session) async { //show edit dialog to update one saved session
    final TextEditingController nameController = TextEditingController( //pre-fill fields with current values
      text: (session['session_name'] as String?) ?? '',
    );

    int selectedWorkDuration =
        (session['work_duration_minutes'] as int?) ?? 25;
    int selectedBreakDuration =
        (session['break_duration_minutes'] as int?) ?? 5;
    bool completed = ((session['completed'] as int?) ?? 0) == 1;

    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: const Text('Edit Session'),
              content: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      TextFormField( //edit session name
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Session Name',
                        ),
                        validator: (String? value) {
                          final String cleaned = value?.trim() ?? '';
                          if (cleaned.isEmpty) {
                            return 'Please enter a session name.';
                          }
                          if (cleaned.length < 3) {
                            return 'Session name must be at least 3 characters.';
                          }
                          if (cleaned.length > 30) {
                            return 'Session name must be 30 characters or less.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<int>( //edit work duration
                        value: selectedWorkDuration,
                        decoration: const InputDecoration(
                          labelText: 'Work Duration',
                        ),
                        items: const <int>[25, 45, 60, 90]
                            .map(
                              (int value) => DropdownMenuItem<int>(
                                value: value,
                                child: Text('$value minutes'),
                              ),
                            )
                            .toList(),
                        onChanged: (int? value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedWorkDuration = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<int>( //edit break duration
                        value: selectedBreakDuration,
                        decoration: const InputDecoration(
                          labelText: 'Break Duration',
                        ),
                        items: const <int>[5, 10, 15, 20]
                            .map(
                              (int value) => DropdownMenuItem<int>(
                                value: value,
                                child: Text('$value minutes'),
                              ),
                            )
                            .toList(),
                        onChanged: (int? value) {
                          if (value != null) {
                            setDialogState(() {
                              selectedBreakDuration = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      CheckboxListTile( //edit completion flag toggle
                        contentPadding: EdgeInsets.zero,
                        value: completed,
                        title: const Text('Completed'),
                        onChanged: (bool? value) {
                          setDialogState(() {
                            completed = value ?? false;
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    nameController.dispose();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    final bool isValid =
                        formKey.currentState?.validate() ?? false;

                    if (!isValid) {
                      return;
                    }

                    try {
                      await DatabaseHelper.instance.updateFocusSession(
                        session['id'] as int,
                        <String, dynamic>{
                          'session_name': nameController.text.trim(),
                          'work_duration_minutes': selectedWorkDuration,
                          'break_duration_minutes': selectedBreakDuration,
                          'completed': completed ? 1 : 0,
                        },
                      );

                      if (!mounted) return;

                      Navigator.of(context).pop();
                      nameController.dispose();

                      await _loadInsights(); //refresh UI

                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Session updated successfully.'),
                        ),
                      );
                    } catch (error) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to update session: $error'),
                        ),
                      );
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading indicator while db data is being read
    if (_isLoading) {
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  'Insights & Tracker',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  'Review your focus performance, productivity trends, and session habits.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),

                // Summary cards
                _InsightCard(
                  title: 'Total Sessions',
                  value: _totalSessions.toString(),
                  subtitle: 'Saved focus sessions in the database',
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(height: 16),
                _InsightCard(
                  title: 'Completed Sessions',
                  value: _completedSessions.toString(),
                  subtitle: 'Sessions marked as completed',
                  icon: Icons.task_alt_outlined,
                ),
                const SizedBox(height: 16),
                _InsightCard(
                  title: 'Total Deep Work Time',
                  value: _formatMinutes(_totalDeepWorkMinutes),
                  subtitle: 'Total planned work duration across saved sessions',
                  icon: Icons.timer_outlined,
                ),
                const SizedBox(height: 16),
                _InsightCard(
                  title: 'Average Work Duration',
                  value: '${_averageWorkDuration.toStringAsFixed(1)} min',
                  subtitle: 'Average work duration per saved session',
                  icon: Icons.bar_chart_outlined,
                ),
                const SizedBox(height: 24),

                // Visible session list with update + delete
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Saved Sessions',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Swipe left to delete. Tap edit to update. Long press also opens edit.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 12),
                        if (_sessions.isEmpty)
                          const Text('No saved sessions yet.')
                        else
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: _sessions.length,
                            separatorBuilder: (BuildContext context, int index) {
                              return const SizedBox(height: 10);
                            },
                            itemBuilder: (BuildContext context, int index) {
                              final Map<String, dynamic> session =
                                  _sessions[index];
                              final int sessionId = session['id'] as int;
                              final String sessionName =
                                  (session['session_name'] as String?) ??
                                      'Untitled Session';
                              final String mood =
                                  (session['mood'] as String?) ?? 'Unknown';
                              final String taskType =
                                  (session['task_type'] as String?) ?? 'Unknown';
                              final int workDuration =
                                  (session['work_duration_minutes'] as int?) ??
                                      0;
                              final int breakDuration =
                                  (session['break_duration_minutes'] as int?) ??
                                      0;
                              final String sessionDate =
                                  (session['session_date'] as String?) ?? '';
                              final bool completed =
                                  ((session['completed'] as int?) ?? 0) == 1;

                              return Dismissible(
                                key: ValueKey<int>(sessionId),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20.0,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade400,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.white,
                                  ),
                                ),
                                confirmDismiss: (DismissDirection direction) {
                                  return _confirmDelete(context);
                                },
                                onDismissed: (DismissDirection direction) {
                                  _deleteSession(sessionId);
                                },
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  child: ListTile(
                                    onLongPress: () {
                                      _showEditSessionDialog(session);
                                    },
                                    title: Text(sessionName),
                                    subtitle: Text(
                                      '$mood • $taskType\n'
                                      'Work: $workDuration min | Break: $breakDuration min\n'
                                      'Date: ${_formatSessionDate(sessionDate)}\n'
                                      'Completed: ${completed ? 'Yes' : 'No'}',
                                    ),
                                    onTap: () { //user can access older sessions
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ActiveSessionScreen(
                                            sessionId: session['id'],
                                            workDuration: session['work_duration_minutes'],
                                            breakDuration: session['break_duration_minutes'],
                                          ),
                                        ),
                                      );
                                    },
                                    isThreeLine: true,
                                    trailing: IconButton(
                                      icon: const Icon(Icons.edit_outlined),
                                      onPressed: () {
                                        _showEditSessionDialog(session);
                                      },
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Reload data from SQLite
                SizedBox(
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _loadInsights,
                    icon: const Icon(Icons.refresh_rounded),
                    label: const Text('Refresh Insights'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _InsightCard extends StatelessWidget { //custom widget
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;

  const _InsightCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Row(
          children: <Widget>[
            CircleAvatar(
              child: Icon(icon),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}