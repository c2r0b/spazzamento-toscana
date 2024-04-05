import '../models/schedule_info/schedule_info.dart';
import 'package:flutter/material.dart';

class ScheduleMonthDayWidget extends StatelessWidget {
  final ScheduleInfo schedule;

  const ScheduleMonthDayWidget({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    if (schedule.dayEven == true) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: 'Giorni ',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            TextSpan(
              text: 'PARI',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else if (schedule.dayOdd == true) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: 'Giorni ',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            TextSpan(
              text: 'DISPARI',
              style: TextStyle(
                  color: Theme.of(context).colorScheme.secondary,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else if (schedule.monthWeek.isNotEmpty) {
      List<InlineSpan> children = [];

      for (int i = 0; i < schedule.monthWeek.length; i++) {
        children.add(
          TextSpan(
            text: '${schedule.monthWeek[i]}°',
            style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold),
          ),
        );

        // Add " e " if it's not the last item
        if (i < schedule.monthWeek.length - 1) {
          children.add(const TextSpan(
              text: ' e ', style: TextStyle(color: Colors.black)));
        }
      }

      children.add(TextSpan(
          text: ' del mese',
          style: TextStyle(color: Theme.of(context).colorScheme.primary)));

      return RichText(text: TextSpan(children: children));
    }

    return const SizedBox.shrink();
  }
}
