
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/language_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  bool _showLegend = false;
  final MapController _mapController = MapController();
  static const LatLng _damascusCenter = LatLng(33.5138, 36.2765);

  final List<Map<String, dynamic>> _roads = [
    {'name': 'Airport Road', 'status': 'heavy', 'points': [LatLng(33.4950, 36.2400), LatLng(33.5050, 36.2600), LatLng(33.5138, 36.2765)]},
    {'name': 'Al-Thawra St', 'status': 'normal', 'points': [LatLng(33.5138, 36.2765), LatLng(33.5200, 36.2900), LatLng(33.5280, 36.3050)]},
    {'name': 'Al-Rais Bridge', 'status': 'moderate', 'points': [LatLng(33.5070, 36.2800), LatLng(33.5138, 36.2765), LatLng(33.5060, 36.2700)]},
    {'name': 'Sahnaya Rd', 'status': 'normal', 'points': [LatLng(33.5350, 36.2600), LatLng(33.5250, 36.2680), LatLng(33.5138, 36.2765)]},
    {'name': 'Baghdad St', 'status': 'closed', 'points': [LatLng(33.5200, 36.3100), LatLng(33.5150, 36.3000), LatLng(33.5100, 36.2900)]},
    {'name': 'Mezzeh Rd', 'status': 'moderate', 'points': [LatLng(33.5138, 36.2765), LatLng(33.5100, 36.2550), LatLng(33.5050, 36.2350)]},
  ];

  final List<Map<String, dynamic>> _nearbyAlerts = [
    {'street': 'طريق المطار الدولي', 'street_en': 'International Airport Rd', 'severity': 'heavy', 'distance': '1.2 km', 'time_ar': 'منذ 3 دقائق', 'time_en': '3 min ago', 'icon': Icons.warning_rounded},
    {'street': 'جسر الرئيس', 'street_en': 'Al-Rais Bridge', 'severity': 'moderate', 'distance': '2.5 km', 'time_ar': 'منذ 8 دقائق', 'time_en': '8 min ago', 'icon': Icons.traffic},
    {'street': 'شارع الثورة', 'street_en': 'Al-Thawra Street', 'severity': 'normal', 'distance': '3.8 km', 'time_ar': 'منذ 12 دقيقة', 'time_en': '12 min ago', 'icon': Icons.check_circle_outline},
    {'street': 'باب توما', 'street_en': 'Bab Touma', 'severity': 'closed', 'distance': '4.1 km', 'time_ar': 'منذ 25 دقيقة', 'time_en': '25 min ago', 'icon': Icons.do_not_disturb_on},
  ];

  Color _statusColor(String s) {
    switch (s) {
      case 'heavy': return AppTheme.danger;
      case 'moderate': return AppTheme.warning;
      case 'closed': return AppTheme.closed;
      default: return AppTheme.normal;
    }
  }

  List<Polyline> get _polylines => _roads.map((road) {
    final color = _statusColor(road['status']);
    return Polyline(
      points: road['points'] as List<LatLng>,
      color: color,
      strokeWidth: road['status'] == 'heavy' ? 6.0 : 4.0,
      borderColor: color.withOpacity(0.3),
      borderStrokeWidth: road['status'] == 'heavy' ? 3.0 : 1.5,
    );
  }).toList();

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.4, end: 1.0).animate(_pulseController);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ls = Provider.of<LanguageService>(context);
    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Real OpenStreetMap
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _damascusCenter,
              initialZoom: 13.5,
              minZoom: 10,
              maxZoom: 18,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
                subdomains: const ['a', 'b', 'c', 'd'],
                userAgentPackageName: 'com.damascustraffic.app',
              ),
              PolylineLayer(polylines: _polylines),
              MarkerLayer(markers: [
                Marker(
                  point: _damascusCenter,
                  width: 44, height: 44,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryAccent,
                      boxShadow: [BoxShadow(color: AppTheme.primaryAccent.withOpacity(0.6), blurRadius: 16, spreadRadius: 4)],
                    ),
                    child: const Icon(Icons.location_city, color: Colors.white, size: 20),
                  ),
                ),
              ]),
            ],
          ),

          // Top gradient
          Positioned(
            top: 0, left: 0, right: 0,
            height: MediaQuery.of(context).size.height * 0.28,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [const Color(0xFF002623).withOpacity(0.95), Colors.transparent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),

          // Header + Stats
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(ls.t('traffic_map'), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
                          Text(ls.t('live_now'), style: TextStyle(color: AppTheme.primaryAccent.withOpacity(0.8), fontSize: 12)),
                        ],
                      ),
                      Row(
                        children: [
                          _iconButton(icon: Icons.layers_outlined, onTap: () => setState(() => _showLegend = !_showLegend)),
                          const SizedBox(width: 8),
                          _iconButton(icon: Icons.my_location, onTap: () => _mapController.move(_damascusCenter, 13.5)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildStatCard('5', ls.t('congested'), Icons.traffic, AppTheme.warning),
                      const SizedBox(width: 10),
                      _buildStatCard('2', ls.t('accidents'), Icons.emergency, AppTheme.danger),
                      const SizedBox(width: 10),
                      _buildStatCard('12', ls.t('reports'), Icons.people_outline, AppTheme.primaryAccent),
                    ],
                  ),
                  if (_showLegend) ...[
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.55),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.white.withOpacity(0.1)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _legendItem(ls.t('clear'), AppTheme.normal),
                              _legendItem(ls.t('moderate'), AppTheme.warning),
                              _legendItem(ls.t('heavy'), AppTheme.danger),
                              _legendItem(ls.t('closed'), AppTheme.closed),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Pulsing Alert Banner
          Positioned(
            top: MediaQuery.of(context).padding.top + 165,
            left: 16, right: 16,
            child: FadeTransition(
              opacity: _pulseAnim,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: AppTheme.danger.withOpacity(0.88),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [BoxShadow(color: AppTheme.danger.withOpacity(0.4), blurRadius: 20, spreadRadius: 1)],
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(color: Colors.white.withOpacity(0.2), shape: BoxShape.circle),
                          child: const Icon(Icons.warning_amber_rounded, color: Colors.white, size: 16),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(ls.t('warning_title'), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                              const SizedBox(height: 1),
                              Text(ls.t('warning_body'), style: const TextStyle(color: Colors.white70, fontSize: 10)),
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_left_rounded, color: Colors.white70),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Bottom Nearby Alerts
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF002623).withOpacity(0.95),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                    border: Border(top: BorderSide(color: AppTheme.primaryAccent.withOpacity(0.2), width: 1)),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        margin: const EdgeInsets.only(top: 12, bottom: 4),
                        width: 36, height: 3.5,
                        decoration: BoxDecoration(color: AppTheme.textSecondary.withOpacity(0.3), borderRadius: BorderRadius.circular(2)),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 6, 20, 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(ls.t('nearby_alerts'), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppTheme.danger.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(50),
                                border: Border.all(color: AppTheme.danger.withOpacity(0.3)),
                              ),
                              child: Text(ls.t('alerts_count'), style: const TextStyle(color: AppTheme.danger, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 180,
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                          itemCount: _nearbyAlerts.length,
                          itemBuilder: (ctx, i) => _buildAlertTile(_nearbyAlerts[i], ls),
                        ),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertTile(Map<String, dynamic> alert, LanguageService ls) {
    final color = _statusColor(alert['severity']);
    final street = ls.isArabic ? alert['street'] : alert['street_en'];
    final time = ls.isArabic ? alert['time_ar'] : alert['time_en'];
    final label = ls.t(alert['severity'] == 'heavy' ? 'heavy_traffic' : alert['severity'] == 'moderate' ? 'moderate_traffic' : alert['severity'] == 'closed' ? 'road_closed' : 'clear_traffic');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: color.withOpacity(0.06), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.2))),
      child: Row(
        children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(10)), child: Icon(alert['icon'], color: color, size: 18)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(street, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Row(
                  children: [
                    Container(padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2), decoration: BoxDecoration(color: color.withOpacity(0.15), borderRadius: BorderRadius.circular(50)), child: Text(label, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold))),
                    const SizedBox(width: 8),
                    Text(time, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10)),
                  ],
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Icon(Icons.location_on, color: AppTheme.textSecondary, size: 13),
              Text(alert['distance'], style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11, fontWeight: FontWeight.w600)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon, Color color) => Expanded(
    child: ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(14), border: Border.all(color: color.withOpacity(0.3))),
          child: Column(children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 6),
            Text(value, style: TextStyle(color: color, fontSize: 22, fontWeight: FontWeight.w900)),
            Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 9), textAlign: TextAlign.center),
          ]),
        ),
      ),
    ),
  );

  Widget _iconButton({required IconData icon, required VoidCallback onTap}) => GestureDetector(
    onTap: onTap,
    child: ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 42, height: 42,
          decoration: BoxDecoration(color: Colors.black.withOpacity(0.45), borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white.withOpacity(0.12))),
          child: Icon(icon, color: AppTheme.textSecondary, size: 20),
        ),
      ),
    ),
  );

  Widget _legendItem(String label, Color color) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(width: 24, height: 4, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2), boxShadow: [BoxShadow(color: color.withOpacity(0.5), blurRadius: 4)])),
      const SizedBox(width: 5),
      Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 10, fontWeight: FontWeight.w500)),
    ],
  );
}
