import 'package:geocoding/geocoding.dart';

class Address {
  final String city;
  final String county;
  final String street;

  Address({
    required this.city,
    required this.county,
    required this.street,
  });

  factory Address.fromPlacemark(Placemark placemark) {
    return Address(
      city: placemark.locality ?? '',
      county:
          placemark.subAdministrativeArea!.replaceFirst("Provincia di ", "") ??
              '',
      street: placemark.thoroughfare ?? '',
    );
  }
}
