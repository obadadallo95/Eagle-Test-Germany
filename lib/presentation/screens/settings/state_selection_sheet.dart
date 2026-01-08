import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/storage/user_preferences_service.dart';
import '../../providers/locale_provider.dart';

/// Modal Bottom Sheet لاختيار الولاية الفيدرالية
class StateSelectionSheet extends ConsumerStatefulWidget {
  const StateSelectionSheet({super.key});

  @override
  ConsumerState<StateSelectionSheet> createState() => _StateSelectionSheetState();
}

class _StateSelectionSheetState extends ConsumerState<StateSelectionSheet> {
  String? _selectedState;

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
    _loadCurrentState();
  }

  Future<void> _loadCurrentState() async {
    final currentState = await UserPreferencesService.getSelectedState();
    if (mounted) {
      setState(() {
        _selectedState = currentState;
      });
    }
  }

  Future<void> _selectState(String? stateCode) async {
    if (stateCode != null) {
      await UserPreferencesService.saveSelectedState(stateCode);
      if (mounted) {
        setState(() {
          _selectedState = stateCode;
        });
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLocale = ref.watch(localeProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    return ConstrainedBox(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    isArabic ? 'الولاية الفيدرالية' : 'Federal State',
                    style: GoogleFonts.poppins(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, size: 24.sp, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: Colors.grey.shade800),
          // States List
          Flexible(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: _germanStates.length,
              itemBuilder: (context, index) {
                final state = _germanStates[index];
                final isSelected = _selectedState == state['code'];
                
                return ListTile(
                  title: Text(
                    isArabic
                        ? '${state['nameAr']} (${state['name']})'
                        : '${state['name']} (${state['nameAr']})',
                    style: GoogleFonts.poppins(
                      fontSize: 16.sp,
                      color: Colors.white,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: Colors.green, size: 24.sp)
                      : null,
                  selected: isSelected,
                  onTap: () => _selectState(state['code']),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

