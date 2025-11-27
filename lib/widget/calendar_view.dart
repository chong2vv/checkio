import 'package:flutter/material.dart';
import 'package:timefly/app_theme.dart';
import 'package:timefly/models/habit.dart';
import 'package:timefly/utils/date_util.dart';

class CalendarView extends StatefulWidget {
  final DateTime currentDay;

  final Habit habit;

  final double Function() caculatorHeight;

  final Map<String, List<HabitRecord>> records;

  const CalendarView({
    Key? key,
    required this.currentDay,
    required this.caculatorHeight,
    required this.habit,
    required this.records,
  }) : super(key: key);

  @override
  _CalendarViewState createState() => _CalendarViewState();
}

class _CalendarViewState extends State<CalendarView> {
  List<DateTime?> days = [];

  @override
  void initState() {
    days = DateUtil.getMonthDays(
        DateTime(widget.currentDay.year, widget.currentDay.month, 1));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.caculatorHeight(),
      child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(left: .3, right: .3),
          itemCount: days.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7, childAspectRatio: 1.8, mainAxisSpacing: 5),
          itemBuilder: (context, index) {
            final day = days[index];
            if (day == null) {
              return Container();
            }
            return Container(
              decoration: getBox(day, index),
              alignment: Alignment.center,
              child: Text(
                '${day.day}',
                style: AppTheme.appTheme.numHeadline1(
                    textColor: containsDay(day)
                        ? Colors.white
                        : AppTheme.appTheme.normalColor(),
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
            );
          }),
    );
  }

  BoxDecoration getBox(DateTime day, int index) {
    final lastDay = index > 0 ? days[index - 1] : null;
    final nextDay = days.length - 1 > index ? days[index + 1] : null;

    if (containsDay(day)) {
      bool containLastDay = lastDay != null && containsDay(lastDay);
      bool containNextDay = nextDay != null && containsDay(nextDay);

      ///昨天和明天都有记录
      if (containLastDay && containNextDay) {
        return colorBox();

        ///昨天有记录，明天没有记录
      } else if (containLastDay && !containNextDay) {
        return rightBox();

        ///昨天没有记录，明天有记录
      } else if (!containLastDay && containNextDay) {
        return leftBox();

        ///昨天和明天都没有记录
      } else {
        return allBox();
      }
    } else {
      return norBox();
    }
  }

  BoxDecoration norBox() {
    return BoxDecoration();
  }

  BoxDecoration colorBox() {
    return BoxDecoration(color: Color(widget.habit.mainColor ?? 0xFF000000));
  }

  BoxDecoration leftBox() {
    return BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15), bottomLeft: Radius.circular(15)),
        color: Color(widget.habit.mainColor ?? 0xFF000000));
  }

  BoxDecoration rightBox() {
    return BoxDecoration(
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.only(
            topRight: Radius.circular(15), bottomRight: Radius.circular(15)),
        color: Color(widget.habit.mainColor ?? 0xFF000000));
  }

  BoxDecoration allBox() {
    return BoxDecoration(
        shape: BoxShape.circle, color: Color(widget.habit.mainColor ?? 0xFF000000));
  }

  bool containsDay(DateTime date) {
    if (widget.records.isEmpty) {
      return false;
    }
    return widget.records.containsKey('${date.year}-${date.month}-${date.day}');
  }

  bool isSunday(DateTime date) {
    return date.weekday == DateTime.sunday;
  }

  bool isMonday(DateTime date) {
    return date.weekday == DateTime.monday;
  }
}
