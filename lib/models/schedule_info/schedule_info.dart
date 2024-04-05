import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule_info.freezed.dart';
part 'schedule_info.g.dart';

@freezed
class ScheduleInfo with _$ScheduleInfo {
  const ScheduleInfo._();

  const factory ScheduleInfo({
    required String city,
    required String county,
    required String street,
    @Default([]) List<int> weekDay,
    @Default([]) List<int> monthWeek,
    String? from,
    String? to,
    String? day,
    String? time,
    @Default('Tutta la strada') String? location,
    bool? dayEven,
    bool? dayOdd,
    bool? numberEven,
    bool? numberOdd,
    bool? leftSide,
    bool? rightSide,
    bool? internalSide,
    bool? externalSide,
    bool? summer,
    bool? morning,
    bool? afternoon,
    String? start,
    String? end,
  }) = _ScheduleInfo;

  String get id => hashCode.toString();

  factory ScheduleInfo.fromJson(Map<String, dynamic> json) =>
      _$ScheduleInfoFromJson({
        ...json,
        'weekDay': json['weekDay'] is int ? [json['weekDay']] : json['weekDay'],
        'monthWeek':
            json['monthWeek'] is int ? [json['monthWeek']] : json['monthWeek'],
      });
}
