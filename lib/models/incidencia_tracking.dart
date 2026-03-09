class IncidenciaTracking {
  final String incidenciaTrackingId;
  final String incidenciaId;
  final String trackingId;

  IncidenciaTracking({
    required this.incidenciaTrackingId,
    required this.incidenciaId,
    required this.trackingId,
  });

  factory IncidenciaTracking.fromMap(Map<String, dynamic> map, String id) {
    return IncidenciaTracking(
      incidenciaTrackingId: id,
      incidenciaId: map['incidencia_id'] ?? '',
      trackingId: map['tracking_id'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'incidencia_id': incidenciaId,
      'tracking_id': trackingId,
    };
  }
}
