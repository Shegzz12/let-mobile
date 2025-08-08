import 'package:flutter/material.dart';

import '../../../utils/app_textstyles.dart';
import 'question_card.dart';

class PopularQuestionsSection extends StatelessWidget {
  const PopularQuestionsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Popular Questions',
            style: AppTextStyle.withColor(
              AppTextStyle.h3,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          SizedBox(height: 16),
          QuestionCard(
            title: 'How to track my order?',
            icon: Icons.local_shipping_outlined,
          ),
          SizedBox(height: 12),
          QuestionCard(
            title: 'How to return an item?',
            icon: Icons.local_shipping_outlined,
          ),
        ],
      ),
    );
  }
}
