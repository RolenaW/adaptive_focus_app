import 'package:flutter/material.dart';
import '../data/database_helper.dart';

class SoundscapeScreen extends StatefulWidget { //SoundScapeScreen class created. Stateful used
  const SoundscapeScreen({super.key});

  @override
  State<SoundscapeScreen> createState() => _SoundscapeScreenState();
}

class _SoundscapeScreenState extends State<SoundscapeScreen> {
  // Current sound toggles
  bool _rainEnabled = true; //SoundScapeScreen class created. Stateful used
  bool _cafeEnabled = false;
  bool _whiteNoiseEnabled = true;
  bool _natureEnabled = false;
  bool _instrumentalEnabled = false;

  // Master volume from 0.0 to 1.0
  double _masterVolume = 0.5; //stores volume

  // Count enabled layers for summary
  int _getEnabledSoundCount() {
    int enabledCount = 0;

    if (_rainEnabled) enabledCount++;
    if (_cafeEnabled) enabledCount++;
    if (_whiteNoiseEnabled) enabledCount++;
    if (_natureEnabled) enabledCount++;
    if (_instrumentalEnabled) enabledCount++;

    return enabledCount;
  }

  // Save a sound preset into SQLite
  Future<void> _showSavePresetDialog() async {
    final TextEditingController presetNameController =
        TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save Sound Preset'),
          content: TextField(
            controller: presetNameController,
            decoration: const InputDecoration(
              labelText: 'Preset Name',
              hintText: 'Example: Deep Focus Rain',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                presetNameController.dispose();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final String presetName =
                    presetNameController.text.trim();

                if (presetName.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Please enter a preset name.'),
                    ),
                  );
                  return;
                }

                try {
                  await DatabaseHelper.instance.createSoundPreset(
                    <String, dynamic>{
                      'preset_name': presetName,
                      'rain_enabled': _rainEnabled ? 1 : 0,
                      'cafe_enabled': _cafeEnabled ? 1 : 0,
                      'white_noise_enabled': _whiteNoiseEnabled ? 1 : 0,
                      'nature_enabled': _natureEnabled ? 1 : 0,
                      'instrumental_enabled': _instrumentalEnabled ? 1 : 0,
                      'master_volume': _masterVolume,
                      'created_at': DateTime.now().toIso8601String(),
                    },
                  );

                  if (!mounted) return;

                  Navigator.of(context).pop();
                  presetNameController.dispose();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Preset saved successfully.'),
                    ),
                  );
                } catch (error) {
                  if (!mounted) return;

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Failed to save preset: $error'),
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
  }

  @override
  Widget build(BuildContext context) {
    final int enabledSoundCount = _getEnabledSoundCount();

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
                    Text(
                      'Soundscape Studio',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Customize your focus audio environment by enabling sound layers and adjusting volume.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 24),

                    // Rain toggle
                    SwitchListTile(
                      value: _rainEnabled,
                      title: const Text('Rain'),
                      subtitle: const Text(
                        'Soft rain ambience for calm focus',
                      ),
                      secondary: const Icon(Icons.water_drop_outlined),
                      onChanged: (bool value) {
                        setState(() {
                          _rainEnabled = value;
                        });
                      },
                    ),

                    // Cafe toggle
                    SwitchListTile(
                      value: _cafeEnabled,
                      title: const Text('Café'),
                      subtitle: const Text(
                        'Background café chatter and room tone',
                      ),
                      secondary: const Icon(Icons.local_cafe_outlined),
                      onChanged: (bool value) {
                        setState(() {
                          _cafeEnabled = value;
                        });
                      },
                    ),

                    // White noise toggle
                    SwitchListTile(
                      value: _whiteNoiseEnabled,
                      title: const Text('White Noise'),
                      subtitle: const Text(
                        'Steady masking noise for fewer distractions',
                      ),
                      secondary: const Icon(Icons.blur_on_outlined),
                      onChanged: (bool value) {
                        setState(() {
                          _whiteNoiseEnabled = value;
                        });
                      },
                    ),

                    // Nature toggle
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

                    // Instrumental toggle
                    SwitchListTile(
                      value: _instrumentalEnabled,
                      title: const Text('Instrumental'),
                      subtitle: const Text(
                        'Gentle background instrumental sound',
                      ),
                      secondary: const Icon(Icons.music_note_outlined),
                      onChanged: (bool value) {
                        setState(() {
                          _instrumentalEnabled = value;
                        });
                      },
                    ),

                    const SizedBox(height: 20),

                    // Volume slider label
                    Text(
                      'Master Volume: ${(_masterVolume * 100).round()}%',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),

                    // Volume slider
                    Slider(
                      value: _masterVolume,
                      min: 0.0,
                      max: 1.0,
                      divisions: 10,
                      label: '${(_masterVolume * 100).round()}%',
                      onChanged: (double value) {
                        setState(() {
                          _masterVolume = value;
                        });
                      },
                    ),

                    const SizedBox(height: 12),

                    // Summary box
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      padding: const EdgeInsets.all(16.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            'Current Mix Summary',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text('Enabled layers: $enabledSoundCount'),
                          Text(
                            'Volume level: ${(_masterVolume * 100).round()}%',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Save preset button
                    SizedBox(
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: _showSavePresetDialog,
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