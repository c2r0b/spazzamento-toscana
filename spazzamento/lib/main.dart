import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ScheduleInfo {
  final int? weekDay;
  final dynamic monthWeek;
  final String? from;
  final String? to;
  final String? day;
  final String? time;
  final String? location;

  ScheduleInfo(
      {required this.day,
      required this.time,
      required this.location,
      this.weekDay,
      this.monthWeek,
      this.from,
      this.to});

  factory ScheduleInfo.fromJson(Map<String, dynamic> json) {
    return ScheduleInfo(
      weekDay: json['weekDay'],
      monthWeek: json['monthWeek'],
      from: json['from'],
      to: json['to'],
      day: json['day'],
      time: json['time'],
      location: json['location'],
    );
  }
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://ozdaupsjprogpcyqfuqf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im96ZGF1cHNqcHJvZ3BjeXFmdXFmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MDk2NTE3MDgsImV4cCI6MjAyNTIyNzcwOH0.tu-ZyWjIBufjQI7GMxwzrWdJxdwKe4Eh9XJWqXEZCeQ',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Spazzamento'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MapController mapController;
  late LatLng _currentPosition = const LatLng(43.5060818, 11.2259568);
  String _currentAddress = 'Searching address...'; // Initial message
  List<ScheduleInfo>? selectedSchedule = [];

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    _centerOnUserLocation();
  }

  void _centerOnUserLocation() {
    _determinePosition().then((position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        mapController.move(_currentPosition, mapController.camera.zoom);
      });
      _lookupAddress(_currentPosition); // Function to lookup the address
    });
  }

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }

  Future<List> getSuggestions(String query) async {
    final response = await http.get(Uri.parse(
        'https://photon.komoot.io/api/?q=Italia+$query&limit=5&layer=street'));

    if (response.statusCode == 200) {
      final List features = json.decode(response.body)['features'];

      // avoid ['properties']['name'] 'properties']['city'] pairs duplicates
      final seen = <String>{};
      features.removeWhere((element) => !seen.add(
          '${element['properties']['name']}-${element['properties']['city']}'));

      return features;
    } else {
      throw Exception('Failed to load suggestions');
    }
  }

  void _lookupAddress(LatLng position) async {
    // Use geocoding to find the address from the LatLng position
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    if (placemarks.isNotEmpty) {
      setState(() {
        _currentAddress =
            '${placemarks.first.name}, ${placemarks.first.locality}';
      });
      _loadSchedule(
          placemarks.first.locality ?? '', placemarks.first.name ?? '');
    }
  }

  void onSelected(Map suggestion) {
    final selectedCity = suggestion['properties']['city'];
    final selectedStreet = suggestion['properties']['name'];
    setState(() {
      _currentPosition = LatLng(suggestion['geometry']['coordinates'][1],
          suggestion['geometry']['coordinates'][0]);
      mapController.move(_currentPosition, 13.0);
      _currentAddress =
          '${suggestion['properties']['name'] ?? '-'}, ${suggestion['properties']['city'] ?? '-'}';
    });
    _loadSchedule(selectedCity, selectedStreet);
  }

  void _loadSchedule(String city, String street) async {
    // clear previous first
    setState(() {
      selectedSchedule = null;
    });
    List<ScheduleInfo>? schedules = await findSchedule(city, street);
    setState(() {
      selectedSchedule = schedules;
    });
  }

  Future<List<ScheduleInfo>?> findSchedule(
      String city, String streetQuery) async {
    try {
      city = city.toUpperCase();

      // get all streets first
      final streetData = await Supabase.instance.client
          .from('data')
          .select('street')
          .eq('city', city);

      // Iterate over the streets in the matched city data.
      String? closestMatch;
      int closestMatchScore = streetQuery
          .length; // Use length of query as initial score, lower is better.

      for (var data in streetData) {
        var streetName = data['street'];
        // Calculate the similarity score between the query and the street name.
        var score = _calculateSimilarity(streetQuery, streetName);

        // If this street has a better score (lower), then it's a closer match.
        if (score < closestMatchScore) {
          closestMatch = streetName;
          closestMatchScore = score;
        }
      }

      if (closestMatch == null) {
        // If we didn't find any matches, then we don't have a good match.
        return null;
      }

      if (closestMatchScore > 50) {
        // If the closest match score is too high, then we don't have a good match.
        return null;
      }

      // Get the schedule for the closest match.
      final scheduleData = await Supabase.instance.client
          .from('data')
          .select('schedule')
          .eq('city', city)
          .eq('street', closestMatch)
          .single()
          .limit(1);
      // Convert the schedule data to a list of ScheduleInfo objects.

      List<ScheduleInfo> schedules = [];
      for (var schedule in scheduleData['schedule']['data']) {
        ScheduleInfo scheduleInfo = ScheduleInfo.fromJson(schedule);
        schedules.add(scheduleInfo);
      }
      return schedules;
    } catch (e) {
      // Handle any other types of errors.
      print("Exception caught: $e");
      return null;
    }
  }

  int _calculateSimilarity(String query, String streetName) {
    double similarity = StringSimilarity.compareTwoStrings(
        query.toLowerCase(), streetName.toLowerCase());
    // Convert the similarity (0.0 - 1.0) to a score. Lower score means more similar.
    // Multiplying by 100 (or more) to express the similarity as an integer.
    return ((1 - similarity) * 100).round();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      drawer: Drawer(
        // Add a ListView to the drawer. This ensures the user can scroll
        // through the options in the drawer if there isn't enough vertical
        // space to fit everything.
        child: ListView(
          // Important: Remove any padding from the ListView.
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              child: Text('Spazzamento'),
            ),
            ListTile(
              title: const Text('Come funziona'),
              leading: const Icon(Icons.help_outline),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Rispetto della privacy'),
              leading: const Icon(Icons.privacy_tip_outlined),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Segnala un problema'),
              leading: const Icon(Icons.report_problem_outlined),
              onTap: () {
                // Update the state of the app
                // Then close the drawer
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: <Widget>[
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: _currentPosition,
              initialZoom: 16.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentPosition,
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.location_pin),
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 8, // This aligns the search bar below the status bar
            left: 8,
            right: 8,
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: TypeAheadField(
                  errorBuilder: (context, error) => const Text('Errore!'),
                  hideOnLoading: true,
                  hideOnEmpty: true,
                  builder: (context, controller, focusNode) {
                    return TextField(
                      controller: controller,
                      focusNode: focusNode,
                      autofocus: false,
                      style: DefaultTextStyle.of(context).style,
                      decoration: const InputDecoration(
                          border: InputBorder.none,
                          icon: Icon(Icons.search),
                          hintText: 'Cerca una strada...'),
                    );
                  },
                  suggestionsCallback: (pattern) async {
                    if (pattern.length < 3) {
                      return [];
                    }
                    return await getSuggestions(pattern);
                  },
                  itemBuilder: (context, suggestion) {
                    return ListTile(
                      title: Text(
                        '${suggestion['properties']['name'] ?? 'Unknown name'}, ${suggestion['properties']['city'] ?? 'Unknown city'}',
                      ),
                      subtitle: Text('${suggestion['properties']['state']}'),
                    );
                  },
                  onSelected: (suggestion) {
                    return onSelected(suggestion);
                  },
                ),
              ),
            ),
          ),
          DraggableScrollableSheet(
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
                child: ListView(
                  controller: scrollController,
                  children: <Widget>[
                    ListTile(
                      title: Text(_currentAddress),
                      leading: const Icon(Icons.location_pin),
                    ),
                    if (selectedSchedule == null)
                      const Center(child: CircularProgressIndicator())
                    else
                      ...selectedSchedule!.map((schedule) => ListTile(
                            title: Text(schedule.location ?? ''),
                            subtitle: Text('${schedule.day}, ${schedule.time}'),
                          )),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _centerOnUserLocation,
        tooltip: 'Dove mi trovo',
        child: const Icon(Icons.my_location),
      ),
    );
  }
}
