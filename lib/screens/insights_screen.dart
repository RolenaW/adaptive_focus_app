import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../widgets/insight_card.dart';
import '../widgets/trend_row.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  bool _isLoading = true;
  int _totalSessions = 0;
  int _completedSessions = 0;
  int _totalDeepWorkMinutes = 0;
  double _averageWorkDuration = 0;

  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async {
    try {
      final sessions =
          await DatabaseHelper.instance.getAllFocusSessions();

      int completedSessions = 0;
      int totalMinutes = 0;

      for (final session in sessions) {
        final int work = session['work_duration_minutes'] ?? 0;
        final int completed = session['completed'] ?? 0;

        totalMinutes += work;
        if (completed == 1) completedSessions++;
      }

      final double avg = sessions.isEmpty ? 0.0 : totalMinutes / sessions.length;

      if (!mounted) return;

      setState(() {
        _sessions = sessions;
        _totalSessions = sessions.length;
        _completedSessions = completedSessions;
        _totalDeepWorkMinutes = totalMinutes;
        _averageWorkDuration = avg;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Insights & Tracker',
              style: Theme.of(context).textTheme.headlineMedium,
            ),

            const SizedBox(height: 20),

            InsightCard(
              title: 'Total Sessions',
              value: _totalSessions.toString(),
              subtitle: 'Saved sessions',
              icon: Icons.check_circle_outline,
            ),

            const SizedBox(height: 16),

            InsightCard(
              title: 'Completed Sessions',
              value: _completedSessions.toString(),
              subtitle: 'Finished sessions',
              icon: Icons.star_outline,
            ),

            const SizedBox(height: 16),

            InsightCard(
              title: 'Total Focus Time',
              value: '$_totalDeepWorkMinutes min',
              subtitle: 'Total work duration',
              icon: Icons.timer,
            ),
          ],
        ),
      ),
    );
  }
}