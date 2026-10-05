import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../app/theme/app_colors.dart';
import '../../core/interactive_quiz.dart';
import '../../core/providers.dart';
import '../../core/widgets/app_widgets.dart';
import '../../services/cloud_sync_service.dart';
import '../../services/diary_service.dart';

class DiaryScreen extends ConsumerStatefulWidget {
  const DiaryScreen({super.key});

  @override
  ConsumerState<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends ConsumerState<DiaryScreen> {
  final TextEditingController _diaryController = TextEditingController();
  String? currentNodeId;

  String? _selectedMood;
  final Set<String> _selectedSymptoms = {};
  List<DiaryEntry> _entries = [];
  bool _loading = true;

  final List<Map<String, String>> _moods = [
    {'emoji': '😊', 'label': 'Ótima'},
    {'emoji': '🙂', 'label': 'Normal'},
    {'emoji': '🥱', 'label': 'Cansada'},
    {'emoji': '🤕', 'label': 'Cólica / Dor'},
    {'emoji': '😢', 'label': 'Sensível'},
    {'emoji': '😤', 'label': 'Irritada'},
  ];

  final List<String> _commonSymptoms = [
    'Cólica menstrual',
    'Dor de cabeça',
    'Inchaço abdominal',
    'Sensibilidade nos seios',
    'Fadiga / Moleza',
    'Náusea / Enjoo',
    'Alteração de humor',
    'Acne',
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final list = await DiaryService.instance.getEntries();
    if (mounted) {
      setState(() {
        _entries = list;
        _loading = false;
      });
    }
  }

  @override
  void dispose() {
    _diaryController.dispose();
    super.dispose();
  }

  Future<void> _saveEntry() async {
    final text = _diaryController.text.trim();
    if (text.isEmpty && _selectedMood == null && _selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione um humor, sintoma ou digite uma anotação.'),
        ),
      );
      return;
    }

    final entry = DiaryEntry(
      id: const Uuid().v4(),
      date: DateTime.now(),
      mood: _selectedMood,
      symptoms: _selectedSymptoms.toList(),
      text: text,
    );

    await DiaryService.instance.addEntry(entry);

    // Sincroniza imediatamente com a nuvem para o parceiro ver na hora
    final db = ref.read(databaseProvider);
    CloudSyncService.instance.syncWomanToCloud(db);

    _diaryController.clear();
    setState(() {
      _selectedMood = null;
      _selectedSymptoms.clear();
    });

