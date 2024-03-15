import 'package:flutter/material.dart';
import '../models/schedule_info.dart';
import '../services/notification.dart';

class ScheduleItemWidget extends StatefulWidget {
  final ScheduleInfo schedule;
  final String currentAddress;

  const ScheduleItemWidget(
      {super.key, required this.schedule, required this.currentAddress});

  @override
  State<ScheduleItemWidget> createState() => _ScheduleItemWidgetState();
}

class _ScheduleItemWidgetState extends State<ScheduleItemWidget> {
  late bool isScheduled = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  void _checkNotificationStatus() async {
    bool status = await NotificationController.isActive(widget.schedule.id);
    setState(() {
      isScheduled = status;
    });
  }

  void _onNotificationToggle(BuildContext context) async {
    if (isScheduled) {
      // Cancel the notification
      NotificationController.cancel(widget.schedule.id)
          .then((value) => {_checkNotificationStatus()});
    } else {
      // Schedule the notification
      await NotificationController.schedule(widget.schedule,
          widget.currentAddress, context, _checkNotificationStatus);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Define the mapping and the order
    final daysOfWeek = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];
    List<dynamic> activeDays = [];

    // Check if weekDay is a list or a single value and adjust accordingly
    if (widget.schedule.weekDay != null) {
      activeDays = widget.schedule.weekDay!;
    }

    Widget daysEvenOddWidget =
        const SizedBox.shrink(); // Empty widget by default
    if (widget.schedule.dayEven == true) {
      daysEvenOddWidget = RichText(
        text: const TextSpan(
          children: [
            TextSpan(text: 'Giorni ', style: TextStyle(color: Colors.black)),
            TextSpan(
              text: 'PARI',
              style: TextStyle(
                  color: Color.fromRGBO(1, 91, 147, 1),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else if (widget.schedule.dayOdd == true) {
      daysEvenOddWidget = RichText(
        text: const TextSpan(
          children: [
            TextSpan(text: 'Giorni ', style: TextStyle(color: Colors.black)),
            TextSpan(
              text: 'DISPARI',
              style: TextStyle(
                  color: Color.fromRGBO(0, 128, 207, 1),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else if (widget.schedule.monthWeek != null) {
      daysEvenOddWidget = RichText(
        text: TextSpan(
          children: [
            ...List<TextSpan>.generate(widget.schedule.monthWeek!.length,
                (index) {
              return TextSpan(
                text: '${widget.schedule.monthWeek![index]}°',
                style: const TextStyle(
                    color: Colors.blue, fontWeight: FontWeight.bold),
              );
            }),
            const TextSpan(
                text: ' del mese', style: TextStyle(color: Colors.black)),
          ],
        ),
      );
    }

    Widget numbersEvenOddWidget =
        const SizedBox.shrink(); // Empty widget by default
    if (widget.schedule.numberEven == true) {
      numbersEvenOddWidget = RichText(
        text: const TextSpan(
          children: [
            TextSpan(text: 'Civici ', style: TextStyle(color: Colors.black)),
            TextSpan(
              text: 'PARI',
              style: TextStyle(
                  color: Color.fromRGBO(1, 91, 147, 1),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    } else if (widget.schedule.numberOdd == true) {
      numbersEvenOddWidget = RichText(
        text: const TextSpan(
          children: [
            TextSpan(text: 'Civici ', style: TextStyle(color: Colors.black)),
            TextSpan(
              text: 'DISPARI',
              style: TextStyle(
                  color: Color.fromRGBO(0, 128, 207, 1),
                  fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }

    return ListTile(
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
            child: RichText(
              text: TextSpan(
                text: widget.schedule.location == ''
                    ? 'Tutta la strada'
                    : widget.schedule.location,
                style: const TextStyle(
                    color: Colors.black,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // notification toggle button
          const SizedBox(width: 10),
          ElevatedButton(
              onPressed: () {
                _onNotificationToggle(context);
              },
              child: isScheduled
                  ? const Icon(
                      Icons.notifications_active,
                      color: Color.fromRGBO(1, 91, 147, 1),
                    )
                  : (const Icon(
                      Icons.notifications_none,
                      color: Color.fromRGBO(1, 91, 147, 1),
                    ))),
        ]),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                    children: List<Widget>.generate(daysOfWeek.length, (index) {
                  return Container(
                    margin: const EdgeInsets.only(
                        right: 4), // Add space between day indicators
                    width: 24,
                    height: 24,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: activeDays.contains(index + 1)
                          ? const Color.fromRGBO(1, 91, 147, 1)
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      daysOfWeek[index],
                      style: TextStyle(
                        color: activeDays.contains(index + 1)
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  );
                })),
                daysEvenOddWidget,
              ],
            ), // Add a divider between the schedules
            const SizedBox(height: 10),
            if (widget.schedule.from != null && widget.schedule.to != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${widget.schedule.from} - ${widget.schedule.to}'),
                  numbersEvenOddWidget
                ],
              ),
            if (widget.schedule.start != null && widget.schedule.end != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Dal ${widget.schedule.start} - Al ${widget.schedule.end}'),
                  numbersEvenOddWidget
                ],
              ),
            const SizedBox(height: 10),
            Divider(color: Theme.of(context).dividerColor),
          ],
        ));
  }
}
