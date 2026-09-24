// lib/widgets/trend_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TrendChart extends StatelessWidget {
  final List<FlSpot> tempSpots;
  final List<FlSpot> humSpots;

  const TrendChart({super.key, required this.tempSpots, required this.humSpots});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Grafik Tren Suhu & Kelembapan", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true),
                  titlesData: const FlTitlesData(
                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  ),
                  borderData: FlBorderData(show: true),
                  lineBarsData: [
                    LineChartBarData(
                      spots: tempSpots.isEmpty ? [const FlSpot(0, 0)] : tempSpots,
                      isCurved: true, color: Colors.orange, barWidth: 3, dotData: const FlDotData(show: false),
                    ),
                    LineChartBarData(
                      spots: humSpots.isEmpty ? [const FlSpot(0, 0)] : humSpots,
                      isCurved: true, color: Colors.blue, barWidth: 3, dotData: const FlDotData(show: false),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}