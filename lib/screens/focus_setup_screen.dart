import 'package:flutter/material.dart';

class FocusSetupScreen extends StatefulWidget { //creates FocusSetupScreen class, statefulwidget used
  const FocusSetupScreen({super.key});

  @override
  State<FocusSetupScreen> createState() => _FocusSetupScreenState();
}

class _FocusSetupScreenState extends State<FocusSetupScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>(); //lets flutter identify/control form
  final TextEditingController _sessionNameController = TextEditingController(); //manages text input for session name

  final List<String> _moodOptions = <String>[ //mood options
    'Calm',
    'Focused',
    'Tired',
    'Stressed',
    'Motivated',
  ];

  final List<String> _taskTypeOptions = <String>[ //task options
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
  DateTime? _selectedStartDate; //stores date

  @override
  void dispose() { //prevent memory leaks. keeps everything clean
    _sessionNameController.dispose(); 
    super.dispose();
  }

  Future<void> _pickStartDate() async { //opens a date picker
    final DateTime now = DateTime.now();

    final DateTime? pickedDate = await showDatePicker( //flutter built-in date picker
      context: context,
      initialDate: _selectedStartDate ?? now,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
      helpText: 'Select Session Date',
    );

    if (pickedDate != null) { //if date is picked then update the screen state, rebuild
      setState(() {
        _selectedStartDate = pickedDate;
      });
    }
  }

  void _submitForm() { //runs when save setup button pressed
    final bool isFormValid = _formKey.currentState?.validate() ?? false; //asks field to validate runs

    if (!isFormValid) { //shows an error if field is incomplete
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields correctly.'),
        ),
      );
      return;
    }

    if (_selectedStartDate == null) { //check if valid date is picked
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a session date.'),
        ),
      );
      return;
    }

    final String cleanedSessionName = _sessionNameController.text.trim(); //removes extra spaces

    showDialog<void>( //showw confirmed dialog
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Session Ready'),
          content: Text(
            'Session "$cleanedSessionName" is ready.\n\n'
            'Mood: $_selectedMood\n'
            'Task: $_selectedTaskType\n'
            'Energy: ${_energyLevel.round()}/10\n'
            'Work: $_selectedWorkDuration min\n'
            'Break: $_selectedBreakDuration min\n'
            'Save as blueprint: ${_saveAsBlueprint ? 'Yes' : 'No'}',
          ),
          actions: <Widget>[
            TextButton( //closes dialog
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  String? _validateSessionName(String? value) { //validates session name
    final String cleanedValue = value?.trim() ?? '';

    if (cleanedValue.isEmpty) { //field can't be blank
      return 'Please enter a session name.';
    }

    if (cleanedValue.length < 3) { //avoids names that are too short
      return 'Session name must be at least 3 characters.';
    }

    if (cleanedValue.length > 30) { //avoids too long names
      return 'Session name must be 30 characters or less.';
    }

    return null; //valid
  }

  String? _validateRequiredSelection(String? value, String fieldName) { //checks dropdown selections
    if (value == null || value.trim().isEmpty) { //if its empty return error
      return 'Please select a $fieldName.';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea( //protection
      child: LayoutBuilder( //gives avaliable width of screen
        builder: (BuildContext context, BoxConstraints constraints) {
          final bool useWideLayout = constraints.maxWidth >= 700;

          return SingleChildScrollView( //scrollable
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Form( //all inputs widgets here
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: <Widget>[
                      Text( //screen heading
                        'Focus Session Setup',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text( //description
                        'Set your mood, task type, energy level, and timing before starting a session.',
                        style: Theme.of(context).textTheme.bodyLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Card( //card that groups main form fields
                        child: Padding( 
                          padding: const EdgeInsets.all(16.0),
                          child: useWideLayout // uses a row with two columns
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
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _submitForm, //save setup button
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

  Widget _buildLeftColumn(BuildContext context) { //builds left half of the form
    return Column(
      children: <Widget>[
        TextFormField( //connects filed to text controller
          controller: _sessionNameController,
          textInputAction: TextInputAction.next, //changes keyboard action to next
          decoration: const InputDecoration( 
            labelText: 'Session Name',
            hintText: 'Example: Deep Study Block',
            prefixIcon: Icon(Icons.edit_note_rounded),
          ),
          validator: _validateSessionName,
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>( //dropdown for mood
          value: _selectedMood,
          decoration: const InputDecoration(
            labelText: 'Mood',
            prefixIcon: Icon(Icons.mood_rounded),
          ),
          items: _moodOptions.map((String mood) { //loops through modd lists and converts each dropdown item
            return DropdownMenuItem<String>(
              value: mood,
              child: Text(mood),
            );
          }).toList(),
          onChanged: (String? value) { //stroes when user picks a mood
            setState(() {
              _selectedMood = value;
            });
          },
          validator: (String? value) => _validateRequiredSelection(value, 'mood'), //uses the reusable validation helper
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          value: _selectedTaskType,
          decoration: const InputDecoration(
            labelText: 'Task Type',
            prefixIcon: Icon(Icons.task_alt_rounded),
          ),
          items: _taskTypeOptions.map((String taskType) { //works the same as mood but task type instead ^
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
        InputDecorator( //makes date section look like a form field
          decoration: const InputDecoration(
            labelText: 'Session Date',
            prefixIcon: Icon(Icons.calendar_today_rounded),
          ),
          child: ListTile( //placeholder text if no date is selected
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
      ],
    );
  }

  Widget _buildRightColumn(BuildContext context) { //builds right half of the form
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Text(
          'Energy Level: ${_energyLevel.round()}/10', //shows slider value
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          value: _energyLevel,
          min: 1,
          max: 10,
          divisions: 9,
          label: _energyLevel.round().toString(),
          onChanged: (double value) { //updatiing UI
            setState(() {
              _energyLevel = value;
            });
          },
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<int>( //work duration
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
          onChanged: (int? value) {
            if (value != null) { //dropdown can be null
              setState(() {
                _selectedWorkDuration = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        DropdownButtonFormField<int>( //same as before
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
          onChanged: (int? value) {
            if (value != null) {
              setState(() {
                _selectedBreakDuration = value;
              });
            }
          },
        ),
        const SizedBox(height: 16),
        CheckboxListTile( //check box requirement
          contentPadding: EdgeInsets.zero,
          value: _saveAsBlueprint,
          title: const Text('Save as reusable blueprint'),
          subtitle: const Text('Store this setup for future sessions'),
          onChanged: (bool? value) {
            setState(() {
              _saveAsBlueprint = value ?? false;
            });
          },
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) { //live summary of form state
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              'Live Summary',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 12),
            _SummaryRow(
              label: 'Session Name',
              value: _sessionNameController.text.trim().isEmpty
                  ? 'Not entered yet'
                  : _sessionNameController.text.trim(),
            ),
            _SummaryRow(
              label: 'Mood',
              value: _selectedMood ?? 'Not selected',
            ),
            _SummaryRow(
              label: 'Task Type',
              value: _selectedTaskType ?? 'Not selected',
            ),
            _SummaryRow(
              label: 'Energy',
              value: '${_energyLevel.round()}/10',
            ),
            _SummaryRow(
              label: 'Work Duration',
              value: '$_selectedWorkDuration minutes',
            ),
            _SummaryRow(
              label: 'Break Duration',
              value: '$_selectedBreakDuration minutes',
            ),
            _SummaryRow(
              label: 'Session Date',
              value: _selectedStartDate == null
                  ? 'Not selected'
                  : _formatDate(_selectedStartDate!),
            ),
            _SummaryRow(
              label: 'Blueprint',
              value: _saveAsBlueprint ? 'Yes' : 'No',
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) { ///converts date into string like: XX/XX/XXXX
    final String month = date.month.toString().padLeft(2, '0');
    final String day = date.day.toString().padLeft(2, '0');
    final String year = date.year.toString();
    return '$month/$day/$year';
  }
}

class _SummaryRow extends StatelessWidget { //reusable widget for summary card
  final String label;
  final String value;

  const _SummaryRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            flex: 2,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(value),
          ),
        ],
      ),
    );
  }
}