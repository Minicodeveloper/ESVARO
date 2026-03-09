import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/firebase_service.dart';
import '../dashboard/main_shell.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _userController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;
  String? _error;
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() { _userController.dispose(); _passwordController.dispose(); _animController.dispose(); super.dispose(); }

  void _login() async {
    final user = _userController.text.trim();
    final pass = _passwordController.text.trim();
    if (user.isEmpty || pass.isEmpty) {
      setState(() => _error = 'Ingrese usuario y contraseña');
      return;
    }
    setState(() { _isLoading = true; _error = null; });
    try {
      final resultado = await FirebaseService.login(user, pass);
      if (resultado != null && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const MainShell()));
      } else {
        if (mounted) setState(() { _error = 'Usuario o contraseña incorrectos'; _isLoading = false; });
      }
    } catch (e) {
      if (mounted) setState(() { _error = 'Error de conexión: $e'; _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width > 800;

    return Scaffold(
      body: isDesktop ? _buildDesktopLayout() : _buildMobileLayout(),
    );
  }

  // ==================== LAYOUT DESKTOP (SPLIT SCREEN) ====================
  Widget _buildDesktopLayout() {
    return Row(
      children: [
        // Panel izquierdo: branding
        Expanded(
          flex: 5,
          child: Container(
            decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
            child: Center(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 120, height: 120,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withValues(alpha: 0.25), width: 2),
                      ),
                      child: const Icon(Icons.local_shipping, size: 56, color: Colors.white),
                    ),
                    const SizedBox(height: 32),
                    const Text('ESVARO', style: TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 8)),
                    const SizedBox(height: 8),
                    Text('LOGÍSTICA', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 10)),
                    const SizedBox(height: 48),
                    SizedBox(
                      width: 360,
                      child: Text(
                        'Sistema integral de gestión de paquetería, control de vuelos, retiros de almacén, y liquidaciones.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 15, color: Colors.white.withValues(alpha: 0.6), height: 1.6),
                      ),
                    ),
                    const SizedBox(height: 48),
                    // Features highlights
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _FeatureChip(icon: Icons.flight, label: 'Vuelos'),
                        const SizedBox(width: 16),
                        _FeatureChip(icon: Icons.inventory_2, label: 'Retiros'),
                        const SizedBox(width: 16),
                        _FeatureChip(icon: Icons.receipt_long, label: 'Cobros'),
                        const SizedBox(width: 16),
                        _FeatureChip(icon: Icons.local_shipping, label: 'Entregas'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Panel derecho: formulario
        Expanded(
          flex: 4,
          child: Container(
            color: AppTheme.scaffoldBg,
            child: Center(
              child: SingleChildScrollView(
                child: SizedBox(
                  width: 400,
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: _buildLoginForm(isDesktop: true),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ==================== LAYOUT MOBILE (FULL SCREEN) ====================
  Widget _buildMobileLayout() {
    return Container(
      decoration: const BoxDecoration(gradient: AppTheme.headerGradient),
      child: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: FadeTransition(
              opacity: _fadeAnim,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 100, height: 100,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 2),
                    ),
                    child: const Icon(Icons.local_shipping, size: 48, color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  const Text('ESVARO', style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: 6)),
                  const SizedBox(height: 4),
                  Text('LOGÍSTICA', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.white.withValues(alpha: 0.7), letterSpacing: 8)),
                  const SizedBox(height: 48),
                  _buildLoginForm(isDesktop: false),
                  const SizedBox(height: 30),
                  Text('v1.0.0 · Gestión de Paquetería', style: TextStyle(fontSize: 12, color: Colors.white.withValues(alpha: 0.5))),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== FORMULARIO COMPARTIDO ====================
  Widget _buildLoginForm({required bool isDesktop}) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: isDesktop ? 0.08 : 0.15), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isDesktop) ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(color: AppTheme.primaryColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(12)),
                  child: const Icon(Icons.local_shipping, color: AppTheme.primaryColor, size: 24),
                ),
                const SizedBox(width: 12),
                const Text('ESVARO', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: AppTheme.primaryColor, letterSpacing: 3)),
              ],
            ),
            const SizedBox(height: 32),
          ],
          const Text('Iniciar Sesión', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.textPrimary), textAlign: TextAlign.center),
          const SizedBox(height: 8),
          const Text('Ingresa tus credenciales para continuar', style: TextStyle(fontSize: 14, color: AppTheme.textSecondary), textAlign: TextAlign.center),

          if (_error != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppTheme.errorColor.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppTheme.errorColor.withValues(alpha: 0.2))),
              child: Row(children: [
                const Icon(Icons.error_outline, color: AppTheme.errorColor, size: 18),
                const SizedBox(width: 10),
                Expanded(child: Text(_error!, style: const TextStyle(color: AppTheme.errorColor, fontSize: 13))),
              ]),
            ),
          ],

          const SizedBox(height: 28),
          const Text('Usuario', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _userController,
            decoration: InputDecoration(
              hintText: 'Ingresa tu usuario',
              prefixIcon: const Icon(Icons.person_outline, color: AppTheme.textMuted),
              filled: true, fillColor: AppTheme.scaffoldBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
            ),
          ),

          const SizedBox(height: 20),
          const Text('Contraseña', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 8),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              hintText: 'Ingresa tu contraseña',
              prefixIcon: const Icon(Icons.lock_outline, color: AppTheme.textMuted),
              suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textMuted),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true, fillColor: AppTheme.scaffoldBg,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
            ),
            onSubmitted: (_) => _login(),
          ),

          const SizedBox(height: 28),
          SizedBox(
            height: 52,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _isLoading
                  ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                  : const Text('INGRESAR', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, letterSpacing: 1.5)),
            ),
          ),

          const SizedBox(height: 16),
          Text('Usuario por defecto: admin / admin', style: TextStyle(fontSize: 11, color: AppTheme.textMuted, fontStyle: FontStyle.italic), textAlign: TextAlign.center),

          if (isDesktop) ...[
            const SizedBox(height: 24),
            Text('v1.0.0 · Gestión de Paquetería', style: TextStyle(fontSize: 12, color: Colors.grey.shade400), textAlign: TextAlign.center),
          ],
        ],
      ),
    );
  }
}

// ==================== FEATURE CHIP (Desktop branding) ====================
class _FeatureChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _FeatureChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white.withValues(alpha: 0.8), size: 16),
          const SizedBox(width: 8),
          Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 13, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
