import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:animate_do/animate_do.dart';
import '../../../core/theme/app_colors.dart';
import '../../../domain/entities/question.dart';
import '../../providers/question_provider.dart';
import '../../providers/locale_provider.dart';
import '../../providers/subscription_provider.dart';
import '../../../core/storage/hive_service.dart';
import '../../../core/services/ai_tutor_service.dart';
import '../../../core/debug/app_logger.dart';
import '../../../core/storage/user_preferences_service.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../subscription/paywall_screen.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';

/// -----------------------------------------------------------------
/// 📚 TOPIC SELECTION SCREEN / THEMEN AUSWAHL / شاشة اختيار الموضوع
/// -----------------------------------------------------------------
/// Displays 6 category cards for different question topics.
/// Each card shows progress and question count.
/// Includes analytics tracking and statistics section.
/// -----------------------------------------------------------------
class TopicSelectionScreen extends ConsumerStatefulWidget {
  const TopicSelectionScreen({super.key});

  @override
  ConsumerState<TopicSelectionScreen> createState() =>
      _TopicSelectionScreenState();
}

class _TopicSelectionScreenState extends ConsumerState<TopicSelectionScreen> {
  // Topic configuration mapping
  static const Map<String, Map<String, dynamic>> _topicConfig = {
    'system': {
      'icon': Icons.account_balance,
      'titleKey': 'topicSystem',
      'color': AppColors.eagleGold,
    },
    'rights': {
      'icon': Icons.gavel,
      'titleKey': 'topicRights',
      'color': Colors.blue,
    },
    'history': {
      'icon': Icons.history_edu,
      'titleKey': 'topicHistory',
      'color': Colors.orange,
    },
    'society': {
      'icon': Icons.people,
      'titleKey': 'topicSociety',
      'color': Colors.green,
    },
    'europe': {
      'icon': Icons.public,
      'titleKey': 'topicEurope',
      'color': Colors.purple,
    },
    'welfare': {
      'icon': Icons.school,
      'titleKey': 'topicWelfare',
      'color': Colors.teal,
    },
  };

  @override
  void initState() {
    super.initState();
    // Track screen view
    AppLogger.event('TopicSelectionScreen viewed',
        source: 'TopicSelectionScreen');
  }

  String _getTopicTitle(String topicKey, AppLocalizations l10n) {
    switch (topicKey) {
      case 'topicSystem':
        return l10n.topicSystem;
      case 'topicRights':
        return l10n.topicRights;
      case 'topicHistory':
        return l10n.topicHistory;
      case 'topicSociety':
        return l10n.topicSociety;
      case 'topicEurope':
        return l10n.topicEurope;
      case 'topicWelfare':
        return l10n.topicWelfare;
      default:
        return topicKey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final questionsAsync = ref.watch(questionsProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.chooseTopic,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
      ),
      body: questionsAsync.when(
        data: (allQuestions) =>
            _buildContent(context, allQuestions, l10n, theme),
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.eagleGold),
        ),
        error: (error, stack) {
          AppLogger.error('Failed to load questions',
              source: 'TopicSelectionScreen', error: error, stackTrace: stack);
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                SizedBox(height: 16.h),
                Text(
                  l10n.noQuestionsForTopic,
                  style: GoogleFonts.poppins(
                    fontSize: 16.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(BuildContext context, List<Question> allQuestions,
      AppLocalizations l10n, ThemeData theme) {
    // Calculate overall statistics
    final stats = _calculateOverallStatistics(allQuestions);

    // استخدام AdaptivePageWrapper مع CustomScrollView
    return AdaptivePageWrapper(
      padding: EdgeInsets.zero,
      enableScroll: false, // CustomScrollView يمرر نفسه
      child: CustomScrollView(
      slivers: [
        // Statistics Section
        SliverToBoxAdapter(
          child: FadeInDown(
            child: _buildStatisticsSection(context, stats, l10n, theme),
          ),
        ),

        // Grid of Topic Cards
        SliverPadding(
          padding: EdgeInsets.all(16.w),
          sliver: SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 0.85,
            ),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                // Check if this is the state questions card (last card)
                final isStateCard = index == _topicConfig.length;
                
                if (isStateCard) {
                  // State-specific questions card
                  return FutureBuilder<String?>(
                    future: UserPreferencesService.getSelectedState(),
                    builder: (context, snapshot) {
                      final stateCode = snapshot.data;
                      final stateQuestions = allQuestions
                          .where((q) => q.stateCode != null && q.stateCode == stateCode)
                          .toList();
                      
                      return FadeInUp(
                        delay: Duration(milliseconds: 100 * (index + 1)),
                        child: _buildStateCard(
                          context,
                          stateCode: stateCode,
                          questions: stateQuestions,
                          allQuestions: allQuestions,
                          l10n: l10n,
                          theme: theme,
                        ),
                      );
                    },
                  );
                }
                
                // Regular topic card
                final topic = _topicConfig.keys.elementAt(index);
                final config = _topicConfig[topic]!;
                final topicQuestions =
                    allQuestions.where((q) => q.topic == topic).toList();

                return FadeInUp(
                  delay: Duration(milliseconds: 100 * (index + 1)),
                  child: _buildTopicCard(
                    context,
                    topic: topic,
                    config: config,
                    questions: topicQuestions,
                    allQuestions: allQuestions,
                    l10n: l10n,
                    theme: theme,
                  ),
                );
              },
              childCount: _topicConfig.length + 1, // +1 for state card
            ),
          ),
        ),
      ],
      ),
    );
  }

