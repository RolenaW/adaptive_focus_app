import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import 'active_session_screen.dart';
import '../data/preference_helper.dart';
import '../models/focus_session.dart';
import '../widgets/summary_row.dart';

// 🔥 NEW IMPORT (AI)
import '../services/focus_ai_service.dart';

class FocusSetupScreen extends StatefulWidget {
  const FocusSetupScreen({super.key});

  @override
  State<FocusSetupScreen> createState() => _FocusSetupScreenState();
}

class _FocusSetupScreenState extends State<FocusSetupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _sessionNameController = TextEditingController();

  final List<String> _moodOptions = [
    'Calm',
    'Focused',
    'Tired',
    'Stressed',
    'Motivated',
  ];

  final List<String> _taskTypeOptions = [
    'Studying',
    'Writing',
    'Coding',
    'Reading',
    'Planning',
  ];

  final List<int> _workDurationOptions = [25, 45, 60, 90];
  final List<int> _breakDurationOptions = [5, 10, 15, 20];

  String? _selectedMood;
  String? _selectedTaskType;
  int _selectedWorkDuration = 25;
  int _selectedBreakDuration = 5;
  double _energyLevel = 5.0;
  bool _saveAsBlueprint = false;
  DateTime? _selectedStartDate;
  bool _darkModeEnabled = false;

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final bool savedDarkMode = await PreferencesHelper.getDarkMode();
    final int savedWorkDuration =
        await PreferencesHelper.getDefaultWorkDuration();
    final int savedBreakDuration =
        await PreferencesHelper.getDefaultBreakDuration();

    if (!mounted) return;

    setState(() {
      _darkModeEnabled = savedDarkMode;
      _selectedWorkDuration = savedWorkDuration;
      _selectedBreakDuration = savedBreakDuration;
    });
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );

    if (pickedDate != null) {
      setState(() {
        _selectedStartDate = pickedDate;
      });
    }
  }

  Future<void> _submitForm() async {
    final bool isFormValid = _formKey.currentState?.validate() ?? false;

    if (!isFormValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields correctly.'),
        ),
      );
      return;
    }

    if (_selectedStartDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a session date.'),
        ),
      );
      return;
    }

    final String cleanedSessionName =
        _sessionNameController.text.trim();

    final FocusSession session = FocusSession(
      sessionName: cleanedSessionName,
      mood: _selectedMood!,
      taskType: _selectedTaskType!,
      energyLevel: _energyLevel.round(),
      workDuration: _selectedWorkDuration,
      breakDuration: _selectedBreakDuration,
      sessionDate: _selectedStartDate!.toIso8601String(),
      completed: false,
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      final int insertedId =
          await DatabaseHelper.instance.createFocusSession(session.toMap());

      if (!mounted) return;

      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Session Saved'),
            content: Text(
              'Session "$cleanedSessionName" was saved successfully.\n\n'
              'Mood: $_selectedMood\n'
              'Task: $_selectedTaskType\n'
              'Energy: ${_energyLevel.round()}/10\n'
              'Work: $_selectedWorkDuration min\n'
              'Break: $_selectedBreakDuration min\n'
              'Save as blueprint: ${_saveAsBlueprint ? 'Yes' : 'No'}',
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Continue'),
              ),
            ],
          );
        },
      );

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              ActiveSessionScreen(sessionId: insertedId),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save session: $error'),
        ),
      );
    }
  }

  // 🔥 NEW AI FUNCTION
  void _runAIRecommendation() {
    if (_selectedMood == null || _selectedTaskType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select mood and task first')),
      );
      return;
    }

    final result = FocusAIService.generateRecommendation(
      mood: _selectedMood!,
      task: _selectedTaskType!,
      energy: _energyLevel.round(),
    );

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('AI Focus Plan'),
        content: Text(
          'Session Type: ${result['sessionType']}\n\n'
          'Sound Mix:\n'
          '${result['rain'] ? '✔ Rain\n' : ''}'
          '${result['cafe'] ? '✔ Café\n' : ''}'
          '${result['whiteNoise'] ? '✔ White Noise\n' : ''}'
          '${result['nature'] ? '✔ Nature\n' : ''}'
          '${result['instrumental'] ? '✔ Instrumental\n' : ''}\n'
          'Volume: ${(result['volume'] * 100).round()}%',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String? _validateSessionName(String? value) {
    final String cleanedValue = value?.trim() ?? '';

    if (cleanedValue.isEmpty) {
      return 'Please enter a session name.';
    }

    if (cleanedValue.length < 3) {
      return 'Session name must be at least 3 characters.';
    }

    if (cleanedValue.length > 30) {
      return 'Session name must be 30 characters or less.';
    }

    return null;
  }

  String? _validateRequiredSelection(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return 'Please select a $fieldName.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool useWideLayout = constraints.maxWidth >= 700;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Focus Session Setup',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set your mood, task type, energy level, and timing before starting a session.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: useWideLayout
                              ? Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    Expanded(child: _buildLeftColumn(context)),
                                    const SizedBox(width: 16),
                                    Expanded(child: _buildRightColumn(context)),
                                  ],
                                )
                              : Column(
                                  children: <Widget>[
                                    _buildLeftColumn(context),
                                    const SizedBox(height: 16),
                                    _buildRightColumn(context),
                                  ],
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),
                      _buildSummaryCard(context),
                      const SizedBox(height: 20),

                      // 🔥 AI BUTTON (ONLY UI ADDITION)
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _runAIRecommendation,
                          icon: const Icon(Icons.auto_awesome),
                          label: const Text('Generate AI Focus Plan'),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _submitForm,
                          icon: const Icon(Icons.play_arrow_rounded),
                          label: const Text('Save Setup'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLeftColumn(BuildContext context) {
    return Column(
      children: <Widget>[
        TextFormField(
          controller: _sessionNameController,
          decoration: const InputDecoration(labelText: 'Session Name'),
          validator: _validateSessionName,
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: _selectedMood,
          decoration: const InputDecoration(labelText: 'Mood'),
          items: _moodOptions
              .map((mood) => DropdownMenuItem(value: mood, child: Text(mood)))
              .toList(),
          onChanged: (value) => setState(() => _selectedMood = value),
          validator: (value) => _validateRequiredSelection(value, 'mood'),
        ),
        const SizedBox(height: 16),

        DropdownButtonFormField<String>(
          value: _selectedTaskType,
          decoration: const InputDecoration(labelText: 'Task Type'),
          items: _taskTypeOptions
              .map((task) => DropdownMenuItem(value: task, child: Text(task)))
              .toList(),
          onChanged: (value) => setState(() => _selectedTaskType = value),
          validator: (value) => _validateRequiredSelection(value, 'task type'),
        ),
        const SizedBox(height: 16),

        ListTile(
          title: Text(
            _selectedStartDate == null
                ? 'Select a date'
                : _formatDate(_selectedStartDate!),
          ),
          trailing: const Icon(Icons.calendar_today),
          onTap: _pickStartDate,
        ),
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) {
    return Column(
      children: <Widget>[
        Text('Energy Level: ${_energyLevel.round()}/10'),
        Slider(
          value: _energyLevel,
          min: 1,
          max: 10,
          divisions: 9,
          onChanged: (value) => setState(() => _energyLevel = value),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SummaryRow(
              label: 'Session Name',
              value: _sessionNameController.text,
            ),
            SummaryRow(
              label: 'Mood',
              value: _selectedMood ?? 'Not selected',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}