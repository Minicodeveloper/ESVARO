import '../models/cliente.dart';
import '../models/consignatario.dart';
import '../models/vuelo.dart';
import '../models/guia.dart';
import '../models/tracking.dart';
import '../models/incidencia.dart';
import '../models/liquidacion.dart';
import '../models/entrega.dart';
import '../models/servicio_adicional.dart';

/// Servicio mock que simula Firebase Firestore.
/// Cuando conectes Firebase, reemplaza estos métodos con las llamadas reales.
/// 
/// CÓMO CONECTAR A FIREBASE:
/// 1. flutter pub add firebase_core cloud_firestore firebase_auth firebase_storage
/// 2. Configurar firebase con FlutterFire CLI: flutterfire configure
/// 3. Reemplazar cada método estático por consultas a FirebaseFirestore.instance
/// Ejemplo:
///   static Future<List<Cliente>> getClientes() async {
///     final snapshot = await FirebaseFirestore.instance.collection('clientes').get();
///     return snapshot.docs.map((doc) => Cliente.fromMap(doc.data(), doc.id)).toList();
///   }
class MockDataService {
  // ====== CLIENTES ======
  static final List<Cliente> _clientes = [
    Cliente(clienteId: 'c1', nombreComercial: 'Importadora ABC S.A.C.', tipoCliente: 'empresa', dniRuc: '20512345678', telefono: '987654321', email: 'contacto@importadoraabc.com', estado: 'activo'),
    Cliente(clienteId: 'c2', nombreComercial: 'Carlos Mendoza', tipoCliente: 'natural', dniRuc: '45678912', telefono: '912345678', email: 'carlos.mendoza@gmail.com', estado: 'activo'),
    Cliente(clienteId: 'c3', nombreComercial: 'Tech Solutions E.I.R.L.', tipoCliente: 'empresa', dniRuc: '20598765432', telefono: '956789123', email: 'compras@techsolutions.pe', estado: 'activo'),
    Cliente(clienteId: 'c4', nombreComercial: 'María Elena Torres', tipoCliente: 'natural', dniRuc: '78912345', telefono: '934567890', email: 'maria.torres@hotmail.com', estado: 'activo'),
    Cliente(clienteId: 'c5', nombreComercial: 'Distribuciones XYZ', tipoCliente: 'empresa', dniRuc: '20601234567', telefono: '978123456', email: 'logistica@distxyz.com', estado: 'inactivo'),
  ];

  // ====== CONSIGNATARIOS ======
  static final List<Consignatario> _consignatarios = [
    Consignatario(consignatarioId: 'con1', clienteId: 'c1', nombreCompleto: 'Juan Pérez García', dniRuc: '12345678'),
    Consignatario(consignatarioId: 'con2', clienteId: 'c1', nombreCompleto: 'María López Ruiz', dniRuc: '23456789'),
    Consignatario(consignatarioId: 'con3', clienteId: 'c2', nombreCompleto: 'Carlos Mendoza Silva', dniRuc: '45678912'),
    Consignatario(consignatarioId: 'con4', clienteId: 'c3', nombreCompleto: 'Roberto Díaz Flores', dniRuc: '56789123'),
    Consignatario(consignatarioId: 'con5', clienteId: 'c3', nombreCompleto: 'Ana Quispe Mamani', dniRuc: '67891234'),
    Consignatario(consignatarioId: 'con6', clienteId: 'c4', nombreCompleto: 'María Elena Torres', dniRuc: '78912345'),
  ];

  // ====== VUELOS / MANIFIESTOS ======
  static final List<Vuelo> _vuelos = [
    Vuelo(vueloId: 'v1', numeroManifiesto: 'MAN-2026-001', fechaLlegada: DateTime(2026, 2, 15, 10, 0), almacenMiami: 'TIB COURIER', estado: 'retirado'),
    Vuelo(vueloId: 'v2', numeroManifiesto: 'MAN-2026-002', fechaLlegada: DateTime(2026, 2, 22, 14, 30), almacenMiami: 'VNSE BOX PERU', estado: 'llegado'),
    Vuelo(vueloId: 'v3', numeroManifiesto: 'MAN-2026-003', fechaLlegada: DateTime(2026, 3, 1, 9, 0), almacenMiami: 'TIB COURIER', estado: 'programado'),
    Vuelo(vueloId: 'v4', numeroManifiesto: 'MAN-2026-004', fechaLlegada: DateTime(2026, 3, 5, 11, 30), almacenMiami: 'MIXTO', estado: 'programado'),
  ];

