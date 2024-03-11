class ScheduleInfo {
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

  ScheduleInfo(
      {required this.day,
      required this.time,
      required this.location,
      this.weekDay,
      this.monthWeek,
      this.from,
      this.to,
      this.dayEven,
      this.dayOdd,
      this.numberEven,
      this.numberOdd,
      this.summer});

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
    );
  }
}
