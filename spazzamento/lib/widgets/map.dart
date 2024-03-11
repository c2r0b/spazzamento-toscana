import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class MapWidget extends StatelessWidget {
  final mapController;
  final currentPosition;

  const MapWidget(
      {super.key, required this.mapController, required this.currentPosition});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(children: [
          ColorFiltered(
              colorFilter: const ColorFilter.matrix([
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0.2126,
                0.7152,
                0.0722,
                0,
                0,
                0,
                0,
                0,
                1,
                0,
              ]),
              child: FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: currentPosition,
                  initialZoom: 16.0,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    subdomains: const ['a', 'b', 'c'],
                  ),
                  MarkerLayer(
                    markers: [
                      Marker(
                        point: currentPosition,
                        width: 80,
                        height: 80,
                        child: const Icon(Icons.location_pin),
                      ),
                    ],
                  ),
                ],
              )),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: const Color.fromRGBO(
                    1, 91, 147, 0.2), // Adjust the color and opacity as needed
              ),
            ),
          ),
        ]));
  }
}
