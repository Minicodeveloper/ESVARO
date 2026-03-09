import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/cliente.dart';
import '../models/consignatario.dart';
import '../models/vuelo.dart';
import '../models/guia.dart';
import '../models/tracking.dart';
import '../models/incidencia.dart';
import '../models/liquidacion.dart';
import '../models/entrega.dart';
import '../models/servicio_adicional.dart';
import '../models/retiro.dart';

class FirebaseService {
  static final _db = FirebaseFirestore.instance;

  // Usuario logueado en sesión actual
  static Map<String, dynamic>? _usuarioActual;
  static Map<String, dynamic>? get usuarioActual => _usuarioActual;

  // ==================== USUARIOS ====================
  static CollectionReference get _usuariosRef => _db.collection('usuarios');

  /// Crea el usuario admin por defecto si no existe en Firestore
  static Future<void> seedUsuarioAdmin() async {
    final snap = await _usuariosRef.where('usuario', isEqualTo: 'admin').get();
    if (snap.docs.isEmpty) {
      await _usuariosRef.add({
        'usuario': 'admin',
        'password': 'admin',
        'nombre': 'Administrador',
        'rol': 'admin',
        'estado': 'activo',
        'fecha_creacion': DateTime.now().toIso8601String(),
      });
    }
  }

  /// Login contra colección 'usuarios' en Firestore
  static Future<Map<String, dynamic>?> login(String usuario, String password) async {
    final snap = await _usuariosRef
        .where('usuario', isEqualTo: usuario)
        .where('password', isEqualTo: password)
        .where('estado', isEqualTo: 'activo')
        .limit(1)
        .get();
    if (snap.docs.isEmpty) return null;
    final data = snap.docs.first.data() as Map<String, dynamic>;
    data['id'] = snap.docs.first.id;
    _usuarioActual = data;
    return data;
  }

  /// Cerrar sesión
  static void logout() {
    _usuarioActual = null;
  }

