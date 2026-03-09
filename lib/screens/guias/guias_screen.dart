import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/guia.dart';
import '../../widgets/status_badge.dart';
import '../../widgets/item_options_sheet.dart';
import '../../services/excel_service.dart';
import 'guia_detalle_screen.dart';

class GuiasScreen extends StatefulWidget {
  const GuiasScreen({super.key});
  @override
  State<GuiasScreen> createState() => _GuiasScreenState();
}

class _GuiasScreenState extends State<GuiasScreen> {
  String _filtro = 'todas';
  String _busqueda = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guías'),
        actions: [IconButton(icon: const Icon(Icons.file_download), tooltip: 'Exportar Excel', onPressed: () async { await ExcelService.exportarGuias(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📊 Guías exportadas'), behavior: SnackBarBehavior.floating)); })],
        bottom: PreferredSize(preferredSize: const Size.fromHeight(60), child: Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
          child: TextField(
            onChanged: (v) => setState(() => _busqueda = v),
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(hintText: 'Buscar guía, cliente...', hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)), prefixIcon: Icon(Icons.search, color: Colors.white.withValues(alpha: 0.7)), border: InputBorder.none, enabledBorder: InputBorder.none, focusedBorder: InputBorder.none),
          ),
        )),
      ),
      body: StreamBuilder<List<Guia>>(
        stream: FirebaseService.guiasStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          var guias = snapshot.data ?? [];
          if (_filtro != 'todas') guias = guias.where((g) => g.estadoLogistico == _filtro).toList();
          if (_busqueda.isNotEmpty) {
            final q = _busqueda.toLowerCase();
            guias = guias.where((g) => g.numeroGuia.toLowerCase().contains(q) || (g.clienteNombre?.toLowerCase().contains(q) ?? false) || (g.consignatarioNombre?.toLowerCase().contains(q) ?? false)).toList();
          }
          return Column(children: [
            SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), child: Row(children: [
              _FilterChip(label: 'Todas', active: _filtro == 'todas', onTap: () => setState(() => _filtro = 'todas')),
              _FilterChip(label: 'Pendiente', active: _filtro == 'pendiente_retiro', onTap: () => setState(() => _filtro = 'pendiente_retiro'), color: AppTheme.pendienteRetiro),
              _FilterChip(label: 'Completas', active: _filtro == 'retirada_completa', onTap: () => setState(() => _filtro = 'retirada_completa'), color: AppTheme.retiradaCompleta),
              _FilterChip(label: 'Incompletas', active: _filtro == 'retirada_incompleta', onTap: () => setState(() => _filtro = 'retirada_incompleta'), color: AppTheme.retiradaIncompleta),
              _FilterChip(label: 'Canal Rojo', active: _filtro == 'canal_rojo', onTap: () => setState(() => _filtro = 'canal_rojo'), color: AppTheme.canalRojo),
            ])),
            Expanded(child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800), child: guias.isEmpty
              ? const Center(child: Text('No se encontraron guías', style: TextStyle(color: AppTheme.textSecondary)))
              : ListView.builder(padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: guias.length, itemBuilder: (context, index) {
                  final g = guias[index];
                  final progress = g.bultosEsperados > 0 ? g.bultosRecibidos / g.bultosEsperados : 0.0;
                  return Card(margin: const EdgeInsets.only(bottom: 10), child: InkWell(borderRadius: BorderRadius.circular(16),
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GuiaDetalleScreen(guiaId: g.guiaId))),
                    onLongPress: () => _opcionesGuia(context, g),
                    child: Padding(padding: const EdgeInsets.all(14), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(g.numeroGuia, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700)), StatusBadge.logistico(g.estadoLogistico)]),
                      const SizedBox(height: 8),
                      Row(children: [const Icon(Icons.person, size: 14, color: AppTheme.textSecondary), const SizedBox(width: 4), Expanded(child: Text(g.clienteNombre ?? '', style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)))]),
                      const SizedBox(height: 4),
                      Row(children: [const Icon(Icons.badge, size: 14, color: AppTheme.textSecondary), const SizedBox(width: 4), Text('Consig: ${g.consignatarioNombre ?? "-"}', style: const TextStyle(fontSize: 12, color: AppTheme.textMuted))]),
                      const SizedBox(height: 10),
                      Row(children: [Expanded(child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: progress, backgroundColor: Colors.grey.shade200, valueColor: AlwaysStoppedAnimation(progress >= 1 ? AppTheme.successColor : AppTheme.pendienteRetiro), minHeight: 6))), const SizedBox(width: 10), Text('${g.bultosRecibidos}/${g.bultosEsperados}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))]),
                      const SizedBox(height: 8),
                      Row(children: [StatusBadge.financiero(g.estadoFinanciero), const SizedBox(width: 6), StatusBadge.entrega(g.estadoEntrega)]),
                    ])),
                  ));
                },
              ),
            ))),
          ]);
        },
      ),
    );
  }

  void _opcionesGuia(BuildContext context, Guia g) {
    ItemOptionsSheet.show(context: context, titulo: g.numeroGuia, subtitulo: g.clienteNombre,
      onEditar: () => _editarGuia(context, g),
      onEliminar: () async {
        final ok = await ItemOptionsSheet.confirmarEliminar(context, g.numeroGuia);
        if (ok && context.mounted) {
          await FirebaseService.eliminarGuia(g.guiaId);
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑 Guía eliminada'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating));
        }
      },
    );
  }

  void _editarGuia(BuildContext context, Guia g) {
    String estLog = g.estadoLogistico; String estFin = g.estadoFinanciero; String estEnt = g.estadoEntrega;
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('Editar ${g.numeroGuia}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 16),
          DropdownButtonFormField<String>(value: estLog, decoration: const InputDecoration(labelText: 'Estado Logístico'),
            items: ['pendiente_retiro', 'retirada_completa', 'retirada_incompleta', 'canal_rojo'].map((e) => DropdownMenuItem(value: e, child: Text(e.replaceAll('_', ' ')))).toList(), onChanged: (v) => setS(() => estLog = v!)), const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: estFin, decoration: const InputDecoration(labelText: 'Estado Financiero'),
            items: ['pendiente', 'liquidado', 'pagado'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setS(() => estFin = v!)), const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: estEnt, decoration: const InputDecoration(labelText: 'Estado Entrega'),
            items: ['pendiente', 'programada', 'entregada'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setS(() => estEnt = v!)), const SizedBox(height: 20),
          SizedBox(height: 50, child: ElevatedButton(onPressed: () async {
            Navigator.pop(ctx);
            await FirebaseService.actualizarGuia(g.guiaId, {'estado_logistico': estLog, 'estado_financiero': estFin, 'estado_entrega': estEnt});
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Guía actualizada'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: const Text('GUARDAR'))), const SizedBox(height: 24),
        ]),
      )),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label; final bool active; final VoidCallback onTap; final Color? color;
  const _FilterChip({required this.label, required this.active, required this.onTap, this.color});
  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primaryColor;
    return Padding(padding: const EdgeInsets.only(right: 8), child: GestureDetector(onTap: onTap, child: AnimatedContainer(
      duration: const Duration(milliseconds: 200), padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: active ? c.withValues(alpha: 0.15) : Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: active ? c : Colors.grey.shade300)),
      child: Text(label, style: TextStyle(fontSize: 12, fontWeight: active ? FontWeight.w700 : FontWeight.w500, color: active ? c : AppTheme.textSecondary)),
    )));
  }
}
