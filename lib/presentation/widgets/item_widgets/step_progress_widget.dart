import 'package:flutter/material.dart';

class StepProgressWidget extends StatelessWidget {
  final String title;
  final int currentStep;
  final int totalSteps;

  const StepProgressWidget({
    super.key,
    required this.title,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final double progress = totalSteps > 0 ? currentStep / totalSteps : 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Title: $title',
        //   style: Theme.of(
        //     context,
        //   ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        // ),
        // const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Progress: $currentStep/$totalSteps',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            Text(
              '${(progress * 100).toStringAsFixed(0)}%',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.green[700]),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: Colors.green[100],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green[600]!),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
