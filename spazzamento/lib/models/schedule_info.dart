class ScheduleInfo {
  final String city;
  final String county;
  final String street;
  final String id;
  final List<int> weekDay;
  final List<int> monthWeek;
  final String? from;
  final String? to;
  final String? day;
  final String? time;
  final String? location;
  final bool? dayEven;
  final bool? dayOdd;
  final bool? numberEven;
  final bool? numberOdd;
  final bool? leftSide;
  final bool? rightSide;
  final bool? internalSide;
  final bool? externalSide;
  final bool? summer;
  final String? start;
  final String? end;

  ScheduleInfo(
      {required this.city,
      required this.county,
      required this.street,
      this.day,
      this.time,
      this.location,
      required this.weekDay,
      required this.monthWeek,
      this.from,
      this.to,
      this.dayEven,
      this.dayOdd,
      this.numberEven,
      this.numberOdd,
      this.leftSide,
      this.rightSide,
      this.internalSide,
      this.externalSide,
      this.summer,
      this.start,
      this.end})
      : id = _generateId(
            city,
            county,
            street,
            weekDay,
            monthWeek,
            from,
            to,
            location,
            dayEven,
            dayOdd,
            numberEven,
            numberOdd,
            summer,
            start,
            end);

  static String _generateId(
      String city,
      String county,
      String street,
      List<int> weekDay,
      List<int> monthWeek,
      String? from,
      String? to,
      String? location,
      bool? dayEven,
      bool? dayOdd,
      bool? numberEven,
      bool? numberOdd,
      bool? summer,
      String? start,
      String? end) {
    return '$city-$county-$street-$location-$dayEven-$dayOdd-$numberEven-$numberOdd-$summer-$start-$end-${weekDay.join('-')}-${monthWeek.join('-')}-$from-$to';
  }

  factory ScheduleInfo.fromJson(
      String city, String county, String street, Map<String, dynamic> json) {
    if (json['weekDay'] is int) {
      json['weekDay'] = [json['weekDay']];
    }
    if (json['monthWeek'] is int) {
      json['monthWeek'] = [json['monthWeek']];
    }

    List<int> weekDay = json['weekDay']?.cast<int>() ?? [];
    List<int> monthWeek = json['monthWeek']?.cast<int>() ?? [];

    return ScheduleInfo(
      city: city,
      county: county,
      street: street,
      weekDay: weekDay,
      monthWeek: monthWeek,
      from: json['from'],
      to: json['to'],
      day: json['day'],
      time: json['time'],
      location: json['location'] ?? 'Tutta la strada',
      dayEven: json['dayEven'],
      dayOdd: json['dayOdd'],
      numberEven: json['numberEven'],
      numberOdd: json['numberOdd'],
      leftSide: json['leftSide'],
      rightSide: json['rightSide'],
      internalSide: json['internalSide'],
      externalSide: json['externalSide'],
      summer: json['summer'],
      start: json['start'],
      end: json['end'],
    );
  }
}
