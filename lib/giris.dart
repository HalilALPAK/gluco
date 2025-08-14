import 'package:flutter/material.dart';

import 'dashboard.dart';
import 'kayit.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';
import 'package:crypto/crypto.dart';

class Giris extends StatefulWidget {
  const Giris({super.key});

  @override
  State<Giris> createState() => _GirisState();
}

class _GirisState extends State<Giris> {
  final _emailController = TextEditingController();
  final _sifreController = TextEditingController();
  bool _sifreGizle = true;
  bool _beniHatirla = false;

  Future<bool> _girisYap(String email, String sifre) async {
    var box = await Hive.openBox('users');
    if (!box.containsKey(email)) return false;
    final user = box.get(email);
    final hash = sha256.convert(utf8.encode(sifre)).toString();
    return user['passwordHash'] == hash;
  }

  void _handleLogin() async {
    final email = _emailController.text.trim();
    final sifre = _sifreController.text;
    if (email.isEmpty || sifre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen tüm alanları doldurun!'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    final basarili = await _girisYap(email, sifre);
    if (basarili) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Giriş başarılı! Hoş geldin 🌱'),
          backgroundColor: Color(0xFF6B8E5A),
        ),
      );
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const Dashboard()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-posta veya şifre hatalı!'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double contentWidth = screenWidth < 500 ? screenWidth * 0.95 : 400;
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFE8F5E8), Color(0xFFF0F8F0), Color(0xFFFFFFFF)],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: contentWidth),
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: screenWidth < 500 ? 8 : 24,
                    vertical: 24,
                  ),
                  child: Column(
                    children: [
                      // Kartın üstüne küçük logo ve isim
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: const Color(0xFF6B8E5A),
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF6B8E5A,
                                  ).withOpacity(0.15),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.eco,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'GlucoPredict',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2D3E27),
                              letterSpacing: 1.1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Giriş kartı
                      Container(
                        constraints: const BoxConstraints(maxWidth: 400),
                        child: Card(
                          elevation: 15,
                          shadowColor: const Color(0xFF6B8E5A).withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(24),
                              color: Colors.white,
                            ),
                            padding: const EdgeInsets.all(32.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // Başlık
                                const Text(
                                  'Hoş Geldin!',
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF2D3E27),
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Hesabınıza giriş yapın',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey[600],
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 32),

                                // E-posta alanı
                                _buildTextField(
                                  controller: _emailController,
                                  labelText: 'E-posta',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                ),
                                const SizedBox(height: 20),

                                // Şifre alanı
                                _buildTextField(
                                  controller: _sifreController,
                                  labelText: 'Şifre',
                                  icon: Icons.lock_outline,
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
                                const SizedBox(height: 20),

                                // Beni hatırla ve şifremi unuttum
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: 20,
                                          height: 20,
                                          child: Checkbox(
                                            value: _beniHatirla,
                                            onChanged: (value) {
                                              setState(() {
                                                _beniHatirla = value ?? false;
                                              });
                                            },
                                            activeColor: const Color(
                                              0xFF6B8E5A,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(4),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Beni hatırla',
                                          style: TextStyle(
                                            color: Color(0xFF6B8E5A),
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        // Şifremi unuttum işlemi
                                      },
                                      child: const Text(
                                        'Şifremi Unuttum?',
                                        style: TextStyle(
                                          color: Color(0xFF6B8E5A),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 32),

                                // Giriş yap butonu
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF6B8E5A),
                                        Color(0xFF8FA876),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    boxShadow: [
                                      BoxShadow(
                                        color: const Color(
                                          0xFF6B8E5A,
                                        ).withOpacity(0.3),
                                        blurRadius: 12,
                                        offset: const Offset(0, 6),
                                      ),
                                    ],
                                  ),
                                  child: ElevatedButton(
                                    onPressed: _handleLogin,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: const Text(
                                      'Giriş Yap',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Sosyal medya giriş ayırıcısı
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Text(
                                        'veya',
                                        style: TextStyle(
                                          color: Colors.grey[600],
                                          fontSize: 14,
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: 1,
                                        color: Colors.grey[300],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 24),

                                // Sosyal medya butonları
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildSocialButton(
                                        icon: Icons.g_mobiledata,
                                        label: 'Google',
                                        onPressed: () {
                                          // Google ile giriş
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: _buildSocialButton(
                                        icon: Icons.facebook,
                                        label: 'Facebook',
                                        onPressed: () {
                                          // Facebook ile giriş
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Kayıt ol bağlantısı
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Hesabınız yok mu? ',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 16,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const Kayit(),
                                ),
                              );
                            },
                            child: const Text(
                              'Kayıt Ol',
                              style: TextStyle(
                                color: Color(0xFF6B8E5A),
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                    ],
                  ), // Column
                ), // Padding
              ), // ConstrainedBox
            ), // SingleChildScrollView
          ),
        ), // Center
      ), // SafeArea
    ); // Container
  }
}

Widget _buildTextField({
  required TextEditingController controller,
  required String labelText,
  required IconData icon,
  bool obscureText = false,
  Widget? suffixIcon,
  TextInputType? keyboardType,
}) {
  return TextFormField(
    controller: controller,
    obscureText: obscureText,
    keyboardType: keyboardType,
    decoration: InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: const Color(0xFF6B8E5A)),
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE8F5E8), width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFE8F5E8), width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFF6B8E5A), width: 2),
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAF8),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      labelStyle: const TextStyle(color: Color(0xFF6B8E5A)),
    ),
  );
}

Widget _buildSocialButton({
  required IconData icon,
  required String label,
  required VoidCallback onPressed,
}) {
  return Container(
    height: 48,
    decoration: BoxDecoration(
      color: const Color(0xFFF8FAF8),
      borderRadius: BorderRadius.circular(12),
    ),
    child: InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: const Color(0xFF43A047)),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF43A047),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
