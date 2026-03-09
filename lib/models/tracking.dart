class Tracking {
  final String trackingId;
  final String numeroTracking;
  final String guiaId;
  final String estado; // esperado / recibido / faltante / retenido / perdido

  Tracking({
    required this.trackingId,
    required this.numeroTracking,
    required this.guiaId,
    this.estado = 'esperado',
  });

  factory Tracking.fromMap(Map<String, dynamic> map, String id) {
    return Tracking(
      trackingId: id,
      numeroTracking: map['numero_tracking'] ?? '',
      guiaId: map['guia_id'] ?? '',
      estado: map['estado'] ?? 'esperado',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero_tracking': numeroTracking,
      'guia_id': guiaId,
      'estado': estado,
    };
  }

  bool get isRecibido => estado == 'recibido';
  bool get isFaltante => estado == 'faltante';
  bool get isEsperado => estado == 'esperado';

  static String estadoLabel(String estado) {
    switch (estado) {
      case 'esperado':
        return 'Esperado';
      case 'recibido':
        return 'Recibido';
      case 'faltante':
        return 'Faltante';
      case 'retenido':
        return 'Retenido';
      case 'perdido':
        return 'Perdido';
      default:
        return estado;
    }
  }
}
