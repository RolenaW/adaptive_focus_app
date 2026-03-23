import 'package:flutter/material.dart';

class InsightsScreen extends StatelessWidget { //InsightsScreen class created. 
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  value: 'placeholder', //edit v(below)
                  subtitle: 'Focus sessions completed this week',
                  icon: Icons.check_circle_outline,
                ),
                const SizedBox(height: 16),
                _InsightCard(
                  title: 'Average Focus Rating',
                  value: 'placeholder',
                  subtitle: 'Based on recent completed sessions',
                  icon: Icons.star_outline,
                ),
                const SizedBox(height: 16),
                _InsightCard(
                  title: 'Total Deep Work Time',
                  value: 'placeholder',
                  subtitle: 'Accumulated focus time this week',
                  icon: Icons.timer_outlined,
                ),
                const SizedBox(height: 16),
                _InsightCard(
                  title: 'Distractions Logged',
                  value: 'placeholder',
                  subtitle: 'Interruptions recorded across sessions',
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
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Real analytics will be connected after SQLite data is added.',
                          ),
                        ),
                      );
                    },
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