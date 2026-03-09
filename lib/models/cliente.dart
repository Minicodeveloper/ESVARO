class Cliente {
  final String clienteId;
  final String nombreComercial;
  final String tipoCliente; // natural / empresa
  final String dniRuc;
  final String telefono;
  final String email;
  final String estado; // activo / inactivo

  Cliente({
    required this.clienteId,
    required this.nombreComercial,
    required this.tipoCliente,
    required this.dniRuc,
    required this.telefono,
    required this.email,
    this.estado = 'activo',
  });

  factory Cliente.fromMap(Map<String, dynamic> map, String id) {
    return Cliente(
      clienteId: id,
      nombreComercial: map['nombre_comercial'] ?? '',
      tipoCliente: map['tipo_cliente'] ?? 'natural',
      dniRuc: map['dni_ruc'] ?? '',
      telefono: map['telefono'] ?? '',
      email: map['email'] ?? '',
      estado: map['estado'] ?? 'activo',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nombre_comercial': nombreComercial,
      'tipo_cliente': tipoCliente,
      'dni_ruc': dniRuc,
      'telefono': telefono,
      'email': email,
      'estado': estado,
    };
  }

  bool get isActivo => estado == 'activo';
}