  // ====== GUÍAS ======
  static final List<Guia> _guias = [
    // Vuelo 1 - MAN-2026-001
    Guia(guiaId: 'g1', numeroGuia: 'ESV-001', clienteId: 'c1', consignatarioId: 'con1', vueloId: 'v1', almacenMiami: 'TIB COURIER', bultosEsperados: 9, bultosRecibidos: 7, estadoLogistico: 'retirada_incompleta', estadoFinanciero: 'liquidada', estadoEntrega: 'programada', clienteNombre: 'Importadora ABC S.A.C.', consignatarioNombre: 'Juan Pérez García', numeroManifiesto: 'MAN-2026-001'),
    Guia(guiaId: 'g2', numeroGuia: 'ESV-002', clienteId: 'c1', consignatarioId: 'con2', vueloId: 'v1', almacenMiami: 'TIB COURIER', bultosEsperados: 5, bultosRecibidos: 5, estadoLogistico: 'retirada_completa', estadoFinanciero: 'liquidada', estadoEntrega: 'entregada', clienteNombre: 'Importadora ABC S.A.C.', consignatarioNombre: 'María López Ruiz', numeroManifiesto: 'MAN-2026-001'),
    Guia(guiaId: 'g3', numeroGuia: 'ESV-003', clienteId: 'c2', consignatarioId: 'con3', vueloId: 'v1', almacenMiami: 'TIB COURIER', bultosEsperados: 12, bultosRecibidos: 12, estadoLogistico: 'retirada_completa', estadoFinanciero: 'pagada', estadoEntrega: 'entregada', clienteNombre: 'Carlos Mendoza', consignatarioNombre: 'Carlos Mendoza Silva', numeroManifiesto: 'MAN-2026-001'),
    Guia(guiaId: 'g4', numeroGuia: 'ESV-004', clienteId: 'c3', consignatarioId: 'con4', vueloId: 'v1', almacenMiami: 'TIB COURIER', bultosEsperados: 3, bultosRecibidos: 3, estadoLogistico: 'retirada_completa', estadoFinanciero: 'pendiente', estadoEntrega: 'pendiente', clienteNombre: 'Tech Solutions E.I.R.L.', consignatarioNombre: 'Roberto Díaz Flores', numeroManifiesto: 'MAN-2026-001'),
    // Vuelo 2 - MAN-2026-002
    Guia(guiaId: 'g5', numeroGuia: 'ESV-005', clienteId: 'c1', consignatarioId: 'con1', vueloId: 'v2', almacenMiami: 'VNSE BOX PERU', bultosEsperados: 6, bultosRecibidos: 0, estadoLogistico: 'pendiente_retiro', estadoFinanciero: 'pendiente', estadoEntrega: 'pendiente', clienteNombre: 'Importadora ABC S.A.C.', consignatarioNombre: 'Juan Pérez García', numeroManifiesto: 'MAN-2026-002'),
    Guia(guiaId: 'g6', numeroGuia: 'ESV-006', clienteId: 'c4', consignatarioId: 'con6', vueloId: 'v2', almacenMiami: 'VNSE BOX PERU', bultosEsperados: 4, bultosRecibidos: 0, estadoLogistico: 'pendiente_retiro', estadoFinanciero: 'pendiente', estadoEntrega: 'pendiente', clienteNombre: 'María Elena Torres', consignatarioNombre: 'María Elena Torres', numeroManifiesto: 'MAN-2026-002'),
    Guia(guiaId: 'g7', numeroGuia: 'ESV-007', clienteId: 'c3', consignatarioId: 'con5', vueloId: 'v2', almacenMiami: 'VNSE BOX PERU', bultosEsperados: 8, bultosRecibidos: 0, estadoLogistico: 'pendiente_retiro', estadoFinanciero: 'pendiente', estadoEntrega: 'pendiente', clienteNombre: 'Tech Solutions E.I.R.L.', consignatarioNombre: 'Ana Quispe Mamani', numeroManifiesto: 'MAN-2026-002'),
  ];

