import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:politik_test/l10n/app_localizations.dart';
import '../../../core/storage/user_preferences_service.dart';
import '../main_screen.dart';
import '../../widgets/app_logo.dart';
import '../../providers/locale_provider.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';

/// -----------------------------------------------------------------
/// 🎯 SETUP SCREEN / EINRICHTUNGSBILDSCHIRM / شاشة الإعداد
/// -----------------------------------------------------------------
/// Onboarding wizard that runs only on first app launch.
/// Guides users through 4 steps: Language Selection, State Selection, Exam Date, and Completion.
/// Saves user preferences (Language, Bundesland and exam date) for personalized experience.
/// -----------------------------------------------------------------
class SetupScreen extends ConsumerStatefulWidget {
  const SetupScreen({super.key});

  @override
  ConsumerState<SetupScreen> createState() => _SetupScreenState();
}

class _SetupScreenState extends ConsumerState<SetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  String? _selectedLanguage;
  String? _selectedState;
  DateTime? _selectedExamDate;

  // قائمة اللغات المدعومة
  static const List<Map<String, String>> _languages = [
    {'code': 'de', 'name': 'Deutsch', 'flag': '🇩🇪', 'nativeName': 'Deutsch'},
    {'code': 'ar', 'name': 'Arabic', 'flag': '🇸🇾', 'nativeName': 'العربية'},
    {'code': 'en', 'name': 'English', 'flag': '🇺🇸', 'nativeName': 'English'},
    {'code': 'tr', 'name': 'Turkish', 'flag': '🇹🇷', 'nativeName': 'Türkçe'},
    {'code': 'uk', 'name': 'Ukrainian', 'flag': '🇺🇦', 'nativeName': 'Українська'},
    {'code': 'ru', 'name': 'Russian', 'flag': '🇷🇺', 'nativeName': 'Русский'},
  ];

  // قائمة الولايات الألمانية الـ 16
  final List<Map<String, String>> _germanStates = [
    {'code': 'BW', 'name': 'Baden-Württemberg', 'nameAr': 'بادن-فورتمبيرغ'},
    {'code': 'BY', 'name': 'Bayern', 'nameAr': 'بافاريا'},
    {'code': 'BE', 'name': 'Berlin', 'nameAr': 'برلين'},
    {'code': 'BB', 'name': 'Brandenburg', 'nameAr': 'براندنبورغ'},
    {'code': 'HB', 'name': 'Bremen', 'nameAr': 'بريمن'},
    {'code': 'HH', 'name': 'Hamburg', 'nameAr': 'هامبورغ'},
    {'code': 'HE', 'name': 'Hessen', 'nameAr': 'هيسن'},
    {'code': 'MV', 'name': 'Mecklenburg-Vorpommern', 'nameAr': 'مكلنبورغ-فوربومرن'},
    {'code': 'NI', 'name': 'Niedersachsen', 'nameAr': 'ساكسونيا السفلى'},
    {'code': 'NW', 'name': 'Nordrhein-Westfalen', 'nameAr': 'شمال الراين-وستفاليا'},
    {'code': 'RP', 'name': 'Rheinland-Pfalz', 'nameAr': 'راينلاند-بالاتينات'},
    {'code': 'SL', 'name': 'Saarland', 'nameAr': 'سارلاند'},
    {'code': 'SN', 'name': 'Sachsen', 'nameAr': 'ساكسونيا'},
    {'code': 'ST', 'name': 'Sachsen-Anhalt', 'nameAr': 'ساكسونيا-أنهالت'},
    {'code': 'SH', 'name': 'Schleswig-Holstein', 'nameAr': 'شليسفيغ-هولشتاين'},
    {'code': 'TH', 'name': 'Thüringen', 'nameAr': 'تورينغيا'},
  ];

  @override
  void initState() {
    super.initState();
    // كشف لغة الجهاز الافتراضية
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _detectDeviceLanguage();
    });
  }

  void _detectDeviceLanguage() {
    final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale;
    final deviceLangCode = deviceLocale.languageCode;
    
    // التحقق من دعم اللغة
    final supportedCodes = _languages.map((l) => l['code']).toList();
    if (supportedCodes.contains(deviceLangCode)) {
      setState(() {
        _selectedLanguage = deviceLangCode;
      });
      // تطبيق اللغة فوراً
      ref.read(localeProvider.notifier).changeLocale(deviceLangCode);
    } else {
      // افتراضي: الألمانية
      setState(() {
        _selectedLanguage = 'de';
      });
      ref.read(localeProvider.notifier).changeLocale('de');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _completeSetup();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeSetup() async {
    if (_selectedLanguage == null || _selectedState == null || _selectedExamDate == null) {
      final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.completeAllSteps ?? 'Please complete all steps'),
        ),
      );
      return;
    }

    // حفظ التفضيلات
    await UserPreferencesService.saveSelectedState(_selectedState!);
    await UserPreferencesService.saveExamDate(_selectedExamDate!);
    await UserPreferencesService.setFirstLaunchCompleted();

      // الانتقال إلى Main Screen (Dashboard)
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const MainScreen()),
        );
      }
  }

  Future<void> _selectExamDate() async {
    final DateTime now = DateTime.now();
    final DateTime firstDate = now;
    final DateTime lastDate = now.add(const Duration(days: 365 * 2));

    final currentLocale = ref.watch(localeProvider);
    
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedExamDate ?? now.add(const Duration(days: 30)),
      firstDate: firstDate,
      lastDate: lastDate,
      locale: currentLocale,
    );

    if (picked != null && picked != _selectedExamDate) {
      setState(() {
        _selectedExamDate = picked;
      });
    }
  }

  void _selectLanguage(String languageCode) {
    setState(() {
      _selectedLanguage = languageCode;
    });
    // تطبيق اللغة فوراً
    ref.read(localeProvider.notifier).changeLocale(languageCode);
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final isArabic = currentLocale.languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(
        title: Text(_getPageTitle(_currentPage, l10n, isArabic)),
        automaticallyImplyLeading: false,
      ),
      body: AdaptivePageWrapper(
        padding: EdgeInsets.zero,
        enableScroll: false, // PageView يملأ الشاشة
        child: PageView(
          controller: _pageController,
          physics: const NeverScrollableScrollPhysics(), // منع السحب
        onPageChanged: (index) {
          setState(() {
            _currentPage = index;
          });
        },
        children: [
          _buildLanguageSelectionPage(),
          _buildStateSelectionPage(l10n, isArabic),
          _buildExamDatePage(l10n, isArabic),
          _buildDonePage(l10n, isArabic),
        ],
        ),
        ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (_currentPage > 0)
              TextButton(
                onPressed: _previousPage,
                child: Text(l10n?.back ?? (l10n?.cancel ?? 'Back')),
              )
            else
              const SizedBox.shrink(),
            ElevatedButton(
              onPressed: _canProceed() ? _nextPage : null,
              child: Text(_getNextButtonText(_currentPage, l10n, isArabic)),
            ),
          ],
        ),
      ),
    );
  }

  String _getPageTitle(int page, AppLocalizations? l10n, bool isArabic) {
    switch (page) {
      case 0:
        return l10n?.welcome ?? (isArabic ? 'مرحباً' : 'Willkommen');
      case 1:
        return l10n?.selectBundesland ?? 'Select State';
      case 2:
        return l10n?.examDate ?? 'Exam Date';
      case 3:
        return l10n?.setupComplete ?? (isArabic ? 'تم الإعداد!' : 'Fertig!');
      default:
        return '';
    }
  }

  String _getNextButtonText(int page, AppLocalizations? l10n, bool isArabic) {
    if (page == 3) {
      return l10n?.letsStart ?? (isArabic ? 'ابدأ' : 'Los geht\'s!');
    }
    return l10n?.next ?? 'Next';
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _selectedLanguage != null;
      case 1:
        return _selectedState != null;
      case 2:
        return _selectedExamDate != null;
      case 3:
        return true;
      default:
        return false;
    }
  }

  Widget _buildLanguageSelectionPage() {
    final currentLocale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);
    final isArabic = currentLocale.languageCode == 'ar';

    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AppLogo(
            width: 120.w,
            height: 120.h,
          ),
          SizedBox(height: 32.h),
          AutoSizeText(
            l10n?.welcome ?? (isArabic ? 'مرحباً' : 'Willkommen'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 24.sp,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
          SizedBox(height: 16.h),
          AutoSizeText(
            l10n?.chooseLanguage ?? (isArabic 
              ? 'اختر لغتك المفضلة للدراسة'
              : 'Choose your preferred language for studying'),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          SizedBox(height: 32.h),
          Expanded(
            child: GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.w,
                mainAxisSpacing: 16.h,
                childAspectRatio: 1.3,
              ),
              itemCount: _languages.length,
              itemBuilder: (context, index) {
                final language = _languages[index];
                final isSelected = _selectedLanguage == language['code'];

                return Card(
                  elevation: isSelected ? 4 : 2,
                  color: isSelected 
                    ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
                    : null,
                  child: InkWell(
                    onTap: () => _selectLanguage(language['code']!),
                    borderRadius: BorderRadius.circular(12.r),
                    child: Padding(
                      padding: EdgeInsets.all(12.w),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: AutoSizeText(
                              language['flag']!,
                              style: TextStyle(fontSize: 36.sp),
                              maxLines: 1,
                              minFontSize: 24.0,
                              stepGranularity: 1.0,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Flexible(
                            child: AutoSizeText(
                              language['nativeName']!,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected 
                                  ? Theme.of(context).primaryColor
                                  : null,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              minFontSize: 10.0,
                              stepGranularity: 1.0,
                            ),
                          ),
                          if (isSelected) ...[
                            SizedBox(height: 4.h),
                            Icon(
                              Icons.check_circle,
                              color: Theme.of(context).primaryColor,
                              size: 18.sp,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStateSelectionPage(AppLocalizations? l10n, bool isArabic) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.map,
            size: 80.sp,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: 32.h),
          AutoSizeText(
            l10n?.selectBundesland ?? (isArabic ? 'اختر ولايتك' : 'Wählen Sie Ihr Bundesland'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 24.sp,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          SizedBox(height: 32.h),
          DropdownButtonFormField<String>(
            initialValue: _selectedState,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: l10n?.selectState ?? (isArabic ? 'الولاية' : 'Bundesland'),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            ),
            items: _germanStates.map((state) {
              final currentLocale = ref.watch(localeProvider);
              final isArabicState = currentLocale.languageCode == 'ar';
              return DropdownMenuItem<String>(
                value: state['code'],
                child: AutoSizeText(
                  isArabicState 
                    ? '${state['nameAr']} (${state['name']})'
                    : '${state['name']} (${state['nameAr']})',
                  style: TextStyle(fontSize: 14.sp),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedState = value;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExamDatePage(AppLocalizations? l10n, bool isArabic) {
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today,
            size: 80.sp,
            color: Theme.of(context).primaryColor,
          ),
          SizedBox(height: 32.h),
          AutoSizeText(
            l10n?.whenIsExam ?? (isArabic ? 'متى موعد امتحانك؟' : 'Wann ist dein Test?'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 24.sp,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          SizedBox(height: 32.h),
          Card(
            elevation: 4,
            child: InkWell(
              onTap: _selectExamDate,
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          AutoSizeText(
                            l10n?.examDate ?? (isArabic ? 'تاريخ الامتحان' : 'Prüfungstermin'),
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 18.sp,
                                ),
                            maxLines: 1,
                          ),
                          SizedBox(height: 8.h),
                          AutoSizeText(
                            _selectedExamDate != null
                              ? '${_selectedExamDate!.day}/${_selectedExamDate!.month}/${_selectedExamDate!.year}'
                              : (l10n?.tapToSelect ?? (isArabic ? 'اضغط للاختيار' : 'Tippen zum Auswählen')),
                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              fontSize: 16.sp,
                              color: _selectedExamDate != null 
                                ? Colors.black 
                                : Colors.grey,
                            ),
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Icon(Icons.calendar_month, size: 24.sp),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDonePage(AppLocalizations? l10n, bool isArabic) {
    final selectedStateName = _germanStates
        .firstWhere((s) => s['code'] == _selectedState, orElse: () => {'name': ''})['name'];
    
    return Padding(
      padding: EdgeInsets.all(24.w),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle,
            size: 80.sp,
            color: Colors.green,
          ),
          SizedBox(height: 32.h),
          AutoSizeText(
            l10n?.setupComplete ?? (isArabic ? 'تم الإعداد!' : 'Fertig!'),
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontSize: 24.sp,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
          SizedBox(height: 16.h),
          AutoSizeText(
            isArabic 
              ? 'الولاية: $selectedStateName'
              : 'Bundesland: $selectedStateName',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: 16.sp,
                ),
            textAlign: TextAlign.center,
            maxLines: 2,
          ),
          if (_selectedExamDate != null) ...[
            SizedBox(height: 8.h),
            AutoSizeText(
              isArabic
                ? 'تاريخ الامتحان: ${_selectedExamDate!.day}/${_selectedExamDate!.month}/${_selectedExamDate!.year}'
                : 'Prüfungstermin: ${_selectedExamDate!.day}.${_selectedExamDate!.month}.${_selectedExamDate!.year}',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontSize: 16.sp,
                  ),
              textAlign: TextAlign.center,
              maxLines: 1,
            ),
          ],
          SizedBox(height: 32.h),
          AutoSizeText(
            l10n?.letsStart ?? (isArabic ? 'لنبدأ!' : 'Los geht\'s!'),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontSize: 20.sp,
                ),
            textAlign: TextAlign.center,
            maxLines: 1,
          ),
        ],
      ),
    );
  }
}