  Widget _buildStatisticsSection(BuildContext context,
      Map<String, dynamic> stats, AppLocalizations l10n, ThemeData theme) {
    return Container(
      margin: EdgeInsets.all(16.w),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: AppColors.eagleGold.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart, color: AppColors.eagleGold, size: 24.sp),
              SizedBox(width: 12.w),
              Flexible(
                child: Text(
                  l10n.topicStatistics,
                  style: GoogleFonts.poppins(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Statistics Grid
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.quiz,
                  label: l10n.totalQuestions,
                  value: '${stats['totalQuestions']}',
                  color: AppColors.eagleGold,
                  theme: theme,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.check_circle,
                  label: l10n.questionsAnswered,
                  value: '${stats['answered']}',
                  color: Colors.green,
                  theme: theme,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: Icons.trending_up,
                  label: l10n.accuracyRate,
                  value: '${stats['accuracy']}%',
                  color: Colors.blue,
                  theme: theme,
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _buildStatCard(
                  context,
                  icon: stats['mostStudied'] != null ? Icons.star : Icons.info,
                  label: stats['mostStudied'] != null
                      ? l10n.mostStudiedTopic
                      : l10n.leastStudiedTopic,
                  value: () {
                    if (stats['mostStudied'] != null) {
                      final topicKey = stats['mostStudied'] as String;
                      final config = _topicConfig[topicKey];
                      if (config != null) {
                        return _getTopicTitle(
                            config['titleKey'] as String, l10n);
                      }
                    }
                    if (stats['leastStudied'] != null) {
                      final topicKey = stats['leastStudied'] as String;
                      final config = _topicConfig[topicKey];
                      if (config != null) {
                        return _getTopicTitle(
                            config['titleKey'] as String, l10n);
                      }
                    }
                    return '-';
                  }(),
                  color: stats['mostStudied'] != null
                      ? Colors.orange
                      : Colors.grey,
                  theme: theme,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    required ThemeData theme,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20.sp),
          SizedBox(height: 8.h),
          Text(
            value,
            style: GoogleFonts.poppins(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          SizedBox(height: 4.h),
          Flexible(
            child: AutoSizeText(
              label,
              style: GoogleFonts.poppins(
                fontSize: 12.sp,
                color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              maxLines: 2,
              minFontSize: 10.0,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _calculateOverallStatistics(
      List<Question> allQuestions) {
    final progress = HiveService.getUserProgress();
    final answersRaw = progress?['answers'];
    final answers = answersRaw != null && answersRaw is Map
        ? Map<String, dynamic>.from(answersRaw)
        : null;

    int totalQuestions = allQuestions.length;
    int answered = 0;
    int correct = 0;

    final Map<String, int> topicAnsweredCount = {};
    final Map<String, int> topicTotalCount = {};

    for (final question in allQuestions) {
      final topic = question.topic ?? 'unknown';
      topicTotalCount[topic] = (topicTotalCount[topic] ?? 0) + 1;

      if (answers != null) {
        final answerData = answers[question.id.toString()];
        if (answerData != null && answerData is Map) {
          answered++;
          topicAnsweredCount[topic] = (topicAnsweredCount[topic] ?? 0) + 1;
          if (answerData['isCorrect'] == true) {
            correct++;
          }
        }
      }
    }

    // Find most and least studied topics
    String? mostStudied;
    String? leastStudied;
    int maxAnswered = 0;
    int minAnswered = totalQuestions;

    for (final entry in topicAnsweredCount.entries) {
      if (entry.value > maxAnswered) {
        maxAnswered = entry.value;
        mostStudied = entry.key;
      }
      if (entry.value < minAnswered && entry.value > 0) {
        minAnswered = entry.value;
        leastStudied = entry.key;
      }
    }

    final accuracy = answered > 0 ? ((correct / answered) * 100).round() : 0;

    return {
      'totalQuestions': totalQuestions,
      'answered': answered,
      'correct': correct,
      'accuracy': accuracy,
      'mostStudied': mostStudied,
      'leastStudied': leastStudied,
    };
  }

  Widget _buildTopicCard(
    BuildContext context, {
    required String topic,
    required Map<String, dynamic> config,
    required List<Question> questions,
    required List<Question> allQuestions,
    required AppLocalizations l10n,
    required ThemeData theme,
  }) {
    final icon = config['icon'] as IconData;
    final color = config['color'] as Color;
    final titleKey = config['titleKey'] as String;
    final title = _getTopicTitle(titleKey, l10n);

    // Calculate progress
    final progress = _calculateTopicProgress(questions);
    final totalCount = questions.length;
    final learnedCount = progress['learnedCount'] as int;
    final correctCount = progress['correctCount'] as int;
    final progressValue =
        totalCount > 0 ? (learnedCount / totalCount).clamp(0.0, 1.0) : 0.0;

    return Card(
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: InkWell(
        onTap: () {
          AppLogger.event('Topic selected',
              source: 'TopicSelectionScreen',
              data: {
                'topic': topic,
                'questionCount': totalCount,
              });
          _navigateToTopicQuestions(context, topic, questions, l10n);
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, size: 24.sp, color: color),
              ),
              SizedBox(height: 8.h),

              // Title
              Flexible(
                child: AutoSizeText(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  minFontSize: 10.0,
                  textAlign: TextAlign.start,
                ),
              ),
              SizedBox(height: 6.h),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4.h,
                ),
              ),
              SizedBox(height: 6.h),

              // Question count
              Flexible(
                child: Text(
                  '$learnedCount/$totalCount ${l10n.learned}',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Correct count (optional)
              if (correctCount > 0)
                Flexible(
                  child: Text(
                    '$correctCount ${l10n.correct}',
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      color: color.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Map<String, int> _calculateTopicProgress(List<Question> questions) {
    final progress = HiveService.getUserProgress();
    if (progress == null) {
      return {'learnedCount': 0, 'correctCount': 0};
    }

    final answersRaw = progress['answers'];
    final answers = answersRaw != null && answersRaw is Map
        ? Map<String, dynamic>.from(answersRaw)
        : null;
    if (answers == null) {
      return {'learnedCount': 0, 'correctCount': 0};
    }

    int learnedCount = 0;
    int correctCount = 0;

    for (final question in questions) {
      final answerData = answers[question.id.toString()];
      if (answerData != null && answerData is Map) {
        learnedCount++;
        if (answerData['isCorrect'] == true) {
          correctCount++;
        }
      }
    }

    return {
      'learnedCount': learnedCount,
      'correctCount': correctCount,
    };
  }

  void _navigateToTopicQuestions(BuildContext context, String topic,
      List<Question> questions, AppLocalizations l10n) async {
    if (questions.isEmpty) {
      AppLogger.warn('No questions available for topic: $topic',
          source: 'TopicSelectionScreen');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noQuestionsForTopic),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // الانتقال إلى شاشة الأسئلة وانتظار العودة
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            TopicQuestionsScreen(topic: topic, questions: questions),
      ),
    );

    // تحديث الشاشة عند العودة لتحديث التقدم
    if (mounted) {
      setState(() {
        // إعادة بناء الشاشة لتحديث التقدم
      });
    }
  }

  Widget _buildStateCard(
    BuildContext context, {
    required String? stateCode,
    required List<Question> questions,
    required List<Question> allQuestions,
    required AppLocalizations l10n,
    required ThemeData theme,
  }) {
    final color = Colors.indigo;
    final title = l10n.topicState;

    // Calculate progress
    final progress = _calculateTopicProgress(questions);
    final totalCount = questions.length;
    final learnedCount = progress['learnedCount'] as int;
    final correctCount = progress['correctCount'] as int;
    final progressValue =
        totalCount > 0 ? (learnedCount / totalCount).clamp(0.0, 1.0) : 0.0;

    return Card(
      color: theme.cardTheme.color,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
        side: BorderSide(
          color: color.withValues(alpha: 0.3),
          width: 1.w,
        ),
      ),
      child: InkWell(
        onTap: () {
          if (stateCode == null || stateCode.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.selectStateFirst),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          if (questions.isEmpty) {
            AppLogger.warn('No state questions available for: $stateCode',
                source: 'TopicSelectionScreen');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n.noQuestionsForTopic),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }

          AppLogger.event('State questions selected',
              source: 'TopicSelectionScreen',
              data: {
                'stateCode': stateCode,
                'questionCount': totalCount,
              });
          _navigateToTopicQuestions(context, 'state', questions, l10n);
        },
        borderRadius: BorderRadius.circular(20.r),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(Icons.location_city, size: 24.sp, color: color),
              ),
              SizedBox(height: 8.h),

              // Title
              Flexible(
                child: AutoSizeText(
                  title,
                  style: GoogleFonts.poppins(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  minFontSize: 10.0,
                  textAlign: TextAlign.start,
                ),
              ),
              SizedBox(height: 6.h),

              // Progress bar
              ClipRRect(
                borderRadius: BorderRadius.circular(4.r),
                child: LinearProgressIndicator(
                  value: progressValue,
                  backgroundColor: color.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4.h,
                ),
              ),
              SizedBox(height: 6.h),

              // Question count
              Flexible(
                child: Text(
                  '$learnedCount/$totalCount ${l10n.learned}',
                  style: GoogleFonts.poppins(
                    fontSize: 10.sp,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Correct count (optional)
              if (correctCount > 0)
                Flexible(
                  child: Text(
                    '$correctCount ${l10n.correct}',
                    style: GoogleFonts.poppins(
                      fontSize: 9.sp,
                      color: color.withValues(alpha: 0.8),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              // State code indicator (if available)
              if (stateCode != null && stateCode.isNotEmpty) ...[
                SizedBox(height: 4.h),
                Flexible(
                  child: Text(
                    '($stateCode)',
                    style: GoogleFonts.poppins(
                      fontSize: 10.sp,
                      color: color.withValues(alpha: 0.6),
                      fontStyle: FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen to display questions filtered by topic
class TopicQuestionsScreen extends ConsumerStatefulWidget {
  final String topic;
  final List<Question> questions;

  const TopicQuestionsScreen({
    super.key,
    required this.topic,
    required this.questions,
  });

  @override
  ConsumerState<TopicQuestionsScreen> createState() =>
      _TopicQuestionsScreenState();
}

class _TopicQuestionsScreenState extends ConsumerState<TopicQuestionsScreen> {
  int _currentIndex = 0;
  String? _selectedAnswerId;
  bool _showTranslation = false;
  bool _isAnswerChecked = false;
  final PageController _pageController = PageController();

  @override
  void initState() {
    super.initState();
    AppLogger.event('TopicQuestionsScreen viewed',
        source: 'TopicQuestionsScreen',
        data: {
          'topic': widget.topic,
          'questionCount': widget.questions.length,
        });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleAnswer(String answerId, Question question) async {
    if (_isAnswerChecked) return;

    setState(() {
      _selectedAnswerId = answerId;
      _isAnswerChecked = true;
    });

    final isCorrect = answerId == question.correctAnswerId;
    await HiveService.saveQuestionAnswer(question.id, answerId, isCorrect);

    AppLogger.event('Question answered in topic',
        source: 'TopicQuestionsScreen',
        data: {
          'topic': widget.topic,
          'questionId': question.id,
          'isCorrect': isCorrect,
        });
  }

  void _nextQuestion() {
    if (_currentIndex < widget.questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      AppLogger.event('All topic questions reviewed',
          source: 'TopicQuestionsScreen',
          data: {
            'topic': widget.topic,
            'totalQuestions': widget.questions.length,
          });

      Navigator.pop(context);
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.allTopicsReviewed),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    if (widget.questions.isEmpty) {
      return Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          title: Text(
            l10n.topicQuestions,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.onSurface,
            ),
          ),
          backgroundColor: theme.appBarTheme.backgroundColor,
        ),
        body: Center(
          child: Text(
            l10n.noQuestionsForTopic,
            style: GoogleFonts.poppins(
              fontSize: 16.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          l10n.topicQuestions,
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
        backgroundColor: theme.appBarTheme.backgroundColor,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(4.h),
          child: LinearProgressIndicator(
            value:
                ((_currentIndex + 1) / widget.questions.length).clamp(0.0, 1.0),
            backgroundColor: AppColors.germanRed.withValues(alpha: 0.2),
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.eagleGold),
          ),
        ),
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.questions.length,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
            _selectedAnswerId = null;
            _showTranslation = false;
            _isAnswerChecked = false;
          });
        },
        itemBuilder: (context, index) {
          final question = widget.questions[index];
          return _buildQuestionView(context, question, l10n, theme);
        },
      ),
    );
  }

  Widget _buildQuestionView(
    BuildContext context,
    Question question,
    AppLocalizations l10n,
    ThemeData theme,
  ) {
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    return SingleChildScrollView(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number
          Text(
            l10n.questionLabel(_currentIndex + 1, widget.questions.length),
            style: GoogleFonts.poppins(
              fontSize: 14.sp,
              color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          SizedBox(height: 16.h),

          // Question Card (German always, translation optional)
          Card(
            color: theme.cardTheme.color,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
              side: BorderSide(
                color: AppColors.eagleGold.withValues(alpha: 0.3),
                width: 1.w,
              ),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // German Question Label
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Question (DE)",
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // AI Tutor Button
                          IconButton(
                            icon: Icon(
                              Icons.auto_awesome,
                              color: AppColors.eagleGold,
                              size: 24.sp,
                            ),
                            onPressed: () =>
                                _showAiExplanation(context, question),
                            tooltip: isArabic
                                ? 'شرح بالذكاء الاصطناعي'
                                : 'Explain with AI',
                          ),
                          // Translation Toggle Button
                          IconButton(
                            icon: Icon(
                              _showTranslation
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                              color: AppColors.eagleGold,
                              size: 24.sp,
                            ),
                            onPressed: () {
                              setState(() {
                                _showTranslation = !_showTranslation;
                              });
                            },
                            tooltip: _showTranslation
                                ? (isArabic
                                    ? 'إخفاء الترجمة'
                                    : 'Hide Translation')
                                : (isArabic
                                    ? 'إظهار الترجمة'
                                    : 'Show Translation'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),

                  // German Question Text
                  AutoSizeText(
                    question.getText('de'),
                    style: GoogleFonts.poppins(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onSurface,
                      height: 1.3,
                    ),
                    textAlign: TextAlign.center,
                    minFontSize: 12,
                    maxLines: 5,
                  ),

                  // Translation (if enabled)
                  if (_showTranslation &&
                      currentLocale.languageCode != 'de') ...[
                    SizedBox(height: 16.h),
                    Divider(color: AppColors.eagleGold.withValues(alpha: 0.3)),
                    SizedBox(height: 8.h),
                    Text(
                      "Translation (${currentLocale.languageCode.toUpperCase()})",
                      style: GoogleFonts.poppins(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Directionality(
                      textDirection: currentLocale.languageCode == 'ar'
                          ? TextDirection.rtl
                          : TextDirection.ltr,
                      child: AutoSizeText(
                        question.getText(currentLocale.languageCode),
                        style: GoogleFonts.poppins(
                          fontSize: 16.sp,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.8),
                          height: 1.3,
                        ),
                        textAlign: currentLocale.languageCode == 'ar'
                            ? TextAlign.right
                            : TextAlign.left,
                        minFontSize: 12,
                        maxLines: 5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          SizedBox(height: 24.h),

          // Answers
          ...question.answers.map((answer) {
            final isSelected = _selectedAnswerId == answer.id;
            final isCorrect = answer.id == question.correctAnswerId;
            final showResult = _isAnswerChecked && isSelected;

            Color? cardColor;
            if (_isAnswerChecked) {
              if (isCorrect) {
                cardColor = Colors.green.withValues(alpha: 0.2);
              } else if (isSelected && !isCorrect) {
                cardColor = Colors.red.withValues(alpha: 0.2);
              }
            }

            return Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Card(
                color: cardColor ?? theme.cardTheme.color,
                child: InkWell(
                  onTap: _isAnswerChecked
                      ? null
                      : () => _handleAnswer(answer.id, question),
                  child: Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 40.w,
                              height: 40.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected
                                    ? (isCorrect ? Colors.green : Colors.red)
                                    : AppColors.eagleGold.withValues(alpha: 0.2),
                              ),
                              child: Center(
                                child: Text(
                                  answer.id,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : AppColors.eagleGold,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 16.w),
                            Expanded(
                              child: Text(
                                answer.getText('de'),
                                style: GoogleFonts.poppins(
                                  fontSize: 16.sp,
                                  fontWeight: FontWeight.w600,
                                  color: theme.colorScheme.onSurface,
                                ),
                              ),
                            ),
                            if (showResult)
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.cancel,
                                color: isCorrect ? Colors.green : Colors.red,
                              ),
                          ],
                        ),
                        // Translation (if enabled)
                        if (_showTranslation &&
                            currentLocale.languageCode != 'de') ...[
                          SizedBox(height: 8.h),
                          Padding(
                            padding: EdgeInsets.only(left: 56.w),
                            child: Directionality(
                              textDirection: currentLocale.languageCode == 'ar'
                                  ? TextDirection.rtl
                                  : TextDirection.ltr,
                              child: Text(
                                answer.getText(currentLocale.languageCode),
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  color: theme.colorScheme.onSurface
                                      .withValues(alpha: 0.7),
                                ),
                                textAlign: currentLocale.languageCode == 'ar'
                                    ? TextAlign.right
                                    : TextAlign.left,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            );
          }),

          // Next button
          if (_isAnswerChecked)
            Padding(
              padding: EdgeInsets.only(top: 24.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _nextQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.eagleGold,
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    _currentIndex < widget.questions.length - 1
                        ? l10n.next
                        : (ref.read(localeProvider).languageCode == 'ar'
                            ? 'إنهاء'
                            : 'Finish'),
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _showAiExplanation(
      BuildContext context, Question question) async {
    final l10n = AppLocalizations.of(context)!;
    if (!mounted) return;
    final currentLocale = ref.read(localeProvider);
    final userLanguage = currentLocale.languageCode;
    final isArabic = userLanguage == 'ar';

    final subscriptionState = ref.read(subscriptionProvider);
    final isPro = subscriptionState.isPro;

    // التحقق من عدد الاستخدامات اليومية للمستخدمين المجانيين
    if (!isPro) {
      final canUse = HiveService.canUseAiTutor(isPro: false);
      final remainingUses =
          HiveService.getRemainingAiTutorUsesToday(isPro: false);

      if (!canUse) {
        // تم تجاوز الحد اليومي (3 مرات)
        showDialog(
          context: context,
          builder: (context) {
            final theme = Theme.of(context);
            return AlertDialog(
              backgroundColor: theme.cardTheme.color,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r)),
              title: Row(
                children: [
                  Icon(Icons.auto_awesome,
                      color: AppColors.eagleGold, size: 28.sp),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      l10n.upgradeToPro,
                      style: GoogleFonts.poppins(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              content: Text(
                l10n.aiTutorDailyLimitReached,
                style: GoogleFonts.poppins(
                  fontSize: 14.sp,
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    l10n.cancel,
                    style: GoogleFonts.poppins(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const PaywallScreen()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.eagleGold,
                    foregroundColor: Colors.black,
                  ),
                  child: Text(
                    l10n.upgrade,
                    style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        );
        return;
      }

      // التحقق من الاستخدامات المتبقية قبل الاستخدام
      if (remainingUses <= 0) {
        return;
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _TopicAiExplanationBottomSheet(
        question: question,
        userLanguage: userLanguage,
        isArabic: isArabic,
        l10n: l10n,
      ),
    );
  }
}

class _TopicAiExplanationBottomSheet extends StatefulWidget {
  final Question question;
  final String userLanguage;
  final bool isArabic;
  final AppLocalizations l10n;

  const _TopicAiExplanationBottomSheet({
    required this.question,
    required this.userLanguage,
    required this.isArabic,
    required this.l10n,
  });

  @override
  State<_TopicAiExplanationBottomSheet> createState() =>
      _TopicAiExplanationBottomSheetState();
}

class _TopicAiExplanationBottomSheetState
    extends State<_TopicAiExplanationBottomSheet> {
  Future<String>? _explanationFuture;
  String? _cachedExplanation;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _explanationFuture = _loadExplanation();
  }

  Future<String> _loadExplanation() async {
    if (_cachedExplanation != null) return _cachedExplanation!;
    final explanation = await AiTutorService.explainQuestion(
      question: widget.question,
      userLanguage: widget.userLanguage,
    );
    if (mounted) setState(() => _cachedExplanation = explanation);
    return explanation;
  }

  Future<void> _refreshExplanation() async {
    setState(() {
      _isRefreshing = true;
      _cachedExplanation = null;
    });
    final newExplanation = await AiTutorService.explainQuestion(
      question: widget.question,
      userLanguage: widget.userLanguage,
    );
    if (mounted) {
      setState(() {
        _cachedExplanation = newExplanation;
        _explanationFuture = Future.value(newExplanation);
        _isRefreshing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      constraints:
          BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24.r),
          topRight: Radius.circular(24.r),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: EdgeInsets.only(top: 12.h),
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade600,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: AppColors.eagleGold.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.auto_awesome,
                      color: AppColors.eagleGold, size: 24.sp),
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        widget.isArabic
                            ? 'شرح من Eagle AI Tutor'
                            : 'Explanation from Eagle AI Tutor',
                        style: GoogleFonts.poppins(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                        maxLines: 1,
                      ),
                      SizedBox(height: 4.h),
                      AutoSizeText(
                        widget.isArabic
                            ? 'شرح مفصل للسؤال والإجابة الصحيحة'
                            : 'Detailed explanation of the question and correct answer',
                        style: GoogleFonts.poppins(
                          fontSize: 12.sp,
                          color: theme.colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: theme.colorScheme.onSurface),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1.h),
          Flexible(
            child: FutureBuilder<String>(
              future: _explanationFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(color: AppColors.eagleGold),
                        SizedBox(height: 16.h),
                        AutoSizeText(
                          widget.isArabic
                              ? 'جاري تحميل الشرح...'
                              : 'Loading explanation...',
                          style: GoogleFonts.poppins(
                              color:
                                  theme.colorScheme.onSurface.withValues(alpha: 0.7)),
                        ),
                      ],
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.error_outline,
                            color: Colors.red, size: 48.sp),
                        SizedBox(height: 16.h),
                        AutoSizeText(
                          widget.isArabic
                              ? 'حدث خطأ أثناء تحميل الشرح'
                              : 'Error loading explanation',
                          style: GoogleFonts.poppins(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return SingleChildScrollView(
                  padding: EdgeInsets.all(20.w),
                  child: AutoSizeText(
                    snapshot.data ?? '',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: theme.colorScheme.onSurface,
                      height: 1.6,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(20.w),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isRefreshing ? null : _refreshExplanation,
                    icon: _isRefreshing
                        ? SizedBox(
                            width: 16.w,
                            height: 16.h,
                            child: const CircularProgressIndicator(
                                strokeWidth: 2, color: AppColors.eagleGold),
                          )
                        : Icon(Icons.refresh, size: 20.sp),
                    label: Text(widget.isArabic ? 'تحديث' : 'Refresh',
                        style: GoogleFonts.poppins()),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.eagleGold),
                      foregroundColor: AppColors.eagleGold,
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.eagleGold,
                      foregroundColor: Colors.black,
                    ),
                    child: Text(
                      widget.isArabic ? 'إغلاق' : 'Close',
                      style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
