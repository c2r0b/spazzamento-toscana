import '../models/schedule_info.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:convert';

Future<List<ScheduleInfo>?> findSchedule(
    String city, String county, String streetQuery) async {
  city = city.toUpperCase();
  county = county.toUpperCase();

  // get all streets first
  final PostgrestList streetData;
  try {
    streetData = await Supabase.instance.client
        .from('data')
        .select('street')
        .eq('county', county)
        .eq('city', city);
  } catch (e) {
    print('Error fetching street data: $e');
    return null;
  }

  // Iterate over the streets in the matched city data.
  String? closestMatch;
  int closestMatchScore = 100;

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

  // Get the schedule for the closest match.
  final PostgrestMap scheduleData;
  try {
    scheduleData = await Supabase.instance.client
        .from('data')
        .select('schedule')
        .eq('city', city)
        .eq('county', county)
        .eq('street', closestMatch)
        .single()
        .limit(1);
  } catch (e) {
    print('Error fetching schedule data: $e');
    return null;
  }

  final schedule = jsonDecode(scheduleData['schedule']) as Map<String, dynamic>;

  List<ScheduleInfo> schedules = [];
  for (var schedule in schedule['data']) {
    ScheduleInfo scheduleInfo =
        ScheduleInfo.fromJson(city, county, closestMatch, schedule);
    schedules.add(scheduleInfo);
  }
  return schedules;
}

int _calculateSimilarity(String query, String streetName) {
  double similarity = StringSimilarity.compareTwoStrings(
      query.toLowerCase(), streetName.toLowerCase());
  // Convert the similarity (0.0 - 1.0) to a score. Lower score means more similar.
  // Multiplying by 100 (or more) to express the similarity as an integer.
  return ((1 - similarity) * 100).round();
}
