import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../core/database/app_database.dart';
import 'diary_service.dart';
import 'notification_service.dart';
import 'user_profile_service.dart';

class CloudSyncService {
  CloudSyncService._();
  static final CloudSyncService instance = CloudSyncService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  StreamSubscription<DocumentSnapshot<Map<String, dynamic>>>?
  _partnerSubscription;

  /// IDs de doses que já estavam como 'tomadas' (para evitar notificar histórico antigo)
  final Set<String> _knownTakenDoseIds = {};
  bool _isFirstSync = true;

  /// Código padrão da mulher (caso não haja um dinâmico)
  static const String defaultWomanCode = "VLM-8X2B-9Q1";

  /// Sincroniza todos os dados locais da Mulher para a nuvem no documento do casal
  Future<void> syncWomanToCloud(AppDatabase db) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      final role = await UserProfileService.instance.getUserRole();
      if (role == UserRole.partner) {
        // Parceiro não sincroniza seus dados locais para cima, apenas lê
        return;
      }

      // Lê todos os dados locais
      final medRows = await db.select(db.medications).get();
      final treatmentRows = await db.select(db.treatments).get();
      final stockRows = await db.select(db.stocks).get();
      final doseRows =
          await (db.select(db.doseRecords)
                ..orderBy([(r) => OrderingTerm.desc(r.scheduledAt)])
                ..limit(100))
              .get();

      final medsData =
          medRows
              .map(
                (m) => {
                  'id': m.id,
                  'name': m.name,
                  'activeIngredient': m.activeIngredient,
                  'concentration': m.concentration,
                  'form': m.form,
                  'category': m.category,
                  'notes': m.notes,
                },
              )
              .toList();

      final treatmentsData =
          treatmentRows
              .map(
                (t) => {
                  'id': t.id,
                  'medicationId': t.medicationId,
                  'startDate': t.startDate.toIso8601String(),
                  'scheduleType': t.scheduleType,
                  'scheduleData': t.scheduleData,
                  'dosePerIntake': t.dosePerIntake,
                  'status': t.status,
                },
              )
              .toList();

      final stocksData =
          stockRows
              .map(
                (s) => {
                  'medicationId': s.medicationId,
                  'quantity': s.quantity,
                  'totalCapacity': s.totalCapacity,
                  'lowStockLimit': s.lowStockLimit,
                  'expirationDate': s.expirationDate?.toIso8601String(),
                  'batch': s.batch,
                },
              )
              .toList();

      final dosesData =
          doseRows
              .map(
                (d) => {
                  'id': d.id,
                  'treatmentId': d.treatmentId,
                  'scheduledAt': d.scheduledAt.toIso8601String(),
                  'takenAt': d.takenAt?.toIso8601String(),
                  'status': d.status,
                  'quantity': d.quantity,
                  'note': d.note,
                },
              )
              .toList();

      // Sincroniza também as anotações do Diário
      final diaryEntries = await DiaryService.instance.getEntries();
      final diaryData = diaryEntries.map((e) => e.toMap()).toList();

