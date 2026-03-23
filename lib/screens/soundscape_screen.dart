import 'package:flutter/material.dart';

class SoundscapeScreen extends StatefulWidget { //SoundScapeScreen class created. Stateful used
  const SoundscapeScreen({super.key});

  @override
  State<SoundscapeScreen> createState() => _SoundscapeScreenState();
}

class _SoundscapeScreenState extends State<SoundscapeScreen> {
  bool _rainEnabled = true; //sound layer state variables
  bool _cafeEnabled = false;
  bool _whiteNoiseEnabled = true;
  bool _natureEnabled = false;
  bool _instrumentalEnabled = false;

  double _masterVolume = 0.5; //stores volume

  void _showPresetMessage() { //shows snackbar when user saves
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Preset saving will be connected later.'),
      ),
    );
  }

  int _getEnabledSoundCount() { //counts how many sound layers are currently turned on
    int enabledCount = 0;

    if (_rainEnabled) enabledCount++;
    if (_cafeEnabled) enabledCount++;
    if (_whiteNoiseEnabled) enabledCount++;
    if (_natureEnabled) enabledCount++;
    if (_instrumentalEnabled) enabledCount++; //checks boolean and adds 1 for each enable sound ^

    return enabledCount;
  }

  @override
  Widget build(BuildContext context) {
    final int enabledSoundCount = _getEnabledSoundCount(); //calculates active sound layers

    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Text( //screen title
                      'Soundscape Studio',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text( //description
                      'Customize your focus audio environment by enabling sound layers and adjusting volume.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),
                    SwitchListTile( //creates toggle row for one sound layer (same for rest below)
                      value: _rainEnabled, //tells whether switch is on or off
                      title: const Text('Rain'), //title
                      subtitle: const Text('Soft rain ambience for calm focus'), //description
                      secondary: const Icon(Icons.water_drop_outlined), //icon
                      onChanged: (bool value) { //runs when switch is flipped
                        setState(() {
                          _rainEnabled = value;
                        });
                      },
                    ),
                    SwitchListTile( 
                      value: _cafeEnabled,
                      title: const Text('Café'),
                      subtitle: const Text('Background café chatter and room tone'),
                      secondary: const Icon(Icons.local_cafe_outlined),
                      onChanged: (bool value) {
                        setState(() {
                          _cafeEnabled = value;
                        });
                      },
                    ),
                    SwitchListTile( 
                      value: _whiteNoiseEnabled,
                      title: const Text('White Noise'),
                      subtitle: const Text('Steady masking noise for fewer distractions'),
                      secondary: const Icon(Icons.blur_on_outlined),
                      onChanged: (bool value) {
                        setState(() {
                          _whiteNoiseEnabled = value;
                        });
                      },
                    ),
                    SwitchListTile( 
                      value: _natureEnabled,
                      title: const Text('Nature'),
                      subtitle: const Text('Forest and outdoor ambience'),
                      secondary: const Icon(Icons.park_outlined),
                      onChanged: (bool value) {
                        setState(() {
                          _natureEnabled = value;
                        });
                      },
                    ),
                    SwitchListTile(
                      value: _instrumentalEnabled,
                      title: const Text('Instrumental'),
                      subtitle: const Text('Gentle background instrumental sound'),
                      secondary: const Icon(Icons.music_note_outlined),
                      onChanged: (bool value) {
                        setState(() {
                          _instrumentalEnabled = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Master Volume: ${(_masterVolume * 100).round()}%', //converts decimal volume to percentage
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Slider( //slider to adjust volume
                      value: _masterVolume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: '${(_masterVolume * 100).round()}%', //shows as percentage on slider
                      onChanged: (double value) { //updates slider
                        setState(() {
                          _masterVolume = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    AnimatedContainer( //smooth animation
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text( //shows layers and volume level
                            'Current Mix Summary',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text('Enabled layers: $enabledSoundCount'), //^
                          Text('Volume level: ${(_masterVolume * 100).round()}%'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox( //save button
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _showPresetMessage,
                        icon: const Icon(Icons.save_outlined),
                        label: const Text('Save Preset'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}