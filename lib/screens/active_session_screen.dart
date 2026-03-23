import 'dart:async';
import 'package:flutter/material.dart';
import '../data/database_helper.dart';

class ActiveSessionScreen extends StatefulWidget { //creates ActiveScreenSession class, stateful used
  final int? sessionId; //tells screen which db row to update
  const ActiveSessionScreen({super.key, this.sessionId,});

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  Timer? _timer; //setting up the timer

  int _remainingSeconds = 25 * 60; //tracks how much time left
  bool _isRunning = false; //tracks whether time is active
  bool _isBreak = false; //track if in break or focus mode

  @override
  void dispose() { 
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _markSessionCompleted() async { //mark saved session as completed
    if (widget.sessionId == null) {
      return;
    }

    try {
      await DatabaseHelper.instance.updateFocusSession(
        widget.sessionId!,
        <String, dynamic>{
          'completed': 1,
        },
      );
    } catch (error) { //prevent crash
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update session: $error'),
        ),
      );
    }
  }

  void _startTimer() { //runs every second
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) { //added to cancel timer if widget is removed
        timer.cancel();
        return;
      }
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel(); //cancel before switching
        _switchMode();
      }
    });
  }

  void _pauseTimer() { //stops timer but keeps remaining time
    _timer?.cancel();

    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() { //resets everything
    _timer?.cancel();

    setState(() {
      _isRunning = false;
      _isBreak = false;
      _remainingSeconds = 25 * 60;
    });
  }
  Future<void> _exitSession() async {
    _timer?.cancel();

    if (!mounted) return;

    Navigator.of(context).pop();
  }

  Future<void> _switchMode() async { //Pomodoro: switching b/w focus and break
    final bool wasFocusSession = !_isBreak; //before switching, lets us check if we're currentlly in focus block

    _timer?.cancel();

    if (wasFocusSession) {
      await _markSessionCompleted(); //update databasse when focus block finishes
    }

    if (!mounted) return;

    setState(() { //switch timer to next mode
      _isRunning = false; //finishing a focus session
      _isBreak = !_isBreak;
      _remainingSeconds = _isBreak ? 5 * 60 : 25 * 60; //swicth duration
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isBreak ? 'Break time!' : 'Back to focus!'),
      ),
    );
  }

  String _formatTime(int seconds) { //formats time to be readable
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
                TweenAnimationBuilder<double>( //scale animation
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

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon( //start: disbaled if running
                      onPressed: _isRunning ? null : _startTimer,
                      icon: const Icon(Icons.play_arrow),
                      label: const Text('Start'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon( //pause: only works if running
                      onPressed: _isRunning ? _pauseTimer : null,
                      icon: const Icon(Icons.pause),
                      label: const Text('Pause'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon( //reset: always avaliable
                      onPressed: _resetTimer,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Reset'),
                    ),
                  ],
                ),

                const SizedBox(height: 16), //exit session
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _exitSession,
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Exit Session'),
                  ),
                ),

                const SizedBox(height: 30),

                Text(
                  _isRunning //gives user status updates
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