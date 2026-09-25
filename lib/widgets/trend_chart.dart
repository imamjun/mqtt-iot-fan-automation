// lib/widgets/trend_chart.dart

import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class TrendChart extends StatelessWidget {
  final String title;
  final List<FlSpot> spots;
  final Color lineColor;
  final String unit;

  const TrendChart({
    super.key,
    required this.title,
    required this.spots,
    required this.lineColor,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Grafik & Indikator Warna
            Row(
              children: [
                Container(width: 14, height: 14, color: lineColor),
                const SizedBox(width: 8),
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 180,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: true, drawVerticalLine: true),
                  titlesData: FlTitlesData(
                    // Sumbu Kanan (Dimatikan)
                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    // Sumbu Atas (Dimatikan)
                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                    // Sumbu Kiri (Menampilkan nilai Sumbu Y / Satuan)
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 42,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()} $unit',
                            style: const TextStyle(fontSize: 10, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    // Sumbu Bawah (Menampilkan urutan waktu/data sumbu X)
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 30,
                        interval: 5, // Interval jarak antar label sumbu X
                        getTitlesWidget: (value, meta) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              '${value.toInt()}',
                              style: const TextStyle(fontSize: 10, color: Colors.grey),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots.isEmpty ? [const FlSpot(0, 0)] : spots,
                      isCurved: true,
                      color: lineColor,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: lineColor.withOpacity(0.15), // Efek arsiran gradasi halus di bawah garis
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 4),
            const Center(
              child: Text(
                "Sumbu X: Urutan Data Waktu (Sampling) | Sumbu Y: Nilai Pengukuran",
                style: TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }
}