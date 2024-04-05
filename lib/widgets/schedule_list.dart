import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import '../models/schedule_info/schedule_info.dart';
import '../widgets/schedule_item.dart';

class ScheduleListWidget extends StatelessWidget {
  final String currentAddress;
  final List<ScheduleInfo>? selectedSchedule;
  final bool locationPermissionEnabled;
  final bool locationServiceEnabled;
  final void Function()? enableLocationService;

  const ScheduleListWidget(
      {super.key,
      required this.currentAddress,
      required this.selectedSchedule,
      required this.locationPermissionEnabled,
      required this.locationServiceEnabled,
      required this.enableLocationService});

  @override
  Widget build(BuildContext context) {
    if (selectedSchedule == []) {
      return const Center(child: CircularProgressIndicator());
    }

    if (selectedSchedule == null) {
      return ListTile(
        title: Text(AppLocalizations.of(context)!.noDataFound),
        leading: const Icon(Icons.error),
      );
    }

    return Column(
      children: selectedSchedule!.map((schedule) {
        return ScheduleItemWidget(
            schedule: schedule, currentAddress: currentAddress);
      }).toList(),
    );
  }
}
