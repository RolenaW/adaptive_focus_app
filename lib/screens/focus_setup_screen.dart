import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../data/preference_helper.dart';
import '../data/ai_focus_dj_helper.dart';
import 'active_session_screen.dart'; //imports
import '/main.dart';

class FocusSetupScreen extends StatefulWidget { //FocusSetupScreen class created. StatefulWidget used.
  const FocusSetupScreen({super.key}); //main screen for focus session setup

  @override
  State<FocusSetupScreen> createState() => _FocusSetupScreenState();
}

class _FocusSetupScreenState extends State<FocusSetupScreen> { //forms key for validation
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); //forms key for validation
  final TextEditingController _sessionNameController = TextEditingController();  // manages text for session name field

  final List<String> _moodOptions = <String>[ //dropdown options for mood and task
    'Calm',
    'Focused',
    'Tired',
    'Stressed',
    'Motivated',
  ];

  final List<String> _taskTypeOptions = <String>[
    'Studying',
    'Writing',
    'Coding',
    'Reading',
    'Planning',
  ];

  final List<int> _workDurationOptions = <int>[25, 45, 60, 90]; //duration options
  final List<int> _breakDurationOptions = <int>[5, 10, 15, 20];

  String? _selectedMood; //stores current mood
  String? _selectedTaskType; //stores task type
  int _selectedWorkDuration = 25; //stores woek duration (default = 25)
  int _selectedBreakDuration = 5; //stores break duration (default = 5)
  double _energyLevel = 5.0; //stores slider value
  bool _saveAsBlueprint = false; //stores whether user checked checkbox (default = false)
  bool _darkModeEnabled = false; //stores date
  DateTime? _selectedStartDate; //stores selcted date

  AiFocusDjRecommendation? _aiRecommendation; //ai state recommendation, store results
  bool _aiApplied = false; //whether ai was applied

  @override  
  void initState() {
    super.initState();
    _loadPreferences(); //loads saved preferences (like darkmode)
  }

  @override
  void dispose() {
    _sessionNameController.dispose();
    super.dispose(); //prevent memory leak
  }

  Future<void> _loadPreferences() async { // Load saved preferences into form, connects UI to local storage
    final bool savedDarkMode = await PreferencesHelper.getDarkMode();
    final int savedWorkDuration = await PreferencesHelper.getDefaultWorkDuration();
    final int savedBreakDuration = await PreferencesHelper.getDefaultBreakDuration();

    if (!mounted) return; //ensures widget exists

    setState(() {
      _darkModeEnabled = savedDarkMode;
      _selectedWorkDuration = savedWorkDuration;
      _selectedBreakDuration = savedBreakDuration;
    });
  }

  Future<void> _pickStartDate() async { //flutter built-in date picker
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker( //calendar popup
      context: context,
      initialDate: _selectedStartDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select Session Date',
    );

    if (pickedDate != null) { //saves date selected
      setState(() {
        _selectedStartDate = pickedDate;
      });
    }
  }

  void _generateAiRecommendation() { //generate rule-based ai recommendation
    final AiFocusDjRecommendation recommendation =
        AiFocusDjHelper.getRecommendation(
      mood: _selectedMood,
      taskType: _selectedTaskType,
      energyLevel: _energyLevel.round(),
    );

    setState(() {
      _aiRecommendation = recommendation; //store result
      _aiApplied = false;
    });
  }

  void _applyAiRecommendation() { //apply ai-recommended work and break durations
    if (_aiRecommendation == null) {
      return;
    }

    setState(() {
      _selectedWorkDuration = _aiRecommendation!.recommendedWorkDuration;
      _selectedBreakDuration = _aiRecommendation!.recommendedBreakDuration;
      _aiApplied = true;
    });

    ScaffoldMessenger.of(context).showSnackBar( //confirmation
      const SnackBar(
        content: Text('AI Focus DJ recommendation applied.'),
      ),
    );
  }

  String _buildSoundMixLabel(AiFocusDjRecommendation recommendation) { // build readable sound list for ai explanation
    final List<String> enabledSounds = <String>[];

    if (recommendation.rainEnabled) enabledSounds.add('Rain');
    if (recommendation.cafeEnabled) enabledSounds.add('Café');
    if (recommendation.whiteNoiseEnabled) enabledSounds.add('White Noise');
    if (recommendation.natureEnabled) enabledSounds.add('Nature');
    if (recommendation.instrumentalEnabled) enabledSounds.add('Instrumental');

    if (enabledSounds.isEmpty) {
      return 'No sound layers selected';
    }
    return enabledSounds.join(', ');
  }

  String? _validateSessionName(String? value) { //validate session name
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

  String? _validateRequiredSelection(String? value, String fieldName) { //reusable dropdown validator
    if (value == null || value.trim().isEmpty) {
      return 'Please select a $fieldName.';
    }
    return null;
  }

  Future<void> _submitForm() async { //save session into SQLite and open active session screen
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

    final String cleanedSessionName = _sessionNameController.text.trim();

    final Map<String, dynamic> sessionData = <String, dynamic>{ //prepares the data for database
      'session_name': cleanedSessionName,
      'mood': _selectedMood!,
      'task_type': _selectedTaskType!,
      'energy_level': _energyLevel.round(),
      'work_duration_minutes': _selectedWorkDuration,
      'break_duration_minutes': _selectedBreakDuration,
      'session_date': _selectedStartDate!.toIso8601String(),
      'completed': 0,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      // Insert session and get new row ID
      final int insertedId =
          await DatabaseHelper.instance.createFocusSession(sessionData);

      if (!mounted) return;

      await showDialog<void>( //shows the confirmation log
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

      Navigator.push( //open active session tied to the saved database row
        context,
        MaterialPageRoute(
          builder: (context) => ActiveSessionScreen(sessionId: insertedId),
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

  String _formatDate(DateTime date) { //format date for screen display
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$month/$day/$year';
  }

  @override
  Widget build(BuildContext context) { //UI build
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text(
                        'Focus Session Setup',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Set your mood, task type, energy level, and timing before starting a session.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),

                      TextFormField( //session name input
                        controller: _sessionNameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Session Name',
                          hintText: 'Example: Deep Study Block',
                          prefixIcon: Icon(Icons.edit_note_rounded),
                        ),
                        validator: _validateSessionName,
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>( //mood dropdown
                        value: _selectedMood,
                        decoration: const InputDecoration(
                          labelText: 'Mood',
                          prefixIcon: Icon(Icons.mood_rounded),
                        ),
                        items: _moodOptions.map((String mood) {
                          return DropdownMenuItem<String>(
                            value: mood,
                            child: Text(mood),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedMood = value;
                          });
                        },
                        validator: (String? value) =>
                            _validateRequiredSelection(value, 'mood'),
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<String>( //task dropdown
                        value: _selectedTaskType,
                        decoration: const InputDecoration(
                          labelText: 'Task Type',
                          prefixIcon: Icon(Icons.task_alt_rounded),
                        ),
                        items: _taskTypeOptions.map((String taskType) {
                          return DropdownMenuItem<String>(
                            value: taskType,
                            child: Text(taskType),
                          );
                        }).toList(),
                        onChanged: (String? value) {
                          setState(() {
                            _selectedTaskType = value;
                          });
                        },
                        validator: (String? value) =>
                            _validateRequiredSelection(value, 'task type'),
                      ),
                      const SizedBox(height: 16),

                      InputDecorator( //date picker
                        decoration: const InputDecoration(
                          labelText: 'Session Date',
                          prefixIcon: Icon(Icons.calendar_today_rounded),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(
                            _selectedStartDate == null
                                ? 'Select a date'
                                : _formatDate(_selectedStartDate!),
                          ),
                          trailing: const Icon(Icons.arrow_drop_down),
                          onTap: _pickStartDate,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text( //energy slider
                        'Energy Level: ${_energyLevel.round()}/10',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Slider(
                        value: _energyLevel,
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: _energyLevel.round().toString(),
                        onChanged: (double value) {
                          setState(() {
                            _energyLevel = value;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      Card( //ai siggestion card
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text(
                                'AI Focus DJ',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Generate a suggested sound mix and session timing based on mood, task type, and energy.',
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 12),
                              ElevatedButton.icon(
                                onPressed: _generateAiRecommendation,
                                icon: const Icon(Icons.auto_awesome),
                                label: const Text('Generate AI Suggestion'),
                              ),
                              if (_aiRecommendation != null) ...[
                                const SizedBox(height: 16),
                                Text(
                                  'Suggested Mix: ${_aiRecommendation!.mixName}',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Sound Layers: ${_buildSoundMixLabel(_aiRecommendation!)}',
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  'Recommended Work: ${_aiRecommendation!.recommendedWorkDuration} minutes',
                                ),
                                Text(
                                  'Recommended Break: ${_aiRecommendation!.recommendedBreakDuration} minutes',
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Why: ${_aiRecommendation!.explanation}',
                                ),
                                const SizedBox(height: 12),
                                ElevatedButton.icon(
                                  onPressed: _applyAiRecommendation,
                                  icon: const Icon(Icons.check_circle_outline),
                                  label: const Text('Apply Suggestion'),
                                ),
                                if (_aiApplied) ...[
                                  const SizedBox(height: 8),
                                  Text(
                                    'Suggestion applied to this session.',
                                    style: TextStyle(
                                      color: Colors.green.shade700,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ],
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      DropdownButtonFormField<int>( //work duration dropdown
                        value: _selectedWorkDuration,
                        decoration: const InputDecoration(
                          labelText: 'Work Duration (minutes)',
                          prefixIcon: Icon(Icons.timer_rounded),
                        ),
                        items: _workDurationOptions.map((int minutes) {
                          return DropdownMenuItem<int>(
                            value: minutes,
                            child: Text('$minutes minutes'),
                          );
                        }).toList(),
                        onChanged: (int? value) async {
                          if (value != null) {
                            await PreferencesHelper.setDefaultWorkDuration(
                              value,
                            );

                            if (!mounted) return;

                            setState(() {
                              _selectedWorkDuration = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      DropdownButtonFormField<int>( //break duration dropdown
                        value: _selectedBreakDuration,
                        decoration: const InputDecoration(
                          labelText: 'Break Duration (minutes)',
                          prefixIcon: Icon(Icons.free_breakfast_rounded),
                        ),
                        items: _breakDurationOptions.map((int minutes) {
                          return DropdownMenuItem<int>(
                            value: minutes,
                            child: Text('$minutes minutes'),
                          );
                        }).toList(),
                        onChanged: (int? value) async {
                          if (value != null) {
                            await PreferencesHelper.setDefaultBreakDuration(
                              value,
                            );

                            if (!mounted) return;

                            setState(() {
                              _selectedBreakDuration = value;
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 16),

                      SwitchListTile( //dark mode switch
                        contentPadding: EdgeInsets.zero,
                        value: _darkModeEnabled,
                        title: const Text('Enable dark mode'),
                        subtitle: const Text(
                          'Save app theme preference locally',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _darkModeEnabled = value;
                          });
                          FocusStudioApp.of(context)?.toggleTheme(value);
                        },
                      ),
                      const SizedBox(height: 16),

                      CheckboxListTile( //blueprint checkbox
                        contentPadding: EdgeInsets.zero,
                        value: _saveAsBlueprint,
                        title: const Text('Save as reusable blueprint'),
                        subtitle: const Text(
                          'Store this setup for future sessions',
                        ),
                        onChanged: (bool? value) {
                          setState(() {
                            _saveAsBlueprint = value ?? false;
                          });
                        },
                      ),
                      const SizedBox(height: 20),

                      SizedBox( //submit button
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
          ),
        ),
      ),
    );
  }
}