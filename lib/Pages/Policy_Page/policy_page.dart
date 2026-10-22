import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:delego/constants/backend.dart';
import 'package:delego/widgets/neon.dart';

class PolicyPage extends StatelessWidget {
  const PolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Policies",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Neon.pink,
      ),
      body: const Center(
        child: Text("Select a policy from the drawer dropdown."),
      ),
    );
  }
}

class PdfViewerPage extends StatelessWidget {
  final String pdfAsset;
  final String title;

  const PdfViewerPage(
      {super.key, required this.pdfAsset, this.title = 'Policy'});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SfPdfViewer.asset(pdfAsset),
    );
  }
}

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  static String get webUrl => '${Backend.baseUrl}/privacy';

  Future<void> _openWebPolicy(BuildContext context) async {
    final uri = Uri.parse(webUrl);
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open web privacy policy')),
      );
    }
  }

  Widget _section(
    BuildContext context,
    String title,
    String body,
  ) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: textTheme.titleMedium?.copyWith(
              color: Neon.pink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: textTheme.bodyMedium?.copyWith(
              color: scheme.onSurface.withValues(alpha: 0.9),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: scheme.surface,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Neon.pink,
        centerTitle: true,
        title: Text(
          'Privacy Policy',
          style: textTheme.titleLarge?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Open in browser',
            icon: const Icon(Icons.open_in_new_rounded, color: Colors.white),
            onPressed: () => _openWebPolicy(context),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          children: [
            Text(
              'Delego — Mumbai MUN 2026 Privacy Policy',
              style: textTheme.titleLarge?.copyWith(
                color: scheme.onSurface,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last updated: 20 October 2026 · MUN Society, MPSTME (NMIMS Mumbai)',
              style: textTheme.bodySmall?.copyWith(
                color: scheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            _section(
              context,
              '1. What We Collect & Why',
              'When you create a Delego account for Mumbai MUN 2026, we collect:\n'
                  '• Name and Email Address: to identify your account, send your 6-digit verification code and password reset emails, and match your conference registration.\n'
                  '• Contact Phone Number: to verify your delegate registration at the registration desk and reach you for urgent committee or conference logistics.\n'
                  '• Date of Birth (Optional): if provided, used only to verify delegate eligibility.\n'
                  '• Food Preference (Veg / Jain) & Meal Scans: to prepare accurate catering counts and issue your QR meal badge at conference meals (breakfast, lunch, and high tea).\n'
                  '• Camera Access (Staff Only): used solely by Organizing Committee staff to scan delegate QR badges. Camera video is never recorded or uploaded.',
            ),
            _section(
              context,
              '2. How Your Data Is Processed & Stored',
              'Your account profile and meal scan records are transmitted over HTTPS and stored in our cloud backend hosted on Render and Supabase (PostgreSQL). Transactional verification and password-reset emails are delivered through Brevo. We do not sell, rent, or share your personal data with advertisers, and the app does not track you across other apps or websites.',
            ),
            _section(
              context,
              '3. Minors & Student Delegates',
              'Mumbai MUN is an academic Model United Nations conference open to high-school and university delegates (aged 13 and above). Personal data of student delegates is collected strictly for event administration, committee participation, and on-campus meal service. Delegates or their parents/guardians may delete their account or request data removal at any time.',
            ),
            _section(
              context,
              '4. Data Retention',
              'We retain delegate account and meal scan data only for the duration of Mumbai MUN 2026 (30 October – 1 November 2026) and post-conference reconciliation (up to 60 days after the conference concludes), after which conference delegate records are permanently deleted.',
            ),
            _section(
              context,
              '5. Account & Data Deletion',
              'You can permanently delete your account and associated personal data at any time:\n'
                  '• Inside the App: Open Settings (from the side menu) and tap "Delete Account" at the bottom of the screen.\n'
                  '• On the Web / By Email: Visit $webUrl or email secretariat.mumbaimun@gmail.com from your registered email address with the subject "Delete Delego Account".',
            ),
            _section(
              context,
              '6. Contact Us',
              'MUN Society, MPSTME, SVKM\'s NMIMS, Vile Parle (West), Mumbai 400056.\n'
                  'Email: secretariat.mumbaimun@gmail.com\n'
                  'Phone: +91 95600 46431',
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () => _openWebPolicy(context),
              icon: const Icon(Icons.language_rounded, size: 18),
              label: const Text('View Web Version'),
            ),
          ],
        ),
      ),
    );
  }
}
