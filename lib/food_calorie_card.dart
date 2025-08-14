import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class FoodCalorieCard extends StatefulWidget {
  final bool small;
  const FoodCalorieCard({Key? key, this.small = false}) : super(key: key);

  @override
  State<FoodCalorieCard> createState() => _FoodCalorieCardState();
}

class _FoodCalorieCardState extends State<FoodCalorieCard> {
  final TextEditingController _foodController = TextEditingController();
  bool _showMore = false;
  bool _loading = false;
  String? _error;
  Map<String, String> _mainNutrients = {
    'Protein': '7.05 G',
    'Toplam lipit (yağ)': '17.6 G',
    'Karbonhidrat, farklılık': '77.6 G',
  };

  Future<void> _fetchNutrients(String yemekAdi) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final response = await http.post(
        Uri.parse('http://127.0.0.1:5002/get_nutrients'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'food_name': yemekAdi}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['nutrients'] != null && data['nutrients'] is Map) {
          final nutrients = Map<String, dynamic>.from(data['nutrients']);
          setState(() {
            _mainNutrients = nutrients.map((k, v) => MapEntry(k, v.toString()));
            _loading = false;
          });
        } else {
          setState(() {
            _error = 'Besin değeri bulunamadı.';
            _loading = false;
          });
        }
      } else {
        setState(() {
          _error = 'API hatası: ${response.statusCode}';
          _loading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Hata: ${e.toString()}';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final double iconSize = widget.small ? 32 : 48;
    final double fontSize = widget.small ? 16 : 20;
    final double padding = widget.small ? 12 : 24;
    final double inputFontSize = widget.small ? 13 : 15;
    final double inputHeight = widget.small ? 36 : 48;
    return Card(
      color: const Color(0xFFFFF3E0),
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.fastfood, size: iconSize, color: Color(0xFFF57C00)),
                SizedBox(width: widget.small ? 12 : 20),
                Text(
                  'Yiyecek Kalori Hesabı',
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFF57C00),
                  ),
                ),
              ],
            ),
            SizedBox(height: widget.small ? 10 : 18),
            SizedBox(
              height: inputHeight,
              child: TextField(
                controller: _foodController,
                style: TextStyle(fontSize: inputFontSize),
                decoration: InputDecoration(
                  labelText: 'Yemek ismi',
                  labelStyle: TextStyle(fontSize: inputFontSize),
                  border: const OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 10,
                  ),
                ),
                onSubmitted: (value) {
                  if (value.trim().isNotEmpty) {
                    _fetchNutrients(value.trim());
                  }
                },
                textInputAction: TextInputAction.search,
              ),
            ),
            SizedBox(height: widget.small ? 10 : 18),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            Text(
              'Besin değerleri:',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: inputFontSize,
              ),
            ),
            SizedBox(height: 8),
            ..._mainNutrients.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      e.key + ':',
                      style: TextStyle(fontSize: inputFontSize),
                    ),
                    Text(
                      e.value,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () {
                  setState(() {
                    _showMore = !_showMore;
                  });
                },
                child: Text(
                  _showMore ? 'Daha az göster' : 'Daha fazla göster',
                  style: TextStyle(fontSize: inputFontSize),
                ),
              ),
            ),
            if (_showMore)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'Daha fazla besin değeri burada gösterilecek...',
                  style: TextStyle(color: Colors.grey, fontSize: inputFontSize),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
