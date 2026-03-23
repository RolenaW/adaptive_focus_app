import 'dart:async';
import 'package:flutter/material.dart';
import '../data/database_helper.dart';

class ActiveSessionScreen extends StatefulWidget {
  final int? sessionId;

  const ActiveSessionScreen({
    super.key,
    this.sessionId,
  });

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  Timer? _timer;

  // Default Pomodoro time
  int _remainingSeconds = 25 * 60;

  // Track whether timer is active
  bool _isRunning = false;

  // Track whether user is on break or focus session
  bool _isBreak = false;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  // Mark the linked saved session as completed
  Future<void> _markSessionCompleted() async {
    if (widget.sessionId == null) {
      return;
    }

    try {
      await DatabaseHelper.instance.updateFocusSession(
        widget.sessionId!,
        <String, dynamic>{'completed': 1},
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update session: $error'),
        ),
      );
    }
  }

  // Start timer if not already running
  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel();
        _switchMode();
      }
    });
  }

  // Pause timer
  void _pauseTimer() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
    });
  }

  // Reset timer back to focus mode defaults
  void _resetTimer() {
    _timer?.cancel();

    setState(() {
      _isRunning = false;
      _isBreak = false;
      _remainingSeconds = 25 * 60;
    });
  }

  // Exit screen and stop timer
  Future<void> _exitSession() async {
    _timer?.cancel();

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  // Switch between focus and break
  Future<void> _switchMode() async {
    final bool wasFocusSession = !_isBreak;

    _timer?.cancel();

    // Only mark session completed when a focus block ends
    if (wasFocusSession) {
      await _markSessionCompleted();
    }

    if (!mounted) return;

    setState(() {
      _isRunning = false;
      _isBreak = !_isBreak;
      _remainingSeconds = _isBreak ? 5 * 60 : 25 * 60;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBreak ? 'Break time!' : 'Back to focus!'),
      ),
    );
  }

  // Convert seconds into MM:SS
  String _formatTime(int seconds) {
    final int minutes = seconds ~/ 60;
    final int secs = seconds % 60;

    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 500),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  _isBreak ? 'Break Time' : 'Focus Session',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 20),

                // Simple timer animation
                TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 300),
                  tween: Tween<double>(begin: 0.9, end: 1.0),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: child,
                    );
                  },
                  child: Text(
                    _formatTime(_remainingSeconds),
                    style: const TextStyle(
                      fontSize: 60,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Main timer controls
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _isRunning ? null : _startTimer,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _isRunning ? _pauseTimer : null,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Exit session button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _exitSession,
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Exit Session'),
                  ),
                ),

                const SizedBox(height: 30),

                // Status text
                Text(
                  _isRunning
                      ? 'Session in progress...'
                      : 'Press Start to begin',
                  style: TextStyle(
                    color: Colors.grey.shade600,
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