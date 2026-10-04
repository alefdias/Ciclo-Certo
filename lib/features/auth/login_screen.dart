import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../app/theme/app_colors.dart';
import '../../services/biometric_service.dart';
import '../../services/user_profile_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _isCheckingAuth = true;
  bool _isLoading = false;
  bool _requiresBiometrics = false;
  bool _isAuthenticatingBiometrics = false;
  User? _currentUser;

  @override
  void initState() {
    super.initState();
    _checkInitialAuth();
  }

  Future<void> _checkInitialAuth() async {
    final user = FirebaseAuth.instance.currentUser;
    final hasLoggedInBefore =
        await BiometricService.instance.hasLoggedInWithGoogle();

    if (user != null && hasLoggedInBefore) {
      final isAvailable =
          await BiometricService.instance.isBiometricsAvailable();
      final isLockEnabled =
          await BiometricService.instance.isBiometricLockEnabled();

      if (isAvailable && isLockEnabled) {
        if (!mounted) return;
        setState(() {
          _currentUser = user;
          _requiresBiometrics = true;
          _isCheckingAuth = false;
        });

        // Solicita biometria automaticamente assim que a tela terminar de renderizar
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _authenticateWithBiometrics();
        });
        return;
      } else {
        // Dispositivo sem biometria ou com biometria desativada: verifica rota
        if (mounted) {
          await _navigatePostAuth();
        }
        return;
      }
    }

    if (!mounted) return;
    setState(() {
      _requiresBiometrics = false;
      _isCheckingAuth = false;
    });
  }

  Future<void> _authenticateWithBiometrics() async {
    if (_isAuthenticatingBiometrics) return;
    setState(() => _isAuthenticatingBiometrics = true);

    try {
      final authenticated = await BiometricService.instance.authenticate(
        reason: 'Confirme sua digital para acessar o Velix Ciclo',
      );

      if (!mounted) return;

      if (authenticated) {
        await _navigatePostAuth();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Autenticação biométrica não reconhecida. Toque no botão para tentar novamente.',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isAuthenticatingBiometrics = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);
    try {
      final googleSignIn = GoogleSignIn(
        serverClientId:
            '914827383527-8ah6upg7vrikmet2fm3u9lt2m4fddbj8.apps.googleusercontent.com',
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        setState(() => _isLoading = false);
        return;
      }

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await FirebaseAuth.instance.signInWithCredential(credential);

      // Marca o primeiro login com sucesso para ativar a biometria nos próximos acessos
      await BiometricService.instance.markGoogleLoginCompleted();

      if (mounted) {
        await _navigatePostAuth();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro no login com Google: $e')),
        );
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _switchAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Trocar de conta?'),
        content: const Text(
          'Você sairá da conta atual e precisará fazer um novo login com o Google.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Trocar de conta'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await FirebaseAuth.instance.signOut();
      try {
        await GoogleSignIn().signOut();
      } catch (_) {}
      await BiometricService.instance.clearSession();
      await UserProfileService.instance.clear();

      if (!mounted) return;
      setState(() {
        _requiresBiometrics = false;
        _currentUser = null;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao sair da conta: $e')),
        );
      }
    }
  }

  Future<void> _navigatePostAuth() async {
    final role = await UserProfileService.instance.getUserRole();
    if (!mounted) return;
    if (role == null) {
      GoRouter.of(context).go('/role-selection');
    } else {
      GoRouter.of(context).go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: _requiresBiometrics
              ? _buildBiometricLockUI()
              : _buildInitialLoginUI(),
        ),
      ),
    );
  }

  /// Interface apresentada a partir do primeiro login com Google (exigindo biometria)
  Widget _buildBiometricLockUI() {
    final displayName = _currentUser?.displayName ?? 'Usuário';
    final email = _currentUser?.email ?? '';
    final photoUrl = _currentUser?.photoURL;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        // Logo & Título
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.violet.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.medical_services_rounded,
              size: 56,
              color: AppColors.violet,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'Velix Ciclo',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.violet,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 32),

        // Card do Usuário
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surfaceSoft,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 26,
                backgroundColor: AppColors.violet.withValues(alpha: 0.2),
                backgroundImage:
                    photoUrl != null ? NetworkImage(photoUrl) : null,
                child: photoUrl == null
                    ? const Icon(Icons.person, color: AppColors.violet, size: 28)
                    : null,
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Olá, $displayName',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (email.isNotEmpty)
                      Text(
                        email,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const Icon(
                Icons.lock_outline_rounded,
                color: AppColors.textMuted,
                size: 20,
              ),
            ],
          ),
        ),

        const Spacer(),

        // Botão Central de Biometria
        Center(
          child: InkWell(
            onTap: _isAuthenticatingBiometrics
                ? null
                : _authenticateWithBiometrics,
            borderRadius: BorderRadius.circular(100),
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: AppColors.brandGradient,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.violet.withValues(alpha: 0.35),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: _isAuthenticatingBiometrics
                  ? const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Icon(
                      Icons.fingerprint_rounded,
                      size: 54,
                      color: Colors.white,
                    ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        const Text(
          'Toque para entrar com digital',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Sua conta está protegida por biometria',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            color: AppColors.textSecondary,
          ),
        ),

        const Spacer(),

        // Botão para trocar de conta / entrar com outra conta Google
        TextButton.icon(
          onPressed: _isLoading ? null : _switchAccount,
          icon: const Icon(Icons.sync_alt_rounded, size: 18),
          label: const Text(
            'Entrar com outra conta Google',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  /// Interface inicial para o primeiro login com Google
  Widget _buildInitialLoginUI() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Spacer(),
        const Icon(
          Icons.medical_services_rounded,
          size: 80,
          color: AppColors.violet,
        ),
        const SizedBox(height: 24),
        Text(
          'Velix Ciclo',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: AppColors.violet,
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Sua rotina de saúde organizada.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
        ),
        const Spacer(),

        if (_isLoading)
          const Center(child: CircularProgressIndicator())
        else
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              side: const BorderSide(color: AppColors.border),
            ),
            icon: const Icon(
              Icons.g_mobiledata_rounded,
              size: 32,
              color: AppColors.textPrimary,
            ),
            label: const Text(
              'Entrar com Google',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            onPressed: _signInWithGoogle,
          ),
        const SizedBox(height: 32),
      ],
    );
  }
}
