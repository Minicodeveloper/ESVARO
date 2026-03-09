import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/servicio_adicional.dart';
import '../../widgets/item_options_sheet.dart';

class ServiciosScreen extends StatelessWidget {
  const ServiciosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Servicios Adicionales')),
      body: StreamBuilder<List<ServicioAdicional>>(
        stream: FirebaseService.serviciosStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final servicios = snapshot.data ?? [];
          if (servicios.isEmpty) return const Center(child: Text('No hay servicios', style: TextStyle(color: AppTheme.textSecondary)));
          return ListView.builder(padding: const EdgeInsets.all(16), itemCount: servicios.length, itemBuilder: (context, index) {
            final s = servicios[index];
            return Card(margin: const EdgeInsets.only(bottom: 12), child: InkWell(borderRadius: BorderRadius.circular(16), onLongPress: () {
              ItemOptionsSheet.show(context: context, titulo: _labelForTipo(s.tipo), subtitulo: s.trackingId,
                onEditar: () => _nuevoServicio(context),
                onEliminar: () async { final ok = await ItemOptionsSheet.confirmarEliminar(context, 'servicio ${_labelForTipo(s.tipo)}'); if (ok && context.mounted) { await FirebaseService.eliminarServicioAdicional(s.servicioId); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑 Servicio eliminado'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating)); } });
            }, child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: const Color(0xFFE91E63).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: Icon(_iconForTipo(s.tipo), color: const Color(0xFFE91E63), size: 20)),
                  const SizedBox(width: 12),
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(_labelForTipo(s.tipo), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                    if (s.trackingId != null) Text('Tracking: ${s.trackingId}', style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                  ]),
                ]),
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), decoration: BoxDecoration(color: s.estado == 'cobrado' ? AppTheme.successColor.withValues(alpha: 0.1) : AppTheme.warningColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
                  child: Text(s.estado == 'cobrado' ? 'Cobrado' : 'Pend.', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: s.estado == 'cobrado' ? AppTheme.successColor : AppTheme.warningColor))),
              ]),
              const SizedBox(height: 12),
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.scaffoldBg, borderRadius: BorderRadius.circular(10)),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                  Column(children: [Text('${s.cantidad}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)), const Text('Cant.', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary))]),
                  Column(children: [Text('\$${s.precioUnitario.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16)), const Text('Unit.', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary))]),
                  Column(children: [Text('\$${s.precioTotal.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 18, color: AppTheme.infoColor)), const Text('Total', style: TextStyle(fontSize: 10, color: AppTheme.textSecondary))]),
                ]),
              ),
              if (s.estado != 'cobrado') ...[const SizedBox(height: 10),
                SizedBox(width: double.infinity, child: ElevatedButton.icon(onPressed: () async {
                  await FirebaseService.actualizarServicioAdicional(s.servicioId, {'estado': 'cobrado'});
                  if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Marcado como cobrado'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
                }, icon: const Icon(Icons.check, size: 16), label: const Text('Marcar Cobrado'), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor, padding: const EdgeInsets.symmetric(vertical: 8))))],
            ]))));
          });
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _nuevoServicio(context), icon: const Icon(Icons.add), label: const Text('Nuevo')),
    );
  }

  IconData _iconForTipo(String t) { switch(t) { case 'foto': return Icons.photo_camera; case 'separacion': return Icons.call_split; case 'reempaque': return Icons.inventory_2; default: return Icons.miscellaneous_services; } }
  String _labelForTipo(String t) { switch(t) { case 'foto': return 'Fotos'; case 'separacion': return 'Separación'; case 'reempaque': return 'Reempaque'; default: return 'Otro'; } }

  void _nuevoServicio(BuildContext context) {
    final cantCtrl = TextEditingController(text: '1'); final precioCtrl = TextEditingController(); final notasCtrl = TextEditingController(); final trackingCtrl = TextEditingController();
    String tipo = 'foto';
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Nuevo Servicio', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 16),
          TextField(controller: trackingCtrl, decoration: const InputDecoration(labelText: 'Tracking', prefixIcon: Icon(Icons.qr_code_scanner))), const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: tipo, decoration: const InputDecoration(labelText: 'Tipo'), items: const [DropdownMenuItem(value: 'foto', child: Text('Fotos')), DropdownMenuItem(value: 'separacion', child: Text('Separación')), DropdownMenuItem(value: 'reempaque', child: Text('Reempaque')), DropdownMenuItem(value: 'otro', child: Text('Otro'))], onChanged: (v) => setS(() => tipo = v!)), const SizedBox(height: 12),
          Row(children: [Expanded(child: TextField(controller: cantCtrl, decoration: const InputDecoration(labelText: 'Cantidad'), keyboardType: TextInputType.number)), const SizedBox(width: 12), Expanded(child: TextField(controller: precioCtrl, decoration: const InputDecoration(labelText: 'Precio Unit. (\$)'), keyboardType: TextInputType.number))]), const SizedBox(height: 12),
          TextField(controller: notasCtrl, decoration: const InputDecoration(labelText: 'Notas'), maxLines: 2), const SizedBox(height: 20),
          SizedBox(height: 50, child: ElevatedButton(onPressed: () async {
            Navigator.pop(ctx);
            final cant = int.tryParse(cantCtrl.text) ?? 1; final precio = double.tryParse(precioCtrl.text) ?? 0;
            await FirebaseService.crearServicioAdicional(ServicioAdicional(servicioId: '', guiaId: '', trackingId: trackingCtrl.text.isNotEmpty ? trackingCtrl.text : null, tipo: tipo, cantidad: cant, precioUnitario: precio, precioTotal: cant * precio, autorizadoPor: null, estado: 'pendiente_cobro', notas: notasCtrl.text.isNotEmpty ? notasCtrl.text : null));
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Servicio creado'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: const Text('GUARDAR'))), const SizedBox(height: 24),
        ]),
      )),
    );
  }
}
