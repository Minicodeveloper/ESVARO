class Vuelo {
  final String vueloId;
  final String numeroManifiesto;
  final DateTime fechaLlegada;
  final String almacenMiami; // TIB COURIER / VNSE BOX PERU / MIXTO
  final String estado; // programado / llegado / retirado / incompleto

  Vuelo({
    required this.vueloId,
    required this.numeroManifiesto,
    required this.fechaLlegada,
    required this.almacenMiami,
    this.estado = 'programado',
  });

  factory Vuelo.fromMap(Map<String, dynamic> map, String id) {
    return Vuelo(
      vueloId: id,
      numeroManifiesto: map['numero_manifiesto'] ?? '',
      fechaLlegada: map['fecha_llegada'] != null
          ? DateTime.parse(map['fecha_llegada'])
          : DateTime.now(),
      almacenMiami: map['almacen_miami'] ?? '',
      estado: map['estado'] ?? 'programado',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'numero_manifiesto': numeroManifiesto,
      'fecha_llegada': fechaLlegada.toIso8601String(),
      'almacen_miami': almacenMiami,
      'estado': estado,
    };
  }

  static String estadoLabel(String estado) {
    switch (estado) {
      case 'programado':
        return 'Programado';
      case 'llegado':
        return 'Llegado';
      case 'retirado':
        return 'Retirado';
      case 'incompleto':
        return 'Incompleto';
      default:
        return estado;
    }
  }
}
