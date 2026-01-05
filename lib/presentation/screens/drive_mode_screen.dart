import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/question_provider.dart';
import '../../domain/entities/question.dart';

/// -----------------------------------------------------------------
/// 🚗 DRIVE MODE SCREEN / FAHRMODUS / شاشة وضع القيادة
/// -----------------------------------------------------------------
/// Hands-free learning mode designed for use while driving or commuting.
/// Automatically reads questions and answers using Text-to-Speech in German.
/// Features auto-advance, pause/resume controls, and minimal dark interface.
/// -----------------------------------------------------------------
/// **Deutsch:** Hands-free-Lernmodus für die Nutzung während der Fahrt oder des Pendelns.
/// Liest automatisch Fragen und Antworten mit Text-to-Speech auf Deutsch vor.
/// -----------------------------------------------------------------
/// **العربية:** وضع التعلم بدون استخدام اليدين مصمم للاستخدام أثناء القيادة أو التنقل.
/// يقرأ تلقائياً الأسئلة والإجابات باستخدام تحويل النص إلى كلام بالألمانية.
/// -----------------------------------------------------------------
class DriveModeScreen extends ConsumerStatefulWidget {
  const DriveModeScreen({super.key});

  @override
  ConsumerState<DriveModeScreen> createState() => _DriveModeScreenState();
}

class _DriveModeScreenState extends ConsumerState<DriveModeScreen> {
  final FlutterTts _flutterTts = FlutterTts();
  bool _isPlaying = false;
  bool _isPaused = false;
  int _currentQuestionIndex = 0;
  List<Question> _questions = [];
  String _currentStatus = '';

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    await _flutterTts.setLanguage("de-DE");
    await _flutterTts.setPitch(1.0);
    
    // جلب سرعة TTS المحفوظة
    final prefs = await SharedPreferences.getInstance();
    final savedSpeed = prefs.getDouble('tts_speed') ?? 1.0;
    await _flutterTts.setSpeechRate(savedSpeed);

    // استماع لانتهاء الكلام
    _flutterTts.setCompletionHandler(() {
      _onSpeechComplete();
    });
  }

  Future<void> _loadQuestions() async {
    // Use general questions for drive mode (better for audio learning)
    final questionsAsync = ref.read(generalQuestionsProvider);
    questionsAsync.whenData((questions) {
      if (questions.isNotEmpty) {
        setState(() {
          _questions = questions;
          _currentQuestionIndex = 0;
        });
        _startDriveMode();
      }
    });
  }

  Future<void> _startDriveMode() async {
    if (_questions.isEmpty) {
      await _loadQuestions();
      return;
    }

    setState(() {
      _isPlaying = true;
      _isPaused = false;
    });

    await _playCurrentQuestion();
  }

  Future<void> _playCurrentQuestion() async {
    if (_currentQuestionIndex >= _questions.length) {
      // انتهت جميع الأسئلة
      setState(() {
        _isPlaying = false;
        _currentStatus = 'انتهت جميع الأسئلة';
      });
      await _flutterTts.speak('Alle Fragen sind beendet. Vielen Dank!');
      return;
    }

    final question = _questions[_currentQuestionIndex];
    
    // 1. قراءة السؤال
    setState(() {
      _currentStatus = 'السؤال ${_currentQuestionIndex + 1}';
    });
    await _flutterTts.speak('Frage ${_currentQuestionIndex + 1}: ${question.getText('de')}');
    
    // انتظار انتهاء الكلام (سيتم استدعاء _onSpeechComplete)
  }

  void _onSpeechComplete() async {
    if (!_isPlaying || _isPaused) return;

    final question = _questions[_currentQuestionIndex];
    
    // 2. انتظار 4 ثواني للتفكير
    await Future.delayed(const Duration(seconds: 4));
    
    if (!_isPlaying || _isPaused) return;

    // 3. قراءة الإجابة الصحيحة
    final correctAnswer = question.answers.firstWhere(
      (a) => a.id == question.correctAnswerId,
    );
    
    setState(() {
      _currentStatus = 'الإجابة الصحيحة';
    });
    await _flutterTts.speak('Die richtige Antwort ist: ${correctAnswer.getText('de')}');
    
    // انتظار انتهاء الكلام
    await Future.delayed(const Duration(seconds: 2));
    
    if (!_isPlaying || _isPaused) return;

    // 4. الانتقال للسؤال التالي
    setState(() {
      _currentQuestionIndex++;
    });
    
    await Future.delayed(const Duration(seconds: 2));
    
    if (_isPlaying && !_isPaused) {
      await _playCurrentQuestion();
    }
  }

  Future<void> _pause() async {
    await _flutterTts.stop();
    setState(() {
      _isPaused = true;
      _currentStatus = 'متوقف';
    });
  }

  Future<void> _resume() async {
    setState(() {
      _isPaused = false;
    });
    await _playCurrentQuestion();
  }

  Future<void> _stop() async {
    await _flutterTts.stop();
    setState(() {
      _isPlaying = false;
      _isPaused = false;
      _currentQuestionIndex = 0;
      _currentStatus = '';
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Use general questions for drive mode (better for audio learning)
    final questionsAsync = ref.watch(generalQuestionsProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text('Drive Mode', style: TextStyle(fontSize: 18.sp)),
        leading: IconButton(
          icon: Icon(Icons.close, size: 24.sp),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: questionsAsync.when(
        data: (questions) {
          if (questions.isEmpty) {
            return Center(
              child: Text(
                'No questions available',
                style: TextStyle(color: Colors.white, fontSize: 16.sp),
              ),
            );
          }

          if (_questions.isEmpty) {
            _questions = questions;
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Status Text
                if (_currentStatus.isNotEmpty)
                  Padding(
                    padding: EdgeInsets.all(24.w),
                    child: Text(
                      _currentStatus,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18.sp,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                SizedBox(height: 48.h),

                // Big Play/Pause Button
                GestureDetector(
                  onTap: () {
                    if (!_isPlaying) {
                      _startDriveMode();
                    } else if (_isPaused) {
                      _resume();
                    } else {
                      _pause();
                    }
                  },
                  child: Container(
                    width: 120.w,
                    height: 120.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isPlaying && !_isPaused
                          ? Colors.red
                          : Colors.green,
                    ),
                    child: Icon(
                      _isPlaying && !_isPaused
                          ? Icons.pause
                          : Icons.play_arrow,
                      size: 60.sp,
                      color: Colors.white,
                    ),
                  ),
                ),

                SizedBox(height: 32.h),

                // Question Counter
                Text(
                  '${_currentQuestionIndex + 1} / ${_questions.length}',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                SizedBox(height: 48.h),

                // Stop Button
                if (_isPlaying)
                  TextButton(
                    onPressed: _stop,
                    child: Text(
                      'Stop',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18.sp,
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
        error: (e, s) => Center(
          child: Text(
            'Error: $e',
            style: TextStyle(color: Colors.white, fontSize: 16.sp),
          ),
        ),
      ),
    );
  }
}

