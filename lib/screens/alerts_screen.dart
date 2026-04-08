import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/language_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);
  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  String _selectedFilter = 'all';

  final List<Map<String, dynamic>> _alerts = [
    {
      'title_ar': 'حادث تصادم خطير', 'title_en': 'Serious Traffic Accident',
      'body_ar': 'تصادم بين مركبتين على طريق المطار الدولي، يرجى تجنب المنطقة واتخاذ طرق بديلة',
      'body_en': 'Two-vehicle collision on International Airport Road, please avoid the area and use alternative routes',
      'severity': 'high', 'street_ar': 'طريق المطار الدولي', 'street_en': 'International Airport Rd',
      'time_ar': 'منذ 5 دقائق', 'time_en': '5 min ago', 'icon': Icons.car_crash,
    },
    {
      'title_ar': 'ازدحام مروري شديد', 'title_en': 'Heavy Traffic Congestion',
      'body_ar': 'ازدحام خانق على جسر الرئيس بسبب أعمال صيانة مفاجئة، التأخير أكثر من 25 دقيقة',
      'body_en': 'Severe congestion on Al-Rais Bridge due to sudden maintenance work, delay over 25 minutes',
      'severity': 'high', 'street_ar': 'جسر الرئيس', 'street_en': 'Al-Rais Bridge',
      'time_ar': 'منذ 12 دقيقة', 'time_en': '12 min ago', 'icon': Icons.traffic,
    },
    {
      'title_ar': 'طريق مغلق جزئياً', 'title_en': 'Partial Road Closure',
      'body_ar': 'إغلاق جزئي لشارع بغداد بسبب حفريات، حارتان من أصل أربع مغلقتان',
      'body_en': 'Partial closure on Baghdad Street due to excavation, two out of four lanes closed',
      'severity': 'medium', 'street_ar': 'شارع بغداد', 'street_en': 'Baghdad Street',
      'time_ar': 'منذ 28 دقيقة', 'time_en': '28 min ago', 'icon': Icons.do_not_disturb_on,
    },
    {
      'title_ar': 'تحسّن في حركة المرور', 'title_en': 'Traffic Improving',
      'body_ar': 'عادت الحركة إلى طبيعتها على شارع الثورة بعد رفع الحادث السابق',
      'body_en': 'Traffic back to normal on Al-Thawra Street after earlier incident was cleared',
      'severity': 'low', 'street_ar': 'شارع الثورة', 'street_en': 'Al-Thawra Street',
      'time_ar': 'منذ 45 دقيقة', 'time_en': '45 min ago', 'icon': Icons.check_circle_outline,
    },
    {
      'title_ar': 'فيضان خفيف', 'title_en': 'Minor Flooding',
      'body_ar': 'تجمع مياه الأمطار عند نفق ميسلون مما يسبب بطءاً في الحركة',
      'body_en': 'Rainwater accumulation at Maysaloun tunnel causing slow traffic',
      'severity': 'medium', 'street_ar': 'نفق ميسلون', 'street_en': 'Maysaloun Tunnel',
      'time_ar': 'منذ ساعة', 'time_en': '1 hour ago', 'icon': Icons.water,
    },
  ];

  List<Map<String, dynamic>> _filteredAlerts(String filterKey) {
    if (filterKey == 'all') return _alerts;
    final map = {'filter_severe': 'high', 'filter_moderate': 'medium', 'filter_info': 'low'};
    return _alerts.where((a) => a['severity'] == map[filterKey]).toList();
  }

  Color _severityColor(String s) {
    switch (s) {
      case 'high': return AppTheme.danger;
      case 'medium': return AppTheme.warning;
      default: return AppTheme.normal;
    }
  }

  @override
  Widget build(BuildContext context) {
    final ls = Provider.of<LanguageService>(context);
    final filters = ['filter_all', 'filter_severe', 'filter_moderate', 'filter_info'];
    final filtered = _filteredAlerts(_selectedFilter);

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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ls.t('alerts_title'), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 28, fontWeight: FontWeight.w900)),
                            Text(ls.t('updated_now'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppTheme.danger.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                              ),
                              child: Row(
                                children: [
                                  Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppTheme.danger)),
                                  const SizedBox(width: 6),
                                  Text(ls.t('live_badge'), style: const TextStyle(color: AppTheme.danger, fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Summary chips
                    Row(
                      children: [
                        _summaryChip('2', ls.t('critical'), AppTheme.danger),
                        const SizedBox(width: 8),
                        _summaryChip('2', ls.t('warnings'), AppTheme.warning),
                        const SizedBox(width: 8),
                        _summaryChip('1', ls.t('info'), AppTheme.normal),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Filter chips
                    SizedBox(
                      height: 36,
                      child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemCount: filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 8),
                        itemBuilder: (ctx, i) {
                          final key = filters[i];
                          final isActive = _selectedFilter == key;
                          return GestureDetector(
                            onTap: () => setState(() => _selectedFilter = key),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                              decoration: BoxDecoration(
                                color: isActive ? AppTheme.primaryAccent : Colors.white.withOpacity(0.06),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: isActive ? AppTheme.primaryAccent : Colors.white.withOpacity(0.1)),
                              ),
                              child: Text(ls.t(key), style: TextStyle(color: isActive ? Colors.white : AppTheme.textSecondary, fontSize: 13, fontWeight: isActive ? FontWeight.bold : FontWeight.normal)),
                            ),
                          );
                        },
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ),
              ),

              // Alert list
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.notifications_off_outlined, color: AppTheme.textSecondary.withOpacity(0.3), size: 60),
                            const SizedBox(height: 12),
                            Text(ls.t('no_alerts'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                        itemCount: filtered.length,
                        itemBuilder: (ctx, i) {
                          final alert = filtered[i];
                          final color = _severityColor(alert['severity']);
                          final title = ls.isArabic ? alert['title_ar'] : alert['title_en'];
                          final body = ls.isArabic ? alert['body_ar'] : alert['body_en'];
                          final street = ls.isArabic ? alert['street_ar'] : alert['street_en'];
                          final time = ls.isArabic ? alert['time_ar'] : alert['time_en'];
                          return TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: 1),
                            duration: Duration(milliseconds: 300 + i * 80),
                            curve: Curves.easeOut,
                            builder: (_, v, child) => Opacity(opacity: v, child: Transform.translate(offset: Offset(0, 20 * (1 - v)), child: child)),
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(color: color.withOpacity(0.05), borderRadius: BorderRadius.circular(18), border: Border.all(color: color.withOpacity(0.2))),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(18),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(width: 46, height: 46, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(12)), child: Icon(alert['icon'], color: color, size: 22)),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15), maxLines: 1, overflow: TextOverflow.ellipsis),
                                                  const SizedBox(height: 2),
                                                  Row(
                                                    children: [
                                                      Container(
                                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                        decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(50), border: Border.all(color: color.withOpacity(0.3))),
                                                        child: Text(ls.t(alert['severity'] == 'high' ? 'severity_high' : alert['severity'] == 'medium' ? 'severity_medium' : 'severity_low'), style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold)),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(time, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 12),
                                        Text(body, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13, height: 1.5)),
                                        const SizedBox(height: 12),
                                        Row(
                                          children: [
                                            const Icon(Icons.location_on, color: AppTheme.textSecondary, size: 13),
                                            const SizedBox(width: 4),
                                            Text(street, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                                            const Spacer(),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                              decoration: BoxDecoration(color: AppTheme.primaryAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.25))),
                                              child: Row(
                                                children: [
                                                  const Icon(Icons.map_outlined, color: AppTheme.primaryAccent, size: 12),
                                                  const SizedBox(width: 4),
                                                  Text(ls.t('view_on_map'), style: const TextStyle(color: AppTheme.primaryAccent, fontSize: 11, fontWeight: FontWeight.w600)),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryChip(String count, String label, Color color) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(color: color.withOpacity(0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withOpacity(0.2))),
      child: Column(
        children: [
          Text(count, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
          Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10), textAlign: TextAlign.center),
        ],
      ),
    ),
  );
}
