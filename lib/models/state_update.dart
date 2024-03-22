import '../models/address.dart';
import 'package:latlong2/latlong.dart';

class StateUpdate {
  final bool isLoading;
  final bool locationServiceEnabled;
  final bool locationPermissionEnabled;
  String currentAddress;
  LatLng? currentPosition;
  Address? address;

  StateUpdate(
      {required this.isLoading,
      required this.locationServiceEnabled,
      required this.locationPermissionEnabled,
      required this.currentAddress,
      this.currentPosition,
      this.address});
}
