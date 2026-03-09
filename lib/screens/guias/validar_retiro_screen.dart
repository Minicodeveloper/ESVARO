import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/guia.dart';
import '../../models/tracking.dart';

class ValidarRetiroScreen extends StatefulWidget {
  const ValidarRetiroScreen({super.key});
  @override
  State<ValidarRetiroScreen> createState() => _ValidarRetiroScreenState();
}

class _ValidarRetiroScreenState extends State<ValidarRetiroScreen> {
  String? _vueloSeleccionado;
  Guia? _guiaSeleccionada;
  List<Tracking> _trackings = [];
  final Set<String> _trackingsValidados = {};
  final _scanController = TextEditingController();
  bool _loadingVuelos = true;
  bool _loadingGuias = false;
  bool _finalizando = false;
  List<dynamic> _vuelos = [];
  List<Guia> _guiasVuelo = [];

  @override
  void initState() { super.initState(); _loadVuelos(); }

  Future<void> _loadVuelos() async {
    final vuelos = await FirebaseService.getVuelos();
    if (mounted) setState(() { _vuelos = vuelos; _loadingVuelos = false; });
  }

  Future<void> _loadGuias(String vueloId) async {
    setState(() => _loadingGuias = true);
    final guias = await FirebaseService.getGuiasPorVuelo(vueloId);
    if (mounted) setState(() { _guiasVuelo = guias; _loadingGuias = false; });
  }

  Future<void> _seleccionarGuia(Guia guia) async {
    final trackings = await FirebaseService.getTrackingsPorGuia(guia.guiaId);
    final validados = <String>{};
    for (final t in trackings) { if (t.isRecibido) validados.add(t.trackingId); }
    if (mounted) setState(() { _guiaSeleccionada = guia; _trackings = trackings; _trackingsValidados.addAll(validados); });
  }

