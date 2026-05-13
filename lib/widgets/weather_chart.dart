import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/weather_data.dart';

class WeatherChart extends StatelessWidget {
  final WeatherData weatherData;

  const WeatherChart({super.key, required this.weatherData});

  @override
  Widget build(BuildContext context) {
    if (weatherData.hourlyTemperatures.isEmpty) {
      return const SizedBox.shrink();
    }

    // Pega as próximas 24 horas
    final temps = weatherData.hourlyTemperatures.take(24).toList();
    final times = weatherData.hourlyTimes.take(24).toList();

    List<FlSpot> spots = [];
    double minTemp = temps[0];
    double maxTemp = temps[0];

    for (int i = 0; i < temps.length; i++) {
      spots.add(FlSpot(i.toDouble(), temps[i]));
      if (temps[i] < minTemp) minTemp = temps[i];
      if (temps[i] > maxTemp) maxTemp = temps[i];
    }

    return Container(
      height: 250,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Previsão para as próximas 24h',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: LineChart(
              LineChartData(
                minY: minTemp - 2,
                maxY: maxTemp + 2,
                minX: 0,
                maxX: 23,
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      interval: 6, // Mostra a cada 6 horas
                      getTitlesWidget: (value, meta) {
                        if (value.toInt() >= times.length) return const SizedBox.shrink();
                        // Formata a string de tempo de "2023-10-12T14:00" para "14:00"
                        final timeStr = times[value.toInt()];
                        final hour = timeStr.split('T').last;
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            hour,
                            style: const TextStyle(color: Colors.white70, fontSize: 12),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: Colors.amberAccent,
                    barWidth: 4,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      color: Colors.amberAccent.withOpacity(0.3),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
