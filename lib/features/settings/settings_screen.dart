import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_widgets.dart';

/// Tela de Configurações e Preferências (§29).
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _notifications = true;
  bool _sound = true;
  bool _vibration = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          // Perfil Simples Local (§30)
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.violet.withValues(alpha: 0.15),
                  child: const Icon(Icons.person_rounded,
                      size: 34, color: AppColors.violet),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Meu Tratamento',
                        style: TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 17),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Modo Offline · Dados locais',
                        style: TextStyle(
                            color: AppColors.textSecondary, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const SectionTitle('Família & Parceiros'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.favorite_rounded, color: AppColors.danger),
              title: const Text('Sincronização com Parceiro(a)', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Compartilhe seu ciclo por código', style: TextStyle(fontSize: 13)),
              trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
              onTap: () => context.push('/partner-sync'),
            ),
          ),
          const SizedBox(height: 24),

          const SectionTitle('Lembretes e Notificações'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Ativar notificações',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Receba alertas das doses programadas',
                      style: TextStyle(fontSize: 13)),
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Som',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  value: _sound,
                  onChanged: (v) => setState(() => _sound = v),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Vibração',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  value: _vibration,
                  onChanged: (v) => setState(() => _vibration = v),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const SectionTitle('Privacidade & Backup'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.fingerprint_rounded, color: AppColors.violet),
                  title: const Text('Privacidade Extrema', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Bloqueio por PIN, Biometria e Modo Anônimo', style: TextStyle(fontSize: 13)),
                  trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
                  onTap: () => context.push('/privacy-lock'),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.cloud_sync_outlined,
                      color: AppColors.violet),
                  title: const Text('Backup e sincronização',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Opcional · Seus dados ficam no aparelho',
                      style: TextStyle(fontSize: 13)),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                            'Velix Med é 100% offline. Nenhum dado é compartilhado sem consentimento.'),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.download_rounded,
                      color: AppColors.teal),
                  title: const Text('Exportar histórico (PDF/CSV)',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  trailing: const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textMuted),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Exportação de dados disponível na Fase 5.'),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const SectionTitle('Sobre o Velix Med'),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VelixLogo(size: 20),
                const SizedBox(height: 8),
                const Text(
                  'Seu tratamento organizado.',
                  style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Velix Med é um aplicativo offline-first para gerenciamento e automatização de esquemas de medicação, ciclos e estoque.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                Text(
                  'Versão 1.0.0 (MVP 1)',
                  style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
