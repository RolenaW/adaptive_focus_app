import 'package:flutter/material.dart';
import '../data/database_helper.dart';
class InsightsScreen extends StatefulWidget { //InsightsScreen class created. Was stateless but changed to stateful
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

  @override //loading data
  void initState() {
    super.initState();
    _loadInsights();
  }

  Future<void> _loadInsights() async { //main SQLite method
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

      final double averageWorkDuration = sessions.isEmpty
          ? 0
          : totalDeepWorkMinutes / sessions.length;

      if (!mounted) return;

      setState(() {
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
          content: Text('Failed to load insights: $error'),
        ),
      );
    }
  }

  String _formatMinutes(int totalMinutes) { //turns raw minutes into text
    final int hours = totalMinutes ~/ 60;
    final int minutes = totalMinutes % 60;

    if (hours == 0) {
      return '${minutes}m';
    }

    return '${hours}h ${minutes}m';
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) { //gices user a loading indicator 
      return const SafeArea(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return SafeArea(
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 700), //limit
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text( //title
                  'Insights & Tracker', 
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Text( //description
                  'Review your focus performance, productivity trends, and session habits.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                const SizedBox(height: 24),
                _InsightCard( //custom widget/reusbale widget for layout
                  title: 'Total Sessions',
                  value: _totalSessions.toString(),
                  subtitle: 'Saved focus sessions in the database',
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(height: 16),
                _InsightCard(
                  title: 'Average Focus Rating',
                  value: _completedSessions.toString(),
                  subtitle: 'Sessions marked as completed',
                  icon: Icons.star_outline,
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
                  title: 'Distractions Logged',
                  value: '${_averageWorkDuration.toStringAsFixed(1)} min',
                  subtitle: 'Average work duration per saved session',
                  icon: Icons.notification_important_outlined,
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          'Recent Trend Notes',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        const _TrendRow(
                          icon: Icons.trending_up,
                          text: 'Your highest focus sessions happen during morning study blocks.',
                        ),
                        const SizedBox(height: 10),
                        const _TrendRow(
                          icon: Icons.graphic_eq_outlined,
                          text: 'Rain and white noise presets appear most often in productive sessions.',
                        ),
                        const SizedBox(height: 10),
                        const _TrendRow(
                          icon: Icons.self_improvement_outlined,
                          text: 'Shorter breaks may be improving session consistency.',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),
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
class _InsightCard extends StatelessWidget { //reusable widget. takes 4 inputs
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

class _TrendRow extends StatelessWidget { //another reusable widget. take 2 inouts
  final IconData icon;
  final String text;

  const _TrendRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text),
        ),
      ],
    );
  }
}