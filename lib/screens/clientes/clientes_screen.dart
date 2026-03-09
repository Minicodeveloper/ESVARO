import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/cliente.dart';
import '../../models/consignatario.dart';
import '../../widgets/item_options_sheet.dart';
import '../../services/excel_service.dart';

class ClientesScreen extends StatefulWidget {
  const ClientesScreen({super.key});
  @override
  State<ClientesScreen> createState() => _ClientesScreenState();
}

class _ClientesScreenState extends State<ClientesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Clientes'), actions: [
        PopupMenuButton<String>(icon: const Icon(Icons.more_vert), onSelected: (v) async {
          if (v == 'import') { final n = await ExcelService.importarClientes(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ $n clientes importados'), behavior: SnackBarBehavior.floating)); }
          if (v == 'export') { await ExcelService.exportarClientes(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('📊 Excel exportado'), behavior: SnackBarBehavior.floating)); }
        }, itemBuilder: (_) => [const PopupMenuItem(value: 'import', child: Row(children: [Icon(Icons.file_upload, size: 18), SizedBox(width: 8), Text('Importar Excel')])), const PopupMenuItem(value: 'export', child: Row(children: [Icon(Icons.file_download, size: 18), SizedBox(width: 8), Text('Exportar Excel')]))]),
      ]),
      body: StreamBuilder<List<Cliente>>(
        stream: FirebaseService.clientesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final clientes = snapshot.data ?? [];
          if (clientes.isEmpty) return const Center(child: Text('No hay clientes', style: TextStyle(color: AppTheme.textSecondary)));
          return Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 800), child: ListView.builder(padding: const EdgeInsets.all(16), itemCount: clientes.length, itemBuilder: (context, index) {
            final c = clientes[index];
            return Card(margin: const EdgeInsets.only(bottom: 12), child: ExpansionTile(
              tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              leading: CircleAvatar(backgroundColor: c.isActivo ? AppTheme.primaryColor.withValues(alpha: 0.1) : Colors.grey.shade200, child: Icon(c.tipoCliente == 'empresa' ? Icons.business : Icons.person, color: c.isActivo ? AppTheme.primaryColor : Colors.grey)),
              title: Text(c.nombreComercial, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
              subtitle: Row(children: [
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: c.isActivo ? AppTheme.successColor.withValues(alpha: 0.1) : AppTheme.errorColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(6)),
                  child: Text(c.isActivo ? 'Activo' : 'Inactivo', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: c.isActivo ? AppTheme.successColor : AppTheme.errorColor))),
                const SizedBox(width: 6),
                Text('${c.tipoCliente == "empresa" ? "RUC" : "DNI"}: ${c.dniRuc}', style: const TextStyle(fontSize: 11, color: AppTheme.textMuted)),
              ]),
              children: [FutureBuilder<List<Consignatario>>(
                future: FirebaseService.getConsignatariosPorCliente(c.clienteId),
                builder: (ctx, consSnap) {
                  final cons = consSnap.data ?? [];
                  return Padding(padding: const EdgeInsets.fromLTRB(16, 0, 16, 16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Divider(),
                    _info(Icons.phone, c.telefono), _info(Icons.email, c.email),
                    FutureBuilder(future: FirebaseService.getGuiasPorCliente(c.clienteId), builder: (_, gs) => _info(Icons.description, '${gs.data?.length ?? 0} guías')),
                    const SizedBox(height: 8),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      const Text('Consignatarios:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                      IconButton(icon: const Icon(Icons.add_circle, color: AppTheme.primaryColor, size: 22), onPressed: () => _nuevoConsignatario(context, c.clienteId)),
                    ]),
                    ...cons.map((con) => GestureDetector(
                      onLongPress: () async { final ok = await ItemOptionsSheet.confirmarEliminar(context, con.nombreCompleto); if (ok && context.mounted) { await FirebaseService.eliminarConsignatario(con.consignatarioId); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑 Consignatario eliminado'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating)); } },
                      child: Padding(padding: const EdgeInsets.only(top: 4), child: Row(children: [const Icon(Icons.badge, size: 14, color: AppTheme.textMuted), const SizedBox(width: 6), Text('${con.nombreCompleto} (${con.dniRuc})', style: const TextStyle(fontSize: 12))])),
                    )),
                    const SizedBox(height: 12),
                    Row(children: [
                      Expanded(child: OutlinedButton.icon(onPressed: () => _editarCliente(context, c), icon: const Icon(Icons.edit, size: 16), label: const Text('Editar'))),
                      const SizedBox(width: 8),
                      Expanded(child: OutlinedButton.icon(onPressed: () async { final ok = await ItemOptionsSheet.confirmarEliminar(context, c.nombreComercial); if (ok && context.mounted) { await FirebaseService.eliminarCliente(c.clienteId); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('🗑 Cliente eliminado'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating)); } }, icon: const Icon(Icons.delete_outline, size: 16, color: AppTheme.errorColor), label: const Text('Eliminar', style: TextStyle(color: AppTheme.errorColor)), style: OutlinedButton.styleFrom(side: const BorderSide(color: AppTheme.errorColor)))),
                    ]),
                  ]));
                },
              )],
            ));
          })));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(onPressed: () => _nuevoCliente(context), icon: const Icon(Icons.add), label: const Text('Nuevo Cliente')),
    );
  }

  Widget _info(IconData icon, String text) => Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Row(children: [Icon(icon, size: 14, color: AppTheme.textSecondary), const SizedBox(width: 8), Text(text, style: const TextStyle(fontSize: 13))]));

  void _nuevoCliente(BuildContext context) {
    final nombreCtrl = TextEditingController(); final dniCtrl = TextEditingController(); final telCtrl = TextEditingController(); final emailCtrl = TextEditingController();
    String tipo = 'natural';
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Nuevo Cliente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 16),
          TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre Comercial', prefixIcon: Icon(Icons.business))), const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: tipo, decoration: const InputDecoration(labelText: 'Tipo'), items: const [DropdownMenuItem(value: 'natural', child: Text('Natural')), DropdownMenuItem(value: 'empresa', child: Text('Empresa'))], onChanged: (v) => setS(() => tipo = v!)), const SizedBox(height: 12),
          TextField(controller: dniCtrl, decoration: const InputDecoration(labelText: 'DNI / RUC', prefixIcon: Icon(Icons.badge))), const SizedBox(height: 12),
          TextField(controller: telCtrl, decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone))), const SizedBox(height: 12),
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email))), const SizedBox(height: 20),
          SizedBox(height: 50, child: ElevatedButton(onPressed: () async {
            if (nombreCtrl.text.isEmpty) return;
            Navigator.pop(ctx);
            await FirebaseService.crearCliente(Cliente(clienteId: '', nombreComercial: nombreCtrl.text, tipoCliente: tipo, dniRuc: dniCtrl.text, telefono: telCtrl.text, email: emailCtrl.text, estado: 'activo'));
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Cliente creado'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: const Text('GUARDAR'))), const SizedBox(height: 24),
        ]),
      )),
    );
  }

  void _nuevoConsignatario(BuildContext context, String clienteId) {
    final nombreCtrl = TextEditingController(); final dniCtrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Nuevo Consignatario'), 
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre Completo')),
        const SizedBox(height: 12),
        TextField(controller: dniCtrl, decoration: const InputDecoration(labelText: 'DNI / RUC')),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(onPressed: () async {
          Navigator.pop(ctx);
          await FirebaseService.crearConsignatario(Consignatario(consignatarioId: '', clienteId: clienteId, nombreCompleto: nombreCtrl.text, dniRuc: dniCtrl.text));
          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Consignatario agregado'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
        }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: const Text('Guardar')),
      ],
    ));
  }

  void _editarCliente(BuildContext context, Cliente c) {
    final nombreCtrl = TextEditingController(text: c.nombreComercial); final dniCtrl = TextEditingController(text: c.dniRuc); final telCtrl = TextEditingController(text: c.telefono); final emailCtrl = TextEditingController(text: c.email);
    String tipo = c.tipoCliente; String estado = c.estado;
    showModalBottomSheet(context: context, isScrollControlled: true, shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setS) => Padding(padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom, left: 20, right: 20, top: 24),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          const Text('Editar Cliente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), const SizedBox(height: 16),
          TextField(controller: nombreCtrl, decoration: const InputDecoration(labelText: 'Nombre Comercial', prefixIcon: Icon(Icons.business))), const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: tipo, decoration: const InputDecoration(labelText: 'Tipo'), items: const [DropdownMenuItem(value: 'natural', child: Text('Natural')), DropdownMenuItem(value: 'empresa', child: Text('Empresa'))], onChanged: (v) => setS(() => tipo = v!)), const SizedBox(height: 12),
          DropdownButtonFormField<String>(value: estado, decoration: const InputDecoration(labelText: 'Estado'), items: const [DropdownMenuItem(value: 'activo', child: Text('Activo')), DropdownMenuItem(value: 'inactivo', child: Text('Inactivo'))], onChanged: (v) => setS(() => estado = v!)), const SizedBox(height: 12),
          TextField(controller: dniCtrl, decoration: const InputDecoration(labelText: 'DNI / RUC', prefixIcon: Icon(Icons.badge))), const SizedBox(height: 12),
          TextField(controller: telCtrl, decoration: const InputDecoration(labelText: 'Teléfono', prefixIcon: Icon(Icons.phone))), const SizedBox(height: 12),
          TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email))), const SizedBox(height: 20),
          SizedBox(height: 50, child: ElevatedButton(onPressed: () async {
            Navigator.pop(ctx);
            await FirebaseService.actualizarCliente(c.clienteId, {'nombre_comercial': nombreCtrl.text, 'tipo_cliente': tipo, 'estado': estado, 'dni_ruc': dniCtrl.text, 'telefono': telCtrl.text, 'email': emailCtrl.text});
            if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Cliente actualizado'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
          }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor), child: const Text('GUARDAR'))), const SizedBox(height: 24),
        ]),
      )),
    );
  }
}
