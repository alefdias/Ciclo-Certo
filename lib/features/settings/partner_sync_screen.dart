import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../core/widgets/app_widgets.dart';
import '../../services/cloud_sync_service.dart';
import '../../services/user_profile_service.dart';
import 'qr_scanner_screen.dart';

class PartnerSyncScreen extends ConsumerStatefulWidget {
  const PartnerSyncScreen({super.key});

  @override
  ConsumerState<PartnerSyncScreen> createState() => _PartnerSyncScreenState();
}

class _PartnerSyncScreenState extends ConsumerState<PartnerSyncScreen> {
  final String womanPairingCode = "VLM-8X2B-9Q1";
  final TextEditingController _partnerInputController = TextEditingController();

  UserRole _role = UserRole.woman;
  String? _pairedCode;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _partnerInputController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    final role = await UserProfileService.instance.getUserRole();
    final pairedCode = await UserProfileService.instance.getPairedPartnerCode();

    if (mounted) {
      setState(() {
        _role = role ?? UserRole.woman;
        _pairedCode = pairedCode;
        if (pairedCode != null) {
          _partnerInputController.text = pairedCode;
        }
        _loading = false;
      });

      final db = ref.read(databaseProvider);
      if (_role == UserRole.woman) {
        CloudSyncService.instance.syncWomanToCloud(db);
      } else {
        CloudSyncService.instance.startPartnerListener(db);
      }
    }
  }

  void _copyCode() {
    Clipboard.setData(ClipboardData(text: womanPairingCode));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Código copiado para a área de transferência!'),
        backgroundColor: AppColors.violet,
      ),
    );
  }

  Future<void> _savePartnerCode() async {
    final code = _partnerInputController.text.trim().toUpperCase();
    if (code.isEmpty) return;

    await UserProfileService.instance.setPairedPartnerCode(code);
    final db = ref.read(databaseProvider);
    CloudSyncService.instance.startPartnerListener(db);

    if (!mounted) return;
    setState(() => _pairedCode = code);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Conectado em tempo real à parceira ($code)!'),
        backgroundColor: AppColors.teal,
      ),
    );
  }

  Future<void> _scanPartnerQr() async {
    final scannedCode = await openQrScanner(context);
    if (scannedCode != null && scannedCode.isNotEmpty) {
      _partnerInputController.text = scannedCode.toUpperCase();
      await _savePartnerCode();
    }
  }

  Future<void> _switchRole(UserRole newRole) async {
    await UserProfileService.instance.setUserRole(newRole);
    if (!mounted) return;
    setState(() => _role = newRole);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Perfil alterado para: ${newRole.label}'),
        backgroundColor: AppColors.violet,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sincronização com Parceiro(a)')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                // Seletor de Perfil no Topo
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildRoleTabButton(
                          title: 'Sou a Mulher',
                          isSelected: _role == UserRole.woman,
                          onTap: () => _switchRole(UserRole.woman),
                        ),
                      ),
                      Expanded(
                        child: _buildRoleTabButton(
                          title: 'Sou o Parceiro',
                          isSelected: _role == UserRole.partner,
                          onTap: () => _switchRole(UserRole.partner),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                if (_role == UserRole.woman)
                  _buildWomanView()
                else
                  _buildPartnerView(),
              ],
            ),
    );
  }

  Widget _buildRoleTabButton({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? AppColors.violet : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildWomanView() {
    return Column(
      children: [
        const Icon(Icons.favorite_rounded, size: 60, color: AppColors.violet),
        const SizedBox(height: 16),
        const Text(
          'Compartilhe seu ciclo',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Peça para o seu parceiro(a) abrir o Ciclo Certo e escanear o QR Code abaixo para acompanhar suas fases do ciclo e apoiar sua rotina.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 28),

        // Card com QR Code da Mulher
        AppCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.violet.withValues(alpha: 0.2),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.violet.withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: QrImageView(
                  data: womanPairingCode,
                  version: QrVersions.auto,
                  size: 200.0,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: AppColors.violet,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.circle,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'OU COMPARTILHE O CÓDIGO',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 20,
                ),
                decoration: BoxDecoration(
                  color: AppColors.violet.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.violet.withValues(alpha: 0.3),
                  ),
                ),
                child: Text(
                  womanPairingCode,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                    color: AppColors.violet,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.violet,
                    side: const BorderSide(color: AppColors.violet),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: _copyCode,
                  icon: const Icon(Icons.copy_rounded, size: 18),
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
                  'Você está no controle: você pode revogar o acesso do parceiro a qualquer momento.',
                  style:
                      TextStyle(fontSize: 13, color: AppColors.textSecondary),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPartnerView() {
    final isConnected = _pairedCode != null && _pairedCode!.isNotEmpty;

    return Column(
      children: [
        const Icon(Icons.people_alt_rounded,
            size: 60, color: Color(0xFF6366F1)),
        const SizedBox(height: 16),
        const Text(
          'Acompanhar Parceira',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        const Text(
          'Escaneie o QR Code exibido no celular da sua parceira para sincronizar instantaneamente.',
          textAlign: TextAlign.center,
          style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        const SizedBox(height: 28),

        // Botão Principal: Escanear QR Code
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.violet,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 4,
            ),
            onPressed: _scanPartnerQr,
            icon: const Icon(Icons.qr_code_scanner_rounded, size: 26),
            label: const Text(
              'Escanear QR Code da Parceira',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        const SizedBox(height: 24),

        AppCard(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (isConnected) ...[
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.successSoft,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.success, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Pareado com sucesso: $_pairedCode',
                          style: const TextStyle(
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const Text(
                'OU DIGITE O CÓDIGO MANUALMENTE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _partnerInputController,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'VLM-XXXX-XXX',
                  filled: true,
                  fillColor: AppColors.surfaceSoft,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.border),
                  ),
                  prefixIcon: const Icon(Icons.keyboard_rounded),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _savePartnerCode,
                child: Text(
                  isConnected ? 'Atualizar Código' : 'Vincular por Código',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
