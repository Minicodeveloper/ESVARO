import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/liquidacion.dart';
import '../../models/guia.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/item_options_sheet.dart';
import '../../services/excel_service.dart';

class LiquidacionesScreen extends StatelessWidget {
  const LiquidacionesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Liquidaciones'), actions: [
        IconButton(icon: const Icon(Icons.file_download), tooltip: 'Exportar Excel', onPressed: () async { await ExcelService.exportarLiquidaciones(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📊 Liquidaciones exportadas'), behavior: SnackBarBehavior.floating)); }),
      ]),
      body: StreamBuilder<List<Liquidacion>>(
        stream: FirebaseService.liquidacionesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final todas = snapshot.data ?? [];
          if (todas.isEmpty) return const Center(child: Text('No hay liquidaciones', style: TextStyle(color: AppTheme.textSecondary)));
          final total = todas.fold<double>(0, (s, l) => s + l.montoTotal);
          final pendientes = todas.where((l) => l.isPendiente).length;
          return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800), child: Column(children: [
            Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: AppTheme.infoColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(14), border: Border.all(color: AppTheme.infoColor.withValues(alpha: 0.2))),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                Column(children: [Text('\$${total.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.infoColor)), const Text('Total', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary))]),
                Column(children: [Text('${todas.length}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const Text('Liquidaciones', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary))]),
                Column(children: [Text('$pendientes', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.warningColor)), const Text('Pendientes', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary))]),
              ]),
            ),
            Expanded(child: ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: todas.length, itemBuilder: (context, index) {
              final l = todas[index];
              return Card(margin: const EdgeInsets.only(bottom: 12), child: InkWell(borderRadius: BorderRadius.circular(16), onLongPress: () {
                ItemOptionsSheet.show(context: context, titulo: l.clienteNombre ?? 'Liquidación', subtitulo: '\$${l.montoTotal.toStringAsFixed(2)}',
                  onEditar: () => _registrarPago(context, l),
                  onEliminar: () async { final ok = await ItemOptionsSheet.confirmarEliminar(context, 'liquidación de ${l.clienteNombre}'); if (ok && context.mounted) { await FirebaseService.eliminarLiquidacion(l.liquidacionId); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑 Liquidación eliminada'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating)); } });
              }, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(l.clienteNombre ?? 'Cliente', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)), Text('Manifiesto: ${l.numeroManifiesto ?? "-"}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))])),
                  StatusBadge.financiero(l.estado),
                ]),
                const SizedBox(height: 12),
                Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.scaffoldBg, borderRadius: BorderRadius.circular(10)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                    Column(children: [Text('${l.cantidadGuias ?? l.guiasIds.length}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)), const Text('Guías', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary))]),
                    Column(children: [Text('\$${l.montoTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.infoColor)), const Text('Monto', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary))]),
                    Column(children: [Text('${l.fechaLiquidacion.day}/${l.fechaLiquidacion.month}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const Text('Fecha', style: TextStyle(fontSize: 11, color: AppTheme.textSecondary))]),
                  ]),
                ),
                if (l.isPendiente) ...[const SizedBox(height: 12), SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  onPressed: () => _registrarPago(context, l),
                  icon: const Icon(Icons.payment, size: 18), label: const Text('Registrar Pago'),
                  style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor, padding: const EdgeInsets.symmetric(vertical: 10)),
                ))],
                if (l.isPagado && l.fechaPago != null) ...[const SizedBox(height: 8), Row(children: [const Icon(Icons.check_circle, color: AppTheme.successColor, size: 16), const SizedBox(width: 6), Text('Pagado: ${l.fechaPago!.day}/${l.fechaPago!.month}/${l.fechaPago!.year}', style: const TextStyle(fontSize: 12, color: AppTheme.successColor, fontWeight: FontWeight.w600))])],
              ]))));
            })),
          ])));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _nuevaLiquidacion(context), icon: const Icon(Icons.add), label: const Text('Nueva')),
    );
  }

  void _registrarPago(BuildContext context, Liquidacion l) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: Text('Registrar Pago - ${l.clienteNombre}'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        Text('Monto: \$${l.montoTotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        const TextField(decoration: InputDecoration(labelText: 'Referencia de pago')),
        const SizedBox(height: 8),
        OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.upload_file), label: const Text('Adjuntar comprobante')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () async {
          Navigator.pop(ctx);
          await FirebaseService.actualizarLiquidacion(l.liquidacionId, {'estado': 'pagado', 'fecha_pago': DateTime.now().toIso8601String()});
          // Actualizar guías asociadas
          for (final gId in l.guiasIds) { await FirebaseService.actualizarGuia(gId, {'estado_financiero': 'pagado'}); }
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Pago registrado'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
        }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor), child: const Text('Confirmar Pago')),
      ],
    ));
  }

  void _nuevaLiquidacion(BuildContext context) async {
    final vuelos = await FirebaseService.getVuelos();
    final clientes = await FirebaseService.getClientesActivos();
    if (!context.mounted) return;

    String? vueloId; String? clienteId; String? clienteNombre; String? numManifiesto;
    List<Guia> guiasCliente = [];
    final guiasSeleccionadas = <String>{};
    final montoController = TextEditingController();

    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) {
        return DraggableScrollableSheet(expand: false, initialChildSize: 0.85, maxChildSize: 0.95, builder: (_, sc) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 20),
          child: ListView(controller: sc, children: [
            const Text('Crear Liquidación', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 20),
            DropdownButtonFormField<String>(value: vueloId, decoration: const InputDecoration(labelText: 'Vuelo', prefixIcon: Icon(Icons.flight)),
              items: vuelos.map((v) => DropdownMenuItem(value: v.vueloId, child: Text(v.numeroManifiesto))).toList(),
              onChanged: (v) async { setModalState(() { vueloId = v; guiasSeleccionadas.clear(); numManifiesto = vuelos.where((x) => x.vueloId == v).firstOrNull?.numeroManifiesto; }); if (clienteId != null && v != null) { final g = await FirebaseService.getGuiasPorVuelo(v); setModalState(() => guiasCliente = g.where((x) => x.clienteId == clienteId).toList()); } }),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(value: clienteId, decoration: const InputDecoration(labelText: 'Cliente', prefixIcon: Icon(Icons.person)),
              items: clientes.map((c) => DropdownMenuItem(value: c.clienteId, child: Text(c.nombreComercial))).toList(),
              onChanged: (v) async { setModalState(() { clienteId = v; clienteNombre = clientes.where((c) => c.clienteId == v).firstOrNull?.nombreComercial; guiasSeleccionadas.clear(); }); if (vueloId != null && v != null) { final g = await FirebaseService.getGuiasPorVuelo(vueloId!); setModalState(() => guiasCliente = g.where((x) => x.clienteId == v).toList()); } }),
            const SizedBox(height: 16),
            if (guiasCliente.isNotEmpty) ...[const Text('Guías a liquidar:', style: TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 8),
              ...guiasCliente.map((g) => CheckboxListTile(value: guiasSeleccionadas.contains(g.guiaId), onChanged: (v) => setModalState(() { if (v!) guiasSeleccionadas.add(g.guiaId); else guiasSeleccionadas.remove(g.guiaId); }),
                title: Text(g.numeroGuia, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text('${g.consignatarioNombre ?? ""} · ${g.bultosRecibidos}/${g.bultosEsperados}'), dense: true, controlAffinity: ListTileControlAffinity.leading))],
            const SizedBox(height: 12),
            TextField(controller: montoController, decoration: const InputDecoration(labelText: 'Monto Total (\$)', prefixIcon: Icon(Icons.attach_money)), keyboardType: TextInputType.number),
            const SizedBox(height: 20),
            SizedBox(height: 52, child: ElevatedButton.icon(
              onPressed: () async {
                if (guiasSeleccionadas.isEmpty || montoController.text.isEmpty) return;
                Navigator.pop(ctx);
                final liq = Liquidacion(liquidacionId: '', clienteId: clienteId!, vueloId: vueloId!, guiasIds: guiasSeleccionadas.toList(), montoTotal: double.tryParse(montoController.text) ?? 0, estado: 'pendiente', fechaLiquidacion: DateTime.now(), clienteNombre: clienteNombre, numeroManifiesto: numManifiesto, cantidadGuias: guiasSeleccionadas.length);
                await FirebaseService.crearLiquidacion(liq);
                for (final gId in guiasSeleccionadas) { await FirebaseService.actualizarGuia(gId, {'estado_financiero': 'liquidado'}); }
                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Liquidación creada'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
              },
              icon: const Icon(Icons.receipt_long), label: Text('GENERAR (${guiasSeleccionadas.length} guías)'),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
            )),
            const SizedBox(height: 20),
          ]),
        ));
      }),
    );
  }
}
