class Entrega {
  final String entregaId;
  final String guiaId;
  final String tipoEntrega; // retiro / delivery
  final DateTime? fechaProgramada;
  final DateTime? fechaEntregada;
  final String? fotoEntregaUrl;
  final String? nombreReceptor;
  final String? dniReceptor;
  final String estado; // pendiente / programada / entregada
  final String? observacion;

  // Desnormalizados
  final String? numeroGuia;
  final String? clienteNombre;
  final String? consignatarioNombre;

  Entrega({
    required this.entregaId,
    required this.guiaId,
    required this.tipoEntrega,
    this.fechaProgramada,
    this.fechaEntregada,
    this.fotoEntregaUrl,
    this.nombreReceptor,
    this.dniReceptor,
    this.estado = 'pendiente',
    this.observacion,
    this.numeroGuia,
    this.clienteNombre,
    this.consignatarioNombre,
  });

  bool get isEntregada => estado == 'entregada';

  factory Entrega.fromMap(Map<String, dynamic> map, String id) {
    return Entrega(
      entregaId: id,
      guiaId: map['guia_id'] ?? '',
      tipoEntrega: map['tipo_entrega'] ?? 'retiro',
      fechaProgramada: map['fecha_programada'] != null
          ? DateTime.parse(map['fecha_programada'])
          : null,
      fechaEntregada: map['fecha_entregada'] != null
          ? DateTime.parse(map['fecha_entregada'])
          : null,
      fotoEntregaUrl: map['foto_entrega_url'],
      nombreReceptor: map['nombre_receptor'],
      dniReceptor: map['dni_receptor'],
      estado: map['estado'] ?? 'pendiente',
      observacion: map['observacion'],
      numeroGuia: map['numero_guia'],
      clienteNombre: map['cliente_nombre'],
      consignatarioNombre: map['consignatario_nombre'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'guia_id': guiaId,
      'tipo_entrega': tipoEntrega,
      'fecha_programada': fechaProgramada?.toIso8601String(),
      'fecha_entregada': fechaEntregada?.toIso8601String(),
      'foto_entrega_url': fotoEntregaUrl,
      'nombre_receptor': nombreReceptor,
      'dni_receptor': dniReceptor,
      'estado': estado,
      'observacion': observacion,
      'numero_guia': numeroGuia,
      'cliente_nombre': clienteNombre,
      'consignatario_nombre': consignatarioNombre,
    };
  }
}
