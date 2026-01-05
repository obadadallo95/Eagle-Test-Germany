import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../widgets/core/adaptive_page_wrapper.dart';
import 'package:politik_test/l10n/app_localizations.dart';

/// -----------------------------------------------------------------
/// ⚖️ LEGAL SCREEN / RECHTSBILDSCHIRM / الشاشة القانونية
/// -----------------------------------------------------------------
/// Displays legal documents including Privacy Policy, Terms of Use,
/// Intellectual Property Rights, and Impressum.
/// All documents are bilingual (German & Arabic) and rendered from Markdown files.
/// -----------------------------------------------------------------
/// **Deutsch:** Zeigt Rechtsdokumente einschließlich Datenschutzerklärung,
/// Nutzungsbedingungen, geistiges Eigentum und Impressum.
/// -----------------------------------------------------------------
/// **العربية:** يعرض الوثائق القانونية بما في ذلك سياسة الخصوصية،
/// شروط الاستخدام، حقوق الملكية الفكرية، و Impressum.
/// -----------------------------------------------------------------
class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.legal ?? 'Legal Information'),
      ),
      body: AdaptivePageWrapper(
        padding: EdgeInsets.zero,
        enableScroll: false, // ListView يمرر نفسه
        child: ListView(
          padding: EdgeInsets.all(16.w),
          children: [
          _buildLegalTile(
            context,
            icon: Icons.privacy_tip,
            title: l10n?.privacyPolicy ?? 'Privacy Policy',
            subtitle: l10n?.datenschutz ?? 'Datenschutz',
            assetPath: 'assets/legal/privacy_policy.md',
          ),
          SizedBox(height: 12.h),
          _buildLegalTile(
            context,
            icon: Icons.gavel,
            title: l10n?.termsOfUse ?? 'Terms of Use',
            subtitle: l10n?.nutzungsbedingungen ?? 'Nutzungsbedingungen',
            assetPath: 'assets/legal/terms_conditions.md',
          ),
          SizedBox(height: 12.h),
          _buildLegalTile(
            context,
            icon: Icons.copyright,
            title: l10n?.intellectualProperty ?? 'Intellectual Property',
            subtitle: l10n?.geistigesEigentum ?? 'Geistiges Eigentum',
            assetPath: 'assets/legal/ip_rights.md',
          ),
          SizedBox(height: 12.h),
          _buildLegalTile(
            context,
            icon: Icons.info,
            title: l10n?.impressum ?? 'Impressum',
            subtitle: l10n?.legalInformation ?? 'Legal Information',
            assetPath: 'assets/legal/impressum.md',
          ),
        ],
        ),
      ),
    );
  }

  Widget _buildLegalTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required String assetPath,
  }) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 32.sp, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LegalDocumentScreen(
                title: title,
                assetPath: assetPath,
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Screen to display individual legal documents
class LegalDocumentScreen extends StatelessWidget {
  final String title;
  final String assetPath;

  const LegalDocumentScreen({
    super.key,
    required this.title,
    required this.assetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: FutureBuilder<String>(
        future: _loadMarkdownFile(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 64.sp, color: Colors.red),
                  SizedBox(height: 16.h),
                  Text(
                    'Error loading document',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 20.sp),
                  ),
                  SizedBox(height: 8.h),
                  Text(snapshot.error.toString()),
                ],
              ),
            );
          }

          return Markdown(
            data: snapshot.data ?? '',
            styleSheet: MarkdownStyleSheet(
              h1: Theme.of(context).textTheme.headlineLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
              h2: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              p: Theme.of(context).textTheme.bodyLarge,
              strong: const TextStyle(fontWeight: FontWeight.bold),
              blockquote: TextStyle(
                color: Colors.grey[700],
                fontStyle: FontStyle.italic,
              ),
            ),
            padding: EdgeInsets.all(16.w),
          );
        },
      ),
    );
  }

  Future<String> _loadMarkdownFile() async {
    try {
      return await rootBundle.loadString(assetPath);
    } catch (e) {
      throw Exception('Failed to load document: $e');
    }
  }
}

