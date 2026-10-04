import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/models.dart';

/// Tela de Controle de Estoque (§11 e §12).
class StockScreen extends ConsumerWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stocksAsync = ref.watch(stocksProvider);
    final medsAsync = ref.watch(medicationsProvider);

    final stocks = stocksAsync.valueOrNull ?? const [];
    final meds = medsAsync.valueOrNull ?? const [];
    final medById = {for (final m in meds) m.id: m};

    return Scaffold(
      appBar: AppBar(title: const Text('Controle de Estoque')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
        children: [
          if (stocksAsync.isLoading || medsAsync.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (stocks.isEmpty)
            const EmptyState(
              icon: Icons.inventory_2_outlined,
              title: 'Nenhum estoque cadastrado',
              subtitle: 'Ao cadastrar cartelas ou métodos, você pode definir a quantidade de pílulas ou itens.',
            )
          else ...[
            for (final stock in stocks) ...[
              if (medById[stock.medicationId] != null) ...[
                _StockItemCard(
                  stock: stock,
                  medication: medById[stock.medicationId]!,
                ),
                const SizedBox(height: 14),
              ],
            ],
          ],
        ],
      ),
    );
  }
}

class _StockItemCard extends ConsumerWidget {
  const _StockItemCard({required this.stock, required this.medication});

  final Stock stock;
  final Medication medication;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stockRepo = ref.watch(stockRepositoryProvider);
    final capacity = stock.totalCapacity ?? stock.quantity;
    final progress = capacity > 0 ? (stock.quantity / capacity).clamp(0.0, 1.0) : 1.0;
    final isLow = stock.isLow;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CategoryAvatar(category: medication.category, size: 44),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      medication.displayName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 16),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isLow ? '⚠️ Estoque baixo' : 'Estoque regular',
                      style: TextStyle(
                        color: isLow ? AppColors.danger : AppColors.success,
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${stock.quantity.toInt()} ${medication.form.unit}s',
                    style: const TextStyle(
                        fontWeight: FontWeight.w800, fontSize: 16),
                  ),
                  if (stock.totalCapacity != null)
                    Text(
                      'de ${stock.totalCapacity!.toInt()}',
                      style: const TextStyle(
                          color: AppColors.textSecondary, fontSize: 12),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          GradientProgress(
            value: progress,
            height: 10,
            danger: isLow,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Alerta quando restar: ${stock.lowStockLimit.toInt()} un.',
                style: const TextStyle(
                    color: AppColors.textSecondary, fontSize: 12),
              ),
              Row(
                children: [
                  IconButton.filledTonal(
                    icon: const Icon(Icons.remove_rounded, size: 18),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(36, 36),
                      backgroundColor: AppColors.surfaceSoft,
                      foregroundColor: AppColors.textPrimary,
                    ),
                    onPressed: () => stockRepo.adjust(medication.id, -1),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filledTonal(
                    icon: const Icon(Icons.add_rounded, size: 18),
                    style: IconButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(36, 36),
                      backgroundColor: AppColors.violet.withValues(alpha: 0.12),
                      foregroundColor: AppColors.violet,
                    ),
                    onPressed: () => stockRepo.adjust(medication.id, 1),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