    await _loadEntries();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anotação salva e sincronizada com sucesso! 🌸'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _deleteEntry(String id) async {
    await DiaryService.instance.deleteEntry(id);
    final db = ref.read(databaseProvider);
    CloudSyncService.instance.syncWomanToCloud(db);
    await _loadEntries();
  }

  void _startQuiz() {
    setState(() {
      currentNodeId = 'root';
    });
    _showQuizModal();
  }

  void _showQuizModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            if (currentNodeId == null || currentNodeId == 'EXIT') {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pop(context);
              });
              return const SizedBox.shrink();
            }

            final node = InteractiveQuizContent.tree[currentNodeId];
            if (node == null) return const SizedBox.shrink();

            return Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: SafeArea(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: AppColors.border,
                        borderRadius: BorderRadius.circular(2),
                      ),
                      margin: const EdgeInsets.only(bottom: 24),
                    ),
                    Text(
                      node.question,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    ...node.options.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: SizedBox(
                          width: double.infinity,
                          child: FilledButton.tonal(
                            onPressed: () {
                              setModalState(() {
                                currentNodeId = entry.value;
                              });
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Text(
                                entry.key,
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          },
        );
      },
    ).whenComplete(() {
      if (mounted) {
        setState(() {
          currentNodeId = null;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isPartner = ref.watch(isPartnerModeProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isPartner ? 'Bem-Estar da Parceira' : 'Meu Diário de Saúde',
        ),
      ),
      body:
          _loading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                onRefresh: _loadEntries,
                child: isPartner ? _buildPartnerView() : _buildWomanView(),
              ),
    );
  }

  /// Visão do Parceiro: Somente leitura e dicas de apoio carinhoso
  Widget _buildPartnerView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppColors.violet.withValues(alpha: 0.15),
                const Color(0xFF6366F1).withValues(alpha: 0.08),
              ],
            ),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: AppColors.violet.withValues(alpha: 0.3)),
          ),
          child: const Row(
            children: [
              Icon(Icons.favorite_rounded, color: AppColors.violet, size: 28),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Acompanhando a Parceira 🌸',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.violet,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Veja aqui como ela está se sentindo hoje para apoiá-la com carinho e cuidado.',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        if (_entries.isNotEmpty) ...[
          _buildPartnerCaringTipCard(_entries.first),
          const SizedBox(height: 20),
        ],

        const SectionTitle('Últimos Registros da Parceira'),
        const SizedBox(height: 10),

        if (_entries.isEmpty)
          const EmptyState(
            icon: Icons.event_note_rounded,
            title: 'Nenhum sintoma registrado ainda',
            subtitle:
                'Assim que sua parceira registrar como está se sentindo, aparecerá aqui automaticamente.',
          )
        else
          for (final entry in _entries) ...[
            _buildPartnerEntryCard(entry),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _buildPartnerCaringTipCard(DiaryEntry latest) {
    String tip = 'Esteja por perto e ofereça carinho e atenção no dia de hoje!';
    IconData icon = Icons.lightbulb_outline_rounded;

    final symptomsStr = latest.symptoms.join(' ').toLowerCase();
    final mood = latest.mood?.toLowerCase() ?? '';

    if (symptomsStr.contains('cólica') || mood.contains('cólica')) {
      tip =
          'Ela relatou cólica. Que tal preparar uma bolsa de água morna ou um chá calmante de camomila? ☕❤️';
      icon = Icons.spa_rounded;
    } else if (symptomsStr.contains('cabeça')) {
      tip =
          'Ela relatou dor de cabeça. Um ambiente silencioso, menos telas e um copo d\'água ajudam muito.';
      icon = Icons.nightlight_round;
    } else if (symptomsStr.contains('fadiga') || mood.contains('cansada')) {
      tip =
          'Ela está se sentindo cansada hoje. Demonstre carinho e ajude a aliviar as tarefas da rotina. 🛋️';
      icon = Icons.bedtime_rounded;
    } else if (mood.contains('ótima')) {
      tip =
          'Ela está se sentindo muito bem hoje! Aproveitem o dia para fazer algo legal juntos! ✨';
      icon = Icons.sentiment_very_satisfied_rounded;
    } else if (mood.contains('sensível') || mood.contains('irritada')) {
      tip =
          'As oscilações hormonais do ciclo podem causar sensibilidade. Paciência, abraços e acolhimento são o melhor remédio.';
      icon = Icons.volunteer_activism_rounded;
    }

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.teal.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.teal, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dica de Cuidado para Você',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: AppColors.teal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  tip,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textPrimary,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPartnerEntryCard(DiaryEntry entry) {
    final dateStr = DateFormat(
      "d 'de' MMMM · HH:mm",
      'pt_BR',
    ).format(entry.date);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (entry.mood != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.violet.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.mood!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.violet,
                    ),
                  ),
                ),
            ],
          ),
          if (entry.symptoms.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children:
                  entry.symptoms.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
          if (entry.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              entry.text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Visão da Mulher: Check-in, seleção de humor, sintomas e anotações livres
  Widget _buildWomanView() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
      children: [
        // Card Check-in Rápido
        AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.self_improvement_rounded, color: AppColors.violet),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Check-in Interativo',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Responda perguntas rápidas para receber orientações sob medida para o seu ciclo.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('Iniciar Check-in'),
                  onPressed: _startQuiz,
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.violet,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        // Como está se sentindo hoje?
        const Text(
          'Como você está se sentindo hoje?',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children:
                _moods.map((m) {
                  final isSelected =
                      _selectedMood == '${m['emoji']} ${m['label']}';
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text('${m['emoji']} ${m['label']}'),
                      selected: isSelected,
                      onSelected: (val) {
                        setState(() {
                          _selectedMood =
                              val ? '${m['emoji']} ${m['label']}' : null;
                        });
                      },
                      selectedColor: AppColors.violet.withValues(alpha: 0.2),
                      checkmarkColor: AppColors.violet,
                    ),
                  );
                }).toList(),
          ),
        ),
        const SizedBox(height: 18),

        // Sintomas Frequentes
        const Text(
          'Sintomas Corporais',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children:
              _commonSymptoms.map((s) {
                final isSelected = _selectedSymptoms.contains(s);
                return FilterChip(
                  label: Text(s),
                  selected: isSelected,
                  onSelected: (val) {
                    setState(() {
                      if (val) {
                        _selectedSymptoms.add(s);
                      } else {
                        _selectedSymptoms.remove(s);
                      }
                    });
                  },
                  selectedColor: AppColors.teal.withValues(alpha: 0.2),
                  checkmarkColor: AppColors.teal,
                );
              }).toList(),
        ),
        const SizedBox(height: 20),

        // Anotações Livres
        const Text(
          'Anotações do Dia',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 10),
        TextField(
          controller: _diaryController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText:
                'Escreva como foi seu dia, pensamentos ou detalhes sobre seus sintomas...',
            filled: true,
            fillColor: AppColors.surface,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.violet,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onPressed: _saveEntry,
            icon: const Icon(Icons.bookmark_added_rounded),
            label: const Text(
              'Salvar no Diário & Notificar Nuvem',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Histórico
        const SectionTitle('Seu Histórico Recente'),
        const SizedBox(height: 10),

        if (_entries.isEmpty)
          const EmptyState(
            icon: Icons.edit_note_rounded,
            title: 'Nenhum registro ainda',
            subtitle:
                'Escreva suas sensações diárias para acompanhar a evolução do seu ciclo.',
          )
        else
          for (final entry in _entries) ...[
            _buildWomanEntryCard(entry),
            const SizedBox(height: 12),
          ],
      ],
    );
  }

  Widget _buildWomanEntryCard(DiaryEntry entry) {
    final dateStr = DateFormat(
      "d 'de' MMMM · HH:mm",
      'pt_BR',
    ).format(entry.date);

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.access_time_rounded,
                size: 16,
                color: AppColors.textMuted,
              ),
              const SizedBox(width: 6),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textMuted,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (entry.mood != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.violet.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    entry.mood!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                      color: AppColors.violet,
                    ),
                  ),
                ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(
                  Icons.delete_outline_rounded,
                  size: 18,
                  color: AppColors.textMuted,
                ),
                onPressed: () => _deleteEntry(entry.id),
              ),
            ],
          ),
          if (entry.symptoms.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children:
                  entry.symptoms.map((s) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceSoft,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        s,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ],
          if (entry.text.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              entry.text,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
