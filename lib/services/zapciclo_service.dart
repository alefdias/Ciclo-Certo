import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';

import 'cloud_sync_service.dart';
import 'notification_service.dart';
import 'user_profile_service.dart';

class ZapMessage {
  final String id;
  final String text;
  final String senderRole; // 'partner' | 'woman'
  final String senderName;
  final String senderId;
  final DateTime sentAt;
  final bool isRead;

  ZapMessage({
    required this.id,
    required this.text,
    required this.senderRole,
    required this.senderName,
    required this.senderId,
    required this.sentAt,
    this.isRead = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'text': text,
    'senderRole': senderRole,
    'senderName': senderName,
    'senderId': senderId,
    'sentAt': sentAt.toIso8601String(),
    'isRead': isRead,
  };

  factory ZapMessage.fromMap(Map<String, dynamic> map) {
    return ZapMessage(
      id: map['id'] as String? ?? '',
      text: map['text'] as String? ?? '',
      senderRole: map['senderRole'] as String? ?? 'woman',
      senderName: map['senderName'] as String? ?? 'Amor',
      senderId: map['senderId'] as String? ?? '',
      sentAt:
          DateTime.tryParse(map['sentAt'] as String? ?? '') ?? DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
    );
  }
}

class ZapCicloService {
  ZapCicloService._();
  static final ZapCicloService instance = ZapCicloService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>? _latestMessageSub;
  String? _lastNotifiedMessageId;
  bool isChatScreenActive = false;

  Future<String> getPairingCode() async {
    final role = await UserProfileService.instance.getUserRole();
    if (role == UserRole.partner) {
      final code = await UserProfileService.instance.getPairedPartnerCode();
      if (code != null && code.trim().isNotEmpty) {
        return code.trim().toUpperCase();
      }
    }
    return CloudSyncService.defaultWomanCode;
  }

  Stream<List<ZapMessage>> getMessagesStream(String pairingCode) {
    return _firestore
        .collection('couples')
        .doc(pairingCode)
        .collection('chat_messages')
        .orderBy('sentAt', descending: true)
        .limit(80)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs
              .map((doc) => ZapMessage.fromMap(doc.data()))
              .toList();
        });
  }

  Future<void> sendMessage({required String text}) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    final code = await getPairingCode();
    final role = await UserProfileService.instance.getUserRole();
    final user = FirebaseAuth.instance.currentUser;

    final roleStr = role == UserRole.partner ? 'partner' : 'woman';
    final defaultName = role == UserRole.partner ? 'Parceiro' : 'Esposa';
    final name =
        (user?.displayName != null && user!.displayName!.isNotEmpty)
            ? user.displayName!
            : defaultName;

    final msgId = const Uuid().v4();
    final now = DateTime.now();

    final message = ZapMessage(
      id: msgId,
      text: cleanText,
      senderRole: roleStr,
      senderName: name,
      senderId: user?.uid ?? 'anon',
      sentAt: now,
    );

    final msgMap = message.toMap();

    // Salva na subcoleção de mensagens
    await _firestore
        .collection('couples')
        .doc(code)
        .collection('chat_messages')
        .doc(msgId)
        .set(msgMap);

    // Atualiza metadados do casal para notificação instantânea do parceiro
    await _firestore.collection('couples').doc(code).set({
      'latestChatMessage': msgMap,
      'lastMessageAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Inicia escuta em segundo plano para notificar quando chegar nova mensagem do ZapCiclo
  void startBackgroundNotificationListener() async {
    _latestMessageSub?.cancel();
    final code = await getPairingCode();
    final myRole = await UserProfileService.instance.getUserRole();
    final myRoleStr = myRole == UserRole.partner ? 'partner' : 'woman';

    _latestMessageSub = _firestore
        .collection('couples')
        .doc(code)
        .snapshots()
        .listen((snapshot) async {
          if (!snapshot.exists || snapshot.data() == null) return;
          final data = snapshot.data()!;
          final latest = data['latestChatMessage'];
          if (latest is Map) {
            final map = Map<String, dynamic>.from(latest);
            final msgId = map['id'] as String?;
            final senderRole = map['senderRole'] as String?;
            final text = map['text'] as String?;
            final senderName = map['senderName'] as String? ?? 'Seu Amor';
            final sentAtStr = map['sentAt'] as String?;

            if (msgId != null &&
                msgId != _lastNotifiedMessageId &&
                senderRole != null &&
                senderRole != myRoleStr &&
                !isChatScreenActive) {
              _lastNotifiedMessageId = msgId;

              // Verifica se a mensagem foi enviada nos últimos 10 minutos
              final sentAt = DateTime.tryParse(sentAtStr ?? '');
              if (sentAt != null &&
                  DateTime.now().difference(sentAt).inMinutes < 10) {
                await NotificationService.instance.showImmediateNotification(
                  id: msgId.hashCode,
                  title: 'ZapCiclo 💬 ($senderName)',
                  body: text ?? 'Nova mensagem recebida',
                );
              }
            }
          }
        });
  }

  void stop() {
    _latestMessageSub?.cancel();
    _latestMessageSub = null;
  }
}
