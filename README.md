# Glukoz Sağlık Paneli

Bu proje Flutter ile geliştirilmiş bir sağlık takip uygulamasıdır. Kullanıcılar kan şekeri, yiyecek kalori, spor ve AI destekli öneriler alabilir.

## Özellikler

- Haftalık kan şekeri grafiği
- Yiyecek kalori ve besin değerleri sorgulama
- Spor ve aktivite takibi
- AI ile doktor rolünde öneriler
- Hive ile güvenli kullanıcı yönetimi
- Kamera ile kalori hesaplama (yakında)

## Kurulum

1. `pubspec.yaml` ile bağımlılıkları yükleyin
2. Python backend için `food_api_server.py` dosyasını çalıştırın
3. Flutter uygulamasını başlatın

## API Koruma

API endpointleri sadece yetkili kullanıcılar tarafından erişilebilir olmalıdır. Gerekirse JWT veya API anahtarı ile koruma ekleyin.

## Ekran Görüntüleri

Giriş Ekranı:
![Giriş Ekranı](screenshots/giris.png)

Dashboard:
![Dashboard](screenshots/dashboard.png)

Haftalık Grafik:
![Haftalık Grafik](screenshots/grafik.png)

## Demo Kullanıcı

Kullanıcı: demo@gmail.com
Şifre: 123456

## Katkı

Katkı sağlamak için pull request gönderebilirsiniz.

# odev

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
