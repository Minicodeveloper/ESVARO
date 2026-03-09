import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/guia.dart';
import '../../models/tracking.dart';
import '../../widgets/status_badge.dart';

class GuiaDetalleScreen extends StatefulWidget {
  final String guiaId;
  const GuiaDetalleScreen({super.key, required this.guiaId});
  @override
  State<GuiaDetalleScreen> createState() => _GuiaDetalleScreenState();
}

class _GuiaDetalleScreenState extends State<GuiaDetalleScreen> {
  Guia? _guia;
  List<Tracking> _trackings = [];
  bool _loading = true;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    final guia = await FirebaseService.getGuiaById(widget.guiaId);
    final trackings = await FirebaseService.getTrackingsPorGuia(widget.guiaId);
    if (mounted) setState(() { _guia = guia; _trackings = trackings; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(appBar: AppBar(title: const Text('Cargando...')), body: const Center(child: CircularProgressIndicator()));
    final guia = _guia;
    if (guia == null) return Scaffold(appBar: AppBar(title: const Text('Error')), body: const Center(child: Text('Guía no encontrada')));

    final recibidos = _trackings.where((t) => t.isRecibido).length;
    final faltantes = _trackings.where((t) => t.isFaltante).length;
    final progress = guia.bultosEsperados > 0 ? guia.bultosRecibidos / guia.bultosEsperados : 0.0;

    return Scaffold(
      appBar: AppBar(title: Text('Guía ${guia.numeroGuia}')),
      body: RefreshIndicator(onRefresh: _load, child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(padding: const EdgeInsets.all(20), decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(20)),
            child: Column(children: [
              Text(guia.numeroGuia, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.w900)),
              const SizedBox(height: 12),
              Wrap(spacing: 8, runSpacing: 4, alignment: WrapAlignment.center, children: [StatusBadge.logistico(guia.estadoLogistico), StatusBadge.financiero(guia.estadoFinanciero), StatusBadge.entrega(guia.estadoEntrega)]),
              const SizedBox(height: 16),
              ClipRRect(borderRadius: BorderRadius.circular(8), child: LinearProgressIndicator(value: progress, minHeight: 10, backgroundColor: Colors.white.withValues(alpha: 0.2), valueColor: AlwaysStoppedAnimation(progress >= 1 ? AppTheme.successColor : Colors.white))),
              const SizedBox(height: 8),
              Text('${guia.bultosRecibidos} de ${guia.bultosEsperados} bultos (${(progress * 100).toStringAsFixed(0)}%)', style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: 13)),
            ]),
          ),
          const SizedBox(height: 16),
          _InfoSection(children: [_DetailRow(label: 'Cliente', value: guia.clienteNombre ?? '-'), _DetailRow(label: 'Consignatario', value: guia.consignatarioNombre ?? '-'), _DetailRow(label: 'Manifiesto', value: guia.numeroManifiesto ?? '-'), _DetailRow(label: 'Almacén', value: guia.almacenMiami)]),
          const SizedBox(height: 16),
          Row(children: [
            Expanded(child: _MiniStat(label: 'Recibidos', value: '$recibidos', color: AppTheme.successColor)),
            const SizedBox(width: 8),
            Expanded(child: _MiniStat(label: 'Faltantes', value: '$faltantes', color: AppTheme.errorColor)),
            const SizedBox(width: 8),
            Expanded(child: _MiniStat(label: 'Total', value: '${_trackings.length}', color: AppTheme.primaryColor)),
          ]),
          const SizedBox(height: 16),
          const Text('Trackings', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ..._trackings.map((t) => Container(
            margin: const EdgeInsets.only(bottom: 8), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade200)),
            child: Row(children: [
              Icon(t.isRecibido ? Icons.check_circle : t.isFaltante ? Icons.cancel : Icons.hourglass_bottom, color: t.isRecibido ? AppTheme.successColor : t.isFaltante ? AppTheme.errorColor : AppTheme.pendienteRetiro, size: 22),
              const SizedBox(width: 12),
              Expanded(child: Text(t.numeroTracking, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, fontFamily: 'monospace'))),
              StatusBadge.tracking(t.estado),
            ]),
          )),
        ]),
      )),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final List<Widget> children;
  const _InfoSection({required this.children});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)), child: Column(children: children));
}

class _DetailRow extends StatelessWidget {
  final String label; final String value;
  const _DetailRow({required this.label, required this.value});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.symmetric(vertical: 6), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [SizedBox(width: 120, child: Text(label, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary))), Expanded(child: Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)))]));
}

class _MiniStat extends StatelessWidget {
  final String label; final String value; final Color color;
  const _MiniStat({required this.label, required this.value, required this.color});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: color.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: color.withValues(alpha: 0.2))), child: Column(children: [Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)), const SizedBox(height: 2), Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500))]));
}
