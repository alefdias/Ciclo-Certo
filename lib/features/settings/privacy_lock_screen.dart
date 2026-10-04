import 'package:flutter/material.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_widgets.dart';

class PrivacyLockScreen extends StatefulWidget {
  const PrivacyLockScreen({super.key});

  @override
  State<PrivacyLockScreen> createState() => _PrivacyLockScreenState();
}

class _PrivacyLockScreenState extends State<PrivacyLockScreen> {
  bool _pinEnabled = false;
  bool _biometricsEnabled = false;
  bool _stealthMode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Privacidade Extrema')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.fingerprint_rounded, size: 60, color: AppColors.violet),
          const SizedBox(height: 16),
          const Text(
            'Bloqueio do Aplicativo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Proteja seus dados sensíveis. Se ativado, será necessário autenticação sempre que abrir o aplicativo.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 32),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.violet,
                  title: const Text('Bloqueio por PIN', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Exigir senha de 4 dígitos para entrar'),
                  value: _pinEnabled,
                  onChanged: (v) {
                    setState(() {
                      _pinEnabled = v;
                      if (!v) _biometricsEnabled = false; // Disable biometrics if PIN is off
                    });
                    if (v) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Por favor, configure o PIN (Modo Demonstração)')));
                    }
                  },
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  activeThumbColor: AppColors.violet,
                  title: const Text('Desbloqueio por Biometria', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Usar FaceID ou Impressão Digital'),
                  value: _biometricsEnabled,
                  onChanged: _pinEnabled ? (v) => setState(() => _biometricsEnabled = v) : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          const SectionTitle('Modo Anônimo'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.danger,
              title: const Text('Ativar Modo Anônimo', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Seus dados não sairão do celular, nem mesmo para backup local seguro.'),
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
                 style: TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.bold),
               ),
             )
        ],
      ),
    );
  }
}
