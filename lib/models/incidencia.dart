class Incidencia {
  final String incidenciaId;
  final String guiaId;
  final String tipo; // faltante_parcial / canal_rojo / no_volo / perdida
  final String descripcion;
  final String estado; // abierta / en_seguimiento / resuelta
  final DateTime fechaCreacion;
  final String? fotoUrl;

  // Desnormalizados
  final String? numeroGuia;
  final String? clienteNombre;
  final List<String>? trackingsAfectados;

  Incidencia({
    required this.incidenciaId,
    required this.guiaId,
    required this.tipo,
    required this.descripcion,
    this.estado = 'abierta',
    required this.fechaCreacion,
    this.fotoUrl,
    this.numeroGuia,
    this.clienteNombre,
    this.trackingsAfectados,
  });

  factory Incidencia.fromMap(Map<String, dynamic> map, String id) {
    return Incidencia(
      incidenciaId: id,
      guiaId: map['guia_id'] ?? '',
      tipo: map['tipo'] ?? '',
      descripcion: map['descripcion'] ?? '',
      estado: map['estado'] ?? 'abierta',
      fechaCreacion: map['fecha_creacion'] != null
          ? DateTime.parse(map['fecha_creacion'])
          : DateTime.now(),
      fotoUrl: map['foto_url'],
      numeroGuia: map['numero_guia'],
      clienteNombre: map['cliente_nombre'],
      trackingsAfectados: map['trackings_afectados'] != null
          ? List<String>.from(map['trackings_afectados'])
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'guia_id': guiaId,
      'tipo': tipo,
      'descripcion': descripcion,
      'estado': estado,
      'fecha_creacion': fechaCreacion.toIso8601String(),
      'foto_url': fotoUrl,
      'numero_guia': numeroGuia,
      'cliente_nombre': clienteNombre,
      'trackings_afectados': trackingsAfectados,
    };
  }

  static String tipoLabel(String tipo) {
    switch (tipo) {
      case 'faltante_parcial':
        return 'Faltante Parcial';
      case 'canal_rojo':
        return 'Canal Rojo';
      case 'no_volo':
        return 'No Voló';
      case 'perdida':
        return 'Pérdida';
      default:
        return tipo;
    }
  }

  static String estadoLabel(String estado) {
    switch (estado) {
      case 'abierta':
        return 'Abierta';
      case 'en_seguimiento':
        return 'En Seguimiento';
      case 'resuelta':
        return 'Resuelta';
      default:
        return estado;
    }
  }
}
