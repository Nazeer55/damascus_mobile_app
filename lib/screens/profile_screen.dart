import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import '../services/language_service.dart';
import '../screens/auth_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  bool _backgroundGps = true;
  bool _pushNotifications = true;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 700));
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _updatePreference(String field, bool value) async {
    try {
      if (!SupabaseService.isPlaceholder && SupabaseService.client.auth.currentUser != null) {
        await SupabaseService.users.update({field: value}).eq('id', SupabaseService.client.auth.currentUser!.id);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final ls = Provider.of<LanguageService>(context);

    final stats = [
      {'value': '12', 'label_key': 'reports_sent', 'icon': Icons.flag_rounded, 'color': AppTheme.primaryAccent},
      {'value': '47', 'label_key': 'km_contributed', 'icon': Icons.route, 'color': AppTheme.warning},
      {'value': '18', 'label_key': 'active_days', 'icon': Icons.calendar_today, 'color': AppTheme.normal},
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF002623), Color(0xFF054239)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fadeIn,
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Hero header
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Positioned(
                        top: 0,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 180,
                          decoration: BoxDecoration(
                            gradient: RadialGradient(
                              colors: [AppTheme.primaryAccent.withOpacity(0.2), Colors.transparent],
                              radius: 1.2,
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
                        child: Column(
                          children: [
                            Stack(
                              children: [
                                Container(
                                  width: 88, height: 88,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient: const LinearGradient(colors: [AppTheme.primaryAccent, AppTheme.primaryDark], begin: Alignment.topLeft, end: Alignment.bottomRight),
                                    boxShadow: [BoxShadow(color: AppTheme.primaryAccent.withOpacity(0.4), blurRadius: 24, spreadRadius: 4)],
                                  ),
                                  child: const Icon(Icons.person_rounded, size: 46, color: Colors.white),
                                ),
                                Positioned(
                                  bottom: 2, right: 2,
                                  child: Container(width: 22, height: 22, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.normal), child: const Icon(Icons.check, color: Colors.white, size: 13)),
                                ),
                              ],
                            ),
                            const SizedBox(height: 14),
                            Text(ls.t('user_name'), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 24, fontWeight: FontWeight.w800)),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.location_on, color: AppTheme.primaryAccent, size: 13),
                                const SizedBox(width: 3),
                                Text(ls.t('user_location'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // Stats row
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: stats.map((s) {
                        final color = s['color'] as Color;
                        return Expanded(
                          child: Container(
                            margin: EdgeInsets.only(left: s == stats.last ? 0 : 8),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: color.withOpacity(0.2)),
                            ),
                            child: Column(
                              children: [
                                Icon(s['icon'] as IconData, color: color, size: 20),
                                const SizedBox(height: 6),
                                Text(s['value'] as String, style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.w900)),
                                Text(ls.t(s['label_key'] as String), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9), textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Settings section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(ls.t('settings_header'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 12),

                        _buildToggleTile(
                          icon: Icons.gps_fixed, iconColor: AppTheme.primaryAccent,
                          title: ls.t('gps_title'), subtitle: ls.t('gps_subtitle'),
                          value: _backgroundGps,
                          onChanged: (v) { setState(() => _backgroundGps = v); _updatePreference('reporting_enabled', v); },
                        ),
                        const SizedBox(height: 10),
                        _buildToggleTile(
                          icon: Icons.notifications_outlined, iconColor: AppTheme.warning,
                          title: ls.t('notif_title'), subtitle: ls.t('notif_subtitle'),
                          value: _pushNotifications,
                          onChanged: (v) { setState(() => _pushNotifications = v); _updatePreference('notif_enabled', v); },
                        ),
                        const SizedBox(height: 10),

                        // Language toggle tile
                        GestureDetector(
                          onTap: ls.toggle,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: BackdropFilter(
                              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                decoration: BoxDecoration(
                                  color: Colors.white.withOpacity(0.04),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(color: Colors.white.withOpacity(0.07)),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40, height: 40,
                                      decoration: BoxDecoration(color: AppTheme.primaryAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(10)),
                                      child: const Icon(Icons.language, color: AppTheme.primaryAccent, size: 20),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(ls.t('language_title'), style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                                          const SizedBox(height: 2),
                                          Text(ls.t('language_subtitle'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primaryAccent.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(50),
                                        border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.3)),
                                      ),
                                      child: Text(
                                        ls.isArabic ? 'English' : 'العربية',
                                        style: const TextStyle(color: AppTheme.primaryAccent, fontSize: 12, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        Text(ls.t('info_header'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        const SizedBox(height: 12),
                        _buildInfoTile(icon: Icons.info_outline, title: ls.t('version'), trailing: 'v1.0.0'),
                        const SizedBox(height: 10),
                        _buildInfoTile(icon: Icons.security, title: ls.t('privacy'), trailing: null),
                        const SizedBox(height: 10),
                        _buildInfoTile(icon: Icons.help_outline, title: ls.t('help'), trailing: null),

                        const SizedBox(height: 28),

                        GestureDetector(
                          onTap: () async {
                            if (!SupabaseService.isPlaceholder) await SupabaseService.client.auth.signOut();
                            if (context.mounted) {
                              Navigator.of(context, rootNavigator: true).pushReplacement(MaterialPageRoute(builder: (_) => const AuthScreen()));
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(color: AppTheme.danger.withOpacity(0.06), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.danger.withOpacity(0.2))),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.logout, color: AppTheme.danger, size: 18),
                                const SizedBox(width: 10),
                                Text(ls.t('logout'), style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold, fontSize: 15)),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildToggleTile({
    required IconData icon, required Color iconColor,
    required String title, required String subtitle,
    required bool value, required ValueChanged<bool> onChanged,
  }) =>
      ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(color: Colors.white.withOpacity(0.04), borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.white.withOpacity(0.07))),
            child: Row(
              children: [
                Container(width: 40, height: 40, decoration: BoxDecoration(color: iconColor.withOpacity(0.12), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: iconColor, size: 20)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 2),
                      Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                    ],
                  ),
                ),
                Switch.adaptive(
                  value: value, onChanged: onChanged,
                  activeColor: AppTheme.primaryAccent,
                  trackColor: MaterialStateProperty.resolveWith((states) => states.contains(MaterialState.selected) ? AppTheme.primaryAccent.withOpacity(0.3) : Colors.white.withOpacity(0.1)),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _buildInfoTile({required IconData icon, required String title, required String? trailing}) =>
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.white.withOpacity(0.06))),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.textSecondary, size: 18),
            const SizedBox(width: 12),
            Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w500)),
            const Spacer(),
            if (trailing != null) Text(trailing, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)) else const Icon(Icons.chevron_left_rounded, color: AppTheme.textSecondary, size: 18),
          ],
        ),
      );
}
