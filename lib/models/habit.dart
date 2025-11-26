import 'dart:convert';
import 'package:equatable/equatable.dart';

class HabitRecord extends Equatable {
  final String habitId;
  final int time;
  final String content;

  const HabitRecord({
    required this.habitId,
    required this.time,
    required this.content,
  });

  @override
  String toString() {
    return 'HabitRecord{time: $time, content: $content, habitId: $habitId}';
  }

  factory HabitRecord.fromJson(Map<String, dynamic> json) {
    return HabitRecord(
      habitId: json['habitId']?.toString() ?? '',
      time: json["time"] is int
          ? json["time"] as int
          : int.tryParse(json["time"]?.toString() ?? '0') ?? 0,
      content: json["content"]?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'habitId': habitId,
      'time': time,
      'content': content,
    };
  }

  @override
  List<Object?> get props => [habitId, time, content];

  HabitRecord copyWith({String? habitId, int? time, String? content}) {
    return HabitRecord(
      habitId: habitId ?? this.habitId,
      time: time ?? this.time,
      content: content ?? this.content,
    );
  }
}

class Habit extends Equatable {
  final String? id;
  final String? name;
  final String? iconPath;
  final int? mainColor;
  final String? mark;
  final List<String> remindTimes;
  final int? completeTime;
  final List<int> completeDays;
  final int? period;
  final int? createTime;
  final int? modifyTime;
  final bool completed;
  final int? doNum;
  final List<HabitRecord> records;

  const Habit({
    this.id,
    this.name,
    this.iconPath,
    this.mainColor,
    this.mark,
    this.remindTimes = const [],
    this.completeDays = const [],
    this.completeTime,
    this.period,
    this.createTime,
    this.modifyTime,
    this.completed = false,
    this.doNum,
    this.records = const [],
  });

  @override
  String toString() {
    return 'Habit{id: $id , name: $name, iconPath: $iconPath, mainColor: '
        '$mainColor, mark: $mark, remindTimes: $remindTimes, completeTime:'
        ' $completeTime, completeDays: $completeDays, period: $period, '
        'createTime: $createTime, modifyTime: $modifyTime, completed: $completed,'
        ' doNum: $doNum, records: $records}';
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    List<HabitRecord> records = const [],
  }) {
    final List<String> remindTimes = [];
    final remindTimesJson = json["remindTimes"];
    if (remindTimesJson != null) {
      final decoded = remindTimesJson is String
          ? jsonDecode(remindTimesJson)
          : remindTimesJson;
      for (final item in decoded) {
        remindTimes.add(item.toString());
      }
    }

    final List<int> completeDays = [];
    final completeDaysJson = json["completeDays"];
    if (completeDaysJson != null) {
      final decoded = completeDaysJson is String
          ? jsonDecode(completeDaysJson)
          : completeDaysJson;
      for (final item in decoded) {
        if (item is int) {
          completeDays.add(item);
        } else if (item is num) {
          completeDays.add(item.toInt());
        } else {
          completeDays.add(int.tryParse(item.toString()) ?? 0);
        }
      }
    }

    return Habit(
      id: json["id"]?.toString(),
      name: json["name"]?.toString(),
      iconPath: json["iconPath"]?.toString(),
      mainColor: json["mainColor"]?.toInt(),
      mark: json["mark"]?.toString(),
      remindTimes: remindTimes,
      completeDays: completeDays,
      completeTime: json['completeTime']?.toInt(),
      period: json["period"]?.toInt(),
      createTime: json["createTime"]?.toInt(),
      modifyTime: json["modifyTime"]?.toInt(),
      completed: json["completed"]?.toInt() == 1,
      doNum: json["doNum"]?.toInt(),
      records: records,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "iconPath": iconPath,
      "mainColor": mainColor,
      "mark": mark,
      "remindTimes": jsonEncode(remindTimes),
      "completeDays": jsonEncode(completeDays),
      "completeTime": completeTime,
      "period": period,
      "createTime": createTime,
      "modifyTime": modifyTime,
      "completed": completed ? 1 : 0,
      "doNum": doNum,
    };
  }

  static Habit createHabit(String key) {
    return Habit(
      id: 'id__$key',
      name: 'name__$key',
      iconPath: 'assets/images/tab_1.png',
      mainColor: 122,
      mark: 'mark__$key',
      remindTimes: const ['time1', 'time2'],
      period: 1,
      createTime: 1111,
      modifyTime: 0,
      completed: false,
      doNum: 0,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        iconPath,
        mainColor,
        mark,
        remindTimes,
        completeDays,
        completeTime,
        period,
        createTime,
        modifyTime,
        completed,
        doNum,
        records,
      ];

  Habit copyWith({
    String? id,
    String? name,
    String? iconPath,
    int? mainColor,
    String? mark,
    List<String>? remindTimes,
    List<int>? completeDays,
    int? completeTime,
    int? period,
    int? createTime,
    int? modifyTime,
    bool? completed,
    int? doNum,
    List<HabitRecord>? records,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      iconPath: iconPath ?? this.iconPath,
      mainColor: mainColor ?? this.mainColor,
      mark: mark ?? this.mark,
      remindTimes: remindTimes ?? this.remindTimes,
      completeDays: completeDays ?? this.completeDays,
      completeTime: completeTime ?? this.completeTime,
      period: period ?? this.period,
      createTime: createTime ?? this.createTime,
      modifyTime: modifyTime ?? this.modifyTime,
      completed: completed ?? this.completed,
      doNum: doNum ?? this.doNum,
      records: records ?? this.records,
    );
  }
}
