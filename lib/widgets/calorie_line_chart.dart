import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class CalorieLineChart extends StatelessWidget {
  const CalorieLineChart({super.key});

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tues', 'Wed', 'Thurs', 'Fri', 'Sat', 'Sun'];
    const values = [220.0, 340, 410, 460, 505, 380, 360];

    return SizedBox(
      height: 220,
      child: Column(
        children: [
          Expanded(
            child: LineChart(
              LineChartData(
                minX: 0,
                maxX: 6,
                minY: 0,
                maxY: 600,
                gridData: FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  rightTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  leftTitles: const AxisTitles(
                    sideTitles: SideTitles(showTitles: false),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index < 0 || index >= days.length) {
                          return const SizedBox.shrink();
                        }
                        final isHighlight = index == 4;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            days[index],
                            style: TextStyle(
                              fontSize: 11,
                              color: isHighlight
                                  ? Colors.white
                                  : Colors.white70,
                              fontWeight: isHighlight
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: [
                      for (int i = 0; i < values.length; i++)
                        FlSpot(i.toDouble(), values[i].toDouble()),
                    ],
                    isCurved: true,
                    color: Colors.white,
                    barWidth: 2,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, _, _, _) {
                        final isHighlight = spot.x.toInt() == 4;
                        return FlDotCirclePainter(
                          radius: isHighlight ? 5 : 3,
                          color: Colors.white,
                          strokeWidth: isHighlight ? 3 : 1,
                          strokeColor: Colors.yellow.shade200,
                        );
                      },
                    ),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.white.withValues(alpha: 0.2),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ],
                extraLinesData: ExtraLinesData(
                  verticalLines: [
                    VerticalLine(
                      x: 4,
                      color: Colors.yellow.shade200,
                      strokeWidth: 1.5,
                      dashArray: [4, 4],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(alignment: Alignment.topCenter, child: _CalorieTooltip()),
        ],
      ),
    );
  }
}

class _CalorieTooltip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFFFFF59D),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Text(
            '505 cal',
            style: TextStyle(
              color: Colors.black87,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        CustomPaint(
          size: const Size(12, 8),
          painter: _TooltipTrianglePainter(),
        ),
      ],
    );
  }
}

class _TooltipTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFFFF59D)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
