import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'giris.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  var box = await Hive.openBox('users');
  // Demo kullanıcıyı ekle (eğer yoksa)
  if (!box.containsKey('demo@gmail.com')) {
    final passwordHash = sha256.convert(utf8.encode('123456')).toString();
    await box.put('demo@gmail.com', {
      'email': 'demo@gmail.com',
      'passwordHash': passwordHash,
      'ad': 'Demo',
      'soyad': 'Kullanıcı',
      'cinsiyet': 'Erkek',
    });
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Giris(), debugShowCheckedModeBanner: false);
  }
}
