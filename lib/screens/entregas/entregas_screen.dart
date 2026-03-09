import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/entrega.dart';
import '../../models/guia.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/item_options_sheet.dart';
import '../../services/excel_service.dart';

class EntregasScreen extends StatelessWidget {
  const EntregasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entregas'), actions: [
        IconButton(icon: const Icon(Icons.file_download), tooltip: 'Exportar Excel', onPressed: () async { await ExcelService.exportarEntregas(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📊 Entregas exportadas'), behavior: SnackBarBehavior.floating)); }),
      ]),
      body: StreamBuilder<List<Entrega>>(
        stream: FirebaseService.entregasStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final entregas = snapshot.data ?? [];
          if (entregas.isEmpty) return const Center(child: Text('No hay entregas', style: TextStyle(color: AppTheme.textSecondary)));
          return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800), child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: entregas.length, itemBuilder: (context, index) {
            final e = entregas[index];
            return Card(margin: const EdgeInsets.only(bottom: 12), child: InkWell(borderRadius: BorderRadius.circular(16), onLongPress: () {
              ItemOptionsSheet.show(context: context, titulo: e.numeroGuia ?? 'Entrega', subtitulo: e.consignatarioNombre,
                onEditar: () => _confirmarEntrega(context, e),
                onEliminar: () async { final ok = await ItemOptionsSheet.confirmarEliminar(context, 'entrega de ${e.numeroGuia}'); if (ok && context.mounted) { await FirebaseService.eliminarEntrega(e.entregaId); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑 Entrega eliminada'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating)); } });
            }, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: (e.tipoEntrega == 'delivery' ? AppTheme.infoColor : AppTheme.accentColor).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                    child: Icon(e.tipoEntrega == 'delivery' ? Icons.local_shipping : Icons.store, color: e.tipoEntrega == 'delivery' ? AppTheme.infoColor : AppTheme.accentColor, size: 20)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(e.numeroGuia ?? '-', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)), Text(e.consignatarioNombre ?? '-', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))]),
                ]),
                StatusBadge.entrega(e.estado),
              ]),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.scaffoldBg, borderRadius: BorderRadius.circular(10)), child: Column(children: [
                _row(Icons.person, 'Cliente: ${e.clienteNombre ?? "-"}'),
                const SizedBox(height: 4), _row(Icons.category, 'Tipo: ${e.tipoEntrega == "delivery" ? "Delivery" : "Retiro"}'),
                if (e.fechaProgramada != null) ...[const SizedBox(height: 4), _row(Icons.calendar_today, 'Fecha: ${e.fechaProgramada!.day}/${e.fechaProgramada!.month}/${e.fechaProgramada!.year}')],
                if (e.isEntregada) ...[const SizedBox(height: 4), _row(Icons.check_circle, 'Receptor: ${e.nombreReceptor ?? "-"}', color: AppTheme.successColor)],
                if (e.observacion != null) ...[const SizedBox(height: 4), _row(Icons.notes, e.observacion!, color: AppTheme.textMuted)],
              ])),
              if (!e.isEntregada) ...[const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.edit, size: 16), label: const Text('Editar'))),
                  const SizedBox(width: 8),
                  Expanded(child: ElevatedButton.icon(onPressed: () => _confirmarEntrega(context, e), icon: const Icon(Icons.check, size: 16), label: const Text('Entregar'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor))),
                ]),
              ],
            ]))));
          })));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _programarEntrega(context), icon: const Icon(Icons.add), label: const Text('Programar')),
    );
  }

  Widget _row(IconData icon, String text, {Color? color}) => Row(children: [Icon(icon, size: 14, color: color ?? AppTheme.textSecondary), const SizedBox(width: 6), Expanded(child: Text(text, style: TextStyle(fontSize: 13, color: color ?? AppTheme.textPrimary)))]);

  void _confirmarEntrega(BuildContext context, Entrega e) {
    final receptorController = TextEditingController();
    final dniController = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Confirmar Entrega'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: receptorController, decoration: const InputDecoration(labelText: 'Nombre del receptor')),
        const SizedBox(height: 12),
        TextField(controller: dniController, decoration: const InputDecoration(labelText: 'DNI del receptor'), keyboardType: TextInputType.number),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () async {
          Navigator.pop(ctx);
          await FirebaseService.actualizarEntrega(e.entregaId, {'estado': 'entregada', 'nombre_receptor': receptorController.text, 'dni_receptor': dniController.text, 'fecha_entregada': DateTime.now().toIso8601String()});
          await FirebaseService.actualizarGuia(e.guiaId, {'estado_entrega': 'entregada'});
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Entrega confirmada'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
        }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor), child: const Text('Confirmar')),
      ],
    ));
  }

  void _programarEntrega(BuildContext context) async {
    final guias = await FirebaseService.getGuias();
    final guiasSinEntrega = guias.where((g) => g.estadoEntrega == 'pendiente' && g.estadoLogistico != 'pendiente_retiro').toList();
    if (!context.mounted) return;

    String? guiaId; String tipo = 'retiro_oficina';
    DateTime fecha = DateTime.now().add(const Duration(days: 1));
    final obsController = TextEditingController();

    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Programar Entrega', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(value: guiaId, decoration: const InputDecoration(labelText: 'Guía', prefixIcon: Icon(Icons.description)),
            items: guiasSinEntrega.map((g) => DropdownMenuItem(value: g.guiaId, child: Text('${g.numeroGuia} - ${g.consignatarioNombre ?? ""}'))).toList(), onChanged: (v) => setModalState(() => guiaId = v)),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: tipo, decoration: const InputDecoration(labelText: 'Tipo', prefixIcon: Icon(Icons.category)),
            items: const [DropdownMenuItem(value: 'retiro_oficina', child: Text('Retiro en oficina')), DropdownMenuItem(value: 'delivery', child: Text('Delivery'))], onChanged: (v) => setModalState(() => tipo = v!)),
          const SizedBox(height: 12),
          GestureDetector(onTap: () async { final d = await showDatePicker(context: ctx, initialDate: fecha, firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 60))); if (d != null) setModalState(() => fecha = d); },
            child: InputDecorator(decoration: const InputDecoration(labelText: 'Fecha', prefixIcon: Icon(Icons.calendar_today)), child: Text('${fecha.day}/${fecha.month}/${fecha.year}'))),
          const SizedBox(height: 12),
          TextField(controller: obsController, decoration: const InputDecoration(labelText: 'Observación'), maxLines: 2),
          const SizedBox(height: 20),
          SizedBox(height: 50, child: ElevatedButton(onPressed: () async {
            if (guiaId == null) return;
            Navigator.pop(ctx);
            final guia = guiasSinEntrega.firstWhere((g) => g.guiaId == guiaId);
            final entrega = Entrega(entregaId: '', guiaId: guiaId!, tipoEntrega: tipo, fechaProgramada: fecha, estado: 'programada', observacion: obsController.text.isNotEmpty ? obsController.text : null, numeroGuia: guia.numeroGuia, clienteNombre: guia.clienteNombre, consignatarioNombre: guia.consignatarioNombre);
            await FirebaseService.crearEntrega(entrega);
            await FirebaseService.actualizarGuia(guiaId!, {'estado_entrega': 'programada'});
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Entrega programada'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: const Text('PROGRAMAR'))),
          const SizedBox(height: 24),
        ]),
      )),
    );
  }
}
