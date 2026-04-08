import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import '../services/language_service.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ReportScreen extends StatefulWidget {
  const ReportScreen({Key? key}) : super(key: key);
  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> with TickerProviderStateMixin {
  final _descriptionController = TextEditingController();
  String _selectedType = 'Traffic Jam';
  bool _isSubmitting = false;
  final MapController _mapController = MapController();
  static const LatLng _damascusCenter = LatLng(33.5138, 36.2765);
  late AnimationController _successController;
  bool _submitted = false;

  final List<Map<String, dynamic>> _incidentTypes = [
    {'key': 'Traffic Jam', 'label_key': 'type_jam', 'icon': Icons.traffic, 'color': AppTheme.warning},
    {'key': 'Accident', 'label_key': 'type_accident', 'icon': Icons.car_crash, 'color': AppTheme.danger},
    {'key': 'Road Closed', 'label_key': 'type_closed', 'icon': Icons.block, 'color': AppTheme.closed},
    {'key': 'Flooding', 'label_key': 'type_flooding', 'icon': Icons.water, 'color': const Color(0xFF2979FF)},
    {'key': 'Construction', 'label_key': 'type_construction', 'icon': Icons.construction, 'color': const Color(0xFFFF6F00)},
    {'key': 'Other', 'label_key': 'type_other', 'icon': Icons.more_horiz, 'color': AppTheme.textSecondary},
  ];

  @override
  void initState() {
    super.initState();
    _successController = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
  }

  @override
  void dispose() {
    _successController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _submitReport() async {
    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 1200));
    try {
      if (!SupabaseService.isPlaceholder) {
        await SupabaseService.incidentReports.insert({
          'user_id': SupabaseService.client.auth.currentUser?.id,
          'type': _selectedType,
          'lat': 33.5138, 'lng': 36.2765,
          'description': _descriptionController.text,
          'status': 'pending',
          'created_at': DateTime.now().toIso8601String(),
        });
      }
      if (mounted) {
        setState(() { _isSubmitting = false; _submitted = true; });
        _successController.forward();
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() { _submitted = false; _descriptionController.clear(); });
            _successController.reset();
          }
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ls = Provider.of<LanguageService>(context);
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF002623), Color(0xFF054239), Color(0xFF03342C)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      children: [
                        Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [Color(0xFF2ECC71), AppTheme.primaryAccent]),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add_location_alt, color: Colors.white, size: 22),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(ls.t('report_title'), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 22, fontWeight: FontWeight.w800)),
                            Text(ls.t('report_subtitle'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Map Location Picker
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.3)),
                        ),
                        child: Stack(
                          children: [
                            FlutterMap(
                              mapController: _mapController,
                              options: MapOptions(
                                initialCenter: _damascusCenter,
                                initialZoom: 14.0,
                                minZoom: 10,
                                maxZoom: 18,
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
                                  subdomains: const ['a', 'b', 'c', 'd'],
                                  userAgentPackageName: 'com.damascustraffic.app',
                                ),
                              ],
                            ),
                            Center(
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 30),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.location_on, color: AppTheme.danger, size: 40),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(color: Colors.black.withOpacity(0.6), borderRadius: BorderRadius.circular(50)),
                                      child: Text(ls.t('drag_location'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Positioned(
                              top: 10, right: 10,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: BackdropFilter(
                                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(color: Colors.black.withOpacity(0.5), borderRadius: BorderRadius.circular(8)),
                                    child: Text(ls.t('location_name'), style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 12, left: 12, right: 12,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  final center = _mapController.camera.center;
                                  final coords = '${center.latitude.toStringAsFixed(5)}, ${center.longitude.toStringAsFixed(5)}';
                                  
                                  setState(() {
                                    if (!_descriptionController.text.contains(coords)) {
                                      if (_descriptionController.text.isEmpty) {
                                        _descriptionController.text = 'Location: $coords\n';
                                      } else {
                                        _descriptionController.text += '\nLocation: $coords';
                                      }
                                    }
                                  });

                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text(ls.t('location_name') + ' - ' + ls.t('select_location')),
                                    backgroundColor: AppTheme.primaryDark,
                                    duration: const Duration(seconds: 2),
                                    behavior: SnackBarBehavior.floating,
                                  ));
                                },
                                icon: const Icon(Icons.check, size: 18),
                                label: Text(ls.t('select_location'), style: const TextStyle(fontWeight: FontWeight.bold)),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryDark,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 10),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  elevation: 4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Incident Types
                    Text(ls.t('incident_type'), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 3,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 10, mainAxisSpacing: 10, childAspectRatio: 1.1,
                      children: _incidentTypes.map((type) {
                        final isSelected = _selectedType == type['key'];
                        final color = type['color'] as Color;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedType = type['key']),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: isSelected ? color.withOpacity(0.15) : Colors.white.withOpacity(0.04),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: isSelected ? color : Colors.white.withOpacity(0.08), width: isSelected ? 1.5 : 1),
                              boxShadow: isSelected ? [BoxShadow(color: color.withOpacity(0.3), blurRadius: 12)] : [],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(type['icon'], color: isSelected ? color : AppTheme.textSecondary, size: 26),
                                const SizedBox(height: 6),
                                Text(ls.t(type['label_key']), style: TextStyle(color: isSelected ? color : AppTheme.textSecondary, fontSize: 11, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal), textAlign: TextAlign.center),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),

                    const SizedBox(height: 24),

                    // Description
                    Text(ls.t('short_desc'), style: const TextStyle(color: AppTheme.textPrimary, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    TextField(
                      controller: _descriptionController,
                      maxLength: 100, maxLines: 3,
                      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
                      decoration: InputDecoration(
                        hintText: ls.t('desc_hint'),
                        hintStyle: TextStyle(color: AppTheme.textSecondary.withOpacity(0.5)),
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.04),
                        counterStyle: const TextStyle(color: AppTheme.textSecondary),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.08))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryAccent, width: 1.5)),
                      ),
                    ),
                  ],
                ),
              ),

              // Submit button
              Positioned(
                bottom: 16, left: 20, right: 20,
                child: _submitted
                    ? ScaleTransition(
                        scale: CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
                        child: Container(
                          height: 58,
                          decoration: BoxDecoration(color: AppTheme.normal.withOpacity(0.15), borderRadius: BorderRadius.circular(16), border: Border.all(color: AppTheme.normal.withOpacity(0.4))),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.check_circle_outline, color: AppTheme.normal, size: 22),
                              const SizedBox(width: 10),
                              Text(ls.t('report_success'), style: const TextStyle(color: AppTheme.normal, fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                        ),
                      )
                    : GestureDetector(
                        onTap: _isSubmitting ? null : _submitReport,
                        child: Container(
                          height: 58,
                          decoration: BoxDecoration(
                            gradient: _isSubmitting ? null : const LinearGradient(colors: [AppTheme.primaryAccent, AppTheme.primaryDark]),
                            color: _isSubmitting ? AppTheme.cardBackground : null,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: _isSubmitting ? [] : [BoxShadow(color: AppTheme.primaryAccent.withOpacity(0.4), blurRadius: 20, offset: const Offset(0, 8))],
                          ),
                          child: Center(
                            child: _isSubmitting
                                ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: AppTheme.primaryAccent, strokeWidth: 2.5))
                                : Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                                      const SizedBox(width: 10),
                                      Text(ls.t('send_report'), style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Mini map painter removed - using real flutter_map
