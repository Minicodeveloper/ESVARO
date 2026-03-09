import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../../models/retiro.dart';
import '../retiros/retiros_screen.dart';
import '../vuelos/registrar_vuelo_screen.dart';
import '../guias/registrar_guias_screen.dart';
import '../liquidaciones/liquidaciones_screen.dart';
import '../entregas/entregas_screen.dart';
import '../clientes/clientes_screen.dart';
import '../servicios_adicionales/servicios_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _stats;
  bool _loading = true;

  @override
  void initState() { super.initState(); _loadStats(); }

  Future<void> _loadStats() async {
    setState(() => _loading = true);
    try {
      final stats = await FirebaseService.getDashboardResumen();
      if (mounted) setState(() { _stats = stats; _loading = false; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _loadStats,
        child: CustomScrollView(slivers: [
          SliverAppBar(expandedHeight: 120, floating: false, pinned: true, backgroundColor: AppTheme.primaryColor,
            flexibleSpace: FlexibleSpaceBar(background: Container(decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
              child: SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    Row(children: [const Icon(Icons.local_shipping, color: Colors.white, size: 26), const SizedBox(width: 10),
                      const Text('ESVARO', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 3))]),
                    const SizedBox(height: 2),
                    Text('Panel de Control', style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.7))),
                  ]),
                  CircleAvatar(backgroundColor: Colors.white.withValues(alpha: 0.15), radius: 20, child: const Icon(Icons.person, color: Colors.white, size: 22)),
                ]),
              )),
            )),
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (_loading)
                        const Padding(padding: EdgeInsets.all(40), child: Center(child: CircularProgressIndicator()))
                      else ...[
                        // ==================== 📦 BLOQUE OPERATIVO ====================
                        const _SectionHeader(icon: Icons.inventory_2, label: 'Operativo', color: AppTheme.primaryColor),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: _MiniCard(icon: Icons.home, label: 'En casa\nsin entregar', value: '${_stats?['enCasaSinEntregar'] ?? 0}', color: AppTheme.pendienteRetiro)),
                          const SizedBox(width: 10),
                          Expanded(child: _MiniCard(icon: Icons.warning_amber, label: 'Incidencias\nabiertas', value: '${_stats?['incidenciasAbiertas'] ?? 0}', color: AppTheme.errorColor)),
                          const SizedBox(width: 10),
                          Expanded(child: _MiniCard(icon: Icons.local_shipping, label: 'Entregas\nprogramadas', value: '${_stats?['entregasProgramadas'] ?? 0}', color: AppTheme.successColor)),
                        ]),
                        // Último retiro
                        if (_stats?['ultimoRetiro'] != null) ...[
                          const SizedBox(height: 10),
                          _UltimoRetiroCard(retiro: _stats!['ultimoRetiro'] as Retiro),
                        ],

                        const SizedBox(height: 24),
                        // ==================== 💰 BLOQUE FINANCIERO ====================
                        const _SectionHeader(icon: Icons.attach_money, label: 'Financiero', color: AppTheme.infoColor),
                        const SizedBox(height: 10),
                        Container(padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.softShadow),
                          child: Column(children: [
                            Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                              _FinStat(label: 'Facturado', value: '\$${(_stats?['totalFacturado'] ?? 0.0).toStringAsFixed(0)}', color: AppTheme.textPrimary),
                              Container(width: 1, height: 40, color: Colors.grey.shade200),
                              _FinStat(label: 'Cobrado', value: '\$${(_stats?['totalCobrado'] ?? 0.0).toStringAsFixed(0)}', color: AppTheme.successColor),
                              Container(width: 1, height: 40, color: Colors.grey.shade200),
                              _FinStat(label: 'Pendiente', value: '\$${(_stats?['totalPendiente'] ?? 0.0).toStringAsFixed(0)}', color: AppTheme.errorColor),
                            ]),
                            const Divider(height: 24),
                            Row(children: [
                              const Icon(Icons.today, size: 16, color: AppTheme.successColor), const SizedBox(width: 6),
                              Text('Cobrado hoy: \$${(_stats?['cobradoHoy'] ?? 0.0).toStringAsFixed(0)}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.successColor)),
                            ]),
                          ]),
                        ),

                        const SizedBox(height: 24),
                        // ==================== ⚠️ BLOQUE RIESGO ====================
                        const _SectionHeader(icon: Icons.shield, label: 'Riesgo', color: AppTheme.warningColor),
                        const SizedBox(height: 10),
                        Row(children: [
                          Expanded(child: _RiskCard(icon: Icons.search_off, label: 'Faltantes\nsin resolver', value: '${_stats?['faltantesSinResolver'] ?? 0}', isAlert: (_stats?['faltantesSinResolver'] ?? 0) > 0)),
                          const SizedBox(width: 10),
                          Expanded(child: _RiskCard(icon: Icons.help_outline, label: 'No\ninstruccionados', value: '${_stats?['noInstruccionados'] ?? 0}', isAlert: (_stats?['noInstruccionados'] ?? 0) > 0)),
                          const SizedBox(width: 10),
                          Expanded(child: _RiskCard(icon: Icons.money_off, label: 'Entregados\nsin pago', value: '${_stats?['entregadosSinPago'] ?? 0}', isAlert: (_stats?['entregadosSinPago'] ?? 0) > 0)),
                        ]),

                        const SizedBox(height: 32),
                        // ==================== ACCIONES ====================
                        const Text('Acciones Rápidas', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
                        const SizedBox(height: 16),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // En web (ancho > 600), mostramos grid de acciones. En móvil, lista.
                            if (constraints.maxWidth > 600) {
                              return Wrap(
                                spacing: 16,
                                runSpacing: 16,
                                children: [
                                  SizedBox(width: (constraints.maxWidth - 16) / 2, child: _ActionButton(icon: Icons.inventory_2, label: 'Retiros', subtitle: 'Recepción', color: AppTheme.primaryColor, onTap: () => _nav(const RetirosScreen()))),
                                  SizedBox(width: (constraints.maxWidth - 16) / 2, child: _ActionButton(icon: Icons.flight_takeoff, label: 'Vuelos', subtitle: 'Manifiestos', color: AppTheme.vueloProgramado, onTap: () => _nav(const RegistrarVueloScreen()))),
                                  SizedBox(width: (constraints.maxWidth - 16) / 2, child: _ActionButton(icon: Icons.post_add, label: 'Guías', subtitle: 'Registro', color: AppTheme.primaryMedium, onTap: () => _nav(const RegistrarGuiasScreen()))),
                                  SizedBox(width: (constraints.maxWidth - 16) / 2, child: _ActionButton(icon: Icons.receipt_long, label: 'Cobros', subtitle: 'Liquidación', color: AppTheme.infoColor, onTap: () => _nav(const LiquidacionesScreen()))),
                                  SizedBox(width: (constraints.maxWidth - 16) / 2, child: _ActionButton(icon: Icons.local_shipping_outlined, label: 'Entregas', subtitle: 'Despacho', color: AppTheme.successColor, onTap: () => _nav(const EntregasScreen()))),
                                  SizedBox(width: (constraints.maxWidth - 16) / 2, child: _ActionButton(icon: Icons.people_outline, label: 'Clientes', subtitle: 'Directorio', color: AppTheme.primaryLight, onTap: () => _nav(const ClientesScreen()))),
                                ],
                              );
                            }
                            return Column(
                              children: [
                                _ActionButton(icon: Icons.inventory_2, label: 'Retiros de Almacén', subtitle: 'Crear retiro, escanear, cerrar', color: AppTheme.primaryColor, onTap: () => _nav(const RetirosScreen())),
                                const SizedBox(height: 8),
                                _ActionButton(icon: Icons.flight_takeoff, label: 'Registrar Vuelo', subtitle: 'Nuevo manifiesto de embarque', color: AppTheme.vueloProgramado, onTap: () => _nav(const RegistrarVueloScreen())),
                                const SizedBox(height: 8),
                                _ActionButton(icon: Icons.post_add, label: 'Registrar Guías', subtitle: 'Agregar guías a un vuelo', color: AppTheme.primaryMedium, onTap: () => _nav(const RegistrarGuiasScreen())),
                                const SizedBox(height: 8),
                                _ActionButton(icon: Icons.receipt_long, label: 'Liquidaciones', subtitle: 'Control de cobros y pagos', color: AppTheme.infoColor, onTap: () => _nav(const LiquidacionesScreen())),
                                const SizedBox(height: 8),
                                _ActionButton(icon: Icons.local_shipping_outlined, label: 'Entregas', subtitle: 'Programar y registrar entregas', color: AppTheme.successColor, onTap: () => _nav(const EntregasScreen())),
                                const SizedBox(height: 8),
                                _ActionButton(icon: Icons.people_outline, label: 'Clientes', subtitle: 'Gestionar clientes y consignatarios', color: AppTheme.primaryLight, onTap: () => _nav(const ClientesScreen())),
                              ],
                            );
                          }
                        ),
                        const SizedBox(height: 40),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  void _nav(Widget screen) async {
    await Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
    _loadStats();
  }
}

