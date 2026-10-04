import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../app/theme/app_colors.dart';
import '../../core/providers.dart';
import '../../core/widgets/app_widgets.dart';
import '../../models/enums.dart';
import '../../models/models.dart';
import '../../models/schedule_rule.dart';

/// Sugestões pré-cadastradas no catálogo local (§21, §35).
class _PresetMedication {
  const _PresetMedication({
    required this.name,
    required this.concentration,
    required this.form,
    required this.category,
    required this.rule,
    this.stock = 30,
    this.activeIngredient,
  });

  final String name;
  final String concentration;
  final PharmaceuticalForm form;
  final MedicationCategory category;
  final ScheduleRule rule;
  final double stock;
  final String? activeIngredient;
}

const _kPresets = [
  _PresetMedication(
    name: 'Selene',
    concentration: '',
    activeIngredient: 'Etinilestradiol + Acetato de Ciproterona',
    form: PharmaceuticalForm.tablet,
    category: MedicationCategory.contraceptive,
    stock: 21,
    rule: ScheduleRule(
      type: ScheduleType.cycle,
      times: [DoseTime(8, 0)],
      usageDays: 21,
      pauseDays: 7,
    ),
  ),
  _PresetMedication(
    name: 'Qlaira',
    concentration: '',
    activeIngredient: 'Valerato de estradiol + Dienogeste',
    form: PharmaceuticalForm.tablet,
    category: MedicationCategory.continuousUse,
    stock: 28,
    rule: ScheduleRule(
      type: ScheduleType.continuous,
      times: [DoseTime(8, 0)],
    ),
  ),
  _PresetMedication(
    name: 'Yaz',
    concentration: '',
    activeIngredient: 'Drospirenona + Etinilestradiol',
    form: PharmaceuticalForm.tablet,
    category: MedicationCategory.contraceptive,
    stock: 24,
    rule: ScheduleRule(
      type: ScheduleType.cycle,
      times: [DoseTime(8, 0)],
      usageDays: 24,
      pauseDays: 4,
    ),
  ),
  _PresetMedication(
    name: 'Yasmin',
    concentration: '',
    activeIngredient: 'Drospirenona + Etinilestradiol',
    form: PharmaceuticalForm.tablet,
    category: MedicationCategory.contraceptive,
    stock: 21,
    rule: ScheduleRule(
      type: ScheduleType.cycle,
      times: [DoseTime(8, 0)],
      usageDays: 21,
      pauseDays: 7,
    ),
  ),
  _PresetMedication(
    name: 'Cerazette',
    concentration: '',
    activeIngredient: 'Desogestrel',
    form: PharmaceuticalForm.tablet,
    category: MedicationCategory.continuousUse,
    stock: 28,
    rule: ScheduleRule(
      type: ScheduleType.continuous,
      times: [DoseTime(8, 0)],
    ),
  ),
  _PresetMedication(
    name: 'Diane 35',
    concentration: '',
    activeIngredient: 'Etinilestradiol + Acetato de ciproterona',
    form: PharmaceuticalForm.tablet,
    category: MedicationCategory.contraceptive,
    stock: 21,
    rule: ScheduleRule(
      type: ScheduleType.cycle,
      times: [DoseTime(8, 0)],
      usageDays: 21,
      pauseDays: 7,
    ),
  ),
  _PresetMedication(
    name: 'Microvlar',
    concentration: '',
    activeIngredient: 'Levonorgestrel + Etinilestradiol',
    form: PharmaceuticalForm.tablet,
    category: MedicationCategory.contraceptive,
    stock: 21,
    rule: ScheduleRule(
      type: ScheduleType.cycle,
      times: [DoseTime(8, 0)],
      usageDays: 21,
      pauseDays: 7,
    ),
  ),
  _PresetMedication(
    name: 'Iumi',
    concentration: '',
    activeIngredient: 'Drospirenona + Etinilestradiol',
    form: PharmaceuticalForm.tablet,
    category: MedicationCategory.contraceptive,
    stock: 24,
    rule: ScheduleRule(
      type: ScheduleType.cycle,
      times: [DoseTime(8, 0)],
      usageDays: 24,
      pauseDays: 4,
    ),
  ),
  _PresetMedication(
    name: 'Slinda',
    concentration: '',
    activeIngredient: 'Drospirenona',
    form: PharmaceuticalForm.tablet,
    category: MedicationCategory.contraceptive,
    stock: 24,
    rule: ScheduleRule(
      type: ScheduleType.cycle,
      times: [DoseTime(8, 0)],
      usageDays: 24,
      pauseDays: 4,
    ),
  ),
  _PresetMedication(
    name: 'Allestra 20',
    concentration: '',
    activeIngredient: 'Gestodeno + Etinilestradiol',
    form: PharmaceuticalForm.tablet,
    category: MedicationCategory.contraceptive,
    stock: 21,
    rule: ScheduleRule(
      type: ScheduleType.cycle,
      times: [DoseTime(8, 0)],
      usageDays: 21,
      pauseDays: 7,
    ),
  ),
];

