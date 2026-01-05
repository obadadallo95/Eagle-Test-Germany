import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:barcode_image/barcode_image.dart';
import 'package:image/image.dart' as img;
import '../../domain/entities/question.dart';
import '../../data/datasources/local_datasource.dart';

/// -----------------------------------------------------------------
/// 📄 PDF EXAM SERVICE / PDF-PRÜFUNGSSERVICE / خدمة PDF للامتحان
/// -----------------------------------------------------------------
/// Generates a realistic "Einbürgerungstest" PDF exam paper
/// -----------------------------------------------------------------
class PdfExamService {
  /// Generate PDF exam with configuration
  static Future<pw.Document> generateExamPdf({
    required bool includeSolutions,
    required bool shuffleQuestions,
    String? stateCode,
  }) async {
    final doc = pw.Document();

    // Load questions
    final localDataSource = LocalDataSourceImpl();
    final allQuestions = await localDataSource.getGeneralQuestions();

    List<Question> stateQuestions = [];
    if (stateCode != null && stateCode.isNotEmpty) {
      stateQuestions = await localDataSource.getStateQuestions(stateCode);
    }

    // Combine: 30 general + 3 state-specific = 33 total
    List<Question> examQuestions = [];
    if (allQuestions.length >= 30) {
      examQuestions = allQuestions.take(30).toList();
    } else {
      examQuestions = allQuestions;
    }

    if (stateQuestions.length >= 3) {
      examQuestions.addAll(stateQuestions.take(3));
    } else if (stateQuestions.isNotEmpty) {
      examQuestions.addAll(stateQuestions);
    }

    // Shuffle if requested
    if (shuffleQuestions) {
      examQuestions.shuffle();
    }

    // Get state name for display
    String stateName = '';
    if (stateCode != null && stateCode.isNotEmpty) {
      final stateMap = {
        'BW': 'Baden-Württemberg',
        'BY': 'Bayern',
        'BE': 'Berlin',
        'BB': 'Brandenburg',
        'HB': 'Bremen',
        'HH': 'Hamburg',
        'HE': 'Hessen',
        'MV': 'Mecklenburg-Vorpommern',
        'NI': 'Niedersachsen',
        'NW': 'Nordrhein-Westfalen',
        'RP': 'Rheinland-Pfalz',
        'SL': 'Saarland',
        'SN': 'Sachsen',
        'ST': 'Sachsen-Anhalt',
        'SH': 'Schleswig-Holstein',
        'TH': 'Thüringen',
      };
      stateName = stateMap[stateCode] ?? stateCode;
    }

    // Generate QR Code data (serialize question IDs)
    final questionIds = examQuestions.map((q) => q.id.toString()).join(',');
    final qrData = 'ids:$questionIds';

    // Generate QR Code image bytes
    final qrImageBytes = await _generateQRCodeBytes(qrData);

    // Build PDF pages
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (pw.Context context) {
          return [
            // Header with QR Code
            _buildHeaderWithQR(stateName, qrImageBytes),
            pw.SizedBox(height: 20),
            
            // Instructions
            _buildInstructions(),
            pw.SizedBox(height: 20),
            
            // Questions (2 columns)
            ..._buildQuestions(examQuestions),
          ];
        },
      ),
    );

    // Add solutions page if requested
    if (includeSolutions) {
      doc.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(40),
          build: (pw.Context context) {
            return [
              _buildSolutionsHeader(),
              pw.SizedBox(height: 20),
              ..._buildSolutions(examQuestions),
            ];
          },
        ),
      );
    }

    return doc;
  }

  static Future<Uint8List?> _generateQRCodeBytes(String data) async {
    try {
      // Create QR code barcode
      final qrCode = Barcode.qrCode();
      
      // Create image with QR code (QR codes don't need text, so no font needed)
      final qrImage = img.Image(width: 80, height: 80);
      drawBarcode(
        qrImage,
        qrCode,
        data,
      );
      
      // Convert to PNG bytes
      final pngBytes = img.encodePng(qrImage);
      return Uint8List.fromList(pngBytes);
    } catch (e) {
      // Fallback: return null if QR generation fails
      return null;
    }
  }

  static pw.Widget _buildHeaderWithQR(String stateName, Uint8List? qrImageBytes) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Left side: Title and info
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Einbürgerungstest',
                style: pw.TextStyle(
                  fontSize: 28,
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.helveticaBold(),
                ),
              ),
              pw.SizedBox(height: 8),
              pw.Text(
                'Modelltest',
                style: pw.TextStyle(
                  fontSize: 20,
                  font: pw.Font.helvetica(),
                ),
              ),
              if (stateName.isNotEmpty) ...[
                pw.SizedBox(height: 8),
                pw.Text(
                  'Bundesland: $stateName',
                  style: pw.TextStyle(
                    fontSize: 14,
                    font: pw.Font.helvetica(),
                  ),
                ),
              ],
              pw.SizedBox(height: 8),
              pw.Text(
                '33 Fragen',
                style: pw.TextStyle(
                  fontSize: 14,
                  font: pw.Font.helvetica(),
                ),
              ),
            ],
          ),
        ),
        // Right side: QR Code
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            qrImageBytes != null
                ? pw.Image(
                    pw.MemoryImage(qrImageBytes),
                    width: 80,
                    height: 80,
                  )
                : pw.Container(
                    width: 80,
                    height: 80,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.grey400),
                    ),
                    child: pw.Center(
                      child: pw.Text(
                        'QR',
                        style: const pw.TextStyle(fontSize: 10),
                      ),
                    ),
                  ),
            pw.SizedBox(height: 4),
            pw.Text(
              'Scan with App to Correct',
              style: pw.TextStyle(
                fontSize: 8,
                font: pw.Font.helvetica(),
              ),
            ),
            pw.Text(
              'Mit App scannen',
              style: pw.TextStyle(
                fontSize: 8,
                font: pw.Font.helvetica(),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildInstructions() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey700),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Anleitung:',
            style: pw.TextStyle(
              fontSize: 12,
              fontWeight: pw.FontWeight.bold,
              font: pw.Font.helveticaBold(),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '• Bitte kreuzen Sie die richtige Antwort an (A, B, C oder D).',
            style: pw.TextStyle(fontSize: 10, font: pw.Font.helvetica()),
          ),
          pw.Text(
            '• Es gibt nur eine richtige Antwort pro Frage.',
            style: pw.TextStyle(fontSize: 10, font: pw.Font.helvetica()),
          ),
          pw.Text(
            '• Sie haben 60 Minuten Zeit.',
            style: pw.TextStyle(fontSize: 10, font: pw.Font.helvetica()),
          ),
        ],
      ),
    );
  }

  static List<pw.Widget> _buildQuestions(List<Question> questions) {
    final widgets = <pw.Widget>[];
    
    // Split into chunks of 2 for 2-column layout
    for (int i = 0; i < questions.length; i += 2) {
      final question1 = questions[i];
      final question2 = i + 1 < questions.length ? questions[i + 1] : null;

      widgets.add(
        pw.Row(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            // Left column
            pw.Expanded(
              child: _buildQuestionCard(question1, i + 1),
            ),
            pw.SizedBox(width: 20),
            // Right column
            pw.Expanded(
              child: question2 != null
                  ? _buildQuestionCard(question2, i + 2)
                  : pw.SizedBox(),
            ),
          ],
        ),
      );
      
      if (i + 2 < questions.length) {
        widgets.add(pw.SizedBox(height: 15));
      }
    }

    return widgets;
  }

  static pw.Widget _buildQuestionCard(Question question, int number) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(10),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(4)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'Frage $number',
            style: pw.TextStyle(
              fontSize: 11,
              fontWeight: pw.FontWeight.bold,
              font: pw.Font.helveticaBold(),
            ),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            question.getText('de'),
            style: pw.TextStyle(
              fontSize: 10,
              font: pw.Font.helvetica(),
            ),
          ),
          pw.SizedBox(height: 8),
          // Answers with checkboxes
          ...question.answers.map((answer) {
            final letter = String.fromCharCode(65 + question.answers.indexOf(answer)); // A, B, C, D
            return pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 4),
              child: pw.Row(
                children: [
                  pw.Container(
                    width: 12,
                    height: 12,
                    decoration: pw.BoxDecoration(
                      border: pw.Border.all(color: PdfColors.black, width: 1),
                      borderRadius: const pw.BorderRadius.all(pw.Radius.circular(2)),
                    ),
                  ),
                  pw.SizedBox(width: 6),
                  pw.Text(
                    '$letter) ',
                    style: pw.TextStyle(
                      fontSize: 9,
                      fontWeight: pw.FontWeight.bold,
                      font: pw.Font.helveticaBold(),
                    ),
                  ),
                  pw.Expanded(
                    child: pw.Text(
                      answer.getText('de'),
                      style: pw.TextStyle(
                        fontSize: 9,
                        font: pw.Font.helvetica(),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  static pw.Widget _buildSolutionsHeader() {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Text(
          'Lösungsschlüssel',
          style: pw.TextStyle(
            fontSize: 24,
            fontWeight: pw.FontWeight.bold,
            font: pw.Font.helveticaBold(),
          ),
        ),
        pw.SizedBox(height: 8),
        pw.Divider(),
      ],
    );
  }

  static List<pw.Widget> _buildSolutions(List<Question> questions) {
    final widgets = <pw.Widget>[];
    
    for (int i = 0; i < questions.length; i++) {
      final question = questions[i];
      final correctAnswer = question.answers.firstWhere(
        (a) => a.id == question.correctAnswerId,
        orElse: () => question.answers.first,
      );
      final correctLetter = String.fromCharCode(65 + question.answers.indexOf(correctAnswer));

      widgets.add(
        pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '${i + 1}. ',
                style: pw.TextStyle(
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                  font: pw.Font.helveticaBold(),
                ),
              ),
              pw.Expanded(
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(
                      question.getText('de'),
                      style: pw.TextStyle(
                        fontSize: 10,
                        font: pw.Font.helvetica(),
                      ),
                    ),
                    pw.SizedBox(height: 4),
                    pw.Text(
                      'Richtige Antwort: $correctLetter) ${correctAnswer.getText('de')}',
                      style: pw.TextStyle(
                        fontSize: 9,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.green700,
                        font: pw.Font.helveticaBold(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return widgets;
  }

  /// Save PDF to file and return path
  static Future<String> savePdfToFile(pw.Document doc) async {
    final directory = await getApplicationDocumentsDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final file = File('${directory.path}/einbuergerungstest_$timestamp.pdf');
    await file.writeAsBytes(await doc.save());
    return file.path;
  }

  /// Share PDF
  static Future<void> sharePdf(String filePath) async {
    await Share.shareXFiles(
      [XFile(filePath)],
      text: 'Einbürgerungstest - Modelltest',
    );
  }

  /// Print PDF
  static Future<void> printPdf(pw.Document doc) async {
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => doc.save(),
    );
  }
}

