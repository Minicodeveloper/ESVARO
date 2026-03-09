import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Muestra menú de opciones al hacer long press
class ItemOptionsSheet {
  static void show({
    required BuildContext context,
    required String titulo,
    String? subtitulo,
    required VoidCallback onEditar,
    required VoidCallback onEliminar,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 16),
            Text(titulo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700), textAlign: TextAlign.center),
            if (subtitulo != null) ...[const SizedBox(height: 4), Text(subtitulo, style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary), textAlign: TextAlign.center)],
            const SizedBox(height: 20),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.infoColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.edit, color: AppTheme.infoColor, size: 20)),
              title: const Text('Editar', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Modificar datos', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, size: 20),
              onTap: () { Navigator.pop(ctx); onEditar(); },
            ),
            const SizedBox(height: 4),
            ListTile(
              leading: Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppTheme.errorColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)), child: const Icon(Icons.delete_outline, color: AppTheme.errorColor, size: 20)),
              title: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.w600, color: AppTheme.errorColor)),
              subtitle: const Text('Eliminar permanentemente', style: TextStyle(fontSize: 12)),
              trailing: const Icon(Icons.chevron_right, size: 20, color: AppTheme.errorColor),
              onTap: () { Navigator.pop(ctx); onEliminar(); },
            ),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }

  /// Diálogo de confirmación antes de eliminar
  static Future<bool> confirmarEliminar(BuildContext context, String nombre) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [Icon(Icons.warning_amber, color: AppTheme.errorColor), SizedBox(width: 10), Text('¿Eliminar?', style: TextStyle(fontSize: 18))]),
        content: Text('¿Estás seguro de eliminar "$nombre"?\n\nEsta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    return result ?? false;
  }
}
