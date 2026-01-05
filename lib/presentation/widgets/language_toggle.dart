import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/language_provider.dart';

/// Widget لتبديل اللغة بين الألمانية والعربية
class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final isArabic = currentLocale.languageCode == 'ar';

    return IconButton(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isArabic ? Icons.language : Icons.translate,
            color: Colors.white,
          ),
          const SizedBox(width: 4),
          Text(
            isArabic ? "DE" : "AR",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
      onPressed: () {
        ref.read(languageProvider.notifier).toggleLanguage();
      },
      tooltip: isArabic ? "Switch to German" : "التبديل إلى العربية",
    );
  }
}

