import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:timefly/app_theme.dart';
import 'package:timefly/models/complete_time.dart';
import 'package:timefly/models/habit.dart';
import 'package:timefly/models/habit_peroid.dart';
import 'package:timefly/utils/date_util.dart';
import 'package:timefly/utils/habit_util.dart';
import 'package:timefly/utils/hex_color.dart';
import 'package:timefly/utils/pair.dart';
import 'package:timefly/widget/clip/bottom_cliper.dart';
import 'package:timefly/widget/tab_indicator.dart';
import 'package:time/time.dart';

class WeekMonthChart extends StatefulWidget {
  final List<Habit> habits;

  const WeekMonthChart({
    Key? key,
    required this.habits,
  }) : super(key: key);

  @override
  _WeekMonthChartState createState() => _WeekMonthChartState();
}

class _WeekMonthChartState extends State<WeekMonthChart>
    with TickerProviderStateMixin {
  late TabController _tabController;
  DateTime _now = DateTime.now();

  int touchedIndex = -1;

  ///当前周标示
  ///0 当前周，1，上一周
  int currentWeekIndex = 0;

  ///当前月标示 0 当前月 1 上个月
  int currentMonthIndex = 0;

  ///当前Chart类型 0 周 1 月
  int currentChart = 0;

  double darken = 0.15;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      setState(() {
        currentChart = _tabController.index;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipPath(
          clipper: BottomClipper(),
          child: Container(
            decoration: BoxDecoration(
                gradient: AppTheme.appTheme.containerGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            )),
            height: 445 + MediaQuery.of(context).padding.top,
          ),
        ),
        Column(
          children: [
            Container(
              alignment: Alignment.center,
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 24,
                  left: 16,
                  right: 16),
              child: TabBar(
                controller: _tabController,
                tabs: ['周', '月']
                    .map((time) => Container(
                          margin: EdgeInsets.only(left: 8, right: 8),
                          alignment: Alignment.center,
                          width: 60,
                          height: 38,
                          child: Text('$time'),
                        ))
                    .toList(),
                labelColor: Colors.white,
                labelStyle:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                unselectedLabelColor: Colors.white70,
                unselectedLabelStyle:
                    TextStyle(fontWeight: FontWeight.normal, fontSize: 18),
                indicator: BorderTabIndicator(
                    indicatorHeight: 36, textScaleFactor: 0.8),
                isScrollable: true,
              ),
            ),
            SizedBox(
              height: 16,
            ),

            ///lineChart
            Container(
              padding: EdgeInsets.only(left: 32, right: 32),
              width: MediaQuery.of(context).size.width,
              height: 230,
              child: currentChart == 0
                  ? BarChart(
                      weekBarData(),
                    )
                  : LineChart(
                      monthLineData(),
                    ),
            ),
            SizedBox(
              height: 12,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    if (currentChart == 0) {
                      setState(() {
                        currentWeekIndex = currentWeekIndex == 0 ? 1 : 0;
                      });
                    } else {
                      setState(() {
                        currentMonthIndex = currentMonthIndex == 0 ? 1 : 0;
                      });
                    }
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                        shape: BoxShape.rectangle,
                        borderRadius: BorderRadius.all(Radius.circular(20)),
                        color: Colors.white.withOpacity(0.2)),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                          size: 16,
                        ),
                        SizedBox(
                          width: 4,
                        ),
                        Text(
                          currentChart == 0
                              ? (currentWeekIndex == 0 ? '本周' : '上周')
                              : (currentMonthIndex == 0 ? '本月' : '上月'),
                          style: AppTheme.appTheme.headline1(
                              textColor: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  BarChartData weekBarData() {
    List<double> currentWeekNums = _getWeekNums(currentWeekIndex);
    List<double> previousWeekNums = _getWeekNums(currentWeekIndex + 1);
    double maxY = 0;
    currentWeekNums.forEach((num) {
      if (num > maxY) {
        maxY = num;
      }
    });
    previousWeekNums.forEach((num) {
      if (num > maxY) {
        maxY = num;
      }
    });
    return BarChartData(
      maxY: maxY >= 5 ? maxY * 1.3 : 5,
      barTouchData: BarTouchData(
        touchTooltipData: BarTouchTooltipData(
            fitInsideHorizontally: true,
            fitInsideVertically: true,
            tooltipPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              return BarTooltipItem(
                  (rod.toY - 1).toInt().toString(),
                  AppTheme.appTheme.numHeadline1(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ));
            }),
        touchCallback: (event, barTouchResponse) {
          setState(() {
            if (barTouchResponse?.spot != null) {
              touchedIndex = barTouchResponse!.spot!.touchedBarGroupIndex;
            } else {
              touchedIndex = -1;
            }
          });
        },
      ),
      titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                return Text(
                  CompleteDay.getSimpleDay(value.toInt() + 1),
                  style: AppTheme.appTheme.headline1(
                      textColor: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
      borderData: FlBorderData(
        show: false,
      ),
      gridData: FlGridData(show: false),
      barGroups: showingGroups(currentWeekNums, previousWeekNums, maxY),
    );
  }

  List<BarChartGroupData> showingGroups(List<double> currentWeekNums,
          List<double> previousWeekNums, double maxY) =>
      List.generate(7, (i) {
        return makeGroupData(i, currentWeekNums[i], previousWeekNums[i],
            isTouched: i == touchedIndex);
      });

  BarChartGroupData makeGroupData(
    int x,
    double currentY,
    double previousY, {
    bool isTouched = false,
    double width = 12,
    List<int> showTooltips = const [],
  }) {
    return BarChartGroupData(
      barsSpace: 6,
      x: x,
      barRods: [
        BarChartRodData(
          toY: isTouched
              ? (currentY > 0 ? currentY + 1 : 1)
              : (currentY > 0 ? currentY : 1),
          color: Colors.white,
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: false,
          ),
        ),
        BarChartRodData(
          toY: isTouched
              ? (previousY > 0 ? previousY + 1 : 1)
              : (previousY > 0 ? previousY : 1),
          color: HexColor.darken(AppTheme.appTheme.grandientColorEnd(), darken),
          width: width,
          backDrawRodData: BackgroundBarChartRodData(
            show: false,
          ),
        ),
      ],
    );
  }

  List<double> _getWeekNums(int weekIndex) {
    Pair<DateTime> week = DateUtil.getWeekStartAndEnd(_now, weekIndex);
    DateTime start = week.x0;
    DateTime end = week.x1;
    List<double> nums = [];
    for (int i = 0; i < 7; i++) {
      DateTime day = start.add(Duration(days: i));
      int count = 0;
      widget.habits.forEach((habit) {
        if ((habit.period ?? HabitPeriod.month) == HabitPeriod.week ||
            (habit.completeDays.contains(day.weekday) &&
                (habit.period ?? HabitPeriod.month) == HabitPeriod.day)) {
          count += HabitUtil.getDoCountOfHabit(habit.records,
              DateUtil.startOfDay(day), DateUtil.endOfDay(day));
        }
      });
      nums.add(count.toDouble());
    }
    return nums;
  }

  LineChartData monthLineData() {
    List<double> currentMonthNums = _getMonthNums(currentMonthIndex);
    List<double> previousMonthNums = _getMonthNums(currentMonthIndex + 1);
    double maxY = 0;
    currentMonthNums.forEach((num) {
      if (num > maxY) {
        maxY = num;
      }
    });
    previousMonthNums.forEach((num) {
      if (num > maxY) {
        maxY = num;
      }
    });
    return LineChartData(
        gridData: FlGridData(show: false),
        lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            getTouchedSpotIndicator: (bar, indexs) {
              return indexs
                  .map((e) => TouchedSpotIndicatorData(
                      FlLine(color: Colors.transparent, strokeWidth: 2),
                      FlDotData(
                          show: true,
                          getDotPainter: (FlSpot spot, double xPercentage,
                              LineChartBarData bar, int index) {
                            final barColor = bar.color ?? Colors.transparent;
                            return FlDotCirclePainter(
                                radius: 5.5,
                                color: barColor == Colors.white
                                    ? barColor
                                    : Colors.transparent,
                                strokeColor:
                                    barColor == Colors.white
                                        ? Colors.black12
                                        : Colors.transparent,
                                strokeWidth: 1);
                          })))
                  .toList();
            },
            touchTooltipData: LineTouchTooltipData(
                tooltipPadding: EdgeInsets.all(8),
                fitInsideVertically: true,
                fitInsideHorizontally: true,
                getTooltipItems: (spots) {
                  return spots
                      .map((spot) => (spot.barIndex == 1
                          ? LineTooltipItem(
                              '${(spot.y - 1).toInt()}\n${getMonthByIndex(spot.x.toInt())}',
                              AppTheme.appTheme.numHeadline1(
                                  fontSize: 20, fontWeight: FontWeight.bold))
                          : null))
                      .toList();
                })),
        titlesData: FlTitlesData(
          show: true,
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  getTitlesWidget: (value, meta) {
                    final style = AppTheme.appTheme.numHeadline1(
                        textColor: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16);
                    switch (value.toInt()) {
                      case 1:
                        return Text('1', style: style);
                      case 5:
                        return Text('5', style: style);
                      case 10:
                        return Text('10', style: style);
                      case 15:
                        return Text('15', style: style);
                      case 20:
                        return Text('20', style: style);
                      case 25:
                        return Text('25', style: style);
                      case 30:
                        return Text('30', style: style);
                      default:
                        return Text('', style: style);
                    }
                  })),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        lineBarsData: monthLines(currentMonthNums, previousMonthNums),
        maxX: 31,
        minX: 0,
        minY: 1,
        maxY: maxY >= 5 ? maxY * 1.3 : 5);
  }

  List<LineChartBarData> monthLines(
      List<double> currentMonthNums, List<double> previousMonthNums) {
    List<FlSpot> currentMonthSpots = [];
    for (int i = 0; i < currentMonthNums.length; i++) {
      currentMonthSpots.add(FlSpot(
          i + 1.0, currentMonthNums[i] > 0 ? currentMonthNums[i] + 1 : 1));
    }
    List<FlSpot> previousMonthSpots = [];
    for (int i = 0; i < previousMonthNums.length; i++) {
      previousMonthSpots.add(FlSpot(
          i + 1.0, previousMonthNums[i] > 0 ? previousMonthNums[i] + 1 : 1));
    }
    return [
      LineChartBarData(
        spots: previousMonthSpots,
        curveSmoothness: .33,
        isCurved: true,
        color: HexColor.darken(AppTheme.appTheme.grandientColorEnd(), darken),
        barWidth: 2,
        isStrokeCapRound: true,
        preventCurveOverShooting: true,
        dotData: FlDotData(
          show: false,
        ),
        belowBarData: BarAreaData(
          show: false,
        ),
      ),
      LineChartBarData(
        spots: currentMonthSpots,
        curveSmoothness: .33,
        isCurved: true,
        color: Colors.white,
        barWidth: 2,
        preventCurveOverShooting: true,
        isStrokeCapRound: true,
        dotData: FlDotData(
            show: true,
            getDotPainter: (FlSpot spot, double xPercentage,
                LineChartBarData bar, int index) {
              final barColor = bar.color ?? Colors.transparent;
              return FlDotCirclePainter(
                  radius: 2,
                  color: barColor == Colors.white
                      ? barColor
                      : Colors.transparent,
                  strokeColor: barColor == Colors.white
                      ? Colors.black12
                      : Colors.transparent,
                  strokeWidth: 0);
            }),
        belowBarData: BarAreaData(
          show: false,
        ),
      ),
    ];
  }

  List<double> _getMonthNums(int monthIndex) {
    Pair<DateTime> month = DateUtil.getMonthStartAndEnd(_now, monthIndex);
    DateTime start = month.x0;
    DateTime end = month.x1;
    int dayCount = end.difference(start).inDays + 1;
    List<double> nums = [];
    for (int i = 0; i < dayCount; i++) {
      DateTime day = start.add(Duration(days: i));
      int count = 0;
      widget.habits.forEach((habit) {
        if ((habit.period ?? HabitPeriod.month) == HabitPeriod.month ||
            (habit.completeDays.contains(day.weekday) &&
                (habit.period ?? HabitPeriod.month) == HabitPeriod.day)) {
          count += HabitUtil.getDoCountOfHabit(habit.records,
              DateUtil.startOfDay(day), DateUtil.endOfDay(day));
        }
      });
      nums.add(count.toDouble());
    }
    return nums;
  }

  String getMonthByIndex(int index) {
    List<String> months = [
      '1月',
      '2月',
      '3月',
      '4月',
      '5月',
      '6月',
      '7月',
      '8月',
      '9月',
      '10月',
      '11月',
      '12月'
    ];
    return months[index - 1];
  }
}
