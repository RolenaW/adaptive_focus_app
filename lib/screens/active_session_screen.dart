import 'dart:async';
import 'package:flutter/material.dart';
import '../data/database_helper.dart';

class ActiveSessionScreen extends StatefulWidget { //ActiveSessionScreen class created. StatefulWidget used.
  final int? sessionId; //session id to mark session as complete
  final int workDuration;
  final int breakDuration;

  const ActiveSessionScreen({super.key,this.sessionId, 
    required this.workDuration,
    required this.breakDuration,
  });

  @override
  State<ActiveSessionScreen> createState() => _ActiveSessionScreenState();
}

class _ActiveSessionScreenState extends State<ActiveSessionScreen> {
  Timer? _timer; //setting up the timer
  late int _remainingSeconds; //tracks how much time left
  bool _isRunning = false; //tracks whether time is active
  bool _isBreak = false; //track if in break or focus mode
  
  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.workDuration * 60; //uses real duration
  }

  @override
  void dispose() {
    _timer?.cancel(); //stops the timer if the screen is left
    super.dispose();
  }


  Future<void> _markSessionCompleted() async { //mark the linked saved session as completed
    if (widget.sessionId == null) {
      return;
    }

    try {
      await DatabaseHelper.instance.updateFocusSession( 
        widget.sessionId!,
        <String, dynamic>{'completed': 1}, // mark session as done
      );
    } catch (error) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar( //shows error if database update fails
        SnackBar(
          content: Text('Failed to update session: $error'),
        ),
      );
    }
  }

  void _startTimer() { //start timer if not already running
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) { //run every second
      if (!mounted) {
        timer.cancel();
        return;
      }

      if (_remainingSeconds > 0) { //countdown
        setState(() {
          _remainingSeconds--;
        });
      } else {
        timer.cancel(); //time done cancel and/or switch mode
        _switchMode();
      }
    });
  }

  void _pauseTimer() { //pause timer
    _timer?.cancel();

    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() { //reset timer back to focus mode defaults
    _timer?.cancel();

    setState(() {
      _isRunning = false;
      _isBreak = false;
      _remainingSeconds = widget.workDuration * 60;
    });
  }

  Future<void> _exitSession() async { //exit screen and stop timer
    _timer?.cancel();

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _switchMode() async { //switch between focus and break
    final bool wasFocusSession = !_isBreak;

    if (wasFocusSession) { //only mark session completed when a focus block ends
      await _markSessionCompleted();
    }

    setState(() {
      _isBreak = !_isBreak;
      _remainingSeconds = _isBreak 
        ? widget.breakDuration * 60
        : widget.workDuration * 60;
    });

    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar( //show user feedback
      SnackBar(
        content: Text(_isBreak ? 'Break time!' : 'Back to focus!'),
      ),
    );
  }

  String _formatTime(int seconds) { //convert seconds into MM:SS
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
                TweenAnimationBuilder<double>( //timer animation
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
                Row( //main timer controls
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
                SizedBox( //exit session button
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _exitSession,
                    icon: const Icon(Icons.exit_to_app),
                    label: const Text('Exit Session'),
                  ),
                ),

                const SizedBox(height: 30),
                Text( //status text
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