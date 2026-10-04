import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

enum UserRole {
  woman,
  partner;

  String get label => switch (this) {
        UserRole.woman => 'Mulher (Usuária Principal)',
        UserRole.partner => 'Parceiro(a)',
      };

  String get description => switch (this) {
        UserRole.woman => 'Gerencio meu próprio tratamento, pílula e ciclo menstrual.',
        UserRole.partner => 'Acompanho o ciclo, lembretes e apoio minha parceira.',
      };
}

class UserProfileService {
  UserProfileService._();
  static final UserProfileService instance = UserProfileService._();

  static const String _keyUserRole = 'user_profile_role';
  static const String _keyPartnerCode = 'paired_partner_code';

  final _roleController = StreamController<UserRole?>.broadcast();
  Stream<UserRole?> get roleStream => _roleController.stream;

  /// Retorna o papel selecionado do usuário, ou null se ainda não escolheu
  Future<UserRole?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_keyUserRole);
    if (value == 'partner') return UserRole.partner;
    if (value == 'woman') return UserRole.woman;
    return null;
  }

  /// Salva o papel selecionado
  Future<void> setUserRole(UserRole role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserRole, role.name);
    _roleController.add(role);
  }

  /// Salva o código da parceira conectado
  Future<void> setPairedPartnerCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyPartnerCode, code.trim());
  }

  /// Retorna o código da parceira conectado, se houver
  Future<String?> getPairedPartnerCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPartnerCode);
  }

  /// Limpa os dados do perfil (ao deslogar)
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyPartnerCode);
  }
}
