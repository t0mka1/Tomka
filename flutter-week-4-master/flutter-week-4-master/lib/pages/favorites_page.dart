import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../translations/locale_keys.g.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  final List<Map<String, dynamic>> demoFavorites = const [
    {'name': 'Sneakers', 'price': 45.0, 'icon': Icons.directions_run},
    {'name': 'Watch', 'price': 90.0, 'icon': Icons.watch},
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKeys.favorites.tr(), style: AppTextStyles.title),
            SizedBox(height: 16.h),
            Expanded(
              child: demoFavorites.isEmpty
                  ? Center(
                      child: Text(LocaleKeys.no_favorites.tr(), style: AppTextStyles.caption),
                    )
                  : ListView.separated(
                      itemCount: demoFavorites.length,
                      separatorBuilder: (_, __) => SizedBox(height: 12.h),
                      itemBuilder: (context, index) {
                        final item = demoFavorites[index];
                        return Container(
                          padding: EdgeInsets.all(12.w),
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
                                width: 60.w,
                                height: 60.w,
                                decoration: BoxDecoration(
                                  color: AppColors.primary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  item['icon'] as IconData,
                                  color: AppColors.primary,
                                  size: 28.sp,
                                ),
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['name'] as String, style: AppTextStyles.body),
                                    SizedBox(height: 4.h),
                                    Text('\$${item['price']}', style: AppTextStyles.price),
                                  ],
                                ),
                              ),
                              Icon(Icons.favorite, color: AppColors.favorite, size: 20.sp),
                            ],
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}