import 'package:flutter/material.dart';
import 'gorev_model.dart';

class GorevTakvim extends StatefulWidget {
  static final GlobalKey<_GorevTakvimState> globalKey =
      GlobalKey<_GorevTakvimState>();
  const GorevTakvim({Key? key}) : super(key: key);
  @override
  State<GorevTakvim> createState() => _GorevTakvimState();

  /// Dışarıdan görev eklemek için statik fonksiyon
  static void disaridanGorevEkle(String baslik, GorevKategori kategori) {
    final state = globalKey.currentState;
    if (state != null) {
      state._disaridanGorevEkle(baslik, kategori);
    }
  }
}

class _GorevTakvimState extends State<GorevTakvim> {
  // Dışarıdan görev ekleme fonksiyonu
  void _disaridanGorevEkle(String baslik, GorevKategori kategori) {
    final yeniGorev = Gorev(
      baslik: baslik,
      kategori: kategori,
      eklenmeZamani: DateTime.now(),
    );
    setState(() {
      _gorevler.add(yeniGorev);
    });
    if (mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Görev takvime eklendi: $baslik')));
    }
  }

  final List<Gorev> _gorevler = [];
  final TextEditingController _controller = TextEditingController();
  GorevKategori? _seciliKategori;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _gorevEkle() {
    if (_controller.text.trim().isEmpty || _seciliKategori == null) return;
    final yeniGorev = Gorev(
      baslik: _controller.text.trim(),
      kategori: _seciliKategori!,
      eklenmeZamani: DateTime.now(),
    );
    setState(() {
      _gorevler.add(yeniGorev);
    });
    _controller.clear();
    _seciliKategori = null;
    // 15dk kala hatırlatma (örnek: debugPrint ile)
    Future.delayed(const Duration(minutes: 15), () {
      if (!_gorevler.contains(yeniGorev) || yeniGorev.tamamlandi) return;
      // Burada gerçek alarm/notification entegre edilebilir
      debugPrint('⏰ Görev için hatırlatma: ${yeniGorev.baslik}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('⏰ Görev zamanı yaklaşıyor: ${yeniGorev.baslik}'),
          ),
        );
      }
    });
  }

  void _gorevTamamla(int idx) {
    setState(() {
      _gorevler[idx].tamamlandi = true;
      _gorevler[idx].tamamlanmaZamani = DateTime.now();
    });
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _gorevler.removeAt(idx));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Görev Ekle',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: const InputDecoration(hintText: 'Görev başlığı'),
                ),
              ),
              const SizedBox(width: 10),
              DropdownButton<GorevKategori>(
                value: _seciliKategori,
                hint: const Text('Kategori'),
                items:
                    GorevKategori.values.map((k) {
                      return DropdownMenuItem(
                        value: k,
                        child: Text(
                          '${kategoriEmoji(k)} ${k.name[0].toUpperCase()}${k.name.substring(1)}',
                        ),
                      );
                    }).toList(),
                onChanged: (v) => setState(() => _seciliKategori = v),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: _gorevEkle,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                child: const Text('Ekle'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Aktif Görevler',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Expanded(
            child:
                _gorevler.isEmpty
                    ? const Center(child: Text('Henüz görev yok.'))
                    : ListView.builder(
                      itemCount: _gorevler.length,
                      itemBuilder: (context, i) {
                        final g = _gorevler[i];
                        if (g.tamamlandi) return const SizedBox.shrink();
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            vertical: 3,
                            horizontal: 2,
                          ),
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ListTile(
                            leading: Text(
                              kategoriEmoji(g.kategori),
                              style: const TextStyle(fontSize: 22),
                            ),
                            title: Text(
                              g.baslik,
                              style: const TextStyle(fontSize: 14),
                            ),
                            subtitle: Text(
                              'Eklendi: ${g.eklenmeZamani.hour.toString().padLeft(2, '0')}:${g.eklenmeZamani.minute.toString().padLeft(2, '0')}',
                              style: const TextStyle(fontSize: 12),
                            ),
                            trailing: Checkbox(
                              value: g.tamamlandi,
                              onChanged: (_) => _gorevTamamla(i),
                            ),
                          ),
                        );
                      },
                    ),
          ),
        ],
      ),
    );
  }
}
