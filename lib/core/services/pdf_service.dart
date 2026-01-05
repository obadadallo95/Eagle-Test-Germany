import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/entities/question.dart';
import '../../presentation/providers/exam_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// خدمة إنشاء ملفات PDF للامتحانات
class PdfService {
  /// إنشاء PDF للامتحان وفتح نافذة الطباعة/المشاركة
  static Future<void> generateExamPdf(WidgetRef ref) async {
    try {
      // جلب الأسئلة من Exam Provider
      final questionsAsync = await ref.read(examQuestionsProvider.future);
      
      if (questionsAsync.isEmpty) {
        throw Exception('No questions available');
      }

      // إنشاء PDF
      final pdf = pw.Document();
      
      // إضافة الصفحات
      final questionPagesCount = _addQuestionPages(pdf, questionsAsync);
      _addAnswerKeyPage(pdf, questionsAsync, questionPagesCount + 1);

      // فتح نافذة الطباعة/المشاركة
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }

  /// إنشاء PDF من قائمة أسئلة مباشرة (للاستخدام من خارج Provider)
  static Future<void> generateExamPdfFromQuestions(List<Question> questions) async {
    try {
      if (questions.isEmpty) {
        throw Exception('No questions available');
      }

      final pdf = pw.Document();
      final questionPagesCount = _addQuestionPages(pdf, questions);
      _addAnswerKeyPage(pdf, questions, questionPagesCount + 1);

      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdf.save(),
      );
    } catch (e) {
      throw Exception('Failed to generate PDF: $e');
    }
  }

  /// إضافة صفحات الأسئلة (صفحات 1-4)
  static int _addQuestionPages(pw.Document pdf, List<Question> questions) {
    // تقسيم الأسئلة إلى صفحات (حوالي 8-9 أسئلة لكل صفحة)
    const questionsPerPage = 8;
    int questionIndex = 0;
    int totalPages = ((questions.length / questionsPerPage).ceil()).clamp(1, 4);
    int currentPageNum = 1;

    for (int pageNum = 0; pageNum < totalPages && questionIndex < questions.length; pageNum++) {
      final pageNumber = currentPageNum;
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.only(
            top: 50,
            bottom: 60,
            left: 40,
            right: 40,
          ),
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                // Header
                pw.Center(
                  child: pw.Text(
                    'Einbürgerungstest - Simulation',
                    style: pw.TextStyle(
                      fontSize: 18,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                ),
                pw.SizedBox(height: 20),

                // Questions in 2 columns
                pw.Expanded(
                  child: pw.Row(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Left Column
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: _buildQuestionsForColumn(
                            questions,
                            questionIndex,
                            questionsPerPage ~/ 2,
                          ),
                        ),
                      ),
                      pw.SizedBox(width: 20),
                      // Right Column
                      pw.Expanded(
                        child: pw.Column(
                          crossAxisAlignment: pw.CrossAxisAlignment.start,
                          children: _buildQuestionsForColumn(
                            questions,
                            questionIndex + (questionsPerPage ~/ 2),
                            questionsPerPage ~/ 2,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Footer with page number
                pw.SizedBox(height: 10),
                pw.Divider(),
                pw.SizedBox(height: 5),
                pw.Center(
                  child: pw.Text(
                    'Seite $pageNumber',
                    style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                  ),
                ),
              ],
            );
          },
        ),
      );

      questionIndex += questionsPerPage;
      currentPageNum++;
    }
    
    return currentPageNum - 1; // إرجاع عدد الصفحات المضافة
  }

  /// بناء قائمة الأسئلة للعمود
  static List<pw.Widget> _buildQuestionsForColumn(
    List<Question> questions,
    int startIndex,
    int count,
  ) {
    final widgets = <pw.Widget>[];
    
    for (int i = 0; i < count && (startIndex + i) < questions.length; i++) {
      final question = questions[startIndex + i];
      final questionNumber = startIndex + i + 1;
      
      widgets.add(
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 20),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Question Number and Text
              pw.Text(
                '$questionNumber. ${question.getText('de')}',
                style: const pw.TextStyle(fontSize: 11),
              ),
              pw.SizedBox(height: 8),
              
              // Answer Options
              ...question.answers.map((answer) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 12, bottom: 4),
                  child: pw.Row(
                    children: [
                      pw.Container(
                        width: 12,
                        height: 12,
                        decoration: pw.BoxDecoration(
                          border: pw.Border.all(color: PdfColors.black, width: 1),
                        ),
                      ),
                      pw.SizedBox(width: 6),
                      pw.Expanded(
                        child: pw.Text(
                          '${answer.id}) ${answer.getText('de')}',
                          style: const pw.TextStyle(fontSize: 10),
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      );
    }
    
    return widgets;
  }

  /// إضافة صفحة مفتاح الإجابات
  static void _addAnswerKeyPage(pw.Document pdf, List<Question> questions, int pageNumber) {
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.only(
          top: 50,
          bottom: 60,
          left: 40,
          right: 40,
        ),
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Header
              pw.Center(
                child: pw.Text(
                  'Lösungsschlüssel',
                  style: pw.TextStyle(
                    fontSize: 20,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
              pw.SizedBox(height: 20),

              // Answer Key Table
              pw.Table(
                border: pw.TableBorder.all(color: PdfColors.black, width: 1),
                children: [
                  // Header Row
                  pw.TableRow(
                    decoration: const pw.BoxDecoration(color: PdfColors.grey300),
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Frage',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(8),
                        child: pw.Text(
                          'Antwort',
                          style: pw.TextStyle(
                            fontWeight: pw.FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                  // Data Rows
                  ...questions.asMap().entries.map((entry) {
                    final index = entry.key;
                    final question = entry.value;
                    return pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            '${index + 1}',
                            style: const pw.TextStyle(fontSize: 11),
                          ),
                        ),
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(8),
                          child: pw.Text(
                            question.correctAnswerId,
                            style: pw.TextStyle(
                              fontSize: 11,
                              fontWeight: pw.FontWeight.bold,
                              color: PdfColors.green700,
                            ),
                          ),
                        ),
                      ],
                    );
                  }),
                ],
              ),

              // Footer
              pw.Spacer(),
              pw.Divider(),
              pw.SizedBox(height: 5),
              pw.Center(
                child: pw.Text(
                  'Seite $pageNumber',
                  style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey700),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  /// حفظ PDF كملف ومشاركته
  static Future<void> saveAndSharePdf(WidgetRef ref) async {
    try {
      final questionsAsync = await ref.read(examQuestionsProvider.future);
      
      if (questionsAsync.isEmpty) {
        throw Exception('No questions available');
      }

      final pdf = pw.Document();
      final questionPagesCount = _addQuestionPages(pdf, questionsAsync);
      _addAnswerKeyPage(pdf, questionsAsync, questionPagesCount + 1);

      // حفظ الملف
      final bytes = await pdf.save();
      final directory = await getApplicationDocumentsDirectory();
      final file = File('${directory.path}/einbuergerungstest_${DateTime.now().millisecondsSinceEpoch}.pdf');
      await file.writeAsBytes(bytes);

      // مشاركة الملف
      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Einbürgerungstest - Modelltest',
      );
    } catch (e) {
      throw Exception('Failed to save PDF: $e');
    }
  }
}

