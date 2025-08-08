import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../utils/app_textstyles.dart';
import '../widgets/edit_profile_screen.dart';
import '../widgets/profile_image.dart';

class EditProfileScreen extends StatelessWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Get.back(),
          icon: Icon(Icons.arrow_back_ios),
        ),
        title: Text(
          'Edit Profile',
          style: AppTextStyle.withColor(
            AppTextStyle.h3,
            isDark ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 24),
            ProfileImage(),
            SizedBox(height: 24),
            ProfileForm(),
          ], ////////////////////////////
        ),
      ),
    );
  }
}
