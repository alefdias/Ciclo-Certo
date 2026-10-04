import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _localAuth = LocalAuthentication();

  static const String _keyBiometricEnabled = 'biometric_lock_enabled';
  static const String _keyHasLoggedInWithGoogle = 'has_logged_in_with_google';

  /// Verifica se o dispositivo possui hardware com suporte e biometria cadastrada
  Future<bool> isBiometricsAvailable() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      if (!isSupported) return false;
      final canCheck = await _localAuth.canCheckBiometrics;
      if (!canCheck) return false;
      final available = await _localAuth.getAvailableBiometrics();
      return available.isNotEmpty;
    } on PlatformException {
      return false;
    }
  }

  /// Verifica se o bloqueio por biometria está ativo
  Future<bool> isBiometricLockEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    final bool? isExplicitlySet = prefs.getBool(_keyBiometricEnabled);
    if (isExplicitlySet != null) {
      return isExplicitlySet;
    }
    // Por padrão, se já realizou o login pelo menos uma vez, ativa automaticamente
    return await hasLoggedInWithGoogle();
  }

  /// Ativa ou desativa a exigência de biometria
  Future<void> setBiometricLockEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyBiometricEnabled, enabled);
  }

  /// Verifica se o usuário já fez login com o Google anteriormente
  Future<bool> hasLoggedInWithGoogle() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyHasLoggedInWithGoogle) ?? false;
  }

  /// Registra que o primeiro login com Google foi realizado com sucesso
  Future<void> markGoogleLoginCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyHasLoggedInWithGoogle, true);
    await prefs.setBool(_keyBiometricEnabled, true);
  }

  /// Executa o diálogo nativo de autenticação biométrica
  Future<bool> authenticate({
    String reason = 'Confirme sua impressão digital para entrar no Velix-Med',
  }) async {
    try {
      final isAvailable = await isBiometricsAvailable();
      if (!isAvailable) {
        return false;
      }

      return await _localAuth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: false,
          useErrorDialogs: true,
        ),
      );
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Limpa os dados de autenticação em caso de logout total
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHasLoggedInWithGoogle);
    await prefs.remove(_keyBiometricEnabled);
  }
}
