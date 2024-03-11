import '../models/state_update.dart';
import '../models/address.dart';

import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';

Future<StateUpdate> determinePosition() async {
  bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) {
    return StateUpdate(
      isLoading: false,
      locationServiceEnabled: false,
      locationPermissionEnabled: true,
      currentAddress: 'Localizzazione disabilitata',
    );
  }

  LocationPermission permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) {
      return StateUpdate(
        isLoading: false,
        locationServiceEnabled: false,
        locationPermissionEnabled: false,
        currentAddress: 'Localizzazione disabilitata',
      );
    }
  }

  if (permission == LocationPermission.deniedForever) {
    return StateUpdate(
      isLoading: false,
      locationServiceEnabled: false,
      locationPermissionEnabled: false,
      currentAddress: 'Servizi di localizzazione disabilitati',
    );
  }

  Position pos = await Geolocator.getCurrentPosition();
  return StateUpdate(
      isLoading: false,
      locationServiceEnabled: true,
      locationPermissionEnabled: true,
      currentAddress: 'Servizi di localizzazione disabilitati',
      currentPosition: LatLng(pos.latitude, pos.longitude));
}

Future<StateUpdate> getUserLocation() async {
  StateUpdate stateUpdate = await determinePosition();

  if (stateUpdate.currentPosition == null) {
    return stateUpdate;
  }

  List<Placemark> placemarks =
      await lookupAddress(stateUpdate.currentPosition!);

  if (placemarks.isNotEmpty) {
    stateUpdate.address = Address.fromPlacemark(placemarks.first);
    stateUpdate.currentAddress =
        '${placemarks.first.street}, ${placemarks.first.locality}';
  } else {
    stateUpdate.currentAddress = 'Indirizzo non trovato';
  }
  return stateUpdate;
}

Future<List<Placemark>> lookupAddress(LatLng position) async {
  // Use geocoding to find the address from the LatLng position
  List<Placemark> placemarks = await placemarkFromCoordinates(
      position.latitude, position.longitude,
      localeIdentifier: 'it_IT');
  if (placemarks.isNotEmpty) {
    return placemarks;
  } else {
    return Future.error('Indirizzo non trovato');
  }
}
