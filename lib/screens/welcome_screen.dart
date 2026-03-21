import 'package:flutter/material.dart';

class WelcomeScreen extends StatelessWidget { //created WelcomeScreen class
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold( //main structure
      appBar: AppBar( 
        title: const Text('Adaptive Focus Studio'),
        centerTitle: true, //top bar of screen (still needs more)
      ),
      body: SafeArea( //keeps content away from certain areas, prevents content being hidden
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500), //limits the width on content
            child: SingleChildScrollView( //if content doesn't fit you can scroll
              padding: const EdgeInsets.symmetric( // adds space sround content
                horizontal: 24.0,
                vertical: 24.0,
              ),
              child: TweenAnimationBuilder<double>( //smooth entrance animation when screen appears
                duration: const Duration(milliseconds: 700), 
                tween: Tween<double>(begin: 0.95, end: 1.0),
                curve: Curves.easeOut, //makes motion start fast and slow down at the end
                builder: (context, animationValue, child) { 
                  return Transform.scale( //zoom
                    scale: animationValue,
                    child: Opacity(
                      opacity: animationValue.clamp(0.0, 1.0),
                      child: child,
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [ //keeping order of widgets
                    _buildHeroIcon(),
                    const SizedBox(height: 24),
                    _buildTitle(),
                    const SizedBox(height: 12),
                    _buildSubtitle(),
                    const SizedBox(height: 28),
                    _buildFeatureCard(),
                    const SizedBox(height: 28),
                    _buildStartButton(context),
                    const SizedBox(height: 12),
                    _buildSecondaryInfo(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroIcon() { //main icon widget
    return Semantics(
      label: 'App focus icon',
      child: CircleAvatar(
        radius: 55,
        child: Icon(
          Icons.graphic_eq_rounded,
          size: 58,
        ),
      ),
    );
  }

  Widget _buildTitle() { //main title widget
    return const Text(
      'Adaptive Focus Studio & Mood Soundscapes',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        height: 1.2,
      ),
    );
  }

  Widget _buildSubtitle() { //description widget
    return Text(
      'Build personalized deep-work sessions using mood, task type, '
      'energy level, and adaptive soundscapes.',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 16,
        height: 1.5,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildFeatureCard() { //material card widget
    return Card(
      elevation: 1.5,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: const [
            _FeatureRow(
              icon: Icons.tune_rounded,
              text: 'Generate soundscapes by mood and task type',
            ),
            SizedBox(height: 12),
            _FeatureRow(
              icon: Icons.timer_outlined,
              text: 'Run Pomodoro-style focus sessions with breaks',
            ),
            SizedBox(height: 12),
            _FeatureRow(
              icon: Icons.analytics_outlined,
              text: 'Track focus quality and productivity trends',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton(BuildContext context) { //main action button widget
    return Semantics(
      button: true,
      label: 'Start using Adaptive Focus Studio',
      child: SizedBox(
        height: 54,
        child: ElevatedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Starting', //still editing
                ),
              ),
            );
          },
          icon: const Icon(Icons.play_arrow_rounded),
          label: const Text(
            'Start Session Setup', //edit
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryInfo() {
    return Text(
      '.', //still editing
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 13,
        color: Colors.grey.shade600,
      ),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _FeatureRow({
    required this.icon,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
      ],
    );
  }
}