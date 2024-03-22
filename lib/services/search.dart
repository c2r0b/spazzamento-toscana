import 'package:http/http.dart' as http;
import 'dart:convert';

Future<List> getSuggestions(String query) async {
  query = '$query, Toscana';
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
