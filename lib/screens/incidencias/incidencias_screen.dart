import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/incidencia.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/item_options_sheet.dart';
import '../../services/excel_service.dart';

class IncidenciasScreen extends StatelessWidget {
  const IncidenciasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Incidencias'), actions: [
        IconButton(icon: const Icon(Icons.file_download), tooltip: 'Exportar Excel', onPressed: () async { await ExcelService.exportarIncidencias(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📊 Incidencias exportadas'), behavior: SnackBarBehavior.floating)); }),
      ]),
      body: StreamBuilder<List<Incidencia>>(
        stream: FirebaseService.incidenciasStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final incidencias = snapshot.data ?? [];
          if (incidencias.isEmpty) return const Center(child: Text('No hay incidencias', style: TextStyle(color: AppTheme.textSecondary)));
          return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800), child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: incidencias.length, itemBuilder: (context, index) {
            final inc = incidencias[index];
            return Card(margin: const EdgeInsets.only(bottom: 12), child: InkWell(borderRadius: BorderRadius.circular(16), onLongPress: () {
              ItemOptionsSheet.show(context: context, titulo: inc.numeroGuia ?? 'Incidencia', subtitulo: _tipoLabel(inc.tipo),
                onEditar: () => _resolverIncidencia(context, inc),
                onEliminar: () async { final ok = await ItemOptionsSheet.confirmarEliminar(context, 'incidencia de ${inc.numeroGuia}'); if (ok && context.mounted) { await FirebaseService.eliminarIncidencia(inc.incidenciaId); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑 Incidencia eliminada'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating)); } });
            }, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.errorColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.warning_amber, color: AppTheme.errorColor, size: 20)),
                  const SizedBox(width: 10),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(inc.numeroGuia ?? '-', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    Text(inc.clienteNombre ?? '', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ]),
                ]),
                StatusBadge.incidencia(inc.estado),
              ]),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4), decoration: BoxDecoration(color: AppTheme.warningColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                child: Text('Tipo: ${_tipoLabel(inc.tipo)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.warningColor))),
              const SizedBox(height: 10),
              Text(inc.descripcion, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              if (inc.trackingsAfectados != null && inc.trackingsAfectados!.isNotEmpty) ...[
                const SizedBox(height: 10), const Text('Trackings afectados:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 4),
                Wrap(spacing: 6, runSpacing: 4, children: inc.trackingsAfectados!.map((t) => Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: AppTheme.errorColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(6)), child: Text(t, style: const TextStyle(fontSize: 11, fontFamily: 'monospace', fontWeight: FontWeight.w600, color: AppTheme.errorColor)))).toList()),
              ],
              const SizedBox(height: 12),
              Row(children: [
                Icon(Icons.calendar_today, size: 13, color: AppTheme.textMuted), const SizedBox(width: 4),
                Text('${inc.fechaCreacion.day}/${inc.fechaCreacion.month}/${inc.fechaCreacion.year}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
                const Spacer(),
                if (inc.estado != 'resuelta')
                  ElevatedButton.icon(
                    onPressed: () => _resolverIncidencia(context, inc),
                    icon: const Icon(Icons.check, size: 16), label: const Text('Resolver'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), textStyle: const TextStyle(fontSize: 12)),
                  ),
              ]),
            ]))));
          })));
        },
      ),
    );
  }

  void _resolverIncidencia(BuildContext context, Incidencia inc) {
    showDialog(context: context, builder: (ctx) {
      final notasController = TextEditingController();
      return AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Resolver Incidencia', style: TextStyle(fontSize: 18)),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Guía: ${inc.numeroGuia}'),
          Text('Tipo: ${_tipoLabel(inc.tipo)}'),
          const SizedBox(height: 12),
          TextField(controller: notasController, decoration: const InputDecoration(labelText: 'Notas de resolución'), maxLines: 3),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseService.actualizarIncidencia(inc.incidenciaId, {'estado': 'resuelta', 'notas_resolucion': notasController.text, 'fecha_resolucion': DateTime.now().toIso8601String()});
              if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Incidencia resuelta'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor),
            child: const Text('Resolver'),
          ),
        ],
      );
    });
  }

  String _tipoLabel(String tipo) {
    switch (tipo) { case 'faltante_parcial': return 'Faltante Parcial'; case 'canal_rojo': return 'Canal Rojo'; case 'no_volo': return 'No Voló'; case 'perdida': return 'Pérdida'; default: return tipo; }
  }
}
