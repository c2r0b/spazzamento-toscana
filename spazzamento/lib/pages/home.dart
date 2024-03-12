import '../models/schedule_info.dart';
import '../models/state_update.dart';
import '../widgets/app_bar.dart';
import '../widgets/drawer.dart';
import '../widgets/map.dart';
import '../widgets/search_bar.dart';
import '../services/location.dart';
import '../services/schedule.dart';
import '../services/notification.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late MapController mapController;
  late LatLng? _currentPosition = const LatLng(43.5060818, 11.2259568);
  String _currentAddress = 'Caricamento...';
  List<ScheduleInfo>? selectedSchedule = [];
  final TextEditingController _typeAheadController = TextEditingController();
  bool locationServiceEnabled = true;
  bool locationPermissionEnabled = true;
  bool isLoading = false;
  double fabHeight = 220;
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _requestNotificationPermission();
  }

  void _requestNotificationPermission() async {
    flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission()
        .then((value) => {_centerOnUserLocation()});
  }

  void _centerOnUserLocation() async {
    setState(() {
      isLoading = true;
      _currentPosition = const LatLng(0, 0);
    });
    StateUpdate stateUpdate = await getUserLocation();
    setState(() {
      _currentAddress = stateUpdate.currentAddress;
      locationServiceEnabled = stateUpdate.locationServiceEnabled;
      locationPermissionEnabled = stateUpdate.locationPermissionEnabled;
      isLoading = stateUpdate.isLoading;

      if (stateUpdate.currentPosition != null) {
        _currentPosition = stateUpdate.currentPosition!;
        mapController.move(_currentPosition!, mapController.camera.zoom);
      }
    });
    if (stateUpdate.address == null) {
      return;
    }
    _loadSchedule(stateUpdate.address!.city, stateUpdate.address!.county,
        stateUpdate.address!.street);
  }

  void onSelected(Map suggestion) {
    final selectedCity = suggestion['properties']['city'];
    final selectedCounty = suggestion['properties']['county'];
    final selectedStreet = suggestion['properties']['name'];
    setState(() {
      isLoading = true;
      _currentPosition = LatLng(suggestion['geometry']['coordinates'][1],
          suggestion['geometry']['coordinates'][0]);
      mapController.move(_currentPosition!, mapController.camera.zoom);
      _currentAddress =
          '${suggestion['properties']['name'] ?? '-'}, ${suggestion['properties']['county'] ?? '-'}';
    });
    _loadSchedule(selectedCity, selectedCounty, selectedStreet);

    // Close the keyboard
    FocusScope.of(context).unfocus();

    // Clear the search bar
    _typeAheadController.clear();
  }

  void _loadSchedule(String city, String county, String street) async {
    // clear previous first
    setState(() {
      selectedSchedule = [];
    });
    List<ScheduleInfo>? schedules = await findSchedule(city, county, street);
    setState(() {
      selectedSchedule = schedules;
      isLoading = false;
    });
  }

  void _enableLocationService() async {
    if (!locationServiceEnabled) {
      await Geolocator.openLocationSettings();

      // retry every 5 seconds until location service is enabled
      Future.doWhile(() async {
        await Future.delayed(const Duration(seconds: 5));
        _centerOnUserLocation();
        return !locationServiceEnabled;
      });
    }

    if (!locationPermissionEnabled) {
      await Geolocator.requestPermission();
      _centerOnUserLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBarWidget(title: widget.title),
      drawer: const DrawerWidget(),
      body: Stack(
        children: <Widget>[
          MapWidget(
              mapController: mapController, currentPosition: _currentPosition),
          SearchBarWidget(
              typeAheadController: _typeAheadController,
              onSelected: onSelected),
          Stack(
            alignment:
                Alignment.bottomCenter, // Align the FAB at the bottom center
            children: <Widget>[
              NotificationListener<DraggableScrollableNotification>(
                onNotification: (notification) {
                  setState(() {
                    // Adjust the FAB position based on the sheet's extent
                    // You can fine-tune the calculation below to get the desired effect
                    final screenHeight = MediaQuery.of(context).size.height;
                    final sheetHeight = screenHeight * notification.extent;

                    // Calculate the FAB height to be just above the sheet
                    fabHeight = sheetHeight * 0.9;
                  });
                  return true;
                },
                child: DraggableScrollableSheet(
                  initialChildSize:
                      0.3, // The initial height of the sheet when the app starts
                  minChildSize:
                      0.1, // The minimum height of the sheet when user can drag it down
                  maxChildSize:
                      0.8, // The maximum height of the sheet when user drags it up
                  builder: (BuildContext context,
                      ScrollController scrollController) {
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
                      child: ListView(
                        controller: scrollController,
                        children: isLoading
                            ? [
                                const Center(
                                  heightFactor: 5,
                                  child: CircularProgressIndicator(),
                                )
                              ]
                            : <Widget>[
                                ListTile(
                                    title: RichText(
                                        text: TextSpan(
                                      text: _currentAddress,
                                      style: const TextStyle(
                                          color: Colors.black,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    )),
                                    subtitle: !locationPermissionEnabled
                                        ? ElevatedButton(
                                            onPressed: _enableLocationService,
                                            child:
                                                const Text('Abilita permesso'))
                                        : (!locationServiceEnabled
                                            ? ElevatedButton(
                                                onPressed:
                                                    _enableLocationService,
                                                child: const Text(
                                                    'Abilita localizzazione'))
                                            : null)),
                                if (selectedSchedule == [])
                                  const Center(
                                      child: CircularProgressIndicator())
                                else if (selectedSchedule == null)
                                  const ListTile(
                                    title: Text('Nessun dato trovato'),
                                    leading: Icon(Icons.error),
                                  )
                                else
                                  ...selectedSchedule!.map((schedule) {
                                    // Define the mapping and the order
                                    final daysOfWeek = [
                                      'L',
                                      'M',
                                      'M',
                                      'G',
                                      'V',
                                      'S',
                                      'D'
                                    ];
                                    List<dynamic> activeDays = [];

                                    // Check if weekDay is a list or a single value and adjust accordingly
                                    if (schedule.weekDay != null) {
                                      activeDays = schedule.weekDay!;
                                    }

                                    Widget daysEvenOddWidget = const SizedBox
                                        .shrink(); // Empty widget by default
                                    if (schedule.dayEven == true) {
                                      daysEvenOddWidget = RichText(
                                        text: const TextSpan(
                                          children: [
                                            TextSpan(
                                                text: 'Giorni ',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            TextSpan(
                                              text: 'PARI',
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      1, 91, 147, 1),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (schedule.dayOdd == true) {
                                      daysEvenOddWidget = RichText(
                                        text: const TextSpan(
                                          children: [
                                            TextSpan(
                                                text: 'Giorni ',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            TextSpan(
                                              text: 'DISPARI',
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      0, 128, 207, 1),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (schedule.monthWeek != null) {
                                      daysEvenOddWidget = RichText(
                                        text: TextSpan(
                                          children: [
                                            ...List<TextSpan>.generate(
                                                schedule.monthWeek!.length,
                                                (index) {
                                              return TextSpan(
                                                text:
                                                    '${schedule.monthWeek![index]}°',
                                                style: const TextStyle(
                                                    color: Colors.blue,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              );
                                            }),
                                            const TextSpan(
                                                text: ' del mese',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                          ],
                                        ),
                                      );
                                    }

                                    Widget numbersEvenOddWidget = const SizedBox
                                        .shrink(); // Empty widget by default
                                    if (schedule.numberEven == true) {
                                      numbersEvenOddWidget = RichText(
                                        text: const TextSpan(
                                          children: [
                                            TextSpan(
                                                text: 'Civici ',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            TextSpan(
                                              text: 'PARI',
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      1, 91, 147, 1),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      );
                                    } else if (schedule.numberOdd == true) {
                                      numbersEvenOddWidget = RichText(
                                        text: const TextSpan(
                                          children: [
                                            TextSpan(
                                                text: 'Civici ',
                                                style: TextStyle(
                                                    color: Colors.black)),
                                            TextSpan(
                                              text: 'DISPARI',
                                              style: TextStyle(
                                                  color: Color.fromRGBO(
                                                      0, 128, 207, 1),
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ],
                                        ),
                                      );
                                    }

                                    return ListTile(
                                      title: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            RichText(
                                              text: TextSpan(
                                                text: schedule.location == ''
                                                    ? 'Tutta la strada'
                                                    : schedule.location,
                                                style: const TextStyle(
                                                    color: Colors.black,
                                                    fontSize: 14,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ),
                                            // notification toggle button
                                            const SizedBox(width: 10),
                                            ElevatedButton(
                                              onPressed: () {
                                                scheduleNotification(
                                                    schedule,
                                                    context,
                                                    flutterLocalNotificationsPlugin);
                                              },
                                              child: const Icon(
                                                Icons.notifications,
                                                color: Color.fromRGBO(
                                                    1, 91, 147, 1),
                                              ),
                                            ),
                                          ]),
                                      subtitle: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          const SizedBox(height: 10),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                  children:
                                                      List<Widget>.generate(
                                                          daysOfWeek.length,
                                                          (index) {
                                                return Container(
                                                  margin: const EdgeInsets.only(
                                                      right:
                                                          4), // Add space between day indicators
                                                  width: 24,
                                                  height: 24,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: activeDays
                                                            .contains(index + 1)
                                                        ? const Color.fromRGBO(
                                                            1, 91, 147, 1)
                                                        : Colors.transparent,
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: Text(
                                                    daysOfWeek[index],
                                                    style: TextStyle(
                                                      color:
                                                          activeDays.contains(
                                                                  index + 1)
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
                                          if (schedule.from != null &&
                                              schedule.to != null)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    '${schedule.from} - ${schedule.to}'),
                                                numbersEvenOddWidget
                                              ],
                                            ),
                                          if (schedule.start != null &&
                                              schedule.end != null)
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                    'Dal ${schedule.start} - Al ${schedule.end}'),
                                                numbersEvenOddWidget
                                              ],
                                            ),
                                          const SizedBox(height: 10),
                                          Divider(
                                              color: Theme.of(context)
                                                  .dividerColor),
                                        ],
                                      ),
                                    );
                                  }),
                              ],
                      ),
                    );
                  },
                ),
              ),
              Positioned(
                bottom: fabHeight +
                    10, // Use the dynamic height based on sheet position
                right: 16, // Standard right padding for the FAB
                child: FloatingActionButton(
                  onPressed: _centerOnUserLocation,
                  tooltip: 'Dove mi trovo',
                  backgroundColor: const Color.fromRGBO(0, 41, 67, 1.0),
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
