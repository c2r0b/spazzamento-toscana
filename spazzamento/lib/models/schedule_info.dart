class ScheduleInfo {
  final String id;
  final List<dynamic>? weekDay;
  final List<dynamic>? monthWeek;
  final String? from;
  final String? to;
  final String? day;
  final String? time;
  final String? location;
  final bool? dayEven;
  final bool? dayOdd;
  final bool? numberEven;
  final bool? numberOdd;
  final bool? summer;
  final String? start;
  final String? end;

  ScheduleInfo(
      {this.day,
      this.time,
      this.location,
      this.weekDay,
      this.monthWeek,
      this.from,
      this.to,
      this.dayEven,
      this.dayOdd,
      this.numberEven,
      this.numberOdd,
      this.summer,
      this.start,
      this.end})
      : id = _generateId(weekDay, monthWeek, from, to, day, location, dayEven,
            dayOdd, summer, start, end);

  static String _generateId(
      List<dynamic>? weekDay,
      List<dynamic>? monthWeek,
      String? from,
      String? to,
      String? day,
      String? location,
      bool? dayEven,
      bool? dayOdd,
      bool? summer,
      String? start,
      String? end) {
    return '$weekDay-$monthWeek-$from-$to-$day-$location-$dayEven-$dayOdd-$summer-$start-$end';
  }

  factory ScheduleInfo.fromJson(Map<String, dynamic> json) {
    if (json['weekDay'] is int) {
      json['weekDay'] = [json['weekDay']];
    }
    if (json['monthWeek'] is int) {
      json['monthWeek'] = [json['monthWeek']];
    }

    return ScheduleInfo(
      weekDay: json['weekDay'],
      monthWeek: json['monthWeek'],
      from: json['from'],
      to: json['to'],
      day: json['day'],
      time: json['time'],
      location: json['location'] ?? 'Tutta la strada',
      dayEven: json['dayEven'],
      dayOdd: json['dayOdd'],
      numberEven: json['numberEven'],
      numberOdd: json['numberOdd'],
      summer: json['summer'],
      start: json['start'],
      end: json['end'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'weekDay': weekDay,
      'monthWeek': monthWeek,
      'from': from,
      'to': to,
      'day': day,
      'time': time,
      'location': location,
      'dayEven': dayEven,
      'dayOdd': dayOdd,
      'numberEven': numberEven,
      'numberOdd': numberOdd,
      'summer': summer,
      'start': start,
      'end': end,
    };
  }
}
