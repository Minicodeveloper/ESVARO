import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/vuelo.dart';
import '../../models/consignatario.dart';

class RegistrarGuiasScreen extends StatefulWidget {
  const RegistrarGuiasScreen({super.key});
  @override
  State<RegistrarGuiasScreen> createState() => _RegistrarGuiasScreenState();
}

class _RegistrarGuiasScreenState extends State<RegistrarGuiasScreen> {
  List<Vuelo> _vuelos = [];
  List<dynamic> _clientes = [];
  List<Consignatario> _consignatarios = [];
  String? _vueloSeleccionado;
  String? _clienteSeleccionado;
  String? _clienteNombre;
  final List<_GuiaForm> _guiasForms = [];
  bool _saving = false;
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadData(); }

  Future<void> _loadData() async {
    final vuelos = await FirebaseService.getVuelos();
    final clientes = await FirebaseService.getClientesActivos();
    if (mounted) setState(() { _vuelos = vuelos; _clientes = clientes; _loading = false; });
  }

  Future<void> _cargarConsignatarios(String clienteId) async {
    final cons = await FirebaseService.getConsignatariosPorCliente(clienteId);
    if (mounted) setState(() => _consignatarios = cons);
  }

  void _agregarGuia() => setState(() => _guiasForms.add(_GuiaForm()));
  void _eliminarGuia(int i) => setState(() => _guiasForms.removeAt(i));

  void _guardar() async {
    if (_vueloSeleccionado == null || _clienteSeleccionado == null || _guiasForms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Complete todos los campos')));
      return;
    }
    setState(() => _saving = true);
    try {
      final vuelo = _vuelos.firstWhere((v) => v.vueloId == _vueloSeleccionado);
      final guiasData = _guiasForms.map((f) {
        final consNombre = _consignatarios.where((c) => c.consignatarioId == f.consignatarioId).firstOrNull?.nombreCompleto ?? '';
        return {'numero_guia': f.guiaController.text.trim(), 'consignatario_id': f.consignatarioId ?? '', 'consignatario_nombre': consNombre, 'trackings': f.trackingsController.text};
      }).toList();

      await FirebaseService.registrarGuiasConTrackings(
        vueloId: _vueloSeleccionado!,
        clienteId: _clienteSeleccionado!,
        clienteNombre: _clienteNombre ?? '',
        almacenMiami: vuelo.almacenMiami,
        numeroManifiesto: vuelo.numeroManifiesto,
        guiasData: guiasData,
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('✅ ${_guiasForms.length} guía(s) registradas'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) { setState(() => _saving = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e'), backgroundColor: AppTheme.errorColor)); }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return Scaffold(appBar: AppBar(title: const Text('Registrar Guías')), body: const Center(child: CircularProgressIndicator()));
    return Scaffold(
      appBar: AppBar(title: const Text('Registrar Guías')),
      body: SingleChildScrollView(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(16)),
          child: const Row(children: [Icon(Icons.post_add, color: Colors.white, size: 28), SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Registrar Guías del Vuelo', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)), Text('Agregar guías instruccionadas', style: TextStyle(color: Colors.white70, fontSize: 12))])])),
        const SizedBox(height: 20),
        DropdownButtonFormField<String>(value: _vueloSeleccionado, decoration: const InputDecoration(labelText: 'Vuelo / Manifiesto', prefixIcon: Icon(Icons.flight)),
          items: _vuelos.map((v) => DropdownMenuItem(value: v.vueloId, child: Text('${v.numeroManifiesto} - ${v.almacenMiami}'))).toList(),
          onChanged: (v) => setState(() => _vueloSeleccionado = v)),
        const SizedBox(height: 12),
        if (_vueloSeleccionado != null)
          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.infoColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
            child: Row(children: [const Icon(Icons.info, color: AppTheme.infoColor, size: 18), const SizedBox(width: 8),
              Text('Almacén: ${_vuelos.where((v) => v.vueloId == _vueloSeleccionado).firstOrNull?.almacenMiami ?? "-"} (heredado)', style: const TextStyle(fontSize: 13, color: AppTheme.infoColor, fontWeight: FontWeight.w500))])),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(value: _clienteSeleccionado, decoration: const InputDecoration(labelText: 'Cliente', prefixIcon: Icon(Icons.person)),
          items: _clientes.map((c) => DropdownMenuItem(value: c.clienteId as String, child: Text(c.nombreComercial as String))).toList(),
          onChanged: (v) { setState(() { _clienteSeleccionado = v; _clienteNombre = _clientes.where((c) => c.clienteId == v).firstOrNull?.nombreComercial; }); _cargarConsignatarios(v!); }),
        const SizedBox(height: 20),
        if (_guiasForms.isNotEmpty)
          ...List.generate(_guiasForms.length, (i) {
            final form = _guiasForms[i];
            return Container(margin: const EdgeInsets.only(bottom: 16), padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200), boxShadow: AppTheme.softShadow),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Guía ${i + 1}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.primaryColor)), IconButton(icon: const Icon(Icons.delete, color: AppTheme.errorColor, size: 20), onPressed: () => _eliminarGuia(i))]),
                const SizedBox(height: 8),
                TextFormField(controller: form.guiaController, decoration: const InputDecoration(labelText: 'Número de Guía', hintText: 'Ej: ESV-008')),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(value: form.consignatarioId, decoration: const InputDecoration(labelText: 'Consignatario'),
                  items: _consignatarios.map<DropdownMenuItem<String>>((c) => DropdownMenuItem<String>(value: c.consignatarioId, child: Text(c.nombreCompleto))).toList(),
                  onChanged: (v) => setState(() => form.consignatarioId = v)),
                const SizedBox(height: 12),
                TextFormField(controller: form.trackingsController, decoration: const InputDecoration(labelText: 'Trackings', hintText: 'Separados por coma: ABC123, DEF456...'), maxLines: 3),
              ]),
            );
          }),
        OutlinedButton.icon(onPressed: _agregarGuia, icon: const Icon(Icons.add), label: const Text('+ Agregar guía'), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14))),
        const SizedBox(height: 20),
        if (_guiasForms.isNotEmpty)
          SizedBox(height: 52, child: ElevatedButton.icon(
            onPressed: _saving ? null : _guardar,
            icon: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
            label: Text(_saving ? 'Guardando...' : 'GUARDAR TODAS (${_guiasForms.length})'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )),
      ])),
    );
  }
}

class _GuiaForm {
  final guiaController = TextEditingController();
  final trackingsController = TextEditingController();
  String? consignatarioId;
}