// ==================== WIDGETS ====================

class _SectionHeader extends StatelessWidget {
  final IconData icon; final String label; final Color color;
  const _SectionHeader({required this.icon, required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Row(children: [
    Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: color, size: 18)),
    const SizedBox(width: 8), Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
  ]);
}

class _MiniCard extends StatelessWidget {
  final IconData icon; final String label, value; final Color color;
  const _MiniCard({required this.icon, required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: AppTheme.softShadow),
    child: Column(children: [
      Icon(icon, color: color, size: 22), const SizedBox(height: 6),
      Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
      const SizedBox(height: 4),
      Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary, height: 1.3), textAlign: TextAlign.center),
    ]),
  );
}

class _FinStat extends StatelessWidget {
  final String label, value; final Color color;
  const _FinStat({required this.label, required this.value, required this.color});
  @override
  Widget build(BuildContext context) => Column(children: [Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: color)), const SizedBox(height: 2), Text(label, style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary))]);
}

class _RiskCard extends StatelessWidget {
  final IconData icon; final String label, value; final bool isAlert;
  const _RiskCard({required this.icon, required this.label, required this.value, this.isAlert = false});
  @override
  Widget build(BuildContext context) {
    final color = isAlert ? AppTheme.errorColor : AppTheme.successColor;
    return Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: isAlert ? AppTheme.errorColor.withValues(alpha: 0.05) : Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: isAlert ? AppTheme.errorColor.withValues(alpha: 0.2) : Colors.grey.shade200), boxShadow: isAlert ? [] : AppTheme.softShadow),
      child: Column(children: [
        Icon(icon, color: color, size: 22), const SizedBox(height: 6),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
        const SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 10, color: isAlert ? AppTheme.errorColor : AppTheme.textSecondary, height: 1.3), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _UltimoRetiroCard extends StatelessWidget {
  final Retiro retiro;
  const _UltimoRetiroCard({required this.retiro});
  @override
  Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(14), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), boxShadow: AppTheme.softShadow, border: Border.all(color: retiro.isAbierto ? AppTheme.warningColor.withValues(alpha: 0.3) : Colors.grey.shade200)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Row(children: [const Icon(Icons.inventory_2, size: 16, color: AppTheme.primaryColor), const SizedBox(width: 6), const Text('Último retiro', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700))]),
        Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: (retiro.isAbierto ? AppTheme.warningColor : AppTheme.successColor).withValues(alpha: 0.1), borderRadius: BorderRadius.circular(8)),
          child: Text(retiro.isAbierto ? 'ABIERTO' : 'CERRADO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: retiro.isAbierto ? AppTheme.warningColor : AppTheme.successColor))),
      ]),
      const SizedBox(height: 8),
      Text(retiro.numeroManifiesto, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
      const SizedBox(height: 6),
      Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
        Text('Esperados: ${retiro.esperados}', style: const TextStyle(fontSize: 12)), Text('Recibidos: ${retiro.recibidos}', style: const TextStyle(fontSize: 12, color: AppTheme.successColor, fontWeight: FontWeight.w600)),
        if (retiro.faltantes > 0) Text('Faltantes: ${retiro.faltantes}', style: const TextStyle(fontSize: 12, color: AppTheme.errorColor, fontWeight: FontWeight.w700)),
      ]),
    ]),
  );
}

class _ActionButton extends StatelessWidget {
  final IconData icon; final String label; final String subtitle; final Color color; final VoidCallback onTap;
  const _ActionButton({required this.icon, required this.label, required this.subtitle, required this.color, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(color: Colors.white, borderRadius: BorderRadius.circular(14), child: InkWell(borderRadius: BorderRadius.circular(14), onTap: onTap, child: Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.shade200)),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color, size: 22)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)), const SizedBox(height: 2), Text(subtitle, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary))])),
      Icon(Icons.chevron_right, color: AppTheme.textMuted, size: 22),
    ]),
  )));
}
