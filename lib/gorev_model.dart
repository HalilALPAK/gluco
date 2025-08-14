import 'package:flutter/material.dart';

enum GorevKategori { spor, yuruyus, yemek, ilac }

class Gorev {
  String baslik;
  GorevKategori kategori;
  DateTime eklenmeZamani;
  bool tamamlandi;
  DateTime? tamamlanmaZamani;
  Gorev({
    required this.baslik,
    required this.kategori,
    required this.eklenmeZamani,
    this.tamamlandi = false,
    this.tamamlanmaZamani,
  });
}

String kategoriEmoji(GorevKategori kategori) {
  switch (kategori) {
    case GorevKategori.spor:
      return '🏋️';
    case GorevKategori.yuruyus:
      return '🚶';
    case GorevKategori.yemek:
      return '🍽️';
    case GorevKategori.ilac:
      return '💊';
  }
}
