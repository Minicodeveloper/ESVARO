import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/retiro.dart';
import '../../models/vuelo.dart';
import '../../models/tracking.dart';
import '../../models/incidencia.dart';
import '../../widgets/item_options_sheet.dart';

class RetirosScreen extends StatelessWidget {
  const RetirosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Retiros de Almacén')),
      body: StreamBuilder<List<Retiro>>(
        stream: FirebaseService.retirosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final retiros = snapshot.data ?? [];
          if (retiros.isEmpty) return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(Icons.inventory_2_outlined, size: 64, color: AppTheme.textMuted),
            const SizedBox(height: 16),
            const Text('No hay retiros registrados', style: TextStyle(color: AppTheme.textSecondary, fontSize: 16)),
            const SizedBox(height: 8),
            const Text('Crea uno para iniciar el control', style: TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          ]));
          return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800), child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: retiros.length, itemBuilder: (context, i) {
            final r = retiros[i];
            return Card(margin: const EdgeInsets.only(bottom: 12), child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: r.isAbierto ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => RetiroDetalleScreen(retiro: r))) : null,
              onLongPress: () {
                ItemOptionsSheet.show(context: context, titulo: r.numeroManifiesto, subtitulo: '${r.fechaRetiro.day}/${r.fechaRetiro.month}/${r.fechaRetiro.year}',
                  onEditar: () {}, onEliminar: () async { final ok = await ItemOptionsSheet.confirmarEliminar(context, r.numeroManifiesto); if (ok && context.mounted) await FirebaseService.eliminarRetiro(r.retiroId); });
              },
              child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Row(children: [
                    Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: (r.isAbierto ? AppTheme.warningColor : AppTheme.successColor).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                      child: Icon(r.isAbierto ? Icons.lock_open : Icons.lock, color: r.isAbierto ? AppTheme.warningColor : AppTheme.successColor, size: 22)),
                    const SizedBox(width: 12),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r.numeroManifiesto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                      Text(r.almacenMiami, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ]),
                  ]),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), decoration: BoxDecoration(color: (r.isAbierto ? AppTheme.warningColor : AppTheme.successColor).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)),
                    child: Text(r.isAbierto ? '🔓 ABIERTO' : '🔒 CERRADO', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: r.isAbierto ? AppTheme.warningColor : AppTheme.successColor))),
                ]),
                const SizedBox(height: 14),
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.scaffoldBg, borderRadius: BorderRadius.circular(12)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    _Stat(label: 'Esperados', value: '${r.esperados}', color: AppTheme.infoColor),
                    Container(width: 1, height: 32, color: Colors.grey.shade300),
                    _Stat(label: 'Recibidos', value: '${r.recibidos}', color: AppTheme.successColor),
                    Container(width: 1, height: 32, color: Colors.grey.shade300),
                    _Stat(label: 'Faltantes', value: '${r.faltantes}', color: AppTheme.errorColor),
                    Container(width: 1, height: 32, color: Colors.grey.shade300),
                    _Stat(label: 'No Instr.', value: '${r.noInstruccionados}', color: AppTheme.warningColor),
                  ]),
                ),
                const SizedBox(height: 10),
                Row(children: [
                  Icon(Icons.calendar_today, size: 13, color: AppTheme.textMuted), const SizedBox(width: 4),
                  Text('${r.fechaRetiro.day}/${r.fechaRetiro.month}/${r.fechaRetiro.year}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                  if (r.cerradoPor != null) ...[const Spacer(), Text('Cerrado por: ${r.cerradoPor}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted))],
                ]),
                if (r.isAbierto) ...[const SizedBox(height: 12),
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => RetiroDetalleScreen(retiro: r))),
                    icon: const Icon(Icons.qr_code_scanner, size: 18), label: const Text('Continuar Escaneo'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 12)),
                  ))],
              ])),
            ));
          })));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crearRetiro(context),
        icon: const Icon(Icons.add), label: const Text('Crear Retiro'),
        backgroundColor: AppTheme.primaryColor,
      ),
    );
  }

  void _crearRetiro(BuildContext context) async {
    final vuelos = await FirebaseService.getVuelos();
    if (!context.mounted) return;
    final vuelosProgramados = vuelos.where((v) => v.estado == 'programado' || v.estado == 'llegado').toList();
    String? vueloId;
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) {
        Vuelo? vueloSel;
        if (vueloId != null) vueloSel = vuelosProgramados.where((v) => v.vueloId == vueloId).firstOrNull;
        return Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 24),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const Text('➕ Crear Retiro', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 8),
            const Text('Selecciona el vuelo para iniciar el retiro en almacén', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)), const SizedBox(height: 20),
            DropdownButtonFormField<String>(
              value: vueloId,
              decoration: const InputDecoration(labelText: 'Vuelo / Manifiesto', prefixIcon: Icon(Icons.flight)),
              items: vuelosProgramados.map((v) => DropdownMenuItem(value: v.vueloId, child: Text('${v.numeroManifiesto} - ${v.almacenMiami}'))).toList(),
              onChanged: (v) => setS(() => vueloId = v),
            ),
            if (vueloSel != null) ...[const SizedBox(height: 16),
              FutureBuilder<int>(
                future: FirebaseService.getGuiasPorVuelo(vueloSel!.vueloId).then((g) => g.length),
                builder: (_, snap) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.infoColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
                  child: Row(children: [const Icon(Icons.info_outline, color: AppTheme.infoColor, size: 20), const SizedBox(width: 10),
                    Text('${snap.data ?? 0} guías esperadas para este vuelo', style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.infoColor))])),
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(height: 54, child: ElevatedButton.icon(
              onPressed: vueloId == null ? null : () async {
                Navigator.pop(ctx);
                final vuelo = vuelosProgramados.firstWhere((v) => v.vueloId == vueloId);
                final guias = await FirebaseService.getGuiasPorVuelo(vueloId!);
                int totalEsperados = 0;
                for (final g in guias) { totalEsperados += g.bultosEsperados; }
                final retiro = Retiro(retiroId: '', vueloId: vueloId!, numeroManifiesto: vuelo.numeroManifiesto, almacenMiami: vuelo.almacenMiami, fechaRetiro: DateTime.now(), estado: 'abierto', esperados: totalEsperados);
                final retiroId = await FirebaseService.crearRetiro(retiro);
                if (context.mounted) {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => RetiroDetalleScreen(retiro: Retiro(retiroId: retiroId, vueloId: vueloId!, numeroManifiesto: vuelo.numeroManifiesto, almacenMiami: vuelo.almacenMiami, fechaRetiro: DateTime.now(), estado: 'abierto', esperados: totalEsperados))));
                }
              },
              icon: const Icon(Icons.play_arrow), label: const Text('INICIAR RETIRO', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            )),
            const SizedBox(height: 24),
          ]),
        );
      }),
    );
  }
}

