import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../translations/locale_keys.g.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKeys.profile.tr(), style: AppTextStyles.title),
            SizedBox(height: 20.h),
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 45.r,
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    child: Icon(Icons.person, color: AppColors.primary, size: 45.sp),
                  ),
                  SizedBox(height: 12.h),
                  Text(LocaleKeys.username.tr(), style: AppTextStyles.subtitle),
                ],
              ),
            ),
            SizedBox(height: 24.h),
            _buildSettingItem(
              icon: Icons.language,
              title: LocaleKeys.language.tr(),
              trailing: DropdownButton<Locale>(
                value: context.locale,
                underline: const SizedBox(),
                items: const [
                  DropdownMenuItem(value: Locale('ru'), child: Text('RU')),
                  DropdownMenuItem(value: Locale('en'), child: Text('EN')),
                  DropdownMenuItem(value: Locale('kk'), child: Text('KK')),
                ],
                onChanged: (locale) {
                  if (locale != null) context.setLocale(locale);
                },
              ),
            ),
            SizedBox(height: 12.h),
            _buildSettingItem(
              icon: Icons.dark_mode,
              title: LocaleKeys.theme.tr(),
              trailing: Switch(
                value: false,
                activeColor: AppColors.primary,
                onChanged: (value) {},
              ),
            ),
            SizedBox(height: 12.h),
            _buildSettingItem(
              icon: Icons.info_outline,
              title: LocaleKeys.about_app.tr(),
              trailing: Text(LocaleKeys.app_version.tr(), style: AppTextStyles.caption),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required Widget trailing,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14.r),
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
          Icon(icon, color: AppColors.primary, size: 22.sp),
          SizedBox(width: 12.w),
          Expanded(child: Text(title, style: AppTextStyles.body)),
          trailing,
        ],
      ),
    );
  }
}