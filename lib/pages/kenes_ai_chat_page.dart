// lib/pages/kenes_ai_chat_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class KenesAIChatPage extends StatefulWidget {
  const KenesAIChatPage({super.key});

  @override
  State<KenesAIChatPage> createState() => _KenesAIChatPageState();
}

class _KenesAIChatPageState extends State<KenesAIChatPage> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;

  // Безопасно берём ключ из .env
  String get _apiKey => dotenv.env['GROK_API_KEY'] ?? '';

  Future<void> _sendMessage(String text) async {
    if (text.trim().isEmpty || _isLoading || _apiKey.isEmpty) {
      if (_apiKey.isEmpty) {
        _addError("GROK API кілті табылмады. .env файлын тексеріңіз.");
      }
      return;
    }

    setState(() {
      _messages.add({"role": "user", "content": text});
      _isLoading = true;
    });
    _controller.clear();
    _scrollToBottom();

    try {
      final response = await http.post(
        Uri.parse("https://api.x.ai/v1/chat/completions"),
        headers: {
          "Authorization": "Bearer $_apiKey",
          "Content-Type": "application/json",
        },
        body: jsonEncode({
          "model": "grok-beta",
          "messages": [
            {
              "role": "system",
              "content":
                  "Сен — KenesAI, қазақша сөйлейтін мейірімді медициналық ИИ-дәрігерсің. Науқасқа қамқор бол, қазақша ғана жауап бер, дәрі жазба, тек кеңес бер."
            },
            ..._messages.map((m) => {"role": m["role"], "content": m["content"]}),
          ],
          "temperature": 0.7,
          "max_tokens": 1024,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        final reply = data["choices"][0]["message"]["content"] as String;

        setState(() {
          _messages.add({"role": "assistant", "content": reply});
          _isLoading = false;
        });
      } else {
        _addError("Сервер қатесі: ${response.statusCode}");
      }
    } catch (e) {
      _addError("Интернетті тексеріңіз");
    }
    _scrollToBottom();
  }

  void _addError(String error) {
    setState(() {
      _messages.add({"role": "assistant", "content": "Қате: $error"});
      _isLoading = false;
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.smart_toy_outlined, size: 40, color: const Color(0xFF06B6D4)),
            const SizedBox(width: 12),
            Text("KenesAI", style: GoogleFonts.inter(fontWeight: FontWeight.bold, color: const Color(0xFF06B6D4))),
          ],
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.smart_toy, size: 100, color: const Color(0xFF06B6D4).withOpacity(0.5)),
                        const SizedBox(height: 20),
                        Text(
                          "Сәлем! Мен KenesAI — сенің жеке ИИ-дәрігеріңмін.\nСимптомдарыңды айт, көмектесейін!",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.manrope(fontSize: 18, color: Colors.white70),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length + (_isLoading ? 1 : 0),
                    itemBuilder: (context, i) {
                      if (i == _messages.length && _isLoading) {
                        return const Align(
                          alignment: Alignment.centerLeft,
                          child: Padding(
                            padding: EdgeInsets.all(8),
                            child: SizedBox(width: 30, height: 30, child: CircularProgressIndicator(color: Color(0xFF06B6D4), strokeWidth: 2)),
                          ),
                        );
                      }
                      final msg = _messages[i];
                      final isUser = msg["role"] == "user";
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          padding: const EdgeInsets.all(16),
                          constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),
                          decoration: BoxDecoration(
                            color: isUser ? const Color(0xFF06B6D4) : const Color(0xFF1E293B),
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Text(
                            msg["content"]!,
                            style: GoogleFonts.manrope(fontSize: 16, color: Colors.white),
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Поле ввода
          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              decoration: const BoxDecoration(
                color: Color(0xFF1E293B),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Симптомдарды сипаттаңыз...",
                        hintStyle: GoogleFonts.manrope(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF334155),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                      ),
                      onSubmitted: (_) => _sendMessage(_controller.text),
                    ),
                  ),
                  const SizedBox(width: 12),
                  FloatingActionButton(
                    backgroundColor: const Color(0xFF06B6D4),
                    onPressed: () => _sendMessage(_controller.text),
                    child: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}