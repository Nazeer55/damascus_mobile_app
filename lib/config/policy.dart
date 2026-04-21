// Shared business-logic policy constants.
// JS mirror lives in js/policy.js (Damascus_Test web app).
// Change here AND there; keep them in sync until a codegen step is added.

class Policy {
  // Congestion % → traffic status thresholds
  static const double congestionNormalMax   = 40;
  static const double congestionModerateMax = 70;

  // Stat-card severity thresholds
  static const int congestedRoadsCritical              = 10;
  static const int highPressureIntersectionsModerate   = 6;
  static const int accidentsTodayCritical              = 2;
  static const int closedRoadsCritical                 = 1;
  static const double averageSpeedCriticalMax          = 40;
  static const double averageSpeedModerateMax          = 55;

  // Background GPS reporting
  static const double slowKmh                          = 10;
  static const int consecutiveReadingsForReport        = 2;
  static const int minIntervalMinutes                  = 15;

  // Dashboard auto-refresh
  static const int dashboardRefreshSeconds             = 30;

  // Alert auto-dismiss
  static const int alertAutoDismissSeconds             = 5;

  // Map defaults (WGS-84; matches web app)
  static const double mapCenterLat   = 33.5138;
  static const double mapCenterLng   = 36.2765;
  static const double mapInitialZoom = 12.0;
  static const double mapMinZoom     = 10.0;
  static const double mapMaxZoom     = 19.0;
}