  void _escanearTracking() {
    final valor = _scanController.text.trim();
    if (valor.isEmpty) return;
    final tracking = _trackings.where((t) => t.numeroTracking.toLowerCase() == valor.toLowerCase()).firstOrNull;
    if (tracking != null && !_trackingsValidados.contains(tracking.trackingId)) {
      setState(() => _trackingsValidados.add(tracking.trackingId));
      // Actualizar en Firebase
      FirebaseService.marcarTrackingRecibido(tracking.trackingId, _guiaSeleccionada!.guiaId);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ ${tracking.numeroTracking} recibido (${_trackingsValidados.length}/${_trackings.length})'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating, duration: const Duration(seconds: 1)));
    } else if (tracking != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('⚠️ ${tracking.numeroTracking} ya fue recibido'), backgroundColor: AppTheme.warningColor, behavior: SnackBarBehavior.floating));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ "$valor" no encontrado'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating));
    }
    _scanController.clear();
  }

  void _toggleTracking(Tracking t) {
    setState(() {
      if (_trackingsValidados.contains(t.trackingId)) {
        _trackingsValidados.remove(t.trackingId);
        FirebaseService.actualizarTracking(t.trackingId, {'estado': 'esperado'});
        FirebaseService.actualizarGuia(_guiaSeleccionada!.guiaId, {'bultos_recibidos': _trackingsValidados.length});
      } else {
        _trackingsValidados.add(t.trackingId);
        FirebaseService.marcarTrackingRecibido(t.trackingId, _guiaSeleccionada!.guiaId);
      }
    });
  }

  void _finalizarValidacion() async {
    final faltantes = _trackings.where((t) => !_trackingsValidados.contains(t.trackingId)).toList();

    if (faltantes.isNotEmpty) {
      showDialog(context: context, builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.warning_amber, color: AppTheme.warningColor, size: 28), SizedBox(width: 10), Text('Incidencia Detectada', style: TextStyle(fontSize: 18))]),
        content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Guía: ${_guiaSeleccionada?.numeroGuia}'),
          Text('Recibidos: ${_trackingsValidados.length}/${_trackings.length}'),
          const SizedBox(height: 12), const Text('Faltantes:', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 6),
          ...faltantes.map((t) => Padding(padding: const EdgeInsets.symmetric(vertical: 2), child: Row(children: [const Icon(Icons.cancel, color: AppTheme.errorColor, size: 16), const SizedBox(width: 6), Text(t.numeroTracking, style: const TextStyle(fontWeight: FontWeight.w600, fontFamily: 'monospace'))]))),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _finalizando = true);
              await FirebaseService.finalizarValidacionGuia(guiaId: _guiaSeleccionada!.guiaId, totalTrackings: _trackings.length, recibidos: _trackingsValidados.length, faltantes: faltantes, numeroGuia: _guiaSeleccionada!.numeroGuia, clienteNombre: _guiaSeleccionada!.clienteNombre);
              if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('⚠️ Incidencia creada - Faltante parcial'), backgroundColor: AppTheme.warningColor, behavior: SnackBarBehavior.floating)); Navigator.pop(context); }
            },
            icon: const Icon(Icons.report_problem), label: const Text('Crear Incidencia'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.warningColor),
          ),
        ],
      ));
    } else {
      setState(() => _finalizando = true);
      await FirebaseService.finalizarValidacionGuia(guiaId: _guiaSeleccionada!.guiaId, totalTrackings: _trackings.length, recibidos: _trackingsValidados.length, faltantes: [], numeroGuia: _guiaSeleccionada!.numeroGuia, clienteNombre: _guiaSeleccionada!.clienteNombre);
      if (mounted) { ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Guía validada - Retirada Completa'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating)); Navigator.pop(context); }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadingVuelos) return Scaffold(appBar: AppBar(title: const Text('Validar Retiro')), body: const Center(child: CircularProgressIndicator()));

    if (_guiaSeleccionada == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Validar Retiro')),
        body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppTheme.accentColor, AppTheme.accentLight]), borderRadius: BorderRadius.circular(16)),
            child: const Row(children: [Icon(Icons.qr_code_scanner, color: Colors.white, size: 28), SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Validación de Retiro', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)), Text('Seleccione vuelo y guía', style: TextStyle(color: Colors.white70, fontSize: 12))])])),
          const SizedBox(height: 20),
          DropdownButtonFormField<String>(value: _vueloSeleccionado, decoration: const InputDecoration(labelText: 'Vuelo / Manifiesto', prefixIcon: Icon(Icons.flight)),
            items: _vuelos.map<DropdownMenuItem<String>>((v) => DropdownMenuItem(value: v.vueloId as String, child: Text('${v.numeroManifiesto} - ${v.almacenMiami}'))).toList(),
            onChanged: (v) { setState(() { _vueloSeleccionado = v; _guiasVuelo = []; }); _loadGuias(v!); }),
          const SizedBox(height: 16),
          if (_loadingGuias) const Center(child: CircularProgressIndicator()),
          if (_guiasVuelo.isNotEmpty) ...[
            const Text('Guías del Vuelo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            const SizedBox(height: 10),
            ..._guiasVuelo.map((g) => Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
              contentPadding: const EdgeInsets.all(14),
              leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: (g.estadoLogistico == 'pendiente_retiro' ? AppTheme.pendienteRetiro : AppTheme.successColor).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(g.estadoLogistico == 'pendiente_retiro' ? Icons.inventory_2 : Icons.check_circle, color: g.estadoLogistico == 'pendiente_retiro' ? AppTheme.pendienteRetiro : AppTheme.successColor)),
              title: Text(g.numeroGuia, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text('${g.bultosRecibidos}/${g.bultosEsperados} · ${g.consignatarioNombre ?? "-"}'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _seleccionarGuia(g),
            ))),
          ],
        ])),
      );
    }

    // Pantalla de validación
    final progress = _trackings.isNotEmpty ? _trackingsValidados.length / _trackings.length : 0.0;
    return Scaffold(
      appBar: AppBar(title: Text('Validar ${_guiaSeleccionada!.numeroGuia}'), leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => setState(() { _guiaSeleccionada = null; _trackingsValidados.clear(); }))),
      body: Column(children: [
        Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(16)),
          child: Column(children: [
            Text(_guiaSeleccionada!.numeroGuia, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 6),
            Text('${_guiaSeleccionada!.consignatarioNombre ?? ""} · ${_guiaSeleccionada!.clienteNombre ?? ""}', style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 13)),
            const SizedBox(height: 12),
            ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 12, backgroundColor: Colors.white.withValues(alpha: 0.2), valueColor: AlwaysStoppedAnimation(progress >= 1 ? AppTheme.successColor : Colors.white))),
            const SizedBox(height: 8),
            Text('${_trackingsValidados.length}/${_trackings.length} (${(progress * 100).toStringAsFixed(0)}%)', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 14, fontWeight: FontWeight.w600)),
          ]),
        ),
        Container(margin: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
          Expanded(child: TextField(controller: _scanController, decoration: InputDecoration(hintText: 'Escanear tracking...', prefixIcon: const Icon(Icons.qr_code_scanner, color: AppTheme.accentColor), filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.accentColor.withValues(alpha: 0.3)))), onSubmitted: (_) => _escanearTracking())),
          const SizedBox(width: 8),
          SizedBox(height: 52, child: ElevatedButton(onPressed: _escanearTracking, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: const Icon(Icons.check, size: 24))),
        ])),
        const SizedBox(height: 12),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Trackings:', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)), Text('${_trackingsValidados.length}/${_trackings.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700))])),
        const SizedBox(height: 8),
        Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: _trackings.length, itemBuilder: (context, index) {
          final t = _trackings[index];
          final validado = _trackingsValidados.contains(t.trackingId);
          return Container(margin: const EdgeInsets.only(bottom: 6), decoration: BoxDecoration(color: validado ? AppTheme.successColor.withValues(alpha: 0.06) : Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: validado ? AppTheme.successColor.withValues(alpha: 0.3) : Colors.grey.shade200)),
            child: ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
              leading: GestureDetector(onTap: () => _toggleTracking(t), child: AnimatedContainer(duration: const Duration(milliseconds: 200), width: 32, height: 32, decoration: BoxDecoration(color: validado ? AppTheme.successColor : Colors.grey.shade200, borderRadius: BorderRadius.circular(8)), child: Icon(validado ? Icons.check : Icons.hourglass_bottom, color: validado ? Colors.white : AppTheme.textMuted, size: 18))),
              title: Text(t.numeroTracking, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, fontFamily: 'monospace', color: validado ? AppTheme.successColor : AppTheme.textPrimary, decoration: validado ? TextDecoration.lineThrough : null)),
              trailing: Text(validado ? 'Recibido' : 'Pendiente', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: validado ? AppTheme.successColor : AppTheme.pendienteRetiro)),
            ),
          );
        })),
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))]),
          child: SafeArea(child: SizedBox(width: double.infinity, height: 52, child: ElevatedButton.icon(
            onPressed: _finalizando ? null : _finalizarValidacion,
            icon: _finalizando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check_circle),
            label: Text(_finalizando ? 'Procesando...' : 'FINALIZAR VALIDACIÓN'),
            style: ElevatedButton.styleFrom(backgroundColor: _trackingsValidados.length == _trackings.length ? AppTheme.successColor : AppTheme.warningColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          ))),
        ),
      ]),
    );
  }

  @override
  void dispose() { _scanController.dispose(); super.dispose(); }
}
