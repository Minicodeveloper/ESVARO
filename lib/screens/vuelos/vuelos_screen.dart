import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../services/excel_service.dart';
import '../../models/vuelo.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/item_options_sheet.dart';
import 'registrar_vuelo_screen.dart';
import '../guias/guias_vuelo_screen.dart';

class VuelosScreen extends StatelessWidget {
  const VuelosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Vuelos / Manifiestos'), actions: [
        IconButton(icon: const Icon(Icons.file_download), tooltip: 'Exportar Excel', onPressed: () async {
          await ExcelService.exportarVuelos();
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📊 Excel exportado'), behavior: SnackBarBehavior.floating));
        }),
      ]),
      body: StreamBuilder<List<Vuelo>>(
        stream: FirebaseService.vuelosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));
          final vuelos = snapshot.data ?? [];
          if (vuelos.isEmpty) return const Center(child: Text('No hay vuelos registrados', style: TextStyle(color: AppTheme.textSecondary)));
          return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800), child: ListView.builder(
            padding: const EdgeInsets.all(16), itemCount: vuelos.length,
            itemBuilder: (context, index) {
              final v = vuelos[index];
              return FutureBuilder<int>(
                future: FirebaseService.getGuiasPorVuelo(v.vueloId).then((g) => g.length),
                builder: (ctx, guiasSnap) {
                  final guiasCount = guiasSnap.data ?? 0;
                  return Card(margin: const EdgeInsets.only(bottom: 12), child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GuiasVueloScreen(vuelo: v))),
                    onLongPress: () => _opciones(context, v),
                    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Row(children: [
                          Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.flight, color: AppTheme.primaryColor, size: 20)),
                          const SizedBox(width: 12),
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(v.numeroManifiesto, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                            Text(v.almacenMiami, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          ]),
                        ]),
                        StatusBadge.vuelo(v.estado),
                      ]),
                      const SizedBox(height: 12),
                      Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.scaffoldBg, borderRadius: BorderRadius.circular(10)),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                          _VueloInfo(icon: Icons.calendar_today, label: 'Llegada', value: '${v.fechaLlegada.day}/${v.fechaLlegada.month}/${v.fechaLlegada.year}'),
                          Container(width: 1, height: 30, color: Colors.grey.shade300),
                          _VueloInfo(icon: Icons.description, label: 'Guías', value: '$guiasCount'),
                          Container(width: 1, height: 30, color: Colors.grey.shade300),
                          _VueloInfo(icon: Icons.store, label: 'Almacén', value: v.almacenMiami.split(' ').first),
                        ]),
                      ),
                      // Resumen financiero del vuelo
                      FutureBuilder<Map<String, dynamic>>(
                        future: FirebaseService.getResumenVuelo(v.vueloId),
                        builder: (_, rsnap) {
                          final r = rsnap.data;
                          if (r == null) return const SizedBox.shrink();
                          return Column(children: [const SizedBox(height: 10), Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8), decoration: BoxDecoration(color: AppTheme.infoColor.withValues(alpha: 0.05), borderRadius: BorderRadius.circular(8)),
                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                              Text('💰\$${(r['facturado'] as double).toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
                              Text('✅\$${(r['cobrado'] as double).toStringAsFixed(0)}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.successColor)),
                              Text('⏳\$${(r['pendiente'] as double).toStringAsFixed(0)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: (r['pendiente'] as double) > 0 ? AppTheme.errorColor : AppTheme.successColor)),
                            ]))]);
                        },
                      ),
                    ])),
                  ));
                },
              );
            },
          )));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegistrarVueloScreen())), icon: const Icon(Icons.add), label: const Text('Nuevo Vuelo')),
    );
  }

  void _opciones(BuildContext context, Vuelo v) {
    ItemOptionsSheet.show(
      context: context,
      titulo: v.numeroManifiesto,
      subtitulo: '${v.almacenMiami} · ${v.fechaLlegada.day}/${v.fechaLlegada.month}/${v.fechaLlegada.year}',
      onEditar: () => _editarVuelo(context, v),
      onEliminar: () => _eliminarVuelo(context, v),
    );
  }

  void _editarVuelo(BuildContext context, Vuelo v) {
    final manifCtrl = TextEditingController(text: v.numeroManifiesto);
    String almacen = v.almacenMiami;
    String estado = v.estado;
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Editar Vuelo', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 16),
          TextField(controller: manifCtrl, decoration: const InputDecoration(labelText: 'Número de Manifiesto', prefixIcon: Icon(Icons.confirmation_number))), const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: almacen, decoration: const InputDecoration(labelText: 'Almacén Miami', prefixIcon: Icon(Icons.warehouse)),
            items: ['TIB COURIER', 'VNSE BOX PERU', 'MIXTO'].map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(), onChanged: (v) => setS(() => almacen = v!)), const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: estado, decoration: const InputDecoration(labelText: 'Estado', prefixIcon: Icon(Icons.flag)),
            items: ['programado', 'en_transito', 'llegado', 'despachado'].map((e) => DropdownMenuItem(value: e, child: Text(e.replaceAll('_', ' ').toUpperCase()))).toList(), onChanged: (v) => setS(() => estado = v!)), const SizedBox(height: 20),
          SizedBox(height: 50, child: ElevatedButton(onPressed: () async {
            Navigator.pop(ctx);
            await FirebaseService.actualizarVuelo(v.vueloId, {'numero_manifiesto': manifCtrl.text, 'almacen_miami': almacen, 'estado': estado});
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Vuelo actualizado'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: const Text('GUARDAR'))), const SizedBox(height: 24),
        ]),
      )),
    );
  }

  void _eliminarVuelo(BuildContext context, Vuelo v) async {
    final ok = await ItemOptionsSheet.confirmarEliminar(context, v.numeroManifiesto);
    if (ok && context.mounted) {
      await FirebaseService.eliminarVuelo(v.vueloId);
      if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑 Vuelo eliminado'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating));
    }
  }
}

class _VueloInfo extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _VueloInfo({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(children: [Icon(icon, size: 16, color: AppTheme.textSecondary), const SizedBox(height: 4), Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)), Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary))]);
  }
}
