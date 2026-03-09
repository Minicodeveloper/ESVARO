class ServicioAdicional {
  final String servicioId;
  final String? trackingId;
  final String? guiaId;
  final String tipo; // foto / separacion / reempaque / otro
  final int cantidad;
  final double precioUnitario;
  final double precioTotal;
  final String? autorizadoPor;
  final String estado; // pendiente_cobro / cobrado / cancelado
  final String? notas;

  ServicioAdicional({
    required this.servicioId,
    this.trackingId,
    this.guiaId,
    required this.tipo,
    required this.cantidad,
    required this.precioUnitario,
    required this.precioTotal,
    this.autorizadoPor,
    this.estado = 'pendiente_cobro',
    this.notas,
  });

  factory ServicioAdicional.fromMap(Map<String, dynamic> map, String id) {
    return ServicioAdicional(
      servicioId: id,
      trackingId: map['tracking_id'],
      guiaId: map['guia_id'],
      tipo: map['tipo'] ?? '',
      cantidad: map['cantidad'] ?? 0,
      precioUnitario: (map['precio_unitario'] ?? 0.0).toDouble(),
      precioTotal: (map['precio_total'] ?? 0.0).toDouble(),
      autorizadoPor: map['autorizado_por'],
      estado: map['estado'] ?? 'pendiente_cobro',
      notas: map['notas'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'tracking_id': trackingId,
      'guia_id': guiaId,
      'tipo': tipo,
      'cantidad': cantidad,
      'precio_unitario': precioUnitario,
      'precio_total': precioTotal,
      'autorizado_por': autorizadoPor,
      'estado': estado,
      'notas': notas,
    };
  }

  static String tipoLabel(String tipo) {
    switch (tipo) {
      case 'foto':
        return 'Fotos';
      case 'separacion':
        return 'Separación';
      case 'reempaque':
        return 'Reempaque';
      case 'otro':
        return 'Otro';
      default:
        return tipo;
    }
  }
}
