import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:fl_chart/fl_chart.dart';

class GlucoseWeeklyChartCard extends StatefulWidget {
  const GlucoseWeeklyChartCard({Key? key}) : super(key: key);

  @override
  State<GlucoseWeeklyChartCard> createState() => _GlucoseWeeklyChartCardState();
}

class _GlucoseWeeklyChartCardState extends State<GlucoseWeeklyChartCard> {
  List<Map> _weeklyData = [];
  bool _showDetails = false;

  @override
  void initState() {
    super.initState();
    _loadWeeklyData();
  }

  Future<void> _loadWeeklyData() async {
    var box = await Hive.openBox('glucose_predictions');
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final all =
        box.values.where((e) {
          final tarih = DateTime.tryParse(e['tarih'] ?? '') ?? now;
          return tarih.isAfter(weekAgo) &&
              tarih.isBefore(now.add(const Duration(days: 1)));
        }).toList();
    all.sort((a, b) => (a['tarih'] ?? '').compareTo(b['tarih'] ?? ''));
    setState(() {
      _weeklyData = List<Map>.from(all);
    });
  }

  List<FlSpot> get _chartSpots {
    return List.generate(_weeklyData.length, (i) {
      final val = _weeklyData[i]['tahmin'] ?? 0.0;
      return FlSpot(
        i.toDouble(),
        (val is double) ? val : double.tryParse(val.toString()) ?? 0.0,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color(0xFFE8F5E9),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.show_chart, color: Colors.green, size: 28),
                const SizedBox(width: 10),
                const Text(
                  'Haftalık Kan Şekeri Grafiği',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const SizedBox(height: 8),
            const Text(
              'Y ekseni: Kan Şekeri (mg/dL)   |   X ekseni: Gün',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
            SizedBox(
              height: 240,
              child:
                  _weeklyData.isEmpty
                      ? const Center(child: Text('Bu hafta için veri yok.'))
                      : LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: _chartSpots,
                              isCurved: true,
                              color: Colors.green,
                              barWidth: 3,
                              dotData: FlDotData(show: true),
                            ),
                          ],
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                reservedSize: 40,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  int idx = value.toInt();
                                  if (idx < 0 || idx >= _weeklyData.length)
                                    return const SizedBox();
                                  final tarihStr =
                                      _weeklyData[idx]['tarih'] ?? '';
                                  DateTime? tarih = DateTime.tryParse(tarihStr);
                                  String label =
                                      tarih != null
                                          ? '${tarih.day}.${tarih.month}'
                                          : '';
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 8),
                                    child: Text(
                                      label,
                                      style: const TextStyle(fontSize: 11),
                                    ),
                                  );
                                },
                                reservedSize: 48,
                              ),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(showTitles: false),
                            ),
                          ),
                          borderData: FlBorderData(
                            show: true,
                            border: const Border.symmetric(
                              vertical: BorderSide(
                                color: Colors.black26,
                                width: 1,
                              ),
                              horizontal: BorderSide(
                                color: Colors.black26,
                                width: 1,
                              ),
                            ),
                          ),
                          gridData: FlGridData(
                            show: true,
                            drawVerticalLine: true,
                            drawHorizontalLine: true,
                          ),
                        ),
                      ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () => setState(() => _showDetails = !_showDetails),
                child: Text(
                  _showDetails ? 'Ayrıntıları Gizle' : 'Ayrıntıları Göster',
                ),
              ),
            ),
            if (_showDetails)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:
                    _weeklyData.reversed.map((e) {
                      final tarih = e['tarih'] ?? '';
                      final tahmin = e['tahmin'] ?? '';
                      final ai = e['ai_cevap'] ?? '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Card(
                          color: Colors.white,
                          elevation: 1,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Tarih: $tarih',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text('Tahmin: $tahmin mg/dL'),
                                Text('AI Yanıtı: $ai'),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
