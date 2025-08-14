import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart'; // kIsWeb
import 'gorev_takvim.dart';
import 'ai_chat_dialog.dart';
// import 'gorev_model.dart';
import 'giris.dart';
import 'food_calorie_card.dart';
import 'spor_card.dart';
import 'glucose_weekly_chart_card.dart'; // Sadece bir kez import
import 'package:hive_flutter/hive_flutter.dart';
import 'profil_dialog.dart';
import 'glucose_weekly_chart_card.dart';

class InitialInfoDialog extends StatefulWidget {
  State<InitialInfoDialog> createState() => InitialInfoDialogState();
}

class InitialInfoDialogState extends State<InitialInfoDialog> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _boyController = TextEditingController();
  final TextEditingController _kiloController = TextEditingController();
  final TextEditingController _yasController = TextEditingController();
  String? _cinsiyet; // 'Kadın' veya 'Erkek'
  bool _showCongrats = false;
  bool _showExtra = false;
  String? _hamilelik; // 'Evet' veya 'Hayır'
  String? _ozelDurum; // 'Evet' veya 'Hayır'

  @override
  void dispose() {
    _boyController.dispose();
    _kiloController.dispose();
    _yasController.dispose();
    super.dispose();
  }

  void _onContinue() {
    if (_formKey.currentState!.validate() && _cinsiyet != null) {
      // Bilgileri Hive'daki kullanıcıya kaydet
      Hive.openBox('users').then((box) {
        final user = box.get('demo@gmail.com');
        if (user != null) {
          user['boy'] = _boyController.text.trim();
          user['kilo'] = _kiloController.text.trim();
          user['yas'] = _yasController.text.trim();
          box.put('demo@gmail.com', user);
        }
      });
      setState(() {
        _showCongrats = true;
      });
      Future.delayed(const Duration(seconds: 1), () {
        if (_cinsiyet == 'Kadın') {
          setState(() {
            _showExtra = true;
          });
        } else {
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _onFinish() {
    if (_hamilelik != null && _ozelDurum != null) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: SizedBox(
          width: 320,
          child:
              !_showCongrats && !_showExtra
                  ? Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Hoşgeldiniz!',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _boyController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Boy (cm)',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Zorunlu alan'
                                      : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _kiloController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Kilo (kg)',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Zorunlu alan'
                                      : null,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _yasController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Yaş',
                            border: OutlineInputBorder(),
                          ),
                          validator:
                              (v) =>
                                  v == null || v.isEmpty
                                      ? 'Zorunlu alan'
                                      : null,
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Text('Cinsiyet: '),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: _cinsiyet,
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Kadın',
                                    child: Text('Kadın'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Erkek',
                                    child: Text('Erkek'),
                                  ),
                                ],
                                onChanged: (v) => setState(() => _cinsiyet = v),
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                ),
                                validator: (v) => v == null ? 'Seçiniz' : null,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ElevatedButton(
                          onPressed: _onContinue,
                          child: const Text(
                            'Devam',
                            style: TextStyle(color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size.fromHeight(44),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  )
                  : _showCongrats && !_showExtra
                  ? Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      Icon(Icons.emoji_emotions, color: Colors.green, size: 48),
                      SizedBox(height: 12),
                      Text(
                        'Aaa daha genç gösteriyorsun!',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  )
                  : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Ek Bilgi',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Hamile misiniz?'),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Evet'),
                              value: 'Evet',
                              groupValue: _hamilelik,
                              onChanged: (v) => setState(() => _hamilelik = v),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Hayır'),
                              value: 'Hayır',
                              groupValue: _hamilelik,
                              onChanged: (v) => setState(() => _hamilelik = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text('Özel bir durumunuz var mı?'),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Evet'),
                              value: 'Evet',
                              groupValue: _ozelDurum,
                              onChanged: (v) => setState(() => _ozelDurum = v),
                            ),
                          ),
                          Expanded(
                            child: RadioListTile<String>(
                              title: const Text('Hayır'),
                              value: 'Hayır',
                              groupValue: _ozelDurum,
                              onChanged: (v) => setState(() => _ozelDurum = v),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 18),
                      ElevatedButton(
                        onPressed: _onFinish,
                        child: const Text(
                          'Tamamla',
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          minimumSize: const Size.fromHeight(44),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
// ...existing code...

class Dashboard extends StatefulWidget {
  const Dashboard({Key? key}) : super(key: key);

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // AI görev ekleme kuyruğu

  // AI'ya sadece kan şekeri değeri prompt olarak gönderilecek, görev ekleme yok.

  // Kullanıcı bilgileri için değişkenler
  // String? _boy;
  // String? _kilo;
  // String? _yas;
  Widget _buildFooterIcon({
    required IconData icon,
    required String label,
    required Color color,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: color,
                  fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _selectedIndex = 0;
  final List<IconData> _icons = [
    Icons.home,
    Icons.calendar_today,
    Icons.calculate,
    Icons.bubble_chart,
  ];
  final List<String> _labels = ['Ev', 'Takvim', 'Hesap', 'AI'];
  final List<Color> _footerColors = [
    Color(0xFF43A047), // yeşil
    Color(0xFF1976D2), // mavi
    Color(0xFFF9A825), // sarı
    Color(0xFF8E24AA), // mor
  ];
  Color get _inactiveColor => Colors.grey.shade400;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showInitialDialog());
  }

  Future<void> _showInitialDialog() async {
    await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) => InitialInfoDialog(),
    );
  }

  // Ev sekmesi için model input formu
  final _carbController = TextEditingController();
  final _stepsController = TextEditingController();
  final _caloriesController = TextEditingController();
  final _heartRateController = TextEditingController();
  String? _predictionResult;
  bool _isLoading = false;
  String? _bolusInsulin;
  String? _basalInsulin;

  @override
  void dispose() {
    _carbController.dispose();
    _stepsController.dispose();
    _caloriesController.dispose();
    _heartRateController.dispose();
    super.dispose();
  }

  Widget _buildEvTab() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 320,
                child: Card(
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Kan Şekeri Tahmini',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
                          controller: _carbController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Karbonhidrat (g)',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _stepsController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Adım',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _caloriesController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Kalori',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _heartRateController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Nabız',
                            border: OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _onPredictPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            minimumSize: const Size.fromHeight(44),
                            foregroundColor: Colors.white,
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text(
                                    'Tahmin Et',
                                    style: TextStyle(color: Colors.white),
                                  ),
                        ),
                        const SizedBox(height: 10),
                        if (_predictionResult != null)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _predictionResult!,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(
                width: 320,
                child: Card(
                  color: Color(0xFFE3F2FD),
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.watch,
                              color: Color(0xFF1976D2),
                              size: 28,
                            ),
                            SizedBox(width: 10),
                            Text(
                              'Akıllı Saat ile Veri Çekme',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1976D2),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Yakında eklenecek',
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(width: 320, child: GlucoseWeeklyChartCard()),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _onPredictPressed() async {
    // 1. Bolus ve bazal insülin için modal dialog aç
    String? bolus;
    String? basal;
    final result = await showDialog<Map<String, String>>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('İnsülin Kullanımı'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Bolus insülin kullanıyor musunuz?'),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Evet'),
                          value: 'Evet',
                          groupValue: bolus,
                          onChanged: (v) => setState(() => bolus = v),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Hayır'),
                          value: 'Hayır',
                          groupValue: bolus,
                          onChanged: (v) => setState(() => bolus = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text('Bazal insülin kullanıyor musunuz?'),
                  Row(
                    children: [
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Evet'),
                          value: 'Evet',
                          groupValue: basal,
                          onChanged: (v) => setState(() => basal = v),
                        ),
                      ),
                      Expanded(
                        child: RadioListTile<String>(
                          title: const Text('Hayır'),
                          value: 'Hayır',
                          groupValue: basal,
                          onChanged: (v) => setState(() => basal = v),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (bolus != null && basal != null) {
                      Navigator.of(
                        context,
                      ).pop({'bolus': bolus!, 'basal': basal!});
                    }
                  },
                  child: const Text('Devam'),
                ),
              ],
            );
          },
        );
      },
    );
    if (result == null) return;
    _bolusInsulin = result['bolus'];
    _basalInsulin = result['basal'];

    setState(() {
      _isLoading = true;
      _predictionResult = null;
    });

    // 2. Inputları hazırla
    final carb = double.tryParse(_carbController.text) ?? 0.0;
    final steps = int.tryParse(_stepsController.text) ?? 0;
    final calories = double.tryParse(_caloriesController.text) ?? 0.0;
    final heartRate = int.tryParse(_heartRateController.text) ?? 0;
    final bolusVal = _bolusInsulin == 'Evet' ? 1.0 : 0.0;
    final basalVal = _basalInsulin == 'Evet' ? 1.0 : 0.0;

    // 3. Python backend API'ye istek at
    try {
      final uri = Uri.parse('http://127.0.0.1:5001/predict');
      print('API isteği gönderiliyor: $uri');
      print(
        'Veriler: {carb_input: $carb, steps: $steps, calories: $calories, heart_rate: $heartRate, bolus_volume_delivered: $bolusVal, basal_rate: $basalVal}',
      );
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'carb_input': carb,
          'steps': steps,
          'calories': calories,
          'heart_rate': heartRate,
          'bolus_volume_delivered': bolusVal,
          'basal_rate': basalVal,
        }),
      );
      print('API cevabı status: ${response.statusCode}');
      print('API cevabı body: ${response.body}');
      double? value;
      String aiBilgi = '';
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        final prediction = result['prediction'];
        value = double.tryParse(prediction.toString());
        if (value != null && value < 0) value = value.abs();
        setState(() {
          _isLoading = false;
          _predictionResult =
              value != null
                  ? 'Kan şekeri tahmini: ${value.toStringAsFixed(3)} mg/dL'
                  : null;
        });

        // AI yanıtı oluştur: Doktor rolünde, kan şekeri aralıklarına göre öneri
        if (value != null) {
          if (value < 70) {
            aiBilgi =
                'Kan şekeri tahmini: ${value.toStringAsFixed(3)} mg/dL\n\nDoktor: Hipoglisemi kritik! (Düşük kan şekeri) Lütfen acil olarak karbonhidrat alınız ve doktorunuza başvurunuz.';
          } else if (value >= 90 && value <= 100) {
            aiBilgi =
                'Kan şekeri tahmini: ${value.toStringAsFixed(3)} mg/dL\n\nDoktor: Hipoglisemiye yaklaşıyor. Kan şekeriniz düşük seviyeye yaklaşıyor, dikkatli olunuz.';
          } else if (value >= 150 && value <= 160) {
            aiBilgi =
                'Kan şekeri tahmini: ${value.toStringAsFixed(3)} mg/dL\n\nDoktor: Hiperglisemiye yaklaşıyor. Kan şekeriniz yüksek seviyeye yaklaşıyor, hareket ve su alımını artırınız.';
          } else if (value > 180 && value <= 250) {
            aiBilgi =
                'Kan şekeri tahmini: ${value.toStringAsFixed(3)} mg/dL\n\nDoktor: Hiperglisemi kritik! (Yüksek kan şekeri) Doktorunuza danışınız.';
          } else if (value > 250) {
            aiBilgi =
                'Kan şekeri tahmini: ${value.toStringAsFixed(3)} mg/dL\n\nDoktor: Hiperglisemi acil! (Çok yüksek kan şekeri) Hemen doktorunuza başvurunuz.';
          } else {
            aiBilgi =
                'Kan şekeri tahmini: ${value.toStringAsFixed(3)} mg/dL\n\nDoktor: Değerler normal aralıkta.';
          }
          // Tahmin ve AI yanıtını Hive'a kaydet
          var box = await Hive.openBox('glucose_predictions');
          final now = DateTime.now();
          await box.add({
            'tarih': now.toIso8601String(),
            'tahmin': value,
            'ai_cevap': aiBilgi,
          });

          setState(() {
            _selectedIndex = 3;
          });
          Future.delayed(const Duration(milliseconds: 300), () {
            showDialog(
              context: context,
              builder: (context) => AIChatDialog(initialMessage: aiBilgi),
            );
          });
        }
      } else {
        setState(() {
          _isLoading = false;
          _predictionResult = null;
        });
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _predictionResult = null;
      });
      print('Tahmin sırasında hata: $e');
    }
  }

  Widget _getBody() {
    // Takvim sekmesi açıldığında bekleyen görevleri ekle
    // WidgetsBinding.instance.addPostFrameCallback((_) {});
    switch (_selectedIndex) {
      case 0:
        return _buildEvTab();
      case 1:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: SizedBox(
              width: 320,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: GorevTakvim(key: GorevTakvim.globalKey),
                ),
              ),
            ),
          ),
        );
      case 2:
        return Padding(
          padding: const EdgeInsets.all(12),
          child: Center(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Yiyecek kalori cardı sol sütunda
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 320, child: FoodCalorieCard(small: true)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Sağda üstte spor, altında kamera cardı
                Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 320, child: SporCard(small: true)),
                      const SizedBox(height: 14),
                      Card(
                        color: const Color(0xFFFFF8E1),
                        elevation: 6,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: SizedBox(
                          width: 320,
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.camera_alt,
                                      size: 32,
                                      color: Color(0xFFF57C00),
                                    ),
                                    SizedBox(width: 12),
                                    Text(
                                      'Kamera ile Kalori Hesaplama',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFFF57C00),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 10),
                                Text(
                                  'Yakında',
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      case 3:
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Center(
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 48,
                      color: Color(0xFF8E24AA),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'AI Sohbet',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.chat),
                      label: const Text('Sohbeti Aç'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF8E24AA),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) => const AIChatDialog(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      default:
        return Center(child: Text('Dashboard içeriği buraya gelecek'));
    }
  }
  // Yiyecek Kalori Hesabı Card'ı

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(64),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF43A047), Color(0xFF1976D2)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.dashboard, color: Colors.white, size: 32),
                  const SizedBox(width: 10),
                  const Text(
                    'GlucoPredict',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () async {
                  var box = await Hive.openBox('users');
                  // Son giriş yapan kullanıcıyı bul (örnek: demo@gmail.com)
                  // Gerçek uygulamada oturum yönetimi ile alınmalı
                  final user = box.get('demo@gmail.com');
                  if (user == null) return;
                  showDialog(
                    context: context,
                    builder:
                        (context) => ProfilDialog(
                          ad: user['ad'] ?? '',
                          soyad: user['soyad'] ?? '',
                          email: user['email'] ?? '',
                          cinsiyet: user['cinsiyet'] ?? '',
                          boy: int.tryParse(user['boy']?.toString() ?? '') ?? 0,
                          kilo:
                              int.tryParse(user['kilo']?.toString() ?? '') ?? 0,
                          cikisCallback: () {
                            Navigator.of(context).pop();
                            Navigator.of(
                              context,
                              rootNavigator: true,
                            ).pushAndRemoveUntil(
                              MaterialPageRoute(
                                builder: (context) => const Giris(),
                              ),
                              (route) => false,
                            );
                          },
                        ),
                  );
                },
                child: CircleAvatar(
                  radius: 22,
                  backgroundColor: Colors.white,
                  backgroundImage: AssetImage('assets/profile.png'),
                ),
              ),
            ],
          ),
        ),
      ),
      body: _getBody(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(_icons.length, (index) {
            final isActive = _selectedIndex == index;
            final color = isActive ? _footerColors[index] : _inactiveColor;
            return _buildFooterIcon(
              icon: _icons[index],
              label: _labels[index],
              color: color,
              selected: isActive,
              onTap: () {
                setState(() {
                  _selectedIndex = index;
                });
                // Takvim sekmesine geçerken bekleyen görevleri ekle
                // if (index == 1) {
                //   WidgetsBinding.instance.addPostFrameCallback((_) {});
                // }
              },
            );
          }),
        ),
      ),
    );
  }
}
