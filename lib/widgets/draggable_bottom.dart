import 'package:flutter/material.dart';
import '../models/schedule_info.dart';
import '../widgets/schedule_list.dart';

class DraggableBottomWidget extends StatelessWidget {
  final String currentAddress;
  final List<ScheduleInfo>? selectedSchedule;
  final bool locationPermissionEnabled;
  final bool locationServiceEnabled;
  final void Function()? enableLocationService;
  final bool isLoading;

  const DraggableBottomWidget(
      {super.key,
      required this.currentAddress,
      required this.selectedSchedule,
      required this.locationPermissionEnabled,
      required this.locationServiceEnabled,
      required this.enableLocationService,
      required this.isLoading});

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize:
            0.3, // The initial height of the sheet when the app starts
        minChildSize:
            0.1, // The minimum height of the sheet when user can drag it down
        maxChildSize:
            0.8, // The maximum height of the sheet when user drags it up
        builder: (BuildContext context, ScrollController scrollController) {
          return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(18.0),
                  topRight: Radius.circular(18.0),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10.0,
                    color: Colors.black26,
                  ),
                ],
              ),
              child: ListView(controller: scrollController, children: [
                isLoading
                    ? const Center(
                        heightFactor: 5,
                        child: CircularProgressIndicator(),
                      )
                    : Column(
                        children: [
                          ListTile(
                              title: RichText(
                                  text: TextSpan(
                                text: currentAddress,
                                style: const TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold),
                              )),
                              subtitle: !locationPermissionEnabled
                                  ? ElevatedButton(
                                      onPressed: enableLocationService,
                                      child: const Text('Abilita permesso'))
                                  : (!locationServiceEnabled
                                      ? ElevatedButton(
                                          onPressed: enableLocationService,
                                          child: const Text(
                                              'Abilita localizzazione'))
                                      : null)),
                          ScheduleListWidget(
                              currentAddress: currentAddress,
                              locationPermissionEnabled:
                                  locationPermissionEnabled,
                              locationServiceEnabled: locationServiceEnabled,
                              selectedSchedule: selectedSchedule,
                              enableLocationService: enableLocationService)
                        ],
                      ),
              ]));
        });
  }
}
