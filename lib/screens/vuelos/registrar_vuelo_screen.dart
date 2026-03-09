import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/vuelo.dart';

class RegistrarVueloScreen extends StatefulWidget {
  const RegistrarVueloScreen({super.key});
  @override
  State<RegistrarVueloScreen> createState() => _RegistrarVueloScreenState();
}

class _RegistrarVueloScreenState extends State<RegistrarVueloScreen> {
  final _formKey = GlobalKey<FormState>();
  final _manifiestoController = TextEditingController();
  DateTime _fechaLlegada = DateTime.now().add(const Duration(days: 3));
  TimeOfDay _horaLlegada = const TimeOfDay(hour: 10, minute: 0);
  String _almacenMiami = 'TIB COURIER';
  bool _saving = false;
  final _almacenes = ['TIB COURIER', 'VNSE BOX PERU', 'MIXTO'];

  @override
  void dispose() { _manifiestoController.dispose(); super.dispose(); }

  void _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);
    try {
      final fecha = DateTime(_fechaLlegada.year, _fechaLlegada.month, _fechaLlegada.day, _horaLlegada.hour, _horaLlegada.minute);
      await FirebaseService.crearVuelo(Vuelo(
        vueloId: '',
        numeroManifiesto: _manifiestoController.text.trim(),
        fechaLlegada: fecha,
        almacenMiami: _almacenMiami,
        estado: 'programado',
      ));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: const Text('✅ Vuelo registrado correctamente'), backgroundColor: AppTheme.successColor, behavior: SnackBarBehavior.floating));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _saving = false);
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('❌ Error: $e'), backgroundColor: AppTheme.errorColor, behavior: SnackBarBehavior.floating));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo Vuelo')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(key: _formKey, child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(16)),
            child: const Row(children: [Icon(Icons.flight_takeoff, color: Colors.white, size: 28), SizedBox(width: 12), Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Registrar Vuelo', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)), Text('Nuevo manifiesto de embarque', style: TextStyle(color: Colors.white70, fontSize: 13))])])),
          const SizedBox(height: 24),
          TextFormField(controller: _manifiestoController, decoration: const InputDecoration(labelText: 'Número de Manifiesto', hintText: 'Ej: MAN-2026-005', prefixIcon: Icon(Icons.confirmation_number)), validator: (v) => v == null || v.isEmpty ? 'Requerido' : null),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async { final date = await showDatePicker(context: context, initialDate: _fechaLlegada, firstDate: DateTime.now().subtract(const Duration(days: 7)), lastDate: DateTime.now().add(const Duration(days: 90))); if (date != null) setState(() => _fechaLlegada = date); },
            child: InputDecorator(decoration: const InputDecoration(labelText: 'Fecha Llegada', prefixIcon: Icon(Icons.calendar_today)), child: Text('${_fechaLlegada.day}/${_fechaLlegada.month}/${_fechaLlegada.year}')),
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () async { final time = await showTimePicker(context: context, initialTime: _horaLlegada); if (time != null) setState(() => _horaLlegada = time); },
            child: InputDecorator(decoration: const InputDecoration(labelText: 'Hora Llegada', prefixIcon: Icon(Icons.access_time)), child: Text('${_horaLlegada.hour.toString().padLeft(2, '0')}:${_horaLlegada.minute.toString().padLeft(2, '0')}')),
          ),
          const SizedBox(height: 16),
          DropdownButtonFormField<String>(value: _almacenMiami, decoration: const InputDecoration(labelText: 'Almacén Miami', prefixIcon: Icon(Icons.warehouse)),
            items: _almacenes.map((a) => DropdownMenuItem(value: a, child: Text(a))).toList(), onChanged: (v) => setState(() => _almacenMiami = v!)),
          const SizedBox(height: 32),
          SizedBox(height: 52, child: ElevatedButton.icon(
            onPressed: _saving ? null : _save,
            icon: _saving ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save),
            label: Text(_saving ? 'Guardando...' : 'GUARDAR VUELO'),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
          )),
        ])),
      ),
    );
  }
}