  /// Obtener todos los usuarios
  static Future<List<Map<String, dynamic>>> getUsuarios() async {
    final snap = await _usuariosRef.get();
    return snap.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      data['id'] = doc.id;
      return data;
    }).toList();
  }

  /// Crear usuario
  static Future<String> crearUsuario(Map<String, dynamic> data) async {
    final ref = await _usuariosRef.add(data);
    return ref.id;
  }

  // ==================== CLIENTES ====================
  static CollectionReference get _clientesRef => _db.collection('clientes');

  static Stream<List<Cliente>> clientesStream() {
    return _clientesRef.snapshots().map((snap) =>
      snap.docs.map((doc) => Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  static Future<List<Cliente>> getClientes() async {
    final snap = await _clientesRef.get();
    return snap.docs.map((doc) => Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<List<Cliente>> getClientesActivos() async {
    final snap = await _clientesRef.where('estado', isEqualTo: 'activo').get();
    return snap.docs.map((doc) => Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<Cliente?> getClienteById(String id) async {
    final doc = await _clientesRef.doc(id).get();
    if (!doc.exists) return null;
    return Cliente.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  static Future<String> crearCliente(Cliente cliente) async {
    final ref = await _clientesRef.add(cliente.toMap());
    return ref.id;
  }

  static Future<void> actualizarCliente(String id, Map<String, dynamic> data) async {
    await _clientesRef.doc(id).update(data);
  }

  // ==================== CONSIGNATARIOS ====================
  static CollectionReference get _consignatariosRef => _db.collection('consignatarios');

  static Future<List<Consignatario>> getConsignatarios() async {
    final snap = await _consignatariosRef.get();
    return snap.docs.map((doc) => Consignatario.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<List<Consignatario>> getConsignatariosPorCliente(String clienteId) async {
    final snap = await _consignatariosRef.where('cliente_id', isEqualTo: clienteId).get();
    return snap.docs.map((doc) => Consignatario.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<String> crearConsignatario(Consignatario c) async {
    final ref = await _consignatariosRef.add(c.toMap());
    return ref.id;
  }

  // ==================== VUELOS ====================
  static CollectionReference get _vuelosRef => _db.collection('vuelos');

  static Stream<List<Vuelo>> vuelosStream() {
    return _vuelosRef.orderBy('fecha_llegada', descending: true).snapshots().map((snap) =>
      snap.docs.map((doc) => Vuelo.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  static Future<List<Vuelo>> getVuelos() async {
    final snap = await _vuelosRef.orderBy('fecha_llegada', descending: true).get();
    return snap.docs.map((doc) => Vuelo.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<Vuelo?> getVueloById(String id) async {
    final doc = await _vuelosRef.doc(id).get();
    if (!doc.exists) return null;
    return Vuelo.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  static Future<String> crearVuelo(Vuelo vuelo) async {
    final ref = await _vuelosRef.add(vuelo.toMap());
    return ref.id;
  }

  static Future<void> actualizarVuelo(String id, Map<String, dynamic> data) async {
    await _vuelosRef.doc(id).update(data);
  }

  // ==================== GUÍAS ====================
  static CollectionReference get _guiasRef => _db.collection('guias');

  static Stream<List<Guia>> guiasStream() {
    return _guiasRef.snapshots().map((snap) =>
      snap.docs.map((doc) => Guia.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  static Future<List<Guia>> getGuias() async {
    final snap = await _guiasRef.get();
    return snap.docs.map((doc) => Guia.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<Guia?> getGuiaById(String id) async {
    final doc = await _guiasRef.doc(id).get();
    if (!doc.exists) return null;
    return Guia.fromMap(doc.data() as Map<String, dynamic>, doc.id);
  }

  static Future<List<Guia>> getGuiasPorVuelo(String vueloId) async {
    final snap = await _guiasRef.where('vuelo_id', isEqualTo: vueloId).get();
    return snap.docs.map((doc) => Guia.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<List<Guia>> getGuiasPorCliente(String clienteId) async {
    final snap = await _guiasRef.where('cliente_id', isEqualTo: clienteId).get();
    return snap.docs.map((doc) => Guia.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<List<Guia>> getGuiasPendientesRetiro() async {
    final snap = await _guiasRef.where('estado_logistico', isEqualTo: 'pendiente_retiro').get();
    return snap.docs.map((doc) => Guia.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<String> crearGuia(Guia guia) async {
    final ref = await _guiasRef.add(guia.toMap());
    return ref.id;
  }

  static Future<void> actualizarGuia(String id, Map<String, dynamic> data) async {
    await _guiasRef.doc(id).update(data);
  }

  // ==================== TRACKINGS ====================
  static CollectionReference get _trackingsRef => _db.collection('trackings');

  static Future<List<Tracking>> getTrackingsPorGuia(String guiaId) async {
    final snap = await _trackingsRef.where('guia_id', isEqualTo: guiaId).get();
    return snap.docs.map((doc) => Tracking.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<Tracking?> buscarTracking(String numero) async {
    final snap = await _trackingsRef.where('numero_tracking', isEqualTo: numero).limit(1).get();
    if (snap.docs.isEmpty) return null;
    return Tracking.fromMap(snap.docs.first.data() as Map<String, dynamic>, snap.docs.first.id);
  }

  static Future<String> crearTracking(Tracking t) async {
    final ref = await _trackingsRef.add(t.toMap());
    return ref.id;
  }

  static Future<void> actualizarTracking(String id, Map<String, dynamic> data) async {
    await _trackingsRef.doc(id).update(data);
  }

  // ==================== INCIDENCIAS ====================
  static CollectionReference get _incidenciasRef => _db.collection('incidencias');

  static Stream<List<Incidencia>> incidenciasStream() {
    return _incidenciasRef.orderBy('fecha_creacion', descending: true).snapshots().map((snap) =>
      snap.docs.map((doc) => Incidencia.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  static Future<List<Incidencia>> getIncidencias() async {
    final snap = await _incidenciasRef.orderBy('fecha_creacion', descending: true).get();
    return snap.docs.map((doc) => Incidencia.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<List<Incidencia>> getIncidenciasAbiertas() async {
    final snap = await _incidenciasRef.where('estado', whereIn: ['abierta', 'en_seguimiento']).get();
    return snap.docs.map((doc) => Incidencia.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<String> crearIncidencia(Incidencia inc) async {
    final ref = await _incidenciasRef.add(inc.toMap());
    return ref.id;
  }

  static Future<void> actualizarIncidencia(String id, Map<String, dynamic> data) async {
    await _incidenciasRef.doc(id).update(data);
  }

  // ==================== INCIDENCIA_TRACKINGS ====================
  static CollectionReference get _incTrackingsRef => _db.collection('incidencia_trackings');

  static Future<void> crearIncidenciaTracking(String incidenciaId, String trackingId) async {
    await _incTrackingsRef.add({'incidencia_id': incidenciaId, 'tracking_id': trackingId});
  }

  // ==================== LIQUIDACIONES ====================
  static CollectionReference get _liquidacionesRef => _db.collection('liquidaciones');

  static Stream<List<Liquidacion>> liquidacionesStream() {
    return _liquidacionesRef.orderBy('fecha_liquidacion', descending: true).snapshots().map((snap) =>
      snap.docs.map((doc) => Liquidacion.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  static Future<List<Liquidacion>> getLiquidaciones() async {
    final snap = await _liquidacionesRef.orderBy('fecha_liquidacion', descending: true).get();
    return snap.docs.map((doc) => Liquidacion.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<List<Liquidacion>> getLiquidacionesPendientes() async {
    final snap = await _liquidacionesRef.where('estado', isEqualTo: 'pendiente').get();
    return snap.docs.map((doc) => Liquidacion.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<String> crearLiquidacion(Liquidacion l) async {
    final ref = await _liquidacionesRef.add(l.toMap());
    return ref.id;
  }

  static Future<void> actualizarLiquidacion(String id, Map<String, dynamic> data) async {
    await _liquidacionesRef.doc(id).update(data);
  }

  // ==================== ENTREGAS ====================
  static CollectionReference get _entregasRef => _db.collection('entregas');

  static Stream<List<Entrega>> entregasStream() {
    return _entregasRef.snapshots().map((snap) =>
      snap.docs.map((doc) => Entrega.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  static Future<List<Entrega>> getEntregas() async {
    final snap = await _entregasRef.get();
    return snap.docs.map((doc) => Entrega.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<String> crearEntrega(Entrega e) async {
    final ref = await _entregasRef.add(e.toMap());
    return ref.id;
  }

  static Future<void> actualizarEntrega(String id, Map<String, dynamic> data) async {
    await _entregasRef.doc(id).update(data);
  }

  // ==================== SERVICIOS ADICIONALES ====================
  static CollectionReference get _serviciosRef => _db.collection('servicios_adicionales');

  static Stream<List<ServicioAdicional>> serviciosStream() {
    return _serviciosRef.snapshots().map((snap) =>
      snap.docs.map((doc) => ServicioAdicional.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList());
  }

  static Future<List<ServicioAdicional>> getServiciosAdicionales() async {
    final snap = await _serviciosRef.get();
    return snap.docs.map((doc) => ServicioAdicional.fromMap(doc.data() as Map<String, dynamic>, doc.id)).toList();
  }

  static Future<String> crearServicioAdicional(ServicioAdicional s) async {
    final ref = await _serviciosRef.add(s.toMap());
    return ref.id;
  }

  static Future<void> actualizarServicioAdicional(String id, Map<String, dynamic> data) async {
    await _serviciosRef.doc(id).update(data);
  }

  // ==================== OPERACIONES BATCH (FASE 1.2) ====================
  /// Registra múltiples guías y sus trackings en un solo vuelo (batch)
  static Future<void> registrarGuiasConTrackings({
    required String vueloId,
    required String clienteId,
    required String clienteNombre,
    required String almacenMiami,
    required String numeroManifiesto,
    required List<Map<String, dynamic>> guiasData,
  }) async {
    final batch = _db.batch();

    for (final gData in guiasData) {
      final guiaRef = _guiasRef.doc();
      final trackingsList = (gData['trackings'] as String).split(',').map((t) => t.trim()).where((t) => t.isNotEmpty).toList();

      batch.set(guiaRef, {
        'numero_guia': gData['numero_guia'],
        'cliente_id': clienteId,
        'consignatario_id': gData['consignatario_id'],
        'vuelo_id': vueloId,
        'almacen_miami': almacenMiami,
        'bultos_esperados': trackingsList.length,
        'bultos_recibidos': 0,
        'estado_logistico': 'pendiente_retiro',
        'estado_financiero': 'pendiente',
        'estado_entrega': 'pendiente',
        'cliente_nombre': clienteNombre,
        'consignatario_nombre': gData['consignatario_nombre'],
        'numero_manifiesto': numeroManifiesto,
      });

      for (final trackNum in trackingsList) {
        final trackRef = _trackingsRef.doc();
        batch.set(trackRef, {
          'numero_tracking': trackNum,
          'guia_id': guiaRef.id,
          'estado': 'esperado',
        });
      }
    }

    await batch.commit();
  }

  // ==================== OPERACIÓN DE VALIDACIÓN (FASE 2) ====================
  /// Marca un tracking como recibido y actualiza bultos_recibidos de la guía
  static Future<void> marcarTrackingRecibido(String trackingId, String guiaId) async {
    final batch = _db.batch();
    batch.update(_trackingsRef.doc(trackingId), {'estado': 'recibido'});
    batch.update(_guiasRef.doc(guiaId), {'bultos_recibidos': FieldValue.increment(1)});
    await batch.commit();
  }

  /// Finaliza la validación de una guía y crea incidencia si hay faltantes
  static Future<void> finalizarValidacionGuia({
    required String guiaId,
    required int totalTrackings,
    required int recibidos,
    required List<Tracking> faltantes,
    required String numeroGuia,
    required String? clienteNombre,
  }) async {
    final batch = _db.batch();

    if (recibidos == totalTrackings) {
      // Completa
      batch.update(_guiasRef.doc(guiaId), {
        'estado_logistico': 'retirada_completa',
        'bultos_recibidos': recibidos,
      });
    } else {
      // Incompleta
      batch.update(_guiasRef.doc(guiaId), {
        'estado_logistico': 'retirada_incompleta',
        'bultos_recibidos': recibidos,
      });

      // Crear incidencia
      final incRef = _incidenciasRef.doc();
      batch.set(incRef, {
        'guia_id': guiaId,
        'tipo': 'faltante_parcial',
        'descripcion': 'Se recibieron $recibidos de $totalTrackings bultos. Faltan ${faltantes.length} trackings.',
        'estado': 'abierta',
        'fecha_creacion': DateTime.now().toIso8601String(),
        'numero_guia': numeroGuia,
        'cliente_nombre': clienteNombre,
        'trackings_afectados': faltantes.map((t) => t.numeroTracking).toList(),
      });

      // Marcar trackings como faltantes
      for (final t in faltantes) {
        batch.update(_trackingsRef.doc(t.trackingId), {'estado': 'faltante'});
        final itRef = _incTrackingsRef.doc();
        batch.set(itRef, {'incidencia_id': incRef.id, 'tracking_id': t.trackingId});
      }
    }

    await batch.commit();
  }

  // ==================== DASHBOARD STATS ====================
  static Future<Map<String, dynamic>> getDashboardStats() async {
    final guias = await getGuias();
    final incidencias = await getIncidenciasAbiertas();
    final liquidaciones = await getLiquidacionesPendientes();
    final entregas = await getEntregas();
    final clientes = await getClientesActivos();
    final vuelos = await getVuelos();

    final guiasPendientes = guias.where((g) => g.estadoLogistico == 'pendiente_retiro').length;
    final montoLiqPendiente = liquidaciones.fold<double>(0, (s, l) => s + l.montoTotal);
    final entregasProgramadas = entregas.where((e) => e.estado == 'programada').length;

    return {
      'guiasPendientes': guiasPendientes,
      'incidenciasAbiertas': incidencias.length,
      'liquidacionesPendienteMonto': montoLiqPendiente,
      'liquidacionesPendienteCount': liquidaciones.length,
      'entregasProgramadas': entregasProgramadas,
      'totalGuias': guias.length,
      'guiasCompletas': guias.where((g) => g.estadoLogistico == 'retirada_completa').length,
      'totalClientes': clientes.length,
      'totalVuelos': vuelos.length,
      'vuelosProgramados': vuelos.where((v) => v.estado == 'programado').length,
    };
  }

  // ==================== DASHBOARD MEJORADO ====================
  static Future<Map<String, dynamic>> getDashboardResumen() async {
    final guias = await getGuias();
    final incidencias = await getIncidencias();
    final liquidaciones = await getLiquidaciones();
    final entregas = await getEntregas();
    final retiros = await getRetiros();

    // Bloque Operativo
    final enCasaSinEntregar = guias.where((g) => g.estadoLogistico == 'retirada_completa' && g.estadoEntrega != 'entregada').length;
    final incidenciasAbiertas = incidencias.where((i) => i.estado != 'resuelta').length;
    final ultimoRetiro = retiros.isNotEmpty ? retiros.first : null;

    // Bloque Financiero
    final totalFacturado = liquidaciones.fold<double>(0, (s, l) => s + l.montoTotal);
    final totalCobrado = liquidaciones.where((l) => l.isPagado).fold<double>(0, (s, l) => s + l.montoTotal);
    final totalPendiente = totalFacturado - totalCobrado;
    final cobradoHoy = liquidaciones.where((l) => l.isPagado && l.fechaPago != null && _isToday(l.fechaPago!)).fold<double>(0, (s, l) => s + l.montoTotal);

    // Bloque Riesgo
    final faltantesSinResolver = incidencias.where((i) => i.estado != 'resuelta' && (i.tipo == 'faltante_parcial' || i.tipo == 'perdida')).length;
    final noInstruccionados = guias.where((g) => g.estadoLogistico == 'pendiente_retiro' && g.estadoEntrega == 'pendiente').length;
    final entregadosSinPago = guias.where((g) => g.estadoEntrega == 'entregada' && g.estadoFinanciero == 'pendiente').length;

    return {
      // Operativo
      'enCasaSinEntregar': enCasaSinEntregar,
      'incidenciasAbiertas': incidenciasAbiertas,
      'ultimoRetiro': ultimoRetiro,
      // Financiero
      'totalFacturado': totalFacturado,
      'totalCobrado': totalCobrado,
      'totalPendiente': totalPendiente,
      'cobradoHoy': cobradoHoy,
      // Riesgo
      'faltantesSinResolver': faltantesSinResolver,
      'noInstruccionados': noInstruccionados,
      'entregadosSinPago': entregadosSinPago,
      // Resumen general
      'totalGuias': guias.length,
      'totalEntregas': entregas.length,
      'entregasProgramadas': entregas.where((e) => e.estado == 'programada').length,
    };
  }

  static bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year && date.month == now.month && date.day == now.day;
  }

  // ==================== RETIROS ====================
  static CollectionReference get _retirosRef => _db.collection('retiros');

  static Stream<List<Retiro>> retirosStream() => _retirosRef.orderBy('fecha_retiro', descending: true).snapshots().map((snap) => snap.docs.map((d) => Retiro.fromMap(d.data() as Map<String, dynamic>, d.id)).toList());

  static Future<List<Retiro>> getRetiros() async {
    final snap = await _retirosRef.orderBy('fecha_retiro', descending: true).get();
    return snap.docs.map((d) => Retiro.fromMap(d.data() as Map<String, dynamic>, d.id)).toList();
  }

  static Future<String> crearRetiro(Retiro retiro) async {
    final ref = await _retirosRef.add(retiro.toMap());
    return ref.id;
  }

  static Future<void> actualizarRetiro(String id, Map<String, dynamic> data) async {
    await _retirosRef.doc(id).update(data);
  }

  static Future<void> cerrarRetiro(String retiroId, {String? fotoUrl, String? notas, required int esperados, required int recibidos, required int faltantes, required int noInstruccionados}) async {
    await _retirosRef.doc(retiroId).update({
      'estado': 'cerrado',
      'foto_cargo_url': fotoUrl,
      'notas': notas,
      'esperados': esperados,
      'recibidos': recibidos,
      'faltantes': faltantes,
      'no_instruccionados': noInstruccionados,
      'cerrado_por': _usuarioActual?['nombre'] ?? 'Admin',
      'fecha_cierre': DateTime.now().toIso8601String(),
    });
  }

  static Future<void> eliminarRetiro(String id) async {
    await _retirosRef.doc(id).delete();
  }

  // ==================== RESUMEN POR VUELO ====================
  static Future<Map<String, dynamic>> getResumenVuelo(String vueloId) async {
    final guias = await getGuiasPorVuelo(vueloId);
    final liquidaciones = await getLiquidaciones();
    final liqsVuelo = liquidaciones.where((l) => l.vueloId == vueloId).toList();
    final facturado = liqsVuelo.fold<double>(0, (s, l) => s + l.montoTotal);
    final cobrado = liqsVuelo.where((l) => l.isPagado).fold<double>(0, (s, l) => s + l.montoTotal);

    return {
      'totalGuias': guias.length,
      'facturado': facturado,
      'cobrado': cobrado,
      'pendiente': facturado - cobrado,
      'retiradaCompleta': guias.where((g) => g.estadoLogistico == 'retirada_completa').length,
      'pendienteRetiro': guias.where((g) => g.estadoLogistico == 'pendiente_retiro').length,
      'entregadas': guias.where((g) => g.estadoEntrega == 'entregada').length,
    };
  }

  // ==================== ELIMINACIONES ====================
  static Future<void> eliminarVuelo(String id) async {
    final guias = await getGuiasPorVuelo(id);
    for (final g in guias) {
      await eliminarGuia(g.guiaId);
    }
    await _vuelosRef.doc(id).delete();
  }

  static Future<void> eliminarGuia(String id) async {
    final trackings = await getTrackingsPorGuia(id);
    for (final t in trackings) {
      await _trackingsRef.doc(t.trackingId).delete();
    }
    await _guiasRef.doc(id).delete();
  }

  static Future<void> eliminarCliente(String id) async {
    final cons = await getConsignatariosPorCliente(id);
    for (final c in cons) {
      await _consignatariosRef.doc(c.consignatarioId).delete();
    }
    await _clientesRef.doc(id).delete();
  }

  static Future<void> eliminarConsignatario(String id) async {
    await _consignatariosRef.doc(id).delete();
  }

  static Future<void> eliminarIncidencia(String id) async {
    await _incidenciasRef.doc(id).delete();
  }

  static Future<void> eliminarLiquidacion(String id) async {
    await _liquidacionesRef.doc(id).delete();
  }

  static Future<void> eliminarEntrega(String id) async {
    await _entregasRef.doc(id).delete();
  }

  static Future<void> eliminarServicioAdicional(String id) async {
    await _serviciosRef.doc(id).delete();
  }
}