  // ====== TRACKINGS ======
  static final List<Tracking> _trackings = [
    // Guía ESV-001 (9 trackings, 7 recibidos, 2 faltantes)
    Tracking(trackingId: 't1', numeroTracking: 'ABC123', guiaId: 'g1', estado: 'recibido'),
    Tracking(trackingId: 't2', numeroTracking: 'DEF456', guiaId: 'g1', estado: 'recibido'),
    Tracking(trackingId: 't3', numeroTracking: 'GHI789', guiaId: 'g1', estado: 'recibido'),
    Tracking(trackingId: 't4', numeroTracking: 'JKL012', guiaId: 'g1', estado: 'faltante'),
    Tracking(trackingId: 't5', numeroTracking: 'MNO345', guiaId: 'g1', estado: 'recibido'),
    Tracking(trackingId: 't6', numeroTracking: 'PQR678', guiaId: 'g1', estado: 'faltante'),
    Tracking(trackingId: 't7', numeroTracking: 'STU901', guiaId: 'g1', estado: 'recibido'),
    Tracking(trackingId: 't8', numeroTracking: 'VWX234', guiaId: 'g1', estado: 'recibido'),
    Tracking(trackingId: 't9', numeroTracking: 'YZA567', guiaId: 'g1', estado: 'recibido'),
    // Guía ESV-002 (5 trackings, todos recibidos)
    Tracking(trackingId: 't10', numeroTracking: 'TRK-201', guiaId: 'g2', estado: 'recibido'),
    Tracking(trackingId: 't11', numeroTracking: 'TRK-202', guiaId: 'g2', estado: 'recibido'),
    Tracking(trackingId: 't12', numeroTracking: 'TRK-203', guiaId: 'g2', estado: 'recibido'),
    Tracking(trackingId: 't13', numeroTracking: 'TRK-204', guiaId: 'g2', estado: 'recibido'),
    Tracking(trackingId: 't14', numeroTracking: 'TRK-205', guiaId: 'g2', estado: 'recibido'),
    // Guía ESV-003 (12 trackings, todos recibidos)
    Tracking(trackingId: 't15', numeroTracking: 'CM-001', guiaId: 'g3', estado: 'recibido'),
    Tracking(trackingId: 't16', numeroTracking: 'CM-002', guiaId: 'g3', estado: 'recibido'),
    Tracking(trackingId: 't17', numeroTracking: 'CM-003', guiaId: 'g3', estado: 'recibido'),
    Tracking(trackingId: 't18', numeroTracking: 'CM-004', guiaId: 'g3', estado: 'recibido'),
    Tracking(trackingId: 't19', numeroTracking: 'CM-005', guiaId: 'g3', estado: 'recibido'),
    Tracking(trackingId: 't20', numeroTracking: 'CM-006', guiaId: 'g3', estado: 'recibido'),
    Tracking(trackingId: 't21', numeroTracking: 'CM-007', guiaId: 'g3', estado: 'recibido'),
    Tracking(trackingId: 't22', numeroTracking: 'CM-008', guiaId: 'g3', estado: 'recibido'),
    Tracking(trackingId: 't23', numeroTracking: 'CM-009', guiaId: 'g3', estado: 'recibido'),
    Tracking(trackingId: 't24', numeroTracking: 'CM-010', guiaId: 'g3', estado: 'recibido'),
    Tracking(trackingId: 't25', numeroTracking: 'CM-011', guiaId: 'g3', estado: 'recibido'),
    Tracking(trackingId: 't26', numeroTracking: 'CM-012', guiaId: 'g3', estado: 'recibido'),
    // Guía ESV-005 (6 trackings, pendientes retiro)
    Tracking(trackingId: 't27', numeroTracking: 'NEW-001', guiaId: 'g5', estado: 'esperado'),
    Tracking(trackingId: 't28', numeroTracking: 'NEW-002', guiaId: 'g5', estado: 'esperado'),
    Tracking(trackingId: 't29', numeroTracking: 'NEW-003', guiaId: 'g5', estado: 'esperado'),
    Tracking(trackingId: 't30', numeroTracking: 'NEW-004', guiaId: 'g5', estado: 'esperado'),
    Tracking(trackingId: 't31', numeroTracking: 'NEW-005', guiaId: 'g5', estado: 'esperado'),
    Tracking(trackingId: 't32', numeroTracking: 'NEW-006', guiaId: 'g5', estado: 'esperado'),
  ];

