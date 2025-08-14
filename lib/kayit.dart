import 'package:flutter/material.dart';

import 'giris.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Kayit extends StatefulWidget {
  const Kayit({super.key});

  @override
  State<Kayit> createState() => _KayitState();
}

class _KayitState extends State<Kayit> {
  Future<bool> _kayitOl({
    required String ad,
    required String soyad,
    required String email,
    required String sifre,
    required String cinsiyet,
  }) async {
    var box = await Hive.openBox('users');
    if (box.containsKey(email)) return false;
    final hash = sha256.convert(utf8.encode(sifre)).toString();
    await box.put(email, {
      'ad': ad,
      'soyad': soyad,
      'email': email,
      'passwordHash': hash,
      'cinsiyet': cinsiyet,
    });
    return true;
  }
  // Profil fotoğrafı kaldırıldı, kayıt sırasında alınmayacak.

  final _adController = TextEditingController();
  final _soyadController = TextEditingController();
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  final _sifreTekrarController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _sifreGizle = true;
  bool _sifreTekrarGizle = true;
  String? _cinsiyet = 'Erkek';

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final ad = _adController.text.trim();
    final soyad = _soyadController.text.trim();
    final email = _emailController.text.trim();
    final sifre = _sifreController.text;
    final sifreTekrar = _sifreTekrarController.text;
    final cinsiyet = _cinsiyet ?? 'Erkek';
    if (sifre != sifreTekrar) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Şifreler eşleşmiyor!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final basarili = await _kayitOl(
      ad: ad,
      soyad: soyad,
      email: email,
      sifre: sifre,
      cinsiyet: cinsiyet,
    );
    if (basarili) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kayıt başarılı! Giriş yapabilirsiniz.'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Giris()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bu e-posta ile kayıtlı kullanıcı var!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5FFF7),
      // AppBar yok, sadece body
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 32,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        const Text(
                          'Kayıt Ol',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF2D3E27),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        _buildTextField(
                          controller: _adController,
                          labelText: 'Ad',
                          icon: Icons.person,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _soyadController,
                          labelText: 'Soyad',
                          icon: Icons.person_outline,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _emailController,
                          labelText: 'E-posta',
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _sifreController,
                          labelText: 'Şifre',
                          icon: Icons.lock,
                          obscureText: _sifreGizle,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _sifreGizle
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF6B8E5A),
                            ),
                            onPressed: () {
                              setState(() {
                                _sifreGizle = !_sifreGizle;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildTextField(
                          controller: _sifreTekrarController,
                          labelText: 'Şifre Tekrar',
                          icon: Icons.lock_outline,
                          obscureText: _sifreTekrarGizle,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _sifreTekrarGizle
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: const Color(0xFF6B8E5A),
                            ),
                            onPressed: () {
                              setState(() {
                                _sifreTekrarGizle = !_sifreTekrarGizle;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Erkek'),
                                value: 'Erkek',
                                groupValue: _cinsiyet,
                                activeColor: Color(0xFF43A047),
                                onChanged: (value) {
                                  setState(() {
                                    _cinsiyet = value;
                                  });
                                },
                              ),
                            ),
                            Expanded(
                              child: RadioListTile<String>(
                                title: const Text('Kadın'),
                                value: 'Kadın',
                                groupValue: _cinsiyet,
                                activeColor: Color(0xFF43A047),
                                onChanged: (value) {
                                  setState(() {
                                    _cinsiyet = value;
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF43A047),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            onPressed: _handleRegister,
                            child: const Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Giris(),
                              ),
                            );
                          },
                          child: const Text(
                            'Zaten hesabın var mı? Giriş Yap',
                            style: TextStyle(color: Color(0xFF43A047)),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  // ...existing code...

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8F5E8), width: 1),
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: labelText,
          prefixIcon: Icon(icon, color: const Color(0xFF6B8E5A)),
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
          labelStyle: const TextStyle(color: Color(0xFF6B8E5A)),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _adController.dispose();
    _soyadController.dispose();
    _emailController.dispose();
    _sifreController.dispose();
    _sifreTekrarController.dispose();
    super.dispose();
  }
}
