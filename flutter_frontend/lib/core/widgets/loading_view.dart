import 'package:flutter/material.dart';

class LoadingView extends StatelessWidget {
  final String? message;
  final Color? color;
  final double size;
  final double strokeWidth;
  final double spacing;

  const LoadingView({
    super.key,
    this.message,
    this.color,
    this.size = 48.0,
    this.strokeWidth = 4.0,
    this.spacing = 16.0,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              color ?? Theme.of(context).colorScheme.primary,
            ),
            strokeWidth: strokeWidth,
          ),
          if (message != null) ...[
            SizedBox(height: spacing),
            Text(
              message!,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
          ],
        ],
      ),
    );
  }
}