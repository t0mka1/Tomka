import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../translations/locale_keys.g.dart';

class Product {
  final String name;
  final double price;
  final IconData icon;
  bool isFavorite;

  Product({
    required this.name,
    required this.price,
    required this.icon,
    this.isFavorite = false,
  });
}

class CatalogPage extends StatefulWidget {
  const CatalogPage({super.key});

  @override
  State<CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<CatalogPage> {
  final List<Product> products = [
    Product(name: 'Sneakers', price: 45.0, icon: Icons.directions_run),
    Product(name: 'Backpack', price: 30.0, icon: Icons.backpack),
    Product(name: 'Watch', price: 90.0, icon: Icons.watch),
    Product(name: 'Headphones', price: 60.0, icon: Icons.headphones),
    Product(name: 'Sunglasses', price: 25.0, icon: Icons.visibility),
    Product(name: 'Cap', price: 15.0, icon: Icons.sports_baseball),
  ];

  void toggleFavorite(int index) {
    setState(() {
      products[index].isFavorite = !products[index].isFavorite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(LocaleKeys.catalog.tr(), style: AppTextStyles.title),
            SizedBox(height: 16.h),
            Expanded(
              child: GridView.builder(
                itemCount: products.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 0.8,
                ),
                itemBuilder: (context, index) {
                  final product = products[index];
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: double.infinity,
                          height: 80.h,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Icon(
                            product.icon,
                            color: AppColors.primary,
                            size: 36.sp,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(product.name, style: AppTextStyles.body),
                        SizedBox(height: 4.h),
                        Text('\$${product.price}', style: AppTextStyles.price),
                        const Spacer(),
                        GestureDetector(
                          onTap: () => toggleFavorite(index),
                          child: Row(
                            children: [
                              Icon(
                                product.isFavorite
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: AppColors.favorite,
                                size: 18.sp,
                              ),
                              SizedBox(width: 4.w),
                              Expanded(
                                child: Text(
                                  LocaleKeys.add_to_favorites.tr(),
                                  style: AppTextStyles.caption,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
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