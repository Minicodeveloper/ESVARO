class Liquidacion {
  final String liquidacionId;
  final String clienteId;
  final String vueloId;
  final List<String> guiasIds;
  final double montoTotal;
  final String estado; // pendiente / pagado
  final String? comprobanteUrl;
  final DateTime fechaLiquidacion;
  final DateTime? fechaPago;
  final String? comprobantePagoUrl;

  // Desnormalizados
  final String? clienteNombre;
  final String? numeroManifiesto;
  final int? cantidadGuias;

  Liquidacion({
    required this.liquidacionId,
    required this.clienteId,
    required this.vueloId,
    required this.guiasIds,
    required this.montoTotal,
    this.estado = 'pendiente',
    this.comprobanteUrl,
    required this.fechaLiquidacion,
    this.fechaPago,
    this.comprobantePagoUrl,
    this.clienteNombre,
    this.numeroManifiesto,
    this.cantidadGuias,
  });

  bool get isPagado => estado == 'pagado';
  bool get isPendiente => estado == 'pendiente';

  factory Liquidacion.fromMap(Map<String, dynamic> map, String id) {
    return Liquidacion(
      liquidacionId: id,
      clienteId: map['cliente_id'] ?? '',
      vueloId: map['vuelo_id'] ?? '',
      guiasIds: map['guias_ids'] != null
          ? List<String>.from(map['guias_ids'])
          : [],
      montoTotal: (map['monto_total'] ?? 0.0).toDouble(),
      estado: map['estado'] ?? 'pendiente',
      comprobanteUrl: map['comprobante_url'],
      fechaLiquidacion: map['fecha_liquidacion'] != null
          ? DateTime.parse(map['fecha_liquidacion'])
          : DateTime.now(),
      fechaPago: map['fecha_pago'] != null
          ? DateTime.parse(map['fecha_pago'])
          : null,
      comprobantePagoUrl: map['comprobante_pago_url'],
      clienteNombre: map['cliente_nombre'],
      numeroManifiesto: map['numero_manifiesto'],
      cantidadGuias: map['cantidad_guias'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cliente_id': clienteId,
      'vuelo_id': vueloId,
      'guias_ids': guiasIds,
      'monto_total': montoTotal,
      'estado': estado,
      'comprobante_url': comprobanteUrl,
      'fecha_liquidacion': fechaLiquidacion.toIso8601String(),
      'fecha_pago': fechaPago?.toIso8601String(),
      'comprobante_pago_url': comprobantePagoUrl,
      'cliente_nombre': clienteNombre,
      'numero_manifiesto': numeroManifiesto,
      'cantidad_guias': cantidadGuias,
    };
  }
}
