import 'package:flutter/material.dart';

/// Shows a small progress indicator instead of [label] while [loading].
class LoadingButtonChild extends StatelessWidget {
  const LoadingButtonChild({
    super.key,
    required this.loading,
    required this.label,
    this.color,
  });

  final bool loading;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (!loading) return Text(label);
    return SizedBox(
      height: 22,
      width: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: color ?? Theme.of(context).colorScheme.onPrimary,
      ),
    );
  }
}
