import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_widgets.dart';
import '../../services/biometric_service.dart';

class PrivacyLockScreen extends StatefulWidget {
  const PrivacyLockScreen({super.key});

  @override
  State<PrivacyLockScreen> createState() => _PrivacyLockScreenState();
}

class _PrivacyLockScreenState extends State<PrivacyLockScreen> {
  bool _pinEnabled = false;
  bool _biometricsEnabled = false;
  bool _biometricsAvailable = true;
  bool _stealthMode = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final available = await BiometricService.instance.isBiometricsAvailable();
    final enabled = await BiometricService.instance.isBiometricLockEnabled();

    if (mounted) {
      setState(() {
        _biometricsAvailable = available;
        _biometricsEnabled = enabled && available;
        _loading = false;
      });
    }
  }

  Future<void> _toggleBiometrics(bool value) async {
    if (value) {
      // Confirma a digital antes de ativar
      final success = await BiometricService.instance.authenticate(
        reason: 'Confirme sua biometria para ativar o bloqueio',
      );
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Falha na confirmação da biometria.')),
          );
        }
        return;
      }
    }

    await BiometricService.instance.setBiometricLockEnabled(value);
    if (mounted) {
      setState(() => _biometricsEnabled = value);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            value
                ? 'Bloqueio por biometria ativado com sucesso!'
                : 'Bloqueio por biometria desativado.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidade Extrema')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Icon(Icons.fingerprint_rounded,
                    size: 60, color: AppColors.violet),
                const SizedBox(height: 16),
                const Text(
                  'Bloqueio do Aplicativo',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Proteja seus dados sensíveis. Se ativado, será necessária autenticação sempre que abrir o aplicativo.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textSecondary, fontSize: 15),
                ),
                const SizedBox(height: 32),
                AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.violet,
                        title: const Text('Desbloqueio por Biometria / Digital',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: Text(
                          _biometricsAvailable
                              ? 'Usar impressão digital ou FaceID nos próximos acessos'
                              : 'Biometria não configurada ou não suportada neste aparelho',
                          style: TextStyle(
                            fontSize: 13,
                            color: _biometricsAvailable
                                ? AppColors.textSecondary
                                : AppColors.danger,
                          ),
                        ),
                        value: _biometricsEnabled,
                        onChanged: _biometricsAvailable
                            ? (v) => _toggleBiometrics(v)
                            : null,
                      ),
                      const Divider(),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.violet,
                        title: const Text('Bloqueio por PIN',
                            style: TextStyle(fontWeight: FontWeight.w600)),
                        subtitle: const Text(
                            'Exigir senha numérica de 4 dígitos para entrar'),
                        value: _pinEnabled,
                        onChanged: (v) {
                          setState(() => _pinEnabled = v);
                          if (v) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Configuração de PIN adicional em desenvolvimento.'),
                              ),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const SectionTitle('Modo Anônimo'),
                AppCard(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    activeColor: AppColors.danger,
                    title: const Text('Ativar Modo Anônimo',
                        style: TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: const Text(
                        'Seus dados não sairão do celular, nem mesmo para backup local seguro.'),
                    value: _stealthMode,
                    onChanged: (v) => setState(() => _stealthMode = v),
                  ),
                ),
                const SizedBox(height: 20),
                if (_stealthMode)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.dangerSoft,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      '⚠️ Atenção: No Modo Anônimo, se você perder o celular, não haverá como recuperar seus dados do diário e tratamentos.',
                      style: TextStyle(
                          color: AppColors.danger,
                          fontSize: 13,
                          fontWeight: FontWeight.bold),
                    ),
                  )
              ],
            ),
    );
  }
}
