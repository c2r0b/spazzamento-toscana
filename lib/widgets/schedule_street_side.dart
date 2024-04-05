import '../models/schedule_info/schedule_info.dart';
import 'package:flutter/material.dart';

class ScheduleStreetSideWidget extends StatelessWidget {
  final ScheduleInfo schedule;

  const ScheduleStreetSideWidget({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    // Define the conditions, text, and colors
    var conditions = [
      {
        'condition': schedule.numberEven,
        'text': 'Civici',
        'value': 'PARI',
        'color': Theme.of(context).colorScheme.tertiary
      },
      {
        'condition': schedule.numberOdd,
        'text': 'Civici',
        'value': 'DISPARI',
        'color': Theme.of(context).colorScheme.secondary
      },
      {
        'condition': schedule.rightSide,
        'text': 'Lato',
        'value': 'DESTRO',
        'color': Theme.of(context).colorScheme.tertiary
      },
      {
        'condition': schedule.leftSide,
        'text': 'Lato',
        'value': 'SINISTRO',
        'color': Theme.of(context).colorScheme.secondary
      },
      {
        'condition': schedule.internalSide,
        'text': 'Lato',
        'value': 'INTERNO',
        'color': Theme.of(context).colorScheme.tertiary
      },
      {
        'condition': schedule.externalSide,
        'text': 'Lato',
        'value': 'ESTERNO',
        'color': Theme.of(context).colorScheme.secondary
      },
    ];

    // Find the first condition that's true and get the corresponding text and color
    var result = conditions.firstWhere((map) => map['condition'] == true,
        orElse: () => {
              'text': null,
              'value': null,
              'color': Theme.of(context).colorScheme.primary
            });

    // Explicitly cast 'text' and 'color' to their respective types
    String? text = result['text'] as String?;
    String? value = result['value'] as String?;
    Color? color = result['color'] as Color?;

    if (text != null && value != null) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: '$text ',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            TextSpan(
              text: value,
              style: TextStyle(color: color!, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }
}
