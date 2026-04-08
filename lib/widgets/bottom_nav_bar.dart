import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/home_screen.dart';
import '../screens/report_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/profile_screen.dart';
import '../services/language_service.dart';
import '../theme/app_theme.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);
  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    ReportScreen(),
    AlertsScreen(),
    ProfileScreen(),
  ];

  final List<_NavEntry> _entries = [
    _NavEntry(icon: Icons.map_outlined, activeIcon: Icons.map, labelKey: 'nav_map'),
    _NavEntry(icon: Icons.add_circle_outline, activeIcon: Icons.add_circle, labelKey: 'nav_report', isCenter: true),
    _NavEntry(icon: Icons.notifications_outlined, activeIcon: Icons.notifications, labelKey: 'nav_alerts', badge: 2),
    _NavEntry(icon: Icons.person_outline, activeIcon: Icons.person, labelKey: 'nav_profile'),
  ];

  void _onTap(int index) {
    if (index == _currentIndex) return;
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final ls = Provider.of<LanguageService>(context);
    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(28),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              height: 70,
              decoration: BoxDecoration(
                color: const Color(0xFF054239).withOpacity(0.94),
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.2)),
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 24, offset: const Offset(0, 8))],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(_entries.length, (i) {
                  final entry = _entries[i];
                  final isActive = _currentIndex == i;

                  if (entry.isCenter) {
                    return GestureDetector(
                      onTap: () => _onTap(i),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [AppTheme.primaryAccent, AppTheme.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: AppTheme.primaryAccent.withOpacity(0.5), blurRadius: 16, spreadRadius: 1)],
                        ),
                        child: Icon(isActive ? entry.activeIcon : entry.icon, color: Colors.white, size: 26),
                      ),
                    );
                  }

                  return GestureDetector(
                    onTap: () => _onTap(i),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isActive ? AppTheme.primaryAccent.withOpacity(0.15) : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Icon(isActive ? entry.activeIcon : entry.icon, color: isActive ? AppTheme.primaryAccent : AppTheme.textSecondary, size: 24),
                              if (entry.badge != null && entry.badge! > 0)
                                Positioned(
                                  top: -4, right: -6,
                                  child: Container(
                                    width: 16, height: 16,
                                    decoration: const BoxDecoration(color: AppTheme.danger, shape: BoxShape.circle),
                                    child: Center(child: Text('${entry.badge}', style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold))),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 3),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(color: isActive ? AppTheme.primaryAccent : AppTheme.textSecondary, fontSize: 10, fontWeight: isActive ? FontWeight.bold : FontWeight.normal),
                            child: Text(ls.t(entry.labelKey)),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavEntry {
  final IconData icon;
  final IconData activeIcon;
  final String labelKey;
  final bool isCenter;
  final int? badge;

  const _NavEntry({
    required this.icon,
    required this.activeIcon,
    required this.labelKey,
    this.isCenter = false,
    this.badge,
  });
}