  // ====== INCIDENCIAS ======
  static final List<Incidencia> _incidencias = [
    Incidencia(
      incidenciaId: 'inc1', guiaId: 'g1', tipo: 'faltante_parcial',
      descripcion: 'Se recibieron 7 de 9 bultos. Faltan trackings JKL012 y PQR678.',
      estado: 'abierta', fechaCreacion: DateTime(2026, 2, 15, 14, 30),
      numeroGuia: 'ESV-001', clienteNombre: 'Importadora ABC S.A.C.',
      trackingsAfectados: ['JKL012', 'PQR678'],
    ),
  ];

  // ====== LIQUIDACIONES ======
  static final List<Liquidacion> _liquidaciones = [
    Liquidacion(
      liquidacionId: 'liq1', clienteId: 'c1', vueloId: 'v1',
      guiasIds: ['g1', 'g2'], montoTotal: 145.55, estado: 'pendiente',
      fechaLiquidacion: DateTime(2026, 2, 16),
      clienteNombre: 'Importadora ABC S.A.C.', numeroManifiesto: 'MAN-2026-001', cantidadGuias: 2,
    ),
    Liquidacion(
      liquidacionId: 'liq2', clienteId: 'c2', vueloId: 'v1',
      guiasIds: ['g3'], montoTotal: 128.00, estado: 'pagado',
      fechaLiquidacion: DateTime(2026, 2, 16), fechaPago: DateTime(2026, 2, 18),
      clienteNombre: 'Carlos Mendoza', numeroManifiesto: 'MAN-2026-001', cantidadGuias: 1,
    ),
  ];

  // ====== ENTREGAS ======
  static final List<Entrega> _entregas = [
    Entrega(
      entregaId: 'e1', guiaId: 'g1', tipoEntrega: 'retiro',
      fechaProgramada: DateTime(2026, 2, 28, 10, 0),
      estado: 'programada', observacion: 'Cliente avisado de faltantes',
      numeroGuia: 'ESV-001', clienteNombre: 'Importadora ABC S.A.C.', consignatarioNombre: 'Juan Pérez García',
    ),
    Entrega(
      entregaId: 'e2', guiaId: 'g2', tipoEntrega: 'delivery',
      fechaProgramada: DateTime(2026, 2, 17, 14, 0), fechaEntregada: DateTime(2026, 2, 17, 14, 30),
      estado: 'entregada', nombreReceptor: 'María López Ruiz', dniReceptor: '23456789',
      numeroGuia: 'ESV-002', clienteNombre: 'Importadora ABC S.A.C.', consignatarioNombre: 'María López Ruiz',
    ),
    Entrega(
      entregaId: 'e3', guiaId: 'g3', tipoEntrega: 'retiro',
      fechaProgramada: DateTime(2026, 2, 18, 9, 0), fechaEntregada: DateTime(2026, 2, 18, 9, 15),
      estado: 'entregada', nombreReceptor: 'Carlos Mendoza Silva', dniReceptor: '45678912',
      numeroGuia: 'ESV-003', clienteNombre: 'Carlos Mendoza', consignatarioNombre: 'Carlos Mendoza Silva',
    ),
  ];

  // ====== SERVICIOS ADICIONALES ======
  static final List<ServicioAdicional> _servicios = [
    ServicioAdicional(servicioId: 'sa1', trackingId: 't1', tipo: 'foto', cantidad: 5, precioUnitario: 2.0, precioTotal: 10.0, autorizadoPor: 'Liliana', estado: 'cobrado', notas: 'Cliente pidió fotos antes de enviar'),
    ServicioAdicional(servicioId: 'sa2', guiaId: 'g4', tipo: 'reempaque', cantidad: 1, precioUnitario: 15.0, precioTotal: 15.0, autorizadoPor: 'Liliana', estado: 'pendiente_cobro', notas: 'Caja dañada, se reempacó'),
  ];

  // ====== MÉTODOS DE CONSULTA ======

  // --- Clientes ---
  static List<Cliente> getClientes() => List.from(_clientes);
  static List<Cliente> getClientesActivos() => _clientes.where((c) => c.isActivo).toList();
  static Cliente? getClienteById(String id) {
    try { return _clientes.firstWhere((c) => c.clienteId == id); } catch (_) { return null; }
  }

