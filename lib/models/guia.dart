class Guia {
  final String guiaId;
  final String numeroGuia;
  final String clienteId;
  final String consignatarioId;
  final String vueloId;
  final String almacenMiami; // TIB COURIER / VNSE BOX PERU
  final int bultosEsperados;
  final int bultosRecibidos;
  final String estadoLogistico; // pendiente_retiro / retirada_completa / retirada_incompleta / canal_rojo
  final String estadoFinanciero; // pendiente / liquidada / pagada
  final String estadoEntrega; // pendiente / programada / entregada

  // Campos desnormalizados para consultas rápidas
  final String? clienteNombre;
  final String? consignatarioNombre;
  final String? numeroManifiesto;

  Guia({
    required this.guiaId,
    required this.numeroGuia,
    required this.clienteId,
    required this.consignatarioId,
    required this.vueloId,
    required this.almacenMiami,
    this.bultosEsperados = 0,
    this.bultosRecibidos = 0,
    this.estadoLogistico = 'pendiente_retiro',
    this.estadoFinanciero = 'pendiente',
    this.estadoEntrega = 'pendiente',
    this.clienteNombre,
    this.consignatarioNombre,
    this.numeroManifiesto,
  });

  double get porcentajeRecibido =>
      bultosEsperados > 0 ? (bultosRecibidos / bultosEsperados) * 100 : 0;

  bool get isCompleta => bultosRecibidos == bultosEsperados && bultosEsperados > 0;

  factory Guia.fromMap(Map<String, dynamic> map, String id) {
    return Guia(
      guiaId: id,
      numeroGuia: map['numero_guia'] ?? '',
      clienteId: map['cliente_id'] ?? '',
      consignatarioId: map['consignatario_id'] ?? '',
      vueloId: map['vuelo_id'] ?? '',
      almacenMiami: map['almacen_miami'] ?? '',
      bultosEsperados: map['bultos_esperados'] ?? 0,
      bultosRecibidos: map['bultos_recibidos'] ?? 0,
      estadoLogistico: map['estado_logistico'] ?? 'pendiente_retiro',
      estadoFinanciero: map['estado_financiero'] ?? 'pendiente',
      estadoEntrega: map['estado_entrega'] ?? 'pendiente',
      clienteNombre: map['cliente_nombre'],
      consignatarioNombre: map['consignatario_nombre'],
      numeroManifiesto: map['numero_manifiesto'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero_guia': numeroGuia,
      'cliente_id': clienteId,
      'consignatario_id': consignatarioId,
      'vuelo_id': vueloId,
      'almacen_miami': almacenMiami,
      'bultos_esperados': bultosEsperados,
      'bultos_recibidos': bultosRecibidos,
      'estado_logistico': estadoLogistico,
      'estado_financiero': estadoFinanciero,
      'estado_entrega': estadoEntrega,
      'cliente_nombre': clienteNombre,
      'consignatario_nombre': consignatarioNombre,
      'numero_manifiesto': numeroManifiesto,
    };
  }

  static String estadoLogisticoLabel(String estado) {
    switch (estado) {
      case 'pendiente_retiro':
        return 'Pendiente Retiro';
      case 'retirada_completa':
        return 'Retirada Completa';
      case 'retirada_incompleta':
        return 'Retirada Incompleta';
      case 'canal_rojo':
        return 'Canal Rojo';
      default:
        return estado;
    }
  }

  static String estadoFinancieroLabel(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'liquidada':
        return 'Liquidada';
      case 'pagada':
        return 'Pagada';
      default:
        return estado;
    }
  }

  static String estadoEntregaLabel(String estado) {
    switch (estado) {
      case 'pendiente':
        return 'Pendiente';
      case 'programada':
        return 'Programada';
      case 'entregada':
        return 'Entregada';
      default:
        return estado;
    }
  }
}
