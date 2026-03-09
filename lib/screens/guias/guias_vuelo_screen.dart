import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../models/vuelo.dart';
import '../../services/firebase_service.dart';
import '../../widgets/status_badge.dart';
import 'guia_detalle_screen.dart';

class GuiasVueloScreen extends StatelessWidget {
  final Vuelo vuelo;
  const GuiasVueloScreen({super.key, required this.vuelo});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(vuelo.numeroManifiesto)),
      body: FutureBuilder(
        future: FirebaseService.getGuiasPorVuelo(vuelo.vueloId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
          final guias = snapshot.data ?? [];
          return Column(children: [
            Container(margin: const EdgeInsets.all(16), padding: const EdgeInsets.all(16), decoration: BoxDecoration(gradient: AppTheme.primaryGradient, borderRadius: BorderRadius.circular(16)),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                _Info(icon: Icons.flight, label: 'Manifiesto', value: vuelo.numeroManifiesto),
                _Info(icon: Icons.store, label: 'Almacén', value: vuelo.almacenMiami),
                _Info(icon: Icons.description, label: 'Guías', value: '${guias.length}'),
              ]),
            ),
            Expanded(child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16), itemCount: guias.length,
              itemBuilder: (context, index) {
                final g = guias[index];
                return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.description, color: AppTheme.primaryColor)),
                  title: Text(g.numeroGuia, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(g.consignatarioNombre ?? '', style: const TextStyle(fontSize: 12)),
                    const SizedBox(height: 4),
                    Row(children: [StatusBadge.logistico(g.estadoLogistico), const SizedBox(width: 6), Text('${g.bultosRecibidos}/${g.bultosEsperados} bultos', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]),
                  ]),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => GuiaDetalleScreen(guiaId: g.guiaId))),
                ));
              },
            )),
          ]);
        },
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final IconData icon; final String label; final String value;
  const _Info({required this.icon, required this.label, required this.value});
  @override
  Widget build(BuildContext context) {
    return Column(children: [Icon(icon, color: Colors.white, size: 20), const SizedBox(height: 6), Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13)), Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.7), fontSize: 11))]);
  }
}
