import 'package:flutter/material.dart';
import '../models/schedule_info/schedule_info.dart';
import '../services/notification.dart';
import './schedule_street_side.dart';
import './schedule_month_day.dart';

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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkNotificationStatus();
  }

  void _checkNotificationStatus() async {
    bool status = await NotificationController.isActive(widget.schedule.id);
    if (mounted) {
      setState(() {
        isScheduled = status;
        isLoading = false;
      });
    }
  }

  void _onNotificationToggle(BuildContext context) {
    if (isScheduled) {
      setState(() {
        isLoading = true; // Start loading
      });
      // Cancel the notification
      NotificationController.cancel(widget.schedule.id).then((value) {
        _checkNotificationStatus();
      });
    } else {
      // Schedule the notification
      showScheduleDialog(context);
    }
  }

  void schedule(BuildContext context, int hoursToSubtract) {
    if (mounted) {
      setState(() {
        isLoading = true; // Start loading
      });
    }
    Navigator.of(context).pop(); // Close the dialog
    NotificationController.activate(
            widget.schedule, widget.currentAddress, hoursToSubtract)
        .then((value) {
      _checkNotificationStatus();
    }).catchError((e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Troppe notifiche attive'),
        ),
      );
      if (mounted) {
        setState(() {
          isLoading = false; // Stop loading
        });
      }
    });
  }

  Future<void> showScheduleDialog(BuildContext context) async {
    // Make sure the user has granted permission
    await NotificationController.requesPermission();

    // Check if the widget is still mounted after the async operation
    if (!context.mounted) return;

    // Display user options for scheduling the notification
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Avvisami'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: const Text('12 ore prima'),
              onTap: () {
                schedule(context, 12);
              },
            ),
            ListTile(
              title: const Text('1 ora prima'),
              onTap: () {
                schedule(context, 1);
              },
            ),
            ListTile(
              title: const Text('Quando inizia'),
              onTap: () async {
                schedule(context, 0);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Define the mapping and the order
    final daysOfWeek = ['L', 'M', 'M', 'G', 'V', 'S', 'D'];
    List<dynamic> activeDays = [];

    // Check if weekDay is a list or a single value and adjust accordingly
    activeDays = widget.schedule.weekDay;

    String? location = widget.schedule.location == ''
        ? 'Tutta la strada'
        : widget.schedule.location;

    return ListTile(
        title:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Flexible(
            child: Text.rich(
              TextSpan(
                text: location,
                style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 14,
                    fontWeight: FontWeight.bold),
              ),
            ),
          ),
          // notification toggle button
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: isLoading ? null : () => _onNotificationToggle(context),
            child: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  )
                : Icon(
                    isScheduled
                        ? Icons.notifications_active
                        : Icons.notifications_none,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
          )
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
                          ? Theme.of(context).colorScheme.tertiary
                          : Colors.transparent,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      daysOfWeek[index],
                      style: TextStyle(
                        color: activeDays.contains(index + 1)
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  );
                })),
                ScheduleMonthDayWidget(schedule: widget.schedule)
              ],
            ), // Add a divider between the schedules
            const SizedBox(height: 10),
            if (widget.schedule.from != null && widget.schedule.to != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('${widget.schedule.from} - ${widget.schedule.to}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      )),
                  ScheduleStreetSideWidget(schedule: widget.schedule)
                ],
              ),
            if (widget.schedule.morning == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('MATTINO',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      )),
                  ScheduleStreetSideWidget(schedule: widget.schedule)
                ],
              ),
            if (widget.schedule.afternoon == true)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('POMERIGGIO',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      )),
                  ScheduleStreetSideWidget(schedule: widget.schedule)
                ],
              ),
            if (widget.schedule.start != null && widget.schedule.end != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                      'Dal ${widget.schedule.start} - Al ${widget.schedule.end}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      )),
                  ScheduleStreetSideWidget(schedule: widget.schedule)
                ],
              ),
            const SizedBox(height: 10),
            Divider(color: Theme.of(context).dividerColor),
          ],
        ));
  }
}