  // --- Consignatarios ---
  static List<Consignatario> getConsignatarios() => List.from(_consignatarios);
  static List<Consignatario> getConsignatariosPorCliente(String clienteId) =>
      _consignatarios.where((c) => c.clienteId == clienteId).toList();

  // --- Vuelos ---
  static List<Vuelo> getVuelos() => List.from(_vuelos);
  static Vuelo? getVueloById(String id) {
    try { return _vuelos.firstWhere((v) => v.vueloId == id); } catch (_) { return null; }
  }

  // --- Guías ---
  static List<Guia> getGuias() => List.from(_guias);
  static Guia? getGuiaById(String id) {
    try { return _guias.firstWhere((g) => g.guiaId == id); } catch (_) { return null; }
  }
  static List<Guia> getGuiasPorVuelo(String vueloId) =>
      _guias.where((g) => g.vueloId == vueloId).toList();
  static List<Guia> getGuiasPorCliente(String clienteId) =>
      _guias.where((g) => g.clienteId == clienteId).toList();
  static List<Guia> getGuiasPendientesRetiro() =>
      _guias.where((g) => g.estadoLogistico == 'pendiente_retiro').toList();

  // --- Trackings ---
  static List<Tracking> getTrackings() => List.from(_trackings);
  static List<Tracking> getTrackingsPorGuia(String guiaId) =>
      _trackings.where((t) => t.guiaId == guiaId).toList();
  static Tracking? buscarTracking(String numero) {
    try { return _trackings.firstWhere((t) => t.numeroTracking.toLowerCase() == numero.toLowerCase()); } catch (_) { return null; }
  }

  // --- Incidencias ---
  static List<Incidencia> getIncidencias() => List.from(_incidencias);
  static List<Incidencia> getIncidenciasAbiertas() =>
      _incidencias.where((i) => i.estado != 'resuelta').toList();

  // --- Liquidaciones ---
  static List<Liquidacion> getLiquidaciones() => List.from(_liquidaciones);
  static List<Liquidacion> getLiquidacionesPendientes() =>
      _liquidaciones.where((l) => l.isPendiente).toList();

  // --- Entregas ---
  static List<Entrega> getEntregas() => List.from(_entregas);
  static List<Entrega> getEntregasProgramadasHoy() {
    final hoy = DateTime.now();
    return _entregas.where((e) =>
      e.estado == 'programada' && e.fechaProgramada != null &&
      e.fechaProgramada!.year == hoy.year &&
      e.fechaProgramada!.month == hoy.month &&
      e.fechaProgramada!.day == hoy.day
    ).toList();
  }

  // --- Servicios Adicionales ---
  static List<ServicioAdicional> getServiciosAdicionales() => List.from(_servicios);

  // ====== ESTADÍSTICAS DASHBOARD ======
  static Map<String, dynamic> getDashboardStats() {
    final guiasPendientes = _guias.where((g) => g.estadoLogistico == 'pendiente_retiro').length;
    final incidenciasAbiertas = _incidencias.where((i) => i.estado != 'resuelta').length;
    final liquidacionesPendientes = _liquidaciones.where((l) => l.isPendiente).toList();
    final montoLiqPendiente = liquidacionesPendientes.fold<double>(0, (s, l) => s + l.montoTotal);
    final entregasHoy = getEntregasProgramadasHoy().length;
    final entregasProgramadas = _entregas.where((e) => e.estado == 'programada').length;
    final totalGuias = _guias.length;
    final guiasCompletas = _guias.where((g) => g.estadoLogistico == 'retirada_completa').length;
    
    return {
      'guiasPendientes': guiasPendientes,
      'incidenciasAbiertas': incidenciasAbiertas,
      'liquidacionesPendienteMonto': montoLiqPendiente,
      'liquidacionesPendienteCount': liquidacionesPendientes.length,
      'entregasHoy': entregasHoy,
      'entregasProgramadas': entregasProgramadas,
      'totalGuias': totalGuias,
      'guiasCompletas': guiasCompletas,
      'totalClientes': _clientes.where((c) => c.isActivo).length,
      'totalVuelos': _vuelos.length,
      'vuelosProgramados': _vuelos.where((v) => v.estado == 'programado').length,
    };
  }
}
