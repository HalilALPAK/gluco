import 'gorev_takvim.dart';
import 'gorev_model.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage(this.text, this.isUser);
}

class AIChatDialog extends StatefulWidget {
  final String? initialMessage;
  const AIChatDialog({Key? key, this.initialMessage}) : super(key: key);

  @override
  State<AIChatDialog> createState() => _AIChatDialogState();
}

class _AIChatDialogState extends State<AIChatDialog> {
  void _addDoctorTask() {
    const String doctorTask = 'Doktora görün 👨‍⚕️';
    GorevTakvim.disaridanGorevEkle(doctorTask, GorevKategori.ilac);
  }

  Future<void> _sendInitialMessage(String text) async {
    setState(() {
      _loading = true;
    });
    try {
      final res = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": text},
              ],
            },
          ],
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final reply =
            data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ??
            "🤖 Yanıt alınamadı.";
        setState(() {
          _messages.add(_ChatMessage(reply, false));
        });
        // Sadeleştirme ve öneri kontrolü
        final lower = reply.toLowerCase();
        if (lower.contains("şeker") ||
            lower.contains("yemek") ||
            lower.contains("ilaç") ||
            lower.contains("spor") ||
            lower.contains("yürüyüş")) {
          final firstLine = reply.split('\n').first;
          _showAddToCalendarDialog(firstLine);
        }
      } else {
        setState(() {
          _messages.add(
            _ChatMessage("❌ Hata: ${res.statusCode}\n${res.body}", false),
          );
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage("❌ Ağ hatası: $e", false));
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showAddToCalendarDialog(String task) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text("AI Önerisi"),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(task),
                const SizedBox(height: 16),
                const Text('...görevini ekleyelim mi?'),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  icon: Icon(Icons.local_hospital, color: Colors.blue),
                  label: const Text('Doktora görün 👨‍⚕️'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                  ),
                  onPressed: () {
                    _addDoctorTask();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Hayır"),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () {
                  // Kategori tespiti
                  GorevKategori kategori = GorevKategori.yemek;
                  final lower = task.toLowerCase();
                  if (lower.contains("ilaç"))
                    kategori = GorevKategori.ilac;
                  else if (lower.contains("spor"))
                    kategori = GorevKategori.spor;
                  else if (lower.contains("yürüyüş"))
                    kategori = GorevKategori.yuruyus;
                  else if (lower.contains("yemek") || lower.contains("şeker"))
                    kategori = GorevKategori.yemek;
                  final state = GorevTakvim.globalKey.currentState;
                  if (state != null) {
                    GorevTakvim.disaridanGorevEkle(task, kategori);
                    Navigator.pop(context);
                  } else {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Takvim aktif değil, görev eklenemedi!'),
                      ),
                    );
                  }
                },
                child: const Text("Evet"),
              ),
            ],
          ),
    );
  }

  final TextEditingController _controller = TextEditingController();
  final List<_ChatMessage> _messages = [];
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialMessage != null && widget.initialMessage!.isNotEmpty) {
      _messages.add(_ChatMessage(widget.initialMessage!, true));
      // Sade ve tek tip öneri prompt'u
      String prompt = widget.initialMessage!;
      final regex = RegExp(r'Kan şekeri tahmini: ([\d\.]+) mg/dL');
      final match = regex.firstMatch(prompt);
      if (match != null) {
        final value = double.tryParse(match.group(1)!);
        if (value != null) {
          prompt =
              "Kan şekeri tahmini: ${value.toStringAsFixed(2)} mg/dL. Doktorsun, ne önerirsin? Sadece öneride bulun, kısa ve sade yaz.";
        }
      }
      Future.delayed(
        Duration(milliseconds: 300),
        () => _sendInitialMessage(prompt),
      );
    }
  }

  static const String apiKey = "AIzaSyD4kfYS0VvrckeS8rNo8DvWn_BXiziy0e4";
  static const String model = "gemini-1.5-flash-latest";
  static const String endpoint =
      "https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey";

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(_ChatMessage(text, true));
      _loading = true;
      _controller.clear();
    });
    try {
      final res = await http.post(
        Uri.parse(endpoint),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "contents": [
            {
              "role": "user",
              "parts": [
                {"text": text},
              ],
            },
          ],
        }),
      );
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final reply =
            data["candidates"]?[0]?["content"]?["parts"]?[0]?["text"] ??
            "🤖 Yanıt alınamadı.";
        setState(() {
          _messages.add(_ChatMessage(reply, false));
        });
        // Sadeleştirme ve öneri kontrolü
        final lower = reply.toLowerCase();
        if (lower.contains("şeker") ||
            lower.contains("yemek") ||
            lower.contains("ilaç") ||
            lower.contains("spor") ||
            lower.contains("yürüyüş")) {
          final firstLine = reply.split('\n').first;
          _showAddToCalendarDialog(firstLine);
        }
      } else {
        setState(() {
          _messages.add(
            _ChatMessage("❌ Hata: ${res.statusCode}\n${res.body}", false),
          );
        });
      }
    } catch (e) {
      setState(() {
        _messages.add(_ChatMessage("❌ Ağ hatası: $e", false));
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '🤖 Gemini Flash Chat',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
            const SizedBox(height: 10),
            Container(
              height: 300,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                itemCount: _messages.length,
                itemBuilder: (context, i) {
                  final m = _messages[i];
                  return Align(
                    alignment:
                        m.isUser ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(
                        vertical: 4,
                        horizontal: 8,
                      ),
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: m.isUser ? Colors.green[100] : Colors.blue[50],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(m.text),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Bir şeyler yaz...',
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon:
                      _loading
                          ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.send, color: Colors.green),
                  onPressed: _loading ? null : _sendMessage,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
