import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';
import '../services/supabase_service.dart';
import '../services/language_service.dart';
import '../widgets/bottom_nav_bar.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isSignUp = false;
  bool _obscurePassword = true;
  late AnimationController _animController;
  late Animation<double> _fadeIn;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700));
    _fadeIn = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit(LanguageService ls) async {
    setState(() => _isLoading = true);
    try {
      if (SupabaseService.isPlaceholder) {
        await Future.delayed(const Duration(milliseconds: 800));
        if (mounted) {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (_) => const BottomNavBar()));
        }
        return;
      }
      if (_isSignUp) {
        await SupabaseService.client.auth.signUp(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } else {
        await SupabaseService.client.auth.signInWithPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      }
      if (mounted) Navigator.pop(context);
    } on AuthException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(e.message), backgroundColor: AppTheme.danger));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final ls = Provider.of<LanguageService>(context);
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF002623), Color(0xFF054239), Color(0xFF03342C)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: FadeTransition(
              opacity: _fadeIn,
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.arrow_back_ios_new,
                                color: AppTheme.textSecondary, size: 18),
                          ),
                        ),
                        GestureDetector(
                          onTap: ls.toggle,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.4)),
                            ),
                            child: Text(
                              ls.isArabic ? 'English' : 'العربية',
                              style: const TextStyle(color: AppTheme.primaryAccent, fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Text(
                      _isSignUp ? ls.t('create_account') : ls.t('welcome_back'),
                      style: const TextStyle(
                          color: AppTheme.textPrimary, fontSize: 34, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _isSignUp ? ls.t('sign_up_subtitle') : ls.t('sign_in_subtitle'),
                      style: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                    ),
                    const SizedBox(height: 48),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: BackdropFilter(
                        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.05),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppTheme.primaryAccent.withOpacity(0.2)),
                          ),
                          child: Column(
                            children: [
                              _buildTextField(label: ls.t('email'), icon: Icons.email_outlined, controller: _emailController, keyboardType: TextInputType.emailAddress),
                              const SizedBox(height: 16),
                              _buildTextField(
                                label: ls.t('password'),
                                icon: Icons.lock_outline,
                                controller: _passwordController,
                                obscure: _obscurePassword,
                                suffix: IconButton(
                                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: AppTheme.textSecondary, size: 20),
                                  onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                                ),
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : () => _submit(ls),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    padding: EdgeInsets.zero,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                  ),
                                  child: Ink(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [AppTheme.primaryAccent, AppTheme.primaryDark]),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: _isLoading
                                          ? const SizedBox(width: 22, height: 22, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                                          : Text(
                                              _isSignUp ? ls.t('create_btn') : ls.t('continue_btn'),
                                              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                                            ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_isSignUp ? ls.t('have_account') : ls.t('no_account'), style: const TextStyle(color: AppTheme.textSecondary)),
                          GestureDetector(
                            onTap: () => setState(() => _isSignUp = !_isSignUp),
                            child: Text(
                              _isSignUp ? ls.t('go_sign_in') : ls.t('go_sign_up'),
                              style: const TextStyle(color: AppTheme.primaryAccent, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffix,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppTheme.textPrimary, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.primaryAccent, size: 20),
        suffixIcon: suffix,
        filled: true,
        fillColor: Colors.white.withOpacity(0.05),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: AppTheme.primaryAccent.withOpacity(0.25))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.primaryAccent, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      ),
    );
  }
}
