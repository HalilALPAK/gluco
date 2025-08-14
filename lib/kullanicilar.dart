import 'dart:typed_data';

class Kullanici {
  String ad;
  String soyad;
  String email;
  String cinsiyet;
  int boy;
  int kilo;
  String? profilFotoPath;
  Uint8List? profilFotoBytes; // Web için

  Kullanici({
    required this.ad,
    required this.soyad,
    required this.email,
    required this.cinsiyet,
    required this.boy,
    required this.kilo,
    this.profilFotoPath,
    this.profilFotoBytes,
  });
}

class KullaniciVeritabani {
  static final List<Kullanici> _kullanicilar = [];

  static void ekle(Kullanici kullanici) {
    _kullanicilar.add(kullanici);
  }

  static List<Kullanici> get kullanicilar => _kullanicilar;
}
