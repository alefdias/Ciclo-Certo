import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../services/cloud_sync_service.dart';
import '../../services/zapciclo_service.dart';

class ZapCicloScreen extends ConsumerStatefulWidget {
  const ZapCicloScreen({super.key});

  @override
  ConsumerState<ZapCicloScreen> createState() => _ZapCicloScreenState();
}

class _ZapCicloScreenState extends ConsumerState<ZapCicloScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String? _pairingCode;
  bool _loading = true;

  final List<String> _quickPhrases = [
    'Já tomou seu remédio hoje? 💊🌸',
    'Tomei meu remédio certinho! 💕',
    'Tô preparando um chá quentinho pra você ☕❤️',
    'Lembre de beber água, amor! 💧',
    'Quer uma massagem para relaxar hoje? 💆‍♀️',
    'Te amo muito! 😘💖',
    'Como você está se sentindo agora? 🌸',
  ];

  @override
  void initState() {
    super.initState();
    ZapCicloService.instance.isChatScreenActive = true;
    _initCode();
  }

  Future<void> _initCode() async {
    final code = await ZapCicloService.instance.getPairingCode();
    if (mounted) {
      setState(() {
        _pairingCode = code;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    ZapCicloService.instance.isChatScreenActive = false;
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? presetText]) async {
    final text = presetText ?? _textController.text.trim();
    if (text.isEmpty) return;

    if (presetText == null) {
      _textController.clear();
    }

    await ZapCicloService.instance.sendMessage(text: text);

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPartner = ref.watch(isPartnerModeProvider);
    final partnerTitle = isPartner ? 'Minha Esposa 🌸' : 'Meu Parceiro 💕';

    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        backgroundColor: AppColors.surface,
        elevation: 1,
        title: Row(
          children: [
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.violet.withValues(alpha: 0.15),
              child: Icon(
                isPartner ? Icons.favorite_rounded : Icons.person_rounded,
                color: AppColors.violet,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        partnerTitle,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(
                            0xFF22C55E,
                          ).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 7,
                              color: Color(0xFF22C55E),
                            ),
                            SizedBox(width: 4),
                            Text(
                              'ZapCiclo',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF16A34A),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Online em tempo real',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Código de Conexão',
            icon: const Icon(Icons.qr_code_2_rounded),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Código do Casal no ZapCiclo: ${_pairingCode ?? "..."}',
                  ),
                  backgroundColor: AppColors.violet,
                ),
              );
            },
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Barra de mensagens
              Expanded(
                child:
                    _loading
                        ? const Center(child: CircularProgressIndicator())
                        : StreamBuilder<List<ZapMessage>>(
                          stream: ZapCicloService.instance.getMessagesStream(
                            _pairingCode ?? CloudSyncService.defaultWomanCode,
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState ==
                                    ConnectionState.waiting &&
                                !snapshot.hasData) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }

                            final messages = snapshot.data ?? [];

                            if (messages.isEmpty) {
                              return _buildEmptyState(isPartner);
                            }

                            return ListView.builder(
                              controller: _scrollController,
                              reverse: true,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 12,
                              ),
                              itemCount: messages.length,
                              itemBuilder: (context, index) {
                                final msg = messages[index];
                                final isMe =
                                    isPartner
                                        ? (msg.senderRole == 'partner')
                                        : (msg.senderRole == 'woman');
                                return _buildMessageBubble(msg, isMe);
                              },
                            );
                          },
                        ),
              ),

              // Chips de frases rápidas do casal
              _buildQuickPhrasesBar(),

              // Campo de texto estilo WhatsApp
              _buildInputBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isPartner) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF22C55E).withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 48,
                color: Color(0xFF16A34A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Bem-vindos ao ZapCiclo! 💬',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              isPartner
                  ? 'Converse diretamente com sua parceira em tempo real, envie carinhos, lembretes de remédio e acompanhe o dia dela.'
                  : 'Converse com seu parceiro em tempo real, compartilhe sensações e receba apoio sempre que precisar.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textSecondary,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 20),
            FilledButton.tonalIcon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(
                  0xFF22C55E,
                ).withValues(alpha: 0.15),
                foregroundColor: const Color(0xFF15803D),
              ),
              onPressed:
                  () => _sendMessage('Oi meu amor! Tô por aqui no ZapCiclo 💕'),
              icon: const Icon(Icons.waving_hand_rounded, size: 18),
              label: const Text('Mandar "Oi meu amor!" 👋'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ZapMessage msg, bool isMe) {
    final timeStr = DateFormat.Hm().format(msg.sentAt);

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
        decoration: BoxDecoration(
          color: isMe ? AppColors.violet : AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
          border: isMe ? null : Border.all(color: AppColors.border),
        ),
        child: Column(
          crossAxisAlignment:
              isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            if (!isMe)
              Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Text(
                  msg.senderName,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: AppColors.violet,
                  ),
                ),
              ),
            Text(
              msg.text,
              style: TextStyle(
                fontSize: 14.5,
                color: isMe ? Colors.white : AppColors.textPrimary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  timeStr,
                  style: TextStyle(
                    fontSize: 10,
                    color: isMe ? Colors.white70 : AppColors.textMuted,
                  ),
                ),
                if (isMe) ...[
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.done_all_rounded,
                    size: 14,
                    color: Color(0xFF67E8F9),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickPhrasesBar() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          top: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(
          children:
              _quickPhrases.map((phrase) {
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ActionChip(
                    visualDensity: VisualDensity.compact,
                    backgroundColor: AppColors.surfaceSoft,
                    side: BorderSide(
                      color: AppColors.border.withValues(alpha: 0.8),
                    ),
                    label: Text(phrase, style: const TextStyle(fontSize: 12)),
                    onPressed: () => _sendMessage(phrase),
                  ),
                );
              }).toList(),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(
              Icons.favorite_rounded,
              color: Color(0xFFF43F5E),
              size: 24,
            ),
            onPressed: () => _sendMessage('❤️ Te amo!'),
          ),
          Expanded(
            child: TextField(
              controller: _textController,
              textCapitalization: TextCapitalization.sentences,
              maxLines: 4,
              minLines: 1,
              decoration: InputDecoration(
                hintText: 'Mensagem no ZapCiclo...',
                hintStyle: const TextStyle(fontSize: 14),
                filled: true,
                fillColor: AppColors.surfaceSoft,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Material(
            color: const Color(0xFF22C55E),
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: () => _sendMessage(),
              child: const Padding(
                padding: EdgeInsets.all(12),
                child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
