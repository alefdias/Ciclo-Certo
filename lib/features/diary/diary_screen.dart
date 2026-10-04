import 'package:flutter/material.dart';
import '../../core/interactive_quiz.dart';
import '../../app/theme/app_colors.dart';
import '../../core/widgets/app_widgets.dart';

class DiaryScreen extends StatefulWidget {
  const DiaryScreen({super.key});

  @override
  State<DiaryScreen> createState() => _DiaryScreenState();
}

class _DiaryScreenState extends State<DiaryScreen> {
  final TextEditingController _diaryController = TextEditingController();
  
  String? currentNodeId;

  @override
  void dispose() {
    _diaryController.dispose();
    super.dispose();
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
                        borderRadius: BorderRadius.circular(2)
                      ), 
                      margin: const EdgeInsets.only(bottom: 24)
                    ),
                    Text(
                      node.question,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                              child: Text(entry.key, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16)),
                            ),
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            );
          }
        );
      }
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
    return Scaffold(
      appBar: AppBar(title: const Text('Meu Diário')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.self_improvement_rounded, color: AppColors.violet),
                    SizedBox(width: 10),
                    Expanded(child: Text('Check-in Diário', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
                  ],
                ),
                const SizedBox(height: 10),
                const Text(
                  'Como você está se sentindo hoje? Faça um rápido check-in e receba dicas personalizadas na hora.',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    icon: const Icon(Icons.chat_bubble_outline_rounded),
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
          const SizedBox(height: 24),
          const Text('Anotações Livres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _diaryController,
            maxLines: 10,
            decoration: InputDecoration(
              hintText: 'Escreva aqui como foi seu dia, seus pensamentos, ou novos sintomas que percebeu...',
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
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                if (_diaryController.text.trim().isEmpty) return;
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Anotação salva com sucesso no diário!')));
                _diaryController.clear();
              },
              child: const Text('Salvar no Diário'),
            ),
          ),
        ],
      ),
    );
  }
}
