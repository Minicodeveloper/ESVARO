class Consignatario {
  final String consignatarioId;
  final String clienteId;
  final String nombreCompleto;
  final String dniRuc;

  Consignatario({
    required this.consignatarioId,
    required this.clienteId,
    required this.nombreCompleto,
    required this.dniRuc,
  });

  factory Consignatario.fromMap(Map<String, dynamic> map, String id) {
    return Consignatario(
      consignatarioId: id,
      clienteId: map['cliente_id'] ?? '',
      nombreCompleto: map['nombre_completo'] ?? '',
      dniRuc: map['dni_ruc'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'cliente_id': clienteId,
      'nombre_completo': nombreCompleto,
      'dni_ruc': dniRuc,
    };
  }
}