/// Tela completa de cadastro de medicamento e tratamento (§19, §20).
class AddMedicationScreen extends ConsumerStatefulWidget {
  const AddMedicationScreen({super.key});

  @override
  ConsumerState<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends ConsumerState<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _concentrationController = TextEditingController();
  final _activeIngredientController = TextEditingController();
  final _stockController = TextEditingController(text: '30');
  final _lowStockLimitController = TextEditingController(text: '7');
  final _durationDaysController = TextEditingController(text: '7');
  final _intervalHoursController = TextEditingController(text: '8');
  final _usageDaysController = TextEditingController(text: '21');
  final _pauseDaysController = TextEditingController(text: '7');

  PharmaceuticalForm _form = PharmaceuticalForm.tablet;
  MedicationCategory _category = MedicationCategory.continuousUse;
  ScheduleType _scheduleType = ScheduleType.continuous;

  DateTime _startDate = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

  List<DoseTime> _times = [];
  _PresetMedication? _identifiedPreset;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _concentrationController.dispose();
    _activeIngredientController.dispose();
    _stockController.dispose();
    _lowStockLimitController.dispose();
    _durationDaysController.dispose();
    _intervalHoursController.dispose();
    _usageDaysController.dispose();
    _pauseDaysController.dispose();
    super.dispose();
  }

  void _applyPreset(_PresetMedication preset) {
    setState(() {
      _identifiedPreset = preset;
      _nameController.text = preset.name;
      _concentrationController.text = preset.concentration;
      _activeIngredientController.text = preset.activeIngredient ?? '';
      _form = preset.form;
      _category = preset.category;
      _scheduleType = preset.rule.type;
      
      // Preserve existing selected times if any, otherwise leave it to the user
      // or optionally we could clear it if switching preset types completely.
      
      _stockController.text = preset.stock.toInt().toString();

      if (preset.rule.durationDays != null) {
        _durationDaysController.text = preset.rule.durationDays.toString();
      }
      if (preset.rule.intervalHours != null) {
        _intervalHoursController.text = preset.rule.intervalHours.toString();
      }
      if (preset.rule.usageDays != null) {
        _usageDaysController.text = preset.rule.usageDays.toString();
      }
      if (preset.rule.pauseDays != null) {
        _pauseDaysController.text = preset.rule.pauseDays.toString();
      }
    });
  }

  Future<void> _pickTime(int index) async {
    final current = _times[index];
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: current.hour, minute: current.minute),
    );
    if (picked != null) {
      setState(() {
        _times[index] = DoseTime(picked.hour, picked.minute);
        _times.sort();
      });
    }
  }

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _times.add(DoseTime(picked.hour, picked.minute));
        _times.sort();
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_scheduleType != ScheduleType.asNeeded && _times.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, adicione pelo menos um horário para a medicação.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      const uuid = Uuid();
      final medId = 'med-${uuid.v4()}';
      final treatId = 'tr-${uuid.v4()}';

      final rule = ScheduleRule(
        type: _scheduleType,
        times: _scheduleType == ScheduleType.asNeeded ? const [] : _times,
        intervalHours: _scheduleType == ScheduleType.intervalHours
            ? int.tryParse(_intervalHoursController.text) ?? 8
            : null,
        durationDays: _scheduleType == ScheduleType.durationDays
            ? int.tryParse(_durationDaysController.text) ?? 7
            : null,
        usageDays: _scheduleType == ScheduleType.cycle
            ? int.tryParse(_usageDaysController.text) ?? 21
            : null,
        pauseDays: _scheduleType == ScheduleType.cycle
            ? int.tryParse(_pauseDaysController.text) ?? 7
            : null,
      );

      final medication = Medication(
        id: medId,
        name: _nameController.text.trim(),
        concentration: _concentrationController.text.trim().isEmpty
            ? null
            : _concentrationController.text.trim(),
        activeIngredient: _activeIngredientController.text.trim().isEmpty
            ? null
            : _activeIngredientController.text.trim(),
        form: _form,
        category: _category,
      );

      final treatment = Treatment(
        id: treatId,
        medicationId: medId,
        startDate: _startDate,
        rule: rule,
        dosePerIntake: 1,
      );

      final stockQty = double.tryParse(_stockController.text) ?? 30;
      final lowLimit = double.tryParse(_lowStockLimitController.text) ?? 7;

      final stock = Stock(
        medicationId: medId,
        quantity: stockQty,
        totalCapacity: stockQty,
        lowStockLimit: lowLimit,
      );

      await ref.read(medicationRepositoryProvider).save(
            medication: medication,
            treatment: treatment,
            stock: stock,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${medication.displayName} cadastrado com sucesso! ✓'),
          backgroundColor: AppColors.success,
        ),
      );

      context.pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro ao cadastrar: $e'),
          backgroundColor: AppColors.danger,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Novo Medicamento'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
          children: [
            // Sugestões rápidas (§35)
            const Text(
              'Sugestões frequentes:',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (final preset in _kPresets) ...[
                    ActionChip(
                      avatar: Icon(
                        CategoryStyle.of(preset.category).icon,
                        size: 16,
                        color: CategoryStyle.of(preset.category).color,
                      ),
                      label: Text(preset.name),
                      onPressed: () => _applyPreset(preset),
                    ),
                    const SizedBox(width: 8),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Card de Identificação Automática (§5, §20)
            if (_identifiedPreset != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.successSoft,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.auto_awesome_rounded,
                            color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Esquema identificado: ${_identifiedPreset!.name}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF047857),
                              fontSize: 14),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Regra: ${_identifiedPreset!.rule.summary}. Os campos abaixo foram preenchidos para sua confirmação.',
                      style: const TextStyle(
                          color: Color(0xFF065F46), fontSize: 12.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 1. Dados básicos
            const SectionTitle('Informações do Medicamento'),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nome do medicamento *',
                      hintText: 'Ex: Losartana, Ciclo 21, Omeprazol',
                    ),
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Informe o nome' : null,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _concentrationController,
                          decoration: const InputDecoration(
                            labelText: 'Concentração',
                            hintText: 'Ex: 50 mg, 10 mL',
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: DropdownButtonFormField<PharmaceuticalForm>(
                          initialValue: _form,
                          decoration: const InputDecoration(labelText: 'Forma'),
                          items: [
                            for (final f in PharmaceuticalForm.values)
                              DropdownMenuItem(
                                value: f,
                                child: Text(f.label, overflow: TextOverflow.ellipsis),
                              ),
                          ],
                          onChanged: (v) {
                            if (v != null) setState(() => _form = v);
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _activeIngredientController,
                    decoration: const InputDecoration(
                      labelText: 'Princípio ativo (opcional)',
                      hintText: 'Ex: Losartana Potássica',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 1.5 Data de Início
            const SectionTitle('Início do Tratamento'),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.calendar_today_rounded, color: AppColors.violet),
                title: const Text('Data de Início'),
                subtitle: Text(
                  '${_startDate.day.toString().padLeft(2, '0')}/${_startDate.month.toString().padLeft(2, '0')}/${_startDate.year}',
                  style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textPrimary),
                ),
                trailing: const Icon(Icons.edit_rounded, size: 20),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _startDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: AppColors.violet,
                            onPrimary: Colors.white,
                            onSurface: AppColors.textPrimary,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (date != null) {
                    setState(() => _startDate = date);
                  }
                },
              ),
            ),
            const SizedBox(height: 20),

            // 2. Categoria
            const SectionTitle('Categoria'),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final cat in MedicationCategory.values) ...[
                    ChoiceChip(
                      avatar: Icon(
                        CategoryStyle.of(cat).icon,
                        size: 16,
                        color: _category == cat ? Colors.white : CategoryStyle.of(cat).color,
                      ),
                      label: Text(cat.label),
                      selected: _category == cat,
                      selectedColor: AppColors.violet,
                      labelStyle: TextStyle(
                        color: _category == cat ? Colors.white : AppColors.textPrimary,
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                      onSelected: (_) => setState(() => _category = cat),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 3. Esquema de Tratamento (§6)
            const SectionTitle('Esquema de Uso'),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownButtonFormField<ScheduleType>(
                    initialValue: _scheduleType,
                    decoration: const InputDecoration(labelText: 'Tipo de esquema'),
                    items: [
                      for (final st in ScheduleType.values)
                        DropdownMenuItem(
                          value: st,
                          child: Text(st.label),
                        ),
                    ],
                    onChanged: (v) {
                      if (v != null) setState(() => _scheduleType = v);
                    },
                  ),
                  const SizedBox(height: 14),

                  if (_scheduleType == ScheduleType.durationDays) ...[
                    TextFormField(
                      controller: _durationDaysController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Duração em dias',
                        suffixText: 'dias',
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  if (_scheduleType == ScheduleType.intervalHours) ...[
                    TextFormField(
                      controller: _intervalHoursController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Intervalo entre doses',
                        suffixText: 'horas',
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  if (_scheduleType == ScheduleType.cycle) ...[
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _usageDaysController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Dias de uso',
                              suffixText: 'dias',
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _pauseDaysController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: 'Dias de pausa',
                              suffixText: 'dias',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                  ],

                  // Seletor de horários (se não for "Se necessário")
                  if (_scheduleType != ScheduleType.asNeeded) ...[
                    const Text(
                      'Horários das doses:',
                      style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (int i = 0; i < _times.length; i++)
                          InputChip(
                            avatar: const Icon(Icons.schedule_rounded, size: 16),
                            label: Text(_times[i].format()),
                            onPressed: () => _pickTime(i),
                            onDeleted: _times.length > 1
                                ? () => setState(() => _times.removeAt(i))
                                : null,
                          ),
                        ActionChip(
                          avatar: const Icon(Icons.add_rounded, size: 16),
                          label: const Text('Horário'),
                          onPressed: _addTime,
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Estoque inicial (§11)
            const SectionTitle('Controle de Estoque'),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _stockController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Quantidade em estoque',
                        suffixText: _form.unit,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lowStockLimitController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Avisar ao restar',
                        suffixText: 'un.',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Botão Salvar
            GradientButton(
              label: _isLoading ? 'Salvando...' : 'Confirmar e Salvar Tratamento',
              icon: Icons.check_circle_rounded,
              onPressed: _isLoading ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}
