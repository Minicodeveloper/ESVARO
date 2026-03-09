class Retiro {
  final String retiroId;
  final String vueloId;
  final String numeroManifiesto;
  final String almacenMiami;
  final DateTime fechaRetiro;
  final String estado; // abierto, cerrado
  final int esperados;
  final int recibidos;
  final int faltantes;
  final int noInstruccionados;
  final String? fotoCargoUrl;
  final String? notas;
  final String? cerradoPor;
  final DateTime? fechaCierre;

  Retiro({
    required this.retiroId,
    required this.vueloId,
    required this.numeroManifiesto,
    required this.almacenMiami,
    required this.fechaRetiro,
    required this.estado,
    this.esperados = 0,
    this.recibidos = 0,
    this.faltantes = 0,
    this.noInstruccionados = 0,
    this.fotoCargoUrl,
    this.notas,
    this.cerradoPor,
    this.fechaCierre,
  });

  bool get isAbierto => estado == 'abierto';
  bool get isCerrado => estado == 'cerrado';

  factory Retiro.fromMap(Map<String, dynamic> map, String id) {
    return Retiro(
      retiroId: id,
      vueloId: map['vuelo_id'] ?? '',
      numeroManifiesto: map['numero_manifiesto'] ?? '',
      almacenMiami: map['almacen_miami'] ?? '',
      fechaRetiro: map['fecha_retiro'] != null ? DateTime.parse(map['fecha_retiro']) : DateTime.now(),
      estado: map['estado'] ?? 'abierto',
      esperados: map['esperados'] ?? 0,
      recibidos: map['recibidos'] ?? 0,
      faltantes: map['faltantes'] ?? 0,
      noInstruccionados: map['no_instruccionados'] ?? 0,
      fotoCargoUrl: map['foto_cargo_url'],
      notas: map['notas'],
      cerradoPor: map['cerrado_por'],
      fechaCierre: map['fecha_cierre'] != null ? DateTime.parse(map['fecha_cierre']) : null,
    );
  }

  Map<String, dynamic> toMap() => {
    'vuelo_id': vueloId,
    'numero_manifiesto': numeroManifiesto,
    'almacen_miami': almacenMiami,
    'fecha_retiro': fechaRetiro.toIso8601String(),
    'estado': estado,
    'esperados': esperados,
    'recibidos': recibidos,
    'faltantes': faltantes,
    'no_instruccionados': noInstruccionados,
    'foto_cargo_url': fotoCargoUrl,
    'notas': notas,
    'cerrado_por': cerradoPor,
    'fecha_cierre': fechaCierre?.toIso8601String(),
  };
}