// ==================== DETALLE RETIRO ====================
class RetiroDetalleScreen extends StatefulWidget {
  final Retiro retiro;
  const RetiroDetalleScreen({super.key, required this.retiro});
  @override
  State<RetiroDetalleScreen> createState() => _RetiroDetalleScreenState();
}

class _RetiroDetalleScreenState extends State<RetiroDetalleScreen> {
  List<Tracking> _trackingsEsperados = [];
  final Set<String> _recibidos = {};
  final Set<String> _noInstruccionados = {};
  final _scanCtrl = TextEditingController();
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _cargarTrackings();
  }

  Future<void> _cargarTrackings() async {
    final guias = await FirebaseService.getGuiasPorVuelo(widget.retiro.vueloId);
    final List<Tracking> all = [];
    for (final g in guias) {
      final t = await FirebaseService.getTrackingsPorGuia(g.guiaId);
      all.addAll(t);
    }
    if (mounted) setState(() { _trackingsEsperados = all; _loading = false; });
  }

  int get esperados => _trackingsEsperados.length;
  int get recibidos => _recibidos.length;
  int get faltantes => esperados - recibidos - _noInstruccionados.length;
  int get noInstruccionados => _noInstruccionados.length;

  void _escanear(String codigo) {
    if (codigo.isEmpty) return;
    final existe = _trackingsEsperados.any((t) => t.numeroTracking.toUpperCase() == codigo.toUpperCase());
    setState(() {
      if (existe) {
        _recibidos.add(codigo.toUpperCase());
      } else {
        _noInstruccionados.add(codigo.toUpperCase());
      }
    });
    _scanCtrl.clear();
    // Actualizar tracking como recibido en Firestore
    if (existe) {
      final t = _trackingsEsperados.firstWhere((t) => t.numeroTracking.toUpperCase() == codigo.toUpperCase());
      FirebaseService.actualizarTracking(t.trackingId, {'estado': 'recibido', 'fecha_recepcion': DateTime.now().toIso8601String()});
    }
  }

  void _cerrarRetiro() {
    final notasCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(children: [Icon(Icons.lock, color: AppTheme.warningColor), SizedBox(width: 10), Text('🔒 Cerrar Retiro')]),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: AppTheme.scaffoldBg, borderRadius: BorderRadius.circular(12)),
          child: Column(children: [
            _resumenRow('Esperados', '$esperados', AppTheme.infoColor),
            _resumenRow('Recibidos', '$recibidos', AppTheme.successColor),
            _resumenRow('Faltantes', '$faltantes', AppTheme.errorColor),
            _resumenRow('No instruccionados', '$noInstruccionados', AppTheme.warningColor),
          ])),
        const SizedBox(height: 12),
        TextField(controller: notasCtrl, decoration: const InputDecoration(labelText: 'Notas / Observaciones'), maxLines: 3),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.camera_alt), label: const Text('Adjuntar foto del cargo')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () async {
          Navigator.pop(ctx);
          await FirebaseService.cerrarRetiro(widget.retiro.retiroId, notas: notasCtrl.text, esperados: esperados, recibidos: recibidos, faltantes: faltantes > 0 ? faltantes : 0, noInstruccionados: noInstruccionados);
          // Crear incidencias automáticas para faltantes
          if (faltantes > 0) {
            final faltantesList = _trackingsEsperados.where((t) => !_recibidos.contains(t.numeroTracking.toUpperCase())).map((t) => t.numeroTracking).toList();
            await FirebaseService.crearIncidencia(Incidencia(
              incidenciaId: '', guiaId: '', tipo: 'faltante_parcial',
              descripcion: 'Faltantes en retiro: ${faltantesList.join(", ")}',
              estado: 'abierta', fechaCreacion: DateTime.now(),
              numeroGuia: widget.retiro.numeroManifiesto,
              clienteNombre: widget.retiro.almacenMiami,
              trackingsAfectados: faltantesList,
            ));
          }
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🔒 Retiro cerrado'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
            Navigator.pop(context);
          }
        }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningColor), child: const Text('🔒 CERRAR RETIRO')),
      ],
    ));
  }

  Widget _resumenRow(String label, String value, Color color) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: const TextStyle(fontSize: 14)), Text(value, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color))]));

  @override
  Widget build(BuildContext context) {
    final progress = esperados > 0 ? recibidos / esperados : 0.0;
    return Scaffold(
      appBar: AppBar(title: Text('Retiro: ${widget.retiro.numeroManifiesto}'),
        actions: [if (!widget.retiro.isCerrado) IconButton(icon: const Icon(Icons.lock), onPressed: _cerrarRetiro, tooltip: 'Cerrar Retiro')],
      ),
      body: _loading ? const Center(child: CircularProgressIndicator())
          : Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800), child: Column(children: [
        // Barra de progreso general
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10)]),
          child: Column(children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
              _BigStat('Esperados', '$esperados', AppTheme.infoColor, Icons.inventory_2),
              _BigStat('Recibidos', '$recibidos', AppTheme.successColor, Icons.check_circle),
              _BigStat('Faltantes', '${faltantes > 0 ? faltantes : 0}', AppTheme.errorColor, Icons.cancel),
              _BigStat('No Instr.', '$noInstruccionados', AppTheme.warningColor, Icons.help),
            ]),
            const SizedBox(height: 14),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation(progress >= 1 ? AppTheme.successColor : AppTheme.primaryColor))),
            const SizedBox(height: 6),
            Text('${(progress * 100).toStringAsFixed(0)}% completado', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: progress >= 1 ? AppTheme.successColor : AppTheme.textSecondary)),
          ]),
        ),
        // Scanner input
        Container(margin: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: AppTheme.softShadow),
          child: TextField(controller: _scanCtrl, autofocus: true,
            decoration: InputDecoration(
              hintText: 'Escanear o escribir tracking...', prefixIcon: const Icon(Icons.qr_code_scanner, color: AppTheme.primaryColor),
              suffixIcon: IconButton(icon: const Icon(Icons.send, color: AppTheme.primaryColor), onPressed: () => _escanear(_scanCtrl.text)),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none), filled: true, fillColor: Colors.white,
            ),
            onSubmitted: _escanear,
          ),
        ),
        // Lista de trackings
        Expanded(child: ListView(padding: const EdgeInsets.symmetric(horizontal: 16), children: [
          if (_noInstruccionados.isNotEmpty) ...[
            const Text('⚠️ No instruccionados:', style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.warningColor, fontSize: 14)), const SizedBox(height: 6),
            ..._noInstruccionados.map((t) => Container(margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: AppTheme.warningColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
              child: Row(children: [const Icon(Icons.help_outline, size: 16, color: AppTheme.warningColor), const SizedBox(width: 8), Text(t, style: const TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600))]))),
            const SizedBox(height: 16),
          ],
          const Text('📋 Trackings esperados:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14)), const SizedBox(height: 6),
          ..._trackingsEsperados.map((t) {
            final recibido = _recibidos.contains(t.numeroTracking.toUpperCase());
            return Container(margin: const EdgeInsets.only(bottom: 4), padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(color: recibido ? AppTheme.successColor.withValues(alpha: 0.08) : Colors.white, borderRadius: BorderRadius.circular(8), border: Border.all(color: recibido ? AppTheme.successColor.withValues(alpha: 0.3) : Colors.grey.shade200)),
              child: Row(children: [
                Icon(recibido ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: recibido ? AppTheme.successColor : AppTheme.textMuted),
                const SizedBox(width: 10),
                Expanded(child: Text(t.numeroTracking, style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.w600, color: recibido ? AppTheme.successColor : AppTheme.textPrimary))),
                if (!recibido) IconButton(icon: const Icon(Icons.check, size: 20), padding: EdgeInsets.zero, constraints: const BoxConstraints(), onPressed: () => _escanear(t.numeroTracking)),
              ]),
            );
          }),
        ])),
      ]))),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label, value; final Color color;
  const _Stat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [Text(value, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: color)), Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary))]);
}

class _BigStat extends StatelessWidget {
  final String label, value; final Color color; final IconData icon;
  const _BigStat(this.label, this.value, this.color, this.icon);
  @override
  Widget build(BuildContext context) => Column(children: [
    Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: color, size: 20)),
    const SizedBox(height: 6), Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)), Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
  ]);
}
