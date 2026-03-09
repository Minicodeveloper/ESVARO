import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class StatusBadge extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.icon,
  });

  // === Factories para estados logísticos ===
  factory StatusBadge.logistico(String estado) {
    switch (estado) {
      case 'pendiente_retiro':
        return StatusBadge(label: 'Pendiente Retiro', color: AppTheme.pendienteRetiro, icon: Icons.schedule);
      case 'retirada_completa':
        return StatusBadge(label: 'Retirada Completa', color: AppTheme.retiradaCompleta, icon: Icons.check_circle);
      case 'retirada_incompleta':
        return StatusBadge(label: 'Incompleta', color: AppTheme.retiradaIncompleta, icon: Icons.warning);
      case 'canal_rojo':
        return StatusBadge(label: 'Canal Rojo', color: AppTheme.canalRojo, icon: Icons.block);
      default:
        return StatusBadge(label: estado, color: AppTheme.textMuted);
    }
  }

  // === Factories para estados financieros ===
  factory StatusBadge.financiero(String estado) {
    switch (estado) {
      case 'pendiente':
        return StatusBadge(label: 'Pendiente', color: AppTheme.finPendiente, icon: Icons.attach_money);
      case 'liquidada':
        return StatusBadge(label: 'Liquidada', color: AppTheme.finLiquidada, icon: Icons.receipt_long);
      case 'pagada':
        return StatusBadge(label: 'Pagada', color: AppTheme.finPagada, icon: Icons.paid);
      default:
        return StatusBadge(label: estado, color: AppTheme.textMuted);
    }
  }

  // === Factories para estados de entrega ===
  factory StatusBadge.entrega(String estado) {
    switch (estado) {
      case 'pendiente':
        return StatusBadge(label: 'Pendiente', color: AppTheme.finPendiente, icon: Icons.pending);
      case 'programada':
        return StatusBadge(label: 'Programada', color: AppTheme.infoColor, icon: Icons.calendar_today);
      case 'entregada':
        return StatusBadge(label: 'Entregada', color: AppTheme.successColor, icon: Icons.check_circle);
      default:
        return StatusBadge(label: estado, color: AppTheme.textMuted);
    }
  }

  // === Factories para estados de vuelo ===
  factory StatusBadge.vuelo(String estado) {
    switch (estado) {
      case 'programado':
        return StatusBadge(label: 'Programado', color: AppTheme.vueloProgramado, icon: Icons.flight_takeoff);
      case 'llegado':
        return StatusBadge(label: 'Llegado', color: AppTheme.vueloLlegado, icon: Icons.flight_land);
      case 'retirado':
        return StatusBadge(label: 'Retirado', color: AppTheme.vueloRetirado, icon: Icons.done_all);
      case 'incompleto':
        return StatusBadge(label: 'Incompleto', color: AppTheme.vueloIncompleto, icon: Icons.error);
      default:
        return StatusBadge(label: estado, color: AppTheme.textMuted);
    }
  }

  // === Factories para estados de tracking ===
  factory StatusBadge.tracking(String estado) {
    switch (estado) {
      case 'esperado':
        return StatusBadge(label: 'Esperado', color: AppTheme.finPendiente, icon: Icons.hourglass_bottom);
      case 'recibido':
        return StatusBadge(label: 'Recibido', color: AppTheme.successColor, icon: Icons.check);
      case 'faltante':
        return StatusBadge(label: 'Faltante', color: AppTheme.errorColor, icon: Icons.close);
      case 'retenido':
        return StatusBadge(label: 'Retenido', color: AppTheme.warningColor, icon: Icons.front_hand);
      case 'perdido':
        return StatusBadge(label: 'Perdido', color: AppTheme.canalRojo, icon: Icons.cancel);
      default:
        return StatusBadge(label: estado, color: AppTheme.textMuted);
    }
  }

  // === Factories para incidencias ===
  factory StatusBadge.incidencia(String estado) {
    switch (estado) {
      case 'abierta':
        return StatusBadge(label: 'Abierta', color: AppTheme.errorColor, icon: Icons.error_outline);
      case 'en_seguimiento':
        return StatusBadge(label: 'En Seguimiento', color: AppTheme.warningColor, icon: Icons.visibility);
      case 'resuelta':
        return StatusBadge(label: 'Resuelta', color: AppTheme.successColor, icon: Icons.check_circle_outline);
      default:
        return StatusBadge(label: estado, color: AppTheme.textMuted);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}
