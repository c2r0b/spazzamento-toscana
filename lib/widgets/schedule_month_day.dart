import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../models/schedule_info/schedule_info.dart';

class ScheduleMonthDayWidget extends StatelessWidget {
  final ScheduleInfo schedule;

  const ScheduleMonthDayWidget({super.key, required this.schedule});

  @override
  Widget build(BuildContext context) {
    if (schedule.dayEven == true) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
                text: '${AppLocalizations.of(context)!.days} ',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            TextSpan(
              text: AppLocalizations.of(context)!.even,
              style: TextStyle(
                  color: Theme.of(context).colorScheme.tertiary,
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else if (schedule.dayOdd == true) {
      return Text.rich(
        TextSpan(
          children: [
            TextSpan(
                text: '${AppLocalizations.of(context)!.days} ',
                style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            TextSpan(
              text: AppLocalizations.of(context)!.odd,
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
          children.add(TextSpan(
              text: ' ${AppLocalizations.of(context)!.and} ',
              style: const TextStyle(color: Colors.black)));
        }
      }

      children.add(TextSpan(
          text: ' ${AppLocalizations.of(context)!.ofTheMonth}',
          style: TextStyle(color: Theme.of(context).colorScheme.primary)));

      return Text.rich(TextSpan(children: children));
    }

    return const SizedBox.shrink();
  }
}
