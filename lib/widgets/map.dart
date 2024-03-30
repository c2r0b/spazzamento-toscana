import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapWidget extends StatelessWidget {
  final MapController mapController;
  final LatLng? currentPosition;
  final VoidCallback onTap;

  const MapWidget(
      {super.key,
      required this.mapController,
      required this.currentPosition,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
        borderRadius: BorderRadius.circular(30),
        child: Stack(children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter: currentPosition!,
              initialZoom: 16.0,
              onTap: (_, __) => onTap(), // Unfocus when the map is tapped
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: currentPosition!,
                    width: 80,
                    height: 80,
                    child: const Icon(Icons.location_pin),
                  ),
                ],
              ),
            ],
          ),
          Positioned.fill(
            child: IgnorePointer(
              child: Container(
                color: const Color.fromRGBO(
                    1, 91, 147, 0.35), // Adjust the color and opacity as needed
              ),
            ),
          ),
        ]));
  }
}
