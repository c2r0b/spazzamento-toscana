import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:string_similarity/string_similarity.dart';
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

class StreetData {
  final String street;
  final List<ScheduleInfo> schedule;

  StreetData({required this.street, required this.schedule});

  factory StreetData.fromJson(Map<String, dynamic> json) {
    List<ScheduleInfo> scheduleList = [];
    if (json['schedule'] != null && json['schedule'] is List) {
      scheduleList = (json['schedule'] as List)
          .map((i) => ScheduleInfo.fromJson(i as Map<String, dynamic>))
          .toList();
    }

    return StreetData(
      street: json['street'] as String,
      schedule: scheduleList,
    );
  }
}

class CityData {
  final String city;
  final List<StreetData> data;

  CityData({required this.city, required this.data});

  factory CityData.fromJson(Map<String, dynamic> json) {
    var list = (json['data'] is List) ? json['data'] as List : [];
    List<StreetData> dataList = list
        .map((i) => StreetData.fromJson(i as Map<String, dynamic>))
        .toList();

    return CityData(
      city: json['city'],
      data: dataList,
    );
  }
}

void main() {
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
  late List<CityData>? cityDataList;
  List<ScheduleInfo>? selectedSchedule = [];

  @override
  void initState() {
    super.initState();
    fetchDataFromAPI();
    mapController = MapController();
    _determinePosition().then((position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        mapController.move(_currentPosition, mapController.camera.zoom);
      });
      _lookupAddress(_currentPosition); // Function to lookup the address
    });
  }

  Future<void> fetchDataFromAPI() async {
    const String apiUrl =
        'https://api.jsonsilo.com/215204ad-13b3-4578-81e5-723026e32152'; // Replace with your actual API URL
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: {
        'X-SILO-KEY': 'yHwQ3dFyBP9LsJcXhCUDPn89FBVcqpHuFTUxOcexKj',
        'Content-Type': 'application/json'
      });
      if (response.statusCode == 200) {
        final jsonResult = json.decode(response.body);
        if (jsonResult.containsKey('data') && jsonResult['data'] is List) {
          List<dynamic> dataList = List.from(jsonResult['data']);
          setState(() {
            cityDataList = dataList
                .map((i) => CityData.fromJson(i as Map<String, dynamic>))
                .toList();
          });
        } else {
          // Handle the case where 'data' is not a list or is null
          print('The "data" key is not a list or is null');
        }
      } else {
        // Handle the case when the server returns a non-200 status code
        print('Failed to load data from API');
      }
    } catch (e) {
      // Handle any errors that occur during the HTTP request
      print('Error occurred while fetching data: $e');
    }
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
      selectedSchedule = findSchedule(selectedCity, selectedStreet);
    });
  }

  List<ScheduleInfo>? findSchedule(String city, String streetQuery) {
    if (cityDataList == null) {
      return null;
    }
    CityData? matchedCity = cityDataList!.firstWhere(
      (c) => c.city.toLowerCase() == city.toLowerCase(),
      orElse: () => CityData(city: '', data: []),
    );

    if (matchedCity.city.isEmpty) {
      return null;
    }

    // Iterate over the streets in the matched city data.
    StreetData? closestMatch;
    int closestMatchScore = streetQuery
        .length; // Use length of query as initial score, lower is better.

    for (var streetData in matchedCity.data) {
      // Calculate the similarity score between the query and the street name.
      var score = _calculateSimilarity(streetQuery, streetData.street);

      // If this street has a better score (lower), then it's a closer match.
      if (score < closestMatchScore) {
        closestMatch = streetData;
        closestMatchScore = score;
      }
    }

    if (closestMatch == null) {
      return null;
    }

    return closestMatch.schedule;
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
    );
  }
}
