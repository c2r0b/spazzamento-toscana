import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../models/schedule_info/schedule_info.dart';

class ScheduleStreetSideWidget extends StatelessWidget {
  final ScheduleInfo schedule;

  const ScheduleStreetSideWidget({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    // Define the conditions, text, and colors
    var conditions = [
      {
        'condition': schedule.numberEven,
        'text': AppLocalizations.of(context)!.civics,
        'value': AppLocalizations.of(context)!.even,
        'color': Theme.of(context).colorScheme.tertiary
      },
      {
        'condition': schedule.numberOdd,
        'text': AppLocalizations.of(context)!.civics,
        'value': AppLocalizations.of(context)!.odd,
        'color': Theme.of(context).colorScheme.secondary
      },
      {
        'condition': schedule.rightSide,
        'text': AppLocalizations.of(context)!.side,
        'value': AppLocalizations.of(context)!.right,
        'color': Theme.of(context).colorScheme.tertiary
      },
      {
        'condition': schedule.leftSide,
        'text': AppLocalizations.of(context)!.side,
        'value': AppLocalizations.of(context)!.left,
        'color': Theme.of(context).colorScheme.secondary
      },
      {
        'condition': schedule.internalSide,
        'text': AppLocalizations.of(context)!.side,
        'value': AppLocalizations.of(context)!.internal,
        'color': Theme.of(context).colorScheme.tertiary
      },
      {
        'condition': schedule.externalSide,
        'text': AppLocalizations.of(context)!.side,
        'value': AppLocalizations.of(context)!.external,
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
      return Text.rich(
        TextSpan(
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