      await _firestore.collection('couples').doc(defaultWomanCode).set({
        'pairingCode': defaultWomanCode,
        'womanUid': user?.uid,
        'womanName': user?.displayName ?? 'Esposa',
        'updatedAt': FieldValue.serverTimestamp(),
        'medications': medsData,
        'treatments': treatmentsData,
        'stocks': stocksData,
        'doseRecords': dosesData,
        'diaryEntries': diaryData,
      }, SetOptions(merge: true));
    } catch (e) {
      // Falha silenciosa se offline (Firestore salvará em cache local)
    }
  }

  /// Inicia a escuta em tempo real no aparelho do parceiro
  void startPartnerListener(AppDatabase db) async {
    _partnerSubscription?.cancel();

    final role = await UserProfileService.instance.getUserRole();
    if (role != UserRole.partner) return;

    final partnerCode =
        await UserProfileService.instance.getPairedPartnerCode();
    final code =
        (partnerCode != null && partnerCode.trim().isNotEmpty)
            ? partnerCode.trim().toUpperCase()
            : defaultWomanCode;

    _isFirstSync = true;

    _partnerSubscription = _firestore
        .collection('couples')
        .doc(code)
        .snapshots()
        .listen((snapshot) async {
          if (!snapshot.exists || snapshot.data() == null) return;
          final data = snapshot.data()!;

          try {
            final List<dynamic> meds = data['medications'] ?? [];
            final List<dynamic> treatments = data['treatments'] ?? [];
            final List<dynamic> stocks = data['stocks'] ?? [];
            final List<dynamic> doses = data['doseRecords'] ?? [];
            final List<dynamic> diaryEntries = data['diaryEntries'] ?? [];

            // Atualiza diário no parceiro
            if (diaryEntries.isNotEmpty) {
              await DiaryService.instance.saveRemoteEntries(diaryEntries);
            }

            // Verifica se uma nova dose foi marcada como tomada pela mulher
            for (final item in doses) {
              final map = Map<String, dynamic>.from(item as Map);
              final doseId = map['id'] as String;
              final status = map['status'] as String? ?? 'pending';

              if (status == 'taken') {
                if (!_isFirstSync && !_knownTakenDoseIds.contains(doseId)) {
                  _knownTakenDoseIds.add(doseId);

                  // Procura o nome do remédio
                  final treatmentId = map['treatmentId'] as String?;
                  String medName = 'o remédio';
                  if (treatmentId != null) {
                    final treat = treatments.firstWhere(
                      (t) => (t as Map)['id'] == treatmentId,
                      orElse: () => null,
                    );
                    if (treat != null) {
                      final medId = (treat as Map)['medicationId'];
                      final med = meds.firstWhere(
                        (m) => (m as Map)['id'] == medId,
                        orElse: () => null,
                      );
                      if (med != null) {
                        medName = (med as Map)['name'] ?? 'o remédio';
                      }
                    }
                  }

                  // Dispara notificação local ao parceiro
                  await NotificationService.instance.showImmediateNotification(
                    id: doseId.hashCode,
                    title: 'Ciclo Certo: Remédio tomado! 🌸',
                    body: 'Sua parceira acabou de tomar $medName.',
                  );
                } else {
                  _knownTakenDoseIds.add(doseId);
                }
              }
            }
            _isFirstSync = false;

            await db.transaction(() async {
              // Deleta medicamentos que foram removidos pela mulher
              final remoteMedIds =
                  meds.map((m) => (m as Map)['id'] as String).toSet();
              final localMeds = await db.select(db.medications).get();
              for (final local in localMeds) {
                if (!remoteMedIds.contains(local.id)) {
                  await (db.delete(db.medications)
                    ..where((tbl) => tbl.id.equals(local.id))).go();
                  await (db.delete(db.treatments)
                    ..where((tbl) => tbl.medicationId.equals(local.id))).go();
                  await (db.delete(db.stocks)
                    ..where((tbl) => tbl.medicationId.equals(local.id))).go();
                }
              }

              // Atualiza medicamentos
              for (final item in meds) {
                final map = Map<String, dynamic>.from(item as Map);
                await db
                    .into(db.medications)
                    .insertOnConflictUpdate(
                      MedicationsCompanion.insert(
                        id: map['id'] as String,
                        name: map['name'] as String,
                        activeIngredient: Value(
                          map['activeIngredient'] as String?,
                        ),
                        concentration: Value(map['concentration'] as String?),
                        form: Value(map['form'] as String? ?? 'tablet'),
                        category: Value(map['category'] as String? ?? 'other'),
                        notes: Value(map['notes'] as String?),
                      ),
                    );
              }

              // Atualiza tratamentos
              for (final item in treatments) {
                final map = Map<String, dynamic>.from(item as Map);
                await db
                    .into(db.treatments)
                    .insertOnConflictUpdate(
                      TreatmentsCompanion.insert(
                        id: map['id'] as String,
                        medicationId: map['medicationId'] as String,
                        startDate: DateTime.parse(map['startDate'] as String),
                        scheduleType: map['scheduleType'] as String? ?? 'daily',
                        scheduleData: map['scheduleData'] as String? ?? '{}',
                        dosePerIntake: Value(
                          (map['dosePerIntake'] as num?)?.toDouble() ?? 1.0,
                        ),
                        status: Value(map['status'] as String? ?? 'active'),
                      ),
                    );
              }

              // Atualiza estoques
              for (final item in stocks) {
                final map = Map<String, dynamic>.from(item as Map);
                await db
                    .into(db.stocks)
                    .insertOnConflictUpdate(
                      StocksCompanion.insert(
                        medicationId: map['medicationId'] as String,
                        quantity: (map['quantity'] as num?)?.toDouble() ?? 0.0,
                        totalCapacity: Value(
                          (map['totalCapacity'] as num?)?.toDouble(),
                        ),
                        lowStockLimit: Value(
                          (map['lowStockLimit'] as num?)?.toDouble() ?? 7.0,
                        ),
                        expirationDate: Value(
                          map['expirationDate'] != null
                              ? DateTime.tryParse(
                                map['expirationDate'] as String,
                              )
                              : null,
                        ),
                        batch: Value(map['batch'] as String?),
                      ),
                    );
              }

              // Atualiza registros de doses
              for (final item in doses) {
                final map = Map<String, dynamic>.from(item as Map);
                await db
                    .into(db.doseRecords)
                    .insertOnConflictUpdate(
                      DoseRecordsCompanion.insert(
                        id: map['id'] as String,
                        treatmentId: map['treatmentId'] as String,
                        scheduledAt: DateTime.parse(
                          map['scheduledAt'] as String,
                        ),
                        takenAt: Value(
                          map['takenAt'] != null
                              ? DateTime.tryParse(map['takenAt'] as String)
                              : null,
                        ),
                        status: map['status'] as String? ?? 'pending',
                        quantity: (map['quantity'] as num?)?.toDouble() ?? 1.0,
                        note: Value(map['note'] as String?),
                      ),
                    );
              }
            });
          } catch (_) {
            // Ignora erros de formato pontuais
          }
        });
  }

  void stopListener() {
    _partnerSubscription?.cancel();
    _partnerSubscription = null;
    _knownTakenDoseIds.clear();
    _isFirstSync = true;
  }
}
