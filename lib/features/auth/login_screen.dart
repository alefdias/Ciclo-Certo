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

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isRegistering = false;
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _checkInitialAuth();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkInitialAuth() async {
    try {
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
    } catch (e) {
      debugPrint('Aviso: Autenticação Firebase não disponível: $e');
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
        reason: 'Confirme sua digital para acessar o Ciclo Certo',
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
            '357182464899-7f00ir2utoeaf0ud3gkvm1b5nv4df9h1.apps.googleusercontent.com',
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro no login com Google: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithApple() async {
    setState(() => _isLoading = true);
    try {
      final appleProvider = OAuthProvider('apple.com');
      appleProvider.addScope('email');
      appleProvider.addScope('name');

      await FirebaseAuth.instance.signInWithProvider(appleProvider);
      await BiometricService.instance.markGoogleLoginCompleted();

      if (mounted) {
        await _navigatePostAuth();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro no login com Apple: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithEmail() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, informe e-mail e senha.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      if (_isRegistering) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      await BiometricService.instance.markGoogleLoginCompleted();

      if (mounted) {
        await _navigatePostAuth();
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = 'Erro na autenticação: ${e.message}';
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {
          msg = 'E-mail ou senha incorretos.';
        } else if (e.code == 'wrong-password') {
          msg = 'Senha incorreta.';
        } else if (e.code == 'email-already-in-use') {
          msg = 'Este e-mail já está cadastrado. Alterne para entrar.';
        } else if (e.code == 'weak-password') {
          msg = 'A senha precisa ter no mínimo 6 caracteres.';
        } else if (e.code == 'invalid-email') {
          msg = 'E-mail em formato inválido.';
        }
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(msg)));
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _switchAccount() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Erro ao sair da conta: $e')));
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
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child:
              _requiresBiometrics
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
          child: Image.asset('assets/icon/app_logo.png', width: 88, height: 88),
        ),
        const SizedBox(height: 16),
        Text(
          'Ciclo Certo :Lembrete',
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
                child:
                    photoUrl == null
                        ? const Icon(
                          Icons.person,
                          color: AppColors.violet,
                          size: 28,
                        )
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
            onTap:
                _isAuthenticatingBiometrics
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
              child:
                  _isAuthenticatingBiometrics
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
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
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

  /// Interface inicial de login (E-mail/Senha, Google e Apple)
  Widget _buildInitialLoginUI() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Image.asset(
              'assets/icon/app_logo.png',
              width: 84,
              height: 84,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'Ciclo Certo :Lembrete',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.violet,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isRegistering
                ? 'Crie sua conta para começar'
                : 'Sua rotina de saúde organizada',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),
          const SizedBox(height: 24),

          // Campos de E-mail e Senha
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: InputDecoration(
              labelText: 'E-mail',
              hintText: 'exemplo@email.com',
              prefixIcon: const Icon(Icons.email_outlined),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 14),
          TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _signInWithEmail(),
            decoration: InputDecoration(
              labelText: 'Senha',
              hintText: 'Mínimo 6 caracteres',
              prefixIcon: const Icon(Icons.lock_outline_rounded),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                ),
                onPressed:
                    () => setState(() => _obscurePassword = !_obscurePassword),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
          ),
          const SizedBox(height: 18),

          if (_isLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            )
          else ...[
            // Botão Entrar / Cadastrar com E-mail
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.violet,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: _signInWithEmail,
              child: Text(
                _isRegistering ? 'Cadastrar com E-mail' : 'Entrar com E-mail',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Alternar entre Login e Cadastro
            TextButton(
              onPressed: () {
                setState(() => _isRegistering = !_isRegistering);
              },
              child: Text(
                _isRegistering
                    ? 'Já tem uma conta? Entrar'
                    : 'Não tem conta? Cadastre-se com e-mail',
                style: const TextStyle(
                  color: AppColors.violet,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Divisor
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    'ou continue com',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 13),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: 16),

            // Botão Google
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
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
                'Continuar com Google',
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: _signInWithGoogle,
            ),
            const SizedBox(height: 10),

            // Botão Apple
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              icon: const Icon(Icons.apple, size: 24, color: Colors.white),
              label: const Text(
                'Continuar com Apple',
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: _signInWithApple,
            ),
            const SizedBox(height: 12),

            // Opção para modo offline / desenvolvimento
            TextButton(
              onPressed: _navigatePostAuth,
              child: const Text(
                'Continuar como convidado (offline)',
                style: TextStyle(color: AppColors.textMuted, fontSize: 13),
              ),
            ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
