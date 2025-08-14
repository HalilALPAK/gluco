import 'package:flutter/material.dart';

class SporCard extends StatefulWidget {
  final bool small;
  const SporCard({Key? key, this.small = false}) : super(key: key);
  @override
  State<SporCard> createState() => _SporCardState();
}

class _SporCardState extends State<SporCard> {
  final TextEditingController _walkController = TextEditingController();
  final TextEditingController _exerciseController = TextEditingController();
  double? _walkCalories;
  double? _exerciseCalories;

  // Ortalama değerler: Yürüyüş: 4 kcal/dk, Egzersiz: 7 kcal/dk
  static const double walkFactor = 4.0;
  static const double exerciseFactor = 7.0;

  void _calculate() {
    setState(() {
      final walkMin = double.tryParse(_walkController.text) ?? 0;
      final exMin = double.tryParse(_exerciseController.text) ?? 0;
      _walkCalories = walkMin * walkFactor;
      _exerciseCalories = exMin * exerciseFactor;
    });
  }

  @override
  void dispose() {
    _walkController.dispose();
    _exerciseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = widget.small ? 32 : 48;
    final double fontSize = widget.small ? 16 : 20;
    final double padding = widget.small ? 12 : 24;
    final double inputFontSize = widget.small ? 13 : 15;
    final double inputHeight = widget.small ? 36 : 48;
    return Card(
      color: const Color(0xFFE3F2FD),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.directions_run,
                  size: iconSize,
                  color: Color(0xFF1976D2),
                ),
                SizedBox(width: widget.small ? 12 : 20),
                Text(
                  'Spor',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1976D2),
                  ),
                ),
              ],
            ),
            SizedBox(height: widget.small ? 10 : 18),
            SizedBox(
              height: inputHeight,
              child: TextField(
                controller: _walkController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: inputFontSize),
                decoration: InputDecoration(
                  labelText: 'Yürüyüş süresi (dakika)',
                  labelStyle: TextStyle(fontSize: inputFontSize),
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),
                ),
                onChanged: (_) => _calculate(),
              ),
            ),
            SizedBox(height: widget.small ? 8 : 12),
            SizedBox(
              height: inputHeight,
              child: TextField(
                controller: _exerciseController,
                keyboardType: TextInputType.number,
                style: TextStyle(fontSize: inputFontSize),
                decoration: InputDecoration(
                  labelText: 'Egzersiz süresi (dakika)',
                  labelStyle: TextStyle(fontSize: inputFontSize),
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),
                ),
                onChanged: (_) => _calculate(),
              ),
            ),
            SizedBox(height: widget.small ? 10 : 18),
            if (_walkCalories != null || _exerciseCalories != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_walkCalories != null)
                    Text(
                      'Yürüyüşte yakılan kalori: ${_walkCalories!.toStringAsFixed(1)} kcal',
                      style: TextStyle(fontSize: inputFontSize),
                    ),
                  if (_exerciseCalories != null)
                    Text(
                      'Egzersizde yakılan kalori: ${_exerciseCalories!.toStringAsFixed(1)} kcal',
                      style: TextStyle(fontSize: inputFontSize),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
