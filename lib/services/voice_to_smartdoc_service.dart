// lib/services/voice_to_smartdoc_service.dart — 100% РАБОТАЕТ НА iOS (ДЕКАБРЬ 2025)
import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:medkenes/pages/smartdoc_preview_page.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class VoiceToSmartDocService {
  static final AudioRecorder _recorder = AudioRecorder();
  static String? _audioPath;

  static Future<bool> startRecordingAndWaitForRelease({
    required BuildContext context,
    required String patientId,
    required String patientName,
  }) async {
    if (!await _recorder.hasPermission()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Микрофонға рұқсат жоқ"), backgroundColor: Colors.red),
      );
      return false;
    }

    final dir = await getTemporaryDirectory();
    _audioPath = '${dir.path}/smartdoc_${DateTime.now().millisecondsSinceEpoch}.wav';

    await _recorder.start(
      const RecordConfig(
        encoder: AudioEncoder.wav,      // ← ВОТ ГЛАВНОЕ — WAV!
        sampleRate: 16000,
        numChannels: 1,
      ),
      path: _audioPath!,
    );
    return true;
  }

  static Future<void> stopRecordingAndProcess({
    required BuildContext context,
    required String patientId,
    required String patientName,
    required Map<String, dynamic> patientData,
  }) async {
    if (_audioPath == null) return;

    await _recorder.stop();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Анализ..."), backgroundColor: Colors.orange),
    );

    final result = await _transcribeAndGenerate(patientData, _audioPath!);

    if (!context.mounted) return;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    if (result == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Транскрипция сәтсіз"), backgroundColor: Colors.red),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SmartDocPreviewPage(
          patientId: patientId,
          patientName: patientName,
          generatedText: result,
        ),
      ),
    );
  }

  static Future<String?> _transcribeAndGenerate(
    Map<String, dynamic> patientData,
    String audioPath,
  ) async {
    final key = dotenv.env['OPENAI_API_KEY'];
    if (key == null) return "OPENAI_API_KEY жоқ";

    print("Отправляем файл: $audioPath (${await File(audioPath).length()} байт)");

    final request = http.MultipartRequest('POST', Uri.parse('https://api.openai.com/v1/audio/transcriptions'))
      ..headers['Authorization'] = 'Bearer $key'
      ..fields['model'] = 'whisper-1'
      ..files.add(await http.MultipartFile.fromPath('file', audioPath, filename: 'audio.wav'));

    try {
      final response = await request.send().timeout(const Duration(seconds: 90));
      final body = await response.stream.bytesToString();
      print("OpenAI ответ: ${response.statusCode}");
      print(body);

      if (response.statusCode == 200) {
        final json = jsonDecode(body);
        final text = json['text'] as String? ?? '';

        print("=== WHISPER СЛЫШАЛ ===");
        print(text.isEmpty ? "[ТИШИНА ИЛИ ПУСТО]" : text);
        print("=== КОНЕЦ ===");

        if (text.trim().isEmpty) {
          return "Дәрігер ештеңе айтпады немесе дыбыс тым әлсіз";
        }

        return await _generateWithPatientInfo(text, patientData);
      } else {
        return "Whisper қатесі: ${response.statusCode}\n$body";
      }
    } catch (e) {
      print("Исключение: $e");
      return "Қате: $e";
    }
  }

  static Future<String> _generateWithPatientInfo(String rawText, Map<String, dynamic> patientData) async {
  // БОЛЬШЕ НЕ ДОБАВЛЯЕМ НИКАКИХ ПАЦИЕНТСКИХ ДАННЫХ СЮДА!
  // Всё это будет в PDF через PdfService, красиво и один раз.

  final grokResponse = await http.post(
    Uri.parse("https://api.x.ai/v1/chat/completions"),
    headers: {
      "Authorization": "Bearer ${dotenv.env['GROK_API_KEY']}",
      "Content-Type": "application/json",
    },
    body: jsonEncode({
      "model": "grok-4-1-fast-reasoning",
      "temperature": 0.1,
      "messages": [
        {
          "role": "system",
          "content": """
Ты — KenesAI, ассистент врача.
Тебе дана диктовка врача.
Твоя задача — вернуть ТОЛЬКО медицинскую часть в таком виде:

ЖАЛОБЫ: ...
АНАМНЕЗ: ...
ОБЪЕКТИВНО: ...
ДИАГНОЗ: ...
РЕКОМЕНДАЦИИ: ...
ПРИМЕЧАНИЕ: ...

НИЧЕГО НЕ ПРИДУМЫВАЙ. Если врач не сказал — оставь пустым.
Не пиши ФИО, возраст, телефон, дату — это будет добавлено автоматически.
Пиши только на казахском или русском — как говорил врач.
"""
        },
        {"role": "user", "content": "Диктовка врача:\n$rawText"}
      ]
    }),
  );

  if (grokResponse.statusCode == 200) {
    final json = jsonDecode(utf8.decode(grokResponse.bodyBytes));
    final content = json["choices"][0]["message"]["content"] as String;
    return content.trim();
  }

  return "ЖАЛОБЫ: —\nАНАМНЕЗ: —\nОБЪЕКТИВНО: —\nДИАГНОЗ: —\nРЕКОМЕНДАЦИИ: —";
}

  static Future<bool> saveSmartDoc({
    required String patientId,
    required String patientName,
    required String content,
  }) async {
    try {
      await FirebaseFirestore.instance.collection('smartdocs').add({
        'patientId': patientId,
        'patientName': patientName,
        'doctorId': FirebaseAuth.instance.currentUser!.uid,
        'doctorName': FirebaseAuth.instance.currentUser!.displayName ?? "Дәрігер",
        'content': content,
        'createdAt': FieldValue.serverTimestamp(),
        'confirmed': true,
      });
      if (_audioPath != null) await File(_audioPath!).delete();
      _audioPath = null;
      return true;
    } catch (e) {
      print("Save error: $e");
      return false;
    }
  }
}