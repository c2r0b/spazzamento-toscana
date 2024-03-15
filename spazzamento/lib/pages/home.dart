import 'dart:async';

import '../models/schedule_info.dart';
import '../models/state_update.dart';
import '../widgets/app_bar.dart';
import '../widgets/drawer.dart';
import '../widgets/map.dart';
import '../widgets/search_bar.dart';
import '../widgets/draggable_bottom.dart';
import '../services/location.dart';
import '../services/schedule.dart';
import '../services/notification.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

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

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    NotificationController.requesPermission()!.then((value) async {
      _centerOnUserLocation();
    });
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
      setState(() {
        isLoading = true;
      });

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

  void _refreshHomeScreen() {}

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
                  child: DraggableBottomWidget(
                      currentAddress: _currentAddress,
                      selectedSchedule: selectedSchedule,
                      locationPermissionEnabled: locationPermissionEnabled,
                      locationServiceEnabled: locationServiceEnabled,
                      enableLocationService: _enableLocationService,
                      isLoading: isLoading)),
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
