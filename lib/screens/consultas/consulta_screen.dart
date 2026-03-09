import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../widgets/status_badge.dart';

class ConsultaScreen extends StatefulWidget {
  const ConsultaScreen({super.key});
  @override
  State<ConsultaScreen> createState() => _ConsultaScreenState();
}

class _ConsultaScreenState extends State<ConsultaScreen> {
  final _searchController = TextEditingController();
  Map<String, dynamic>? _resultado;
  String? _error;
  bool _buscando = false;

  void _buscar() async {
    final q = _searchController.text.trim();
    if (q.isEmpty) return;
    setState(() { _error = null; _resultado = null; _buscando = true; });

    // Buscar por tracking
    final tracking = await FirebaseService.buscarTracking(q);
    if (tracking != null) {
      final guia = await FirebaseService.getGuiaById(tracking.guiaId);
      final vuelo = guia != null ? await FirebaseService.getVueloById(guia.vueloId) : null;
      if (mounted) setState(() { _resultado = {'tipo': 'tracking', 'tracking': tracking, 'guia': guia, 'vuelo': vuelo}; _buscando = false; });
      return;
    }

    // Buscar por guía
    final guias = await FirebaseService.getGuias();
    final match = guias.where((g) => g.numeroGuia.toLowerCase().contains(q.toLowerCase())).toList();
    if (match.isNotEmpty) {
      final guia = match.first;
      final vuelo = await FirebaseService.getVueloById(guia.vueloId);
      if (mounted) setState(() { _resultado = {'tipo': 'guia', 'guia': guia, 'vuelo': vuelo}; _buscando = false; });
      return;
    }

    if (mounted) setState(() { _error = 'No se encontró resultado para "$q"'; _buscando = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consultas')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20)),
          child: Column(children: [
            const Icon(Icons.search, color: Colors.white, size: 40), const SizedBox(height: 10),
            const Text('¿Qué buscas?', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w700)),
            Text('Busca por tracking o guía', style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 13)),
            const SizedBox(height: 16),
            Row(children: [
              Expanded(child: TextField(controller: _searchController, onSubmitted: (_) => _buscar(), style: const TextStyle(fontSize: 15),
                decoration: InputDecoration(hintText: 'Ej: ABC123, ESV-001...', filled: true, fillColor: Colors.white, border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none), prefixIcon: const Icon(Icons.search), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14)))),
              const SizedBox(width: 8),
              SizedBox(height: 50, child: ElevatedButton(onPressed: _buscando ? null : _buscar, style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))), child: _buscando ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Buscar'))),
            ]),
          ]),
        ),
        const SizedBox(height: 20),

        if (_error != null) Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.errorColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12)),
          child: Row(children: [const Icon(Icons.error_outline, color: AppTheme.errorColor), const SizedBox(width: 10), Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.errorColor)))])),

        if (_resultado != null && _resultado!['tipo'] == 'tracking') _buildTrackingResult(),
        if (_resultado != null && _resultado!['tipo'] == 'guia') _buildGuiaResult(),

        const SizedBox(height: 24),
        const Text('Deudores Pendientes', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
        const SizedBox(height: 10),
        FutureBuilder(
          future: FirebaseService.getLiquidacionesPendientes(),
          builder: (ctx, snap) {
            if (snap.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            final pendientes = snap.data ?? [];
            if (pendientes.isEmpty) return const Text('Sin deudas pendientes', style: TextStyle(color: AppTheme.textSecondary));
            return Column(children: pendientes.map((l) => Container(
              margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l.clienteNombre ?? '-', style: const TextStyle(fontWeight: FontWeight.w700)), Text('${l.cantidadGuias ?? l.guiasIds.length} guías', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))]),
                Text('\$${l.montoTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.errorColor)),
              ]),
            )).toList());
          },
        ),
      ])),
    );
  }

  Widget _buildTrackingResult() {
    final t = _resultado!['tracking']; final g = _resultado!['guia']; final v = _resultado!['vuelo'];
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200), boxShadow: AppTheme.softShadow),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.local_shipping, color: AppTheme.primaryColor), const SizedBox(width: 10), const Text('Resultado Tracking', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))]),
        const Divider(height: 20),
        _resRow('Tracking', t.numeroTracking), _resRow('Estado', t.estado.toString().toUpperCase()),
        if (g != null) ...[_resRow('Guía', g.numeroGuia), _resRow('Cliente', g.clienteNombre ?? '-'), _resRow('Consignatario', g.consignatarioNombre ?? '-')],
        if (v != null) ...[_resRow('Vuelo', v.numeroManifiesto), _resRow('Llegada', '${v.fechaLlegada.day}/${v.fechaLlegada.month}/${v.fechaLlegada.year}')],
        const SizedBox(height: 8), StatusBadge.tracking(t.estado),
      ]),
    );
  }

  Widget _buildGuiaResult() {
    final g = _resultado!['guia']; final v = _resultado!['vuelo'];
    return Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: Colors.grey.shade200)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [const Icon(Icons.description, color: AppTheme.primaryColor), const SizedBox(width: 10), const Text('Resultado Guía', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700))]),
        const Divider(height: 20),
        _resRow('Guía', g.numeroGuia), _resRow('Cliente', g.clienteNombre ?? '-'), _resRow('Consignatario', g.consignatarioNombre ?? '-'), _resRow('Bultos', '${g.bultosRecibidos}/${g.bultosEsperados}'),
        if (v != null) _resRow('Vuelo', v.numeroManifiesto),
        const SizedBox(height: 8),
        Wrap(spacing: 6, children: [StatusBadge.logistico(g.estadoLogistico), StatusBadge.financiero(g.estadoFinanciero), StatusBadge.entrega(g.estadoEntrega)]),
      ]),
    );
  }

  Widget _resRow(String label, String value) => Padding(padding: const EdgeInsets.symmetric(vertical: 4), child: Row(children: [SizedBox(width: 110, child: Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13))), Expanded(child: Text(value, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)))]));
}
