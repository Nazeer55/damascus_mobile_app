/// Returns a human-readable relative time string.
/// JS mirror: js/utils/time_ago.js (Damascus_Test web app).
String timeAgo(DateTime dt, {bool arabic = false}) {
  final sec = DateTime.now().difference(dt).inSeconds.clamp(0, double.maxFinite.toInt());
  if (arabic) {
    if (sec < 60)    return 'الآن';
    if (sec < 3600)  return 'منذ ${sec ~/ 60} دقيقة';
    if (sec < 86400) return 'منذ ${sec ~/ 3600} ساعة';
    return 'منذ ${sec ~/ 86400} يوم';
  }
  if (sec < 60)    return 'Just now';
  if (sec < 3600)  return '${sec ~/ 60} min ago';
  if (sec < 86400) return '${sec ~/ 3600}h ago';
  return '${sec ~/ 86400}d ago';
}
