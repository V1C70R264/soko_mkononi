import 'package:flutter/material.dart';
import 'package:e_commerce/presentation/widgets/common/app_back_button.dart';

class PrivacyTermsScreen extends StatelessWidget {
  const PrivacyTermsScreen({super.key});

  static const _sections = [
    (
      '1. Information We Collect',
      'We collect information you provide directly, such as your name, email, phone number, '
          'shipping addresses, and order history, to operate and improve Soko Mkononi.',
    ),
    (
      '2. How We Use Your Information',
      'Your information is used to process orders, deliver products, send order and account '
          'notifications, and improve our services. We do not sell your personal data to third parties.',
    ),
    (
      '3. Data Security',
      'We take reasonable technical and organizational measures to protect your data from '
          'unauthorized access, alteration, or disclosure.',
    ),
    (
      '4. Your Rights',
      'You may access, update, or request deletion of your personal information at any time '
          'through your profile, or by contacting support.',
    ),
    (
      '5. Changes to This Policy',
      'We may update this policy from time to time. Continued use of the app after changes '
          'constitutes acceptance of the updated policy.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 16, 8),
              child: Row(
                children: [
                  const AppBackButton(),
                  const Expanded(
                    child: Text(
                      'Privacy & Terms',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black87,
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                  const SizedBox(width: 42),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                children: [
                  Text(
                    'Last updated: October 2026',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                  ),
                  const SizedBox(height: 16),
                  ..._sections.map(
                    (section) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            section.$1,
                            style: const TextStyle(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            section.$2,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade700,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
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
}