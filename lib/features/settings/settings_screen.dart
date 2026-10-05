import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../core/widgets/app_widgets.dart';
import '../../services/biometric_service.dart';
import '../../services/medical_report_service.dart';

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
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          // Perfil Conectado / Local (§30)
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: AppColors.violet.withValues(alpha: 0.15),
                  backgroundImage:
                      user?.photoURL != null
                          ? NetworkImage(user!.photoURL!)
                          : null,
                  child:
                      user?.photoURL == null
                          ? const Icon(
                            Icons.person_rounded,
                            size: 34,
                            color: AppColors.violet,
                          )
                          : null,
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.displayName ?? 'Meu Tratamento',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 17,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        user?.email ?? 'Modo Offline · Dados locais',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          Builder(
            builder: (context) {
              final isPartner = ref.watch(isPartnerModeProvider);
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SectionTitle(
                    isPartner
                        ? 'Conexão com a Parceira'
                        : 'Família & Parceiros',
                  ),
                  AppCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isPartner ? Icons.link_rounded : Icons.favorite_rounded,
                        color: isPartner ? AppColors.violet : AppColors.danger,
                      ),
                      title: Text(
                        isPartner
                            ? 'Status da Parceria'
                            : 'Sincronização com Parceiro(a)',
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        isPartner
                            ? 'Ver código conectado e gerenciar conexão'
                            : 'Compartilhe seu ciclo por código ou QR Code',
                        style: const TextStyle(fontSize: 13),
                      ),
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        color: AppColors.textMuted,
                      ),
                      onTap: () => context.push('/partner-sync'),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          const SectionTitle('Lembretes e Notificações'),
          AppCard(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Column(
              children: [
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Ativar notificações',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Receba alertas das doses programadas',
                    style: TextStyle(fontSize: 13),
                  ),
                  value: _notifications,
                  onChanged: (v) => setState(() => _notifications = v),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Som',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  value: _sound,
                  onChanged: (v) => setState(() => _sound = v),
                ),
                const Divider(),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    'Vibração',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
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
                  leading: const Icon(
                    Icons.fingerprint_rounded,
                    color: AppColors.violet,
                  ),
                  title: const Text(
                    'Privacidade Extrema',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Bloqueio por PIN, Biometria e Modo Anônimo',
                    style: TextStyle(fontSize: 13),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                  onTap: () => context.push('/privacy-lock'),
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.cloud_sync_outlined,
                    color: AppColors.violet,
                  ),
                  title: const Text(
                    'Backup e sincronização',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Opcional · Seus dados ficam no aparelho',
                    style: TextStyle(fontSize: 13),
                  ),
                  trailing: const Icon(
                    Icons.chevron_right_rounded,
                    color: AppColors.textMuted,
                  ),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Ciclo Certo :Lembrete: sincronização segura de dados com sua família.',
                        ),
                      ),
                    );
                  },
                ),
                const Divider(),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.assignment_outlined,
                    color: AppColors.teal,
                  ),
                  title: const Text(
                    'Relatório para Consulta Médica',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Exportar histórico de sintomas, ciclo e adesão',
                    style: TextStyle(fontSize: 13),
                  ),
                  trailing: const Icon(
                    Icons.share_rounded,
                    color: AppColors.teal,
                  ),
                  onTap:
                      () => MedicalReportService.instance.exportAndShare(
                        context,
                        ref,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const SectionTitle('Sobre o Ciclo Certo'),
          AppCard(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const VelixLogo(size: 20),
                const SizedBox(height: 8),
                const Text(
                  'Seu ciclo e saúde organizados.',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Ciclo Certo :Lembrete é um aplicativo inteligente para gerenciamento e acompanhamento de ciclos menstruais, anticoncepcionais e rotina de saúde.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Versão 1.0.0 (MVP 1)',
                  style: TextStyle(
                    color: AppColors.textMuted,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          if (user != null) ...[
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.danger,
                side: BorderSide(
                  color: AppColors.danger.withValues(alpha: 0.3),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: const Icon(Icons.logout_rounded, size: 20),
              label: const Text(
                'Sair da conta Google',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder:
                      (ctx) => AlertDialog(
                        title: const Text('Sair da conta?'),
                        content: const Text(
                          'Ao sair, você precisará fazer um novo login com o Google.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(ctx).pop(false),
                            child: const Text('Cancelar'),
                          ),
                          FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: AppColors.danger,
                            ),
                            onPressed: () => Navigator.of(ctx).pop(true),
                            child: const Text('Sair'),
                          ),
                        ],
                      ),
                );
                if (confirm == true) {
                  await FirebaseAuth.instance.signOut();
                  try {
                    await GoogleSignIn().signOut();
                  } catch (_) {}
                  await BiometricService.instance.clearSession();
                  if (context.mounted) {
                    context.go('/login');
                  }
                }
              },
            ),
          ],
        ],
      ),
    );
  }
}
