import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_widgets.dart';

class PartnerSyncScreen extends StatefulWidget {
  const PartnerSyncScreen({super.key});

  @override
  State<PartnerSyncScreen> createState() => _PartnerSyncScreenState();
}

class _PartnerSyncScreenState extends State<PartnerSyncScreen> {
  final String pairingCode = "VLM-8X2B-9Q1";

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: pairingCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Código copiado para a área de transferência!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronização com Parceiro(a)')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.favorite_rounded, size: 60, color: AppColors.danger),
          const SizedBox(height: 16),
          const Text(
            'Compartilhe seu ciclo',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          const Text(
            'Peça para o seu parceiro(a) baixar o Velix-Med e inserir este código. Ele(a) receberá notificações sobre suas fases do ciclo, TPM e janela fértil.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.textSecondary, fontSize: 15),
          ),
          const SizedBox(height: 32),
          AppCard(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Text('SEU CÓDIGO DE PAREAMENTO',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                  decoration: BoxDecoration(
                    color: AppColors.violet.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.violet.withValues(alpha: 0.3)),
                  ),
                  child: Text(
                    pairingCode,
                    style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800, letterSpacing: 3, color: AppColors.violet),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _copyCode,
                    icon: const Icon(Icons.copy_rounded),
                    label: const Text('Copiar Código'),
                  ),
                )
              ],
            ),
          ),
          const SizedBox(height: 24),
          const AppCard(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.shield_rounded, color: AppColors.teal),
                SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Você está no controle: você pode revogar o acesso a qualquer momento nas configurações.',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
