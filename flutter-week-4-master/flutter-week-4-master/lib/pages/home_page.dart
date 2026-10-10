import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../translations/locale_keys.g.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(LocaleKeys.home.tr(), style: AppTextStyles.title),
              SizedBox(height: 8.h),
              Text(LocaleKeys.welcome.tr(), style: AppTextStyles.subtitle),
              SizedBox(height: 4.h),
              Text(LocaleKeys.home_subtitle.tr(), style: AppTextStyles.caption),
              SizedBox(height: 20.h),
              _buildCard(
                icon: Icons.fiber_new,
                title: LocaleKeys.card_title_1.tr(),
                desc: LocaleKeys.card_desc_1.tr(),
              ),
              SizedBox(height: 12.h),
              _buildCard(
                icon: Icons.local_offer,
                title: LocaleKeys.card_title_2.tr(),
                desc: LocaleKeys.card_desc_2.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required IconData icon,
    required String title,
    required String desc,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(icon, color: AppColors.primary, size: 26.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: AppTextStyles.subtitle),
                SizedBox(height: 4.h),
                Text(desc, style: AppTextStyles.caption),
              ],
            ),
          ),
        ],
      ),
    );
  }
}