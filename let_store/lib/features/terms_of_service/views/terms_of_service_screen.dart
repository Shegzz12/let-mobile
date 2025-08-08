import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/app_textstyles.dart';
import '../../privacy_policy/widgets/info_section.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenSize = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(
            Icons.arrow_back_ios,
            color: isDark ? Colors.white : Colors.black,
          ),
        ),
        title: Text(
          'Terms of Service',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: EdgeInsets.all(screenSize.width * 0.05),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InfoSection(
                title: 'Welcome to Fashion Store',
                content:
                    'By accessing and using this application, you accept and agree to be bound by the terms, privacy and conditions',
              ),
              InfoSection(
                title: 'Welcome to Fashion Store',
                content:
                    'By accessing and using this application, you accept and agree to be bound by the terms, privacy and conditions',
              ),
              InfoSection(
                title: 'Welcome to Fashion Store',
                content:
                    'By accessing and using this application, you accept and agree to be bound by the terms, privacy and conditions',
              ),
              InfoSection(
                title: 'Account Registration',
                content:
                    'By accessing and using this application, you accept and agree to be bound by the terms, privacy and conditions',
              ),
              InfoSection(
                title: 'User Responsibilities',
                content:
                    'By accessing and using this application, you accept and agree to be bound by the terms, privacy and conditions',
              ),
              InfoSection(
                title: 'Privacy Policy',
                content:
                    'By accessing and using this application, you accept and agree to be bound by the terms, privacy and conditions',
              ),
              InfoSection(
                title: 'Intellectual Property',
                content:
                    'By accessing and using this application, you accept and agree to be bound by the terms, privacy and conditions',
              ),
              InfoSection(
                title: 'Termination',
                content:
                    'By accessing and using this application, you accept and agree to be bound by the terms, privacy and conditions',
              ),
              SizedBox(height: 24),
              Text(
                'Last updated: July, 2025',
                style: AppTextStyle.withColor(
                  AppTextStyle.bodySmall,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
