import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_datetime_picker/flutter_datetime_picker.dart';
import 'package:month_year_picker/month_year_picker.dart';
import 'package:shizen_app/models/provider.dart';
import 'package:shizen_app/utils/allUtils.dart';
import 'package:intl/intl.dart';

class _LineChart extends StatelessWidget {
  const _LineChart({required this.maxCompletions, required this.spots});

  final maxCompletions;
  final spots;

  @override
  Widget build(BuildContext context) {
    return LineChart(
      sampleData2,
      swapAnimationDuration: const Duration(milliseconds: 250),
    );
  }

  LineChartData get sampleData2 => LineChartData(
        lineTouchData: lineTouchData2,
        gridData: gridData,
        titlesData: titlesData2,
        borderData: borderData,
        lineBarsData: lineBarsData2,
        minX: 1,
        maxX: spots.length.toDouble(),
        maxY: maxCompletions < 3 ? 3 : maxCompletions.toDouble(),
        minY: 0,
      );

  LineTouchData get lineTouchData2 => LineTouchData(
        enabled: true,
      );

  FlTitlesData get titlesData2 => FlTitlesData(
        bottomTitles: AxisTitles(
          axisNameWidget:
              Text('Date (month)', style: TextStyle(color: Colors.white)),
          sideTitles: bottomTitles,
        ),
        rightTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        topTitles: AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          axisNameWidget:
              Text('Completions', style: TextStyle(color: Colors.white)),
          sideTitles: leftTitles(),
        ),
      );

  List<LineChartBarData> get lineBarsData2 => [
        lineChartBarData2_1,
      ];

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color.fromARGB(255, 125, 146, 170),
      fontWeight: FontWeight.bold,
      fontSize: 14,
    );
    String text;
    try {
      text = '${value.toInt()}';
    } catch (e) {
      return Container();
    }

    return Text(text, style: style, textAlign: TextAlign.center);
  }

  SideTitles leftTitles() => SideTitles(
        getTitlesWidget: leftTitleWidgets,
        showTitles: true,
        interval: maxCompletions < 5 ? 1.0 : null,
        reservedSize: 40,
      );

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    const style = TextStyle(
      color: Color.fromARGB(255, 125, 146, 170),
      fontWeight: FontWeight.bold,
      fontSize: 16,
    );
    Widget text;
    if (value.toInt() == 1 ||
        value.toInt() == 5 ||
        value.toInt() == 10 ||
        value.toInt() == 15 ||
        value.toInt() == 20 ||
        value.toInt() == 25 ||
        value.toInt() == spots.length) {
      text = Text(value.toInt().toString(), style: style);
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 10,
        child: text,
      );
    } else {
      text = const Text('');
      return SideTitleWidget(
        axisSide: meta.axisSide,
        space: 10,
        child: text,
      );
    }
  }

  SideTitles get bottomTitles => SideTitles(
        showTitles: true,
        reservedSize: 32,
        interval: 1,
        getTitlesWidget: bottomTitleWidgets,
      );

  FlGridData get gridData =>
      FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 1.0);

  FlBorderData get borderData => FlBorderData(
        show: true,
        border: const Border(
          bottom: BorderSide(color: Color(0xff4e4965), width: 4),
          left: BorderSide(color: Color(0xff4e4965), width: 4),
          right: BorderSide(color: Colors.transparent),
          top: BorderSide(color: Colors.transparent),
        ),
      );

  LineChartBarData get lineChartBarData2_1 => LineChartBarData(
      isCurved: true,
      curveSmoothness: 0,
      color: const Color(0x444af699),
      barWidth: 4,
      isStrokeCapRound: true,
      dotData: FlDotData(show: false),
      belowBarData: BarAreaData(show: true),
      spots: spots);
}

class LineChartSample1 extends StatefulWidget {
  const LineChartSample1(
      {Key? key,
      required this.spots,
      required this.maxCompletions,
      required this.month})
      : super(key: key);

  final List<FlSpot> spots;
  final maxCompletions;
  final month;

  @override
  State<StatefulWidget> createState() => LineChartSample1State();
}

class LineChartSample1State extends State<LineChartSample1> {
  late bool isShowingMainData;
  final selectedDateTime = ValueNotifier(DateTime.now());

  @override
  void initState() {
    super.initState();
    isShowingMainData = true;
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.23,
      child: Container(
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(18)),
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 53, 59, 71),
              Color.fromARGB(255, 82, 94, 107),
            ],
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
          ),
        ),
        child: Stack(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const SizedBox(
                  height: 10,
                ),
                Text(
                  '${Provider.of<UserProvider>(context).user.name}\'s Progress',
                  style: TextStyle(
                    color: Color.fromARGB(255, 125, 146, 170),
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 4,
                ),
                Text(
                  'Completions in ${widget.month.value} ${selectedDateTime.value.year}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(right: 15.0),
                    child: _LineChart(
                        maxCompletions: widget.maxCompletions,
                        spots: widget.spots),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
            IconButton(
              icon: Icon(
                Icons.date_range_rounded,
                color: Colors.white.withOpacity(1.0),
              ),
              onPressed: () async {
                final selected = await showMonthYearPicker(
                  context: context,
                  initialDate: selectedDateTime.value,
                  firstDate: DateTime(2020),
                  lastDate: DateTime.now(),
                );
                if (selected == null) {
                  return;
                }
                selectedDateTime.value = selected;
                widget.month.value = DateFormat("MMM").format(selected);
              },
            )
          ],
        ),
      ),
    );
  }
}
