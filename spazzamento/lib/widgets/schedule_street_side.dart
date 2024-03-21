import 'package:Spazzamento/models/schedule_info.dart';
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
        'color': const Color.fromRGBO(1, 91, 147, 1)
      },
      {
        'condition': schedule.numberOdd,
        'text': 'Civici',
        'value': 'DISPARI',
        'color': const Color.fromRGBO(0, 128, 207, 1)
      },
      {
        'condition': schedule.rightSide,
        'text': 'Lato',
        'value': 'DESTRO',
        'color': const Color.fromRGBO(1, 91, 147, 1)
      },
      {
        'condition': schedule.leftSide,
        'text': 'Lato',
        'value': 'SINISTRO',
        'color': const Color.fromRGBO(0, 128, 207, 1)
      },
      {
        'condition': schedule.internalSide,
        'text': 'Lato',
        'value': 'INTERNO',
        'color': const Color.fromRGBO(1, 91, 147, 1)
      },
      {
        'condition': schedule.externalSide,
        'text': 'Lato',
        'value': 'ESTERNO',
        'color': const Color.fromRGBO(0, 128, 207, 1)
      },
    ];

    // Find the first condition that's true and get the corresponding text and color
    var result = conditions.firstWhere((map) => map['condition'] == true,
        orElse: () => {'text': null, 'value': null, 'color': Colors.black});

    // Explicitly cast 'text' and 'color' to their respective types
    String? text = result['text'] as String?;
    String? value = result['value'] as String?;
    Color? color = result['color'] as Color?;

    if (text != null && value != null) {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: '$text ', style: const TextStyle(color: Colors.black)),
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
