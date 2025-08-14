import 'package:flutter/material.dart';
import 'dart:io' as io;
import 'package:image_picker/image_picker.dart';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'kullanicilar.dart';

class ProfilDialog extends StatefulWidget {
  final VoidCallback? cikisCallback;
  final String ad;
  final String soyad;
  final String email;
  final String cinsiyet;
  final int boy;
  final int kilo;
  final String? profilFotoPath;
  final String? profilFotoUrl;

  const ProfilDialog({
    Key? key,
    required this.ad,
    required this.soyad,
    required this.email,
    required this.cinsiyet,
    required this.boy,
    required this.kilo,
    this.profilFotoPath,
    this.profilFotoUrl,
    this.cikisCallback,
  }) : super(key: key);

  @override
  State<ProfilDialog> createState() => _ProfilDialogState();
}

class _ProfilDialogState extends State<ProfilDialog> {
  late String ad;
  late String soyad;
  late String email;
  late String cinsiyet;
  late int boy;
  late int kilo;
  String? profilFotoPath;
  String? profilFotoUrl;
  Uint8List? profilFotoBytes; // Web için
  bool duzenleModu = false;

  @override
  void initState() {
    super.initState();
    ad = widget.ad;
    soyad = widget.soyad;
    email = widget.email;
    cinsiyet = widget.cinsiyet;
    boy = widget.boy;
    kilo = widget.kilo;
    profilFotoPath = widget.profilFotoPath;
    profilFotoUrl = widget.profilFotoUrl;
    profilFotoBytes = null;
  }

  void _kaydetVeKapat() {
    // Son kullanıcıya güncel bilgileri kaydet
    if (KullaniciVeritabani.kullanicilar.isNotEmpty) {
      final sonKullanici = KullaniciVeritabani.kullanicilar.last;
      sonKullanici.ad = ad;
      sonKullanici.soyad = soyad;
      sonKullanici.email = email;
      sonKullanici.cinsiyet = cinsiyet;
      sonKullanici.boy = boy;
      sonKullanici.kilo = kilo;
      sonKullanici.profilFotoPath = profilFotoPath;
      sonKullanici.profilFotoBytes = profilFotoBytes;
    }
    Navigator.pop(context);
  }

  Future<void> _profilFotoSec() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      if (kIsWeb) {
        final bytes = await picked.readAsBytes();
        setState(() {
          profilFotoBytes = bytes;
          profilFotoPath = null;
          profilFotoUrl = null;
        });
        // KullaniciVeritabani'ndaki son kullanıcıya kaydet
        if (KullaniciVeritabani.kullanicilar.isNotEmpty) {
          final sonKullanici = KullaniciVeritabani.kullanicilar.last;
          sonKullanici.profilFotoBytes = bytes;
          sonKullanici.profilFotoPath = null;
        }
      } else {
        setState(() {
          profilFotoPath = picked.path;
          profilFotoUrl = null;
          profilFotoBytes = null;
        });
        if (KullaniciVeritabani.kullanicilar.isNotEmpty) {
          final sonKullanici = KullaniciVeritabani.kullanicilar.last;
          sonKullanici.profilFotoPath = picked.path;
          sonKullanici.profilFotoBytes = null;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double avatarSize = 96;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.grey[200],
                    ),
                    clipBehavior: Clip.antiAlias,
                    child:
                        !kIsWeb
                            ? (profilFotoPath != null &&
                                    io.File(profilFotoPath!).existsSync()
                                ? Image.file(
                                  io.File(profilFotoPath!),
                                  fit: BoxFit.cover,
                                )
                                : (profilFotoUrl != null
                                    ? Image.network(
                                      profilFotoUrl!,
                                      fit: BoxFit.cover,
                                    )
                                    : Image.asset(
                                      'assets/default_profile.png',
                                      fit: BoxFit.cover,
                                    )))
                            : (profilFotoBytes != null
                                ? Image.memory(
                                  profilFotoBytes!,
                                  fit: BoxFit.cover,
                                )
                                : Icon(
                                  Icons.person,
                                  size: avatarSize * 0.7,
                                  color: Colors.grey,
                                )),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: duzenleModu ? _profilFotoSec : null,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(6),
                        child: Icon(
                          Icons.camera_alt,
                          color: duzenleModu ? Colors.green : Colors.grey,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // ...butonlar üstte olmayacak...
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Profil Bilgileri',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(
                      Icons.edit,
                      color: duzenleModu ? Colors.green : Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        duzenleModu = !duzenleModu;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _profilSatir(
                'Ad',
                ad,
                duzenleModu,
                (v) => setState(() => ad = v),
              ),
              _profilSatir(
                'Soyad',
                soyad,
                duzenleModu,
                (v) => setState(() => soyad = v),
              ),
              _profilSatir('Email', email, false, null),
              _profilSatir(
                'Cinsiyet',
                cinsiyet,
                duzenleModu,
                (v) => setState(() => cinsiyet = v),
              ),
              _profilSatir(
                'Boy',
                boy.toString(),
                duzenleModu,
                (v) => setState(() => boy = int.tryParse(v) ?? boy),
              ),
              _profilSatir(
                'Kilo',
                kilo.toString(),
                duzenleModu,
                (v) => setState(() => kilo = int.tryParse(v) ?? kilo),
              ),
              const SizedBox(height: 20),
              if (widget.cikisCallback != null) ...[
                ElevatedButton(
                  onPressed: _kaydetVeKapat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF43A047),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 12,
                    ),
                  ),
                  child: const Text(
                    'Kaydet',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  icon: const Icon(Icons.logout),
                  label: const Text('Çıkış Yap'),
                  onPressed: widget.cikisCallback,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _profilSatir(
    String label,
    String value,
    bool editable,
    ValueChanged<String>? onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 90,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          const SizedBox(width: 8),
          if (editable && onChanged != null)
            Expanded(
              child: TextFormField(
                initialValue: value,
                onChanged: onChanged,
                decoration: const InputDecoration(
                  isDense: true,
                  border: OutlineInputBorder(),
                ),
              ),
            )
          else
            Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }
}
