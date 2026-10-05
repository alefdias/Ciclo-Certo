import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../app/theme/app_colors.dart';
import '../core/database/app_database.dart';
import '../core/providers.dart';
import 'diary_service.dart';

class MedicalReportService {
  MedicalReportService._();
  static final MedicalReportService instance = MedicalReportService._();

  Future<String> generateReport({
    required AppDatabase db,
    required List<DiaryEntry> diaryEntries,
  }) async {
    final now = DateTime.now();
    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');
    final shortDate = DateFormat('dd/MM/yyyy');

    final meds = await db.select(db.medications).get();
    final treatments = await db.select(db.treatments).get();
    final doseRows =
        await (db.select(db.doseRecords)
              ..orderBy([(r) => OrderingTerm.desc(r.scheduledAt)])
              ..limit(120))
            .get();

    final buffer = StringBuffer();
    buffer.writeln('📋 RELATÓRIO DE ACOMPANHAMENTO DE SAÚDE & CICLO');
    buffer.writeln(
      'Emitido pelo aplicativo Ciclo Certo em: ${dateFmt.format(now)}',
    );
    buffer.writeln('--------------------------------------------------\n');

    // 1. Tratamentos Ativos & Anticoncepcionais
    buffer.writeln('💊 MÉTODOS E MEDICAMENTOS ATIVOS');
    if (treatments.isEmpty) {
      buffer.writeln('• Nenhum tratamento ativo cadastrado.\n');
    } else {
      for (final t in treatments) {
        final med = meds.where((m) => m.id == t.medicationId).firstOrNull;
        final name = med?.name ?? 'Medicamento';
        final concentration =
            med?.concentration != null ? ' (${med!.concentration})' : '';
        buffer.writeln('• $name$concentration');
        buffer.writeln(
          '  Início: ${shortDate.format(t.startDate)} | Tipo: ${t.scheduleType}',
        );
      }
      buffer.writeln();
    }

    // 2. Histórico de Adesão às Doses
    final totalDoses = doseRows.length;
    final takenDoses = doseRows.where((d) => d.status == 'taken').length;
    final missedDoses =
        doseRows
            .where((d) => d.status == 'missed' || d.status == 'skipped')
            .length;
    final adherenceRate =
        totalDoses > 0
            ? ((takenDoses / totalDoses) * 100).toStringAsFixed(1)
            : '100.0';

    buffer.writeln('📊 ADESÃO AO TRATAMENTO');
    buffer.writeln('• Taxa geral de adesão recente: $adherenceRate%');
    buffer.writeln(
      '• Doses registradas como tomadas: $takenDoses de $totalDoses',
    );
    buffer.writeln('• Doses esquecidas ou puladas: $missedDoses');
    buffer.writeln();

    // 3. Sintomas e Sensações (Diário)
    buffer.writeln('🩺 SINTOMAS E QUEIXAS REPORTADAS (Últimos registros)');
    if (diaryEntries.isEmpty) {
      buffer.writeln('• Nenhum sintoma registrado no diário de saúde.\n');
    } else {
      // Contagem de sintomas mais frequentes
      final Map<String, int> symptomCount = {};
      final Map<String, int> moodCount = {};
      int intimacyCount = 0;
      int protectedCount = 0;
      int unprotectedCount = 0;

      for (final entry in diaryEntries) {
        for (final s in entry.symptoms) {
          symptomCount[s] = (symptomCount[s] ?? 0) + 1;
        }
        if (entry.mood != null) {
          moodCount[entry.mood!] = (moodCount[entry.mood!] ?? 0) + 1;
        }
        if (entry.hadIntimacy) {
          intimacyCount++;
          if (entry.usedProtection == true) {
            protectedCount++;
          } else if (entry.usedProtection == false) {
            unprotectedCount++;
          }
        }
      }

      if (symptomCount.isNotEmpty) {
        buffer.writeln('Frequência de sintomas:');
        final sorted =
            symptomCount.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
        for (final item in sorted) {
          buffer.writeln('  - ${item.key}: ${item.value}x');
        }
      } else {
        buffer.writeln('• Nenhum sintoma físico específico reportado.');
      }

      if (moodCount.isNotEmpty) {
        buffer.writeln('\nHumor e sensações emocionais:');
        final sortedMoods =
            moodCount.entries.toList()
              ..sort((a, b) => b.value.compareTo(a.value));
        for (final item in sortedMoods) {
          buffer.writeln('  - ${item.key}: ${item.value}x');
        }
      }

      buffer.writeln('\nVida íntima registrada:');
      buffer.writeln('• Total de relações registradas: $intimacyCount');
      if (intimacyCount > 0) {
        buffer.writeln('  - Com proteção: $protectedCount');
        buffer.writeln('  - Sem proteção: $unprotectedCount');
      }
      buffer.writeln();

      // Últimas 5 anotações descritivas
      final notes =
          diaryEntries.where((e) => e.text.trim().isNotEmpty).take(5).toList();
      if (notes.isNotEmpty) {
        buffer.writeln('📝 ÚLTIMAS OBSERVAÇÕES E NOTAS:');
        for (final n in notes) {
          buffer.writeln('• ${shortDate.format(n.date)}: "${n.text.trim()}"');
        }
        buffer.writeln();
      }
    }

    buffer.writeln('--------------------------------------------------');
    buffer.writeln(
      'Relatório gerado para auxílio e consulta com profissional de saúde.',
    );

    return buffer.toString();
  }

  Future<void> exportAndShare(BuildContext context, WidgetRef ref) async {
    try {
      final db = ref.read(databaseProvider);
      final entries = await DiaryService.instance.getEntries();
      final report = await generateReport(db: db, diaryEntries: entries);
      if (!context.mounted) return;

      final box = context.findRenderObject() as RenderBox?;
      final originRect =
          box != null ? box.localToGlobal(Offset.zero) & box.size : null;

      await Share.share(
        report,
        subject: 'Relatório de Saúde e Ciclo - Ciclo Certo',
        sharePositionOrigin: originRect,
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Não foi possível exportar o relatório: $e'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }
}
