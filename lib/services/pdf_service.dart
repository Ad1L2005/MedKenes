// lib/services/pdf_service.dart — ОФИЦИАЛЬНЫЙ SMARTDOC ПО ФОРМЕ №025/у РК (ЧИСТАЯ ВЕРСИЯ)

import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PdfService {
  static Future<void> generateOfficialSmartDoc({
    required String patientName,
    required String doctorName,
    required String patientIIN,
    required String patientGender,
    required String patientBirthDate,
    required String patientPhone,
    required String content,
    String? receptionDate,
  }) async {
    final fontData = await rootBundle.load("lib/fonts/Roboto-Regular.ttf"); // УБЕДИСЬ, ЧТО ПУТЬ ПРАВИЛЬНЫЙ!
    final boldData = await rootBundle.load("lib/fonts/Roboto-Bold.ttf");
    final regular = pw.Font.ttf(fontData);
    final bold = pw.Font.ttf(boldData);
    final signatureImage = await imageFromAssetBundle('assets/image.png');
    final pdf = pw.Document();

    // Убираем дублирующийся заголовок из диктовки
    String cleanContent = _extractMedicalPartOnly(content);

    final lines = cleanContent
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    const chunkSize = 45;
    final chunks = <List<String>>[];
    for (var i = 0; i < lines.length; i += chunkSize) {
      chunks.add(lines.sublist(
          i, i + chunkSize > lines.length ? lines.length : i + chunkSize));
    }

    final dateStr = receptionDate ??
        "${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year}";

    for (int page = 0; page < chunks.length; page++) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(50),
          build: (_) => pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Шапка формы (справа сверху)
              pw.Align(
                alignment: pw.Alignment.topRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Text("Утверждена", style: pw.TextStyle(font: regular, fontSize: 10)),
                    pw.Text("Министерством здравоохранения РК", style: pw.TextStyle(font: regular, fontSize: 10)),
                    pw.Text("Учетная форма № 025/у", style: pw.TextStyle(font: bold, fontSize: 11)),
                    pw.SizedBox(height: 8),
                  ],
                ),
              ),

              pw.Center(
                  child: pw.Text("МЕДИЦИНСКАЯ КАРТА ПАЦИЕНТА",
                      style: pw.TextStyle(font: bold, fontSize: 18))),
              pw.Center(
                  child: pw.Text("ДЛЯ АМБУЛАТОРНО-ПОЛИКЛИНИЧЕСКИХ ОРГАНИЗАЦИЙ",
                      style: pw.TextStyle(font: bold, fontSize: 14))),
              pw.SizedBox(height: 30),

              // Данные пациента
              _buildInfoRow("ФИО пациента:", patientName, regular, bold),
              _buildInfoRow("ИИН:", patientIIN, regular, bold),
              _buildInfoRow("Дата рождения:", patientBirthDate, regular, bold),
              _buildInfoRow("Телефон:", patientPhone, regular, bold),
              _buildInfoRow("Дата приёма:", dateStr, regular, bold),

              pw.Divider(thickness: 1.5),
              pw.SizedBox(height: 20),

              pw.Text("ЗАКЛЮЧЕНИЕ ВРАЧА:", style: pw.TextStyle(font: bold, fontSize: 15)),
              pw.SizedBox(height: 12),

              // Чистый медицинский текст
              ...chunks[page].map((line) => pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 7),
                    child: pw.Text(line,
                        style: pw.TextStyle(font: regular, fontSize: 13.5, height: 1.6)),
                  )),

                            pw.Spacer(),

              // === ОФИЦИАЛЬНАЯ ПОДПИСЬ ВРАЧА КАК НА ФОРМЕ 025/у ===
              pw.Container(
                width: double.infinity,
                child: pw.Stack(
                  alignment: pw.Alignment.bottomRight,
                  children: [
                    

                    // Сама подпись (чуть выше линии)
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(right: 60, bottom: 95),
                      child: pw.Image(
                        signatureImage,
                        width: 195,
                        height: 85,
                        fit: pw.BoxFit.contain,
                      ),
                    ),
                  ],
                ),
              ),

              // Маленький отступ снизу, чтобы подпись не прилипала к краю листа
              pw.SizedBox(height: 60),
            ],
      )
      )
          );
    }

    await Printing.layoutPdf(
      onLayout: (_) => pdf.save(),
      name: "SmartDoc_$dateStr.pdf",
    );
  }

  // ВОТ ЭТОТ МЕТОД ТЫ ЗАБЫЛ — ОН ОБЯЗАТЕЛЕН!
  static pw.Widget _buildInfoRow(String label, String value, pw.Font regular, pw.Font bold) {
    return pw.Padding(
      padding: const pw.EdgeInsets.only(bottom: 8),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(
            width: 120,
            child: pw.Text(label, style: pw.TextStyle(font: bold, fontSize: 13)),
          ),
          pw.Expanded(
            child: pw.Text(value, style: pw.TextStyle(font: regular, fontSize: 13)),
          ),
        ],
      ),
    );
  }

  // Убираем служебный заголовок из диктовки
  static String _extractMedicalPartOnly(String fullText) {
    final lines = fullText.split('\n');
    final keywords = [
      'ЖАЛОБЫ:',
      'ШАҒЫМДАР:',
      'АНАМНЕЗ:',
      'ДИАГНОЗ:',
      'НАЗНАЧЕНИЯ:',
      'РЕКОМЕНДАЦИИ:',
      'ҰСЫНЫСТАР:',
      'RECOMMENDATIONS:',
    ];

    int startIndex = 0;
    for (int i = 0; i < lines.length; i++) {
      final trimmed = lines[i].trim();
      if (keywords.any((kw) => trimmed.startsWith(kw))) {
        startIndex = i;
        break;
      }
    }

    // Если ключевых слов нет — возвращаем весь текст (на всякий случай)
    if (startIndex == 0 && !keywords.any((kw) => fullText.contains(kw))) {
      return fullText.trim();
    }

    return lines.skip(startIndex).join('\n').trim();
  }
}