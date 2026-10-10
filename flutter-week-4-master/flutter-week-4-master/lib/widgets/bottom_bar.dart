import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/constants/app_colors.dart';
import '../translations/locale_keys.g.dart';
import '../pages/home_page.dart';
import '../pages/catalog_page.dart';
import '../pages/favorites_page.dart';
import '../pages/profile_page.dart';

class BottomBar extends StatefulWidget {
  const BottomBar({super.key});

  @override
  State<BottomBar> createState() => _BottomBarState();
}

class _BottomBarState extends State<BottomBar> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomePage(),
    CatalogPage(),
    FavoritesPage(),
    ProfilePage(),
  ];

  void onTap(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: const Icon(Icons.home),
            label: LocaleKeys.home.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.shopping_bag),
            label: LocaleKeys.catalog.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.favorite),
            label: LocaleKeys.favorites.tr(),
          ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.person),
            label: LocaleKeys.profile.tr(),
          ),
        ],
      ),
    );
  }
}