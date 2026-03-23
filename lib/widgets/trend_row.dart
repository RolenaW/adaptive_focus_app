import 'package:flutter/material.dart';

class TrendRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const TrendRow({
    super.key,
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
        Expanded(child: Text(text)),
      ],
    );
  }
}