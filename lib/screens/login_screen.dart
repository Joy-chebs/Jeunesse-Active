import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_provider.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class LoginScreen extends StatefulWidget {
  final UserType userType;
  const LoginScreen({super.key, required this.userType});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoginMode = true;

  // Registration fields
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _companyController = TextEditingController();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();

    // Pre-fill demo credentials
    if (widget.userType == UserType.employee) {
      _emailController.text = 'jpmbarga@email.com';
    } else {
      _emailController.text = 'contact@techinno.cm';
    }
    _passwordController.text = '123456';
  }

  @override
  void dispose() {
    _animController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _confirmPasswordController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  bool get isEmployee => widget.userType == UserType.employee;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();

    if (_isLoginMode) {
      final success = await auth.login(
        _emailController.text.trim(),
        _passwordController.text,
        widget.userType,
      );
      if (success && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
      } else if (mounted && auth.error != null) {
        _showError(auth.error!);
        auth.clearError();
      }
    } else {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showError('Les mots de passe ne correspondent pas');
        return;
      }
      final success = await auth.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text,
        userType: widget.userType,
        companyName: isEmployee ? null : _companyController.text.trim(),
      );
      if (success && mounted) {
        Navigator.of(context).pushNamedAndRemoveUntil('/home', (_) => false);
      } else if (mounted && auth.error != null) {
        _showError(auth.error!);
        auth.clearError();
      }
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = isEmployee ? AppTheme.primary : AppTheme.accent;
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: Column(
        children: [
          // Header
          Container(
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 12,
              bottom: 28,
              left: 20,
              right: 20,
            ),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  color,
                  color.withOpacity(0.7),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.arrow_back_ios_rounded,
                            color: Colors.white, size: 16),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        isEmployee ? '👷 Prestataire' : '🏢 Employeur',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  _isLoginMode ? 'Bon retour !' : 'Créer un compte',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _isLoginMode
                      ? 'Connectez-vous pour continuer'
                      : 'Rejoignez la communauté JeunesseActive',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          // Form
          Expanded(
            child: FadeTransition(
              opacity: _fadeAnim,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!_isLoginMode) ...[
                        AppTextField(
                          label: 'Nom complet',
                          controller: _nameController,
                          prefixIcon: const Icon(Icons.person_outline),
                          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                        ),
                        const SizedBox(height: 14),
                        if (!isEmployee) ...[
                          AppTextField(
                            label: 'Nom de l\'entreprise',
                            controller: _companyController,
                            prefixIcon: const Icon(Icons.business_outlined),
                          ),
                          const SizedBox(height: 14),
                        ],
                        AppTextField(
                          label: 'Téléphone',
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          prefixIcon: const Icon(Icons.phone_outlined),
                          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                        ),
                        const SizedBox(height: 14),
                      ],

                      AppTextField(
                        label: 'Adresse email',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                        validator: (v) {
                          if (v!.isEmpty) return 'Champ requis';
                          if (!v.contains('@')) return 'Email invalide';
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      AppTextField(
                        label: 'Mot de passe',
                        controller: _passwordController,
                        obscureText: !_isPasswordVisible,
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                          child: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                          ),
                        ),
                        validator: (v) {
                          if (v!.isEmpty) return 'Champ requis';
                          if (v.length < 6) return 'Min 6 caractères';
                          return null;
                        },
                      ),

                      if (!_isLoginMode) ...[
                        const SizedBox(height: 14),
                        AppTextField(
                          label: 'Confirmer le mot de passe',
                          controller: _confirmPasswordController,
                          obscureText: !_isPasswordVisible,
                          prefixIcon: const Icon(Icons.lock_outline),
                          validator: (v) => v!.isEmpty ? 'Champ requis' : null,
                        ),
                      ],

                      if (_isLoginMode) ...[
                        const SizedBox(height: 8),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: const Text(
                              'Mot de passe oublié ?',
                              style: TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                            ),
                          ),
                        ),
                      ],

                      const SizedBox(height: 10),

                      // Demo hint
                      if (_isLoginMode)
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.07),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(color: color.withOpacity(0.2)),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.info_outline, size: 16, color: color),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Démo: Utilisez les identifiants pré-remplis ou inscrivez-vous.',
                                  style: TextStyle(fontSize: 11, color: color),
                                ),
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 24),

                      AppButton(
                        label: _isLoginMode ? 'Se connecter' : 'Créer mon compte',
                        onPressed: _submit,
                        isLoading: auth.isLoading,
                        color: color,
                      ),

                      const SizedBox(height: 20),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            _isLoginMode ? 'Pas encore de compte ? ' : 'Déjà un compte ? ',
                            style: const TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              setState(() => _isLoginMode = !_isLoginMode);
                              _animController.reset();
                              _animController.forward();
                            },
                            child: Text(
                              _isLoginMode ? 'S\'inscrire' : 'Se connecter',
                              style: TextStyle(
                                color: color,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
