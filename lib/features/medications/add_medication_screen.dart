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
    name: 'Ciclo 21',
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

  bool _isAlreadyTaking = false;
  DateTime? _lastDayBeforePause;

  final List<DoseTime> _times = [];
  _PresetMedication? _identifiedPreset;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
    _usageDaysController.addListener(_onCycleSettingsChanged);
    _pauseDaysController.addListener(_onCycleSettingsChanged);
    _durationDaysController.addListener(_onCycleSettingsChanged);
  }

  void _onNameChanged() {
    setState(() {});
  }

  void _onCycleSettingsChanged() {
    if (_isAlreadyTaking) {
      setState(() {
        _updateCalculatedStartDate();
      });
    }
  }

  void _updateCalculatedStartDate() {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    if (!_isAlreadyTaking) return;

    if (_scheduleType == ScheduleType.cycle) {
      final usage = int.tryParse(_usageDaysController.text) ?? 21;
      _lastDayBeforePause ??= today.add(const Duration(days: 6));
      _startDate = _lastDayBeforePause!.subtract(Duration(days: usage - 1));
    } else if (_scheduleType == ScheduleType.durationDays) {
      final duration = int.tryParse(_durationDaysController.text) ?? 7;
      _lastDayBeforePause ??= today.add(const Duration(days: 3));
      _startDate = _lastDayBeforePause!.subtract(Duration(days: duration - 1));
    }
  }

  String _formatDate(DateTime d) {
    return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  }

  int _daysBetween(DateTime a, DateTime b) {
    final da = DateTime(a.year, a.month, a.day);
    final db = DateTime(b.year, b.month, b.day);
    return db.difference(da).inDays;
  }

  Future<void> _pickCustomStartDate() async {
    final picked = await showDatePicker(
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
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _pickLastDayBeforePause() async {
    final today = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _lastDayBeforePause ?? today.add(const Duration(days: 3)),
      firstDate: today,
      lastDate: today.add(const Duration(days: 180)),
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
    if (picked != null) {
      setState(() {
        _lastDayBeforePause = picked;
        _updateCalculatedStartDate();
      });
    }
  }

  @override
  void dispose() {
    _nameController.removeListener(_onNameChanged);
    _usageDaysController.removeListener(_onCycleSettingsChanged);
    _pauseDaysController.removeListener(_onCycleSettingsChanged);
    _durationDaysController.removeListener(_onCycleSettingsChanged);
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
      
      if (_times.isEmpty) {
        _times.addAll(preset.rule.times);
      }
      
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

      if (_isAlreadyTaking) {
        _updateCalculatedStartDate();
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
                          // ignore: deprecated_member_use
                          value: _form,
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
                    // ignore: deprecated_member_use
                    value: _scheduleType,
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

            // Início do Tratamento dinâmico (visível apenas ao escolher/digitar medicamento)
            _buildStartTreatmentSection(),

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

  Widget _buildStartTreatmentSection() {
    final hasMedication = _nameController.text.trim().isNotEmpty;
    if (!hasMedication) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle('Início do Tratamento'),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Você vai começar a tomar hoje ou já está tomando?',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildOptionTile(
                      icon: Icons.play_circle_outline_rounded,
                      title: 'Começar hoje',
                      subtitle: 'Primeiro dia agora',
                      isSelected: !_isAlreadyTaking,
                      onTap: () {
                        setState(() {
                          _isAlreadyTaking = false;
                          _startDate = DateTime(
                            DateTime.now().year,
                            DateTime.now().month,
                            DateTime.now().day,
                          );
                          _lastDayBeforePause = null;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildOptionTile(
                      icon: Icons.history_rounded,
                      title: 'Já estou tomando',
                      subtitle: 'Em andamento na cartela',
                      isSelected: _isAlreadyTaking,
                      onTap: () {
                        setState(() {
                          _isAlreadyTaking = true;
                          _updateCalculatedStartDate();
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!_isAlreadyTaking)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceSoft,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          color: AppColors.violet, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data da 1ª dose / início:',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(_startDate),
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ],
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickCustomStartDate,
                        icon: const Icon(Icons.edit_calendar_rounded, size: 16),
                        label: const Text('Alterar'),
                      ),
                    ],
                  ),
                )
              else if (_scheduleType == ScheduleType.cycle) ...[
                _buildCycleTakingSection(),
              ] else if (_scheduleType == ScheduleType.durationDays) ...[
                _buildDurationTakingSection(),
              ] else ...[
                _buildContinuousTakingSection(),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildCycleTakingSection() {
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.violet.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.violet.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.pause_circle_outline_rounded,
                      color: AppColors.violet, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Qual será o último dia que vai tomar antes da pausa?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickLastDayBeforePause,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.violet.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_available_rounded,
                          color: AppColors.violet, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Último comprimido antes da pausa:',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary),
                            ),
                            Text(
                              _lastDayBeforePause != null
                                  ? _formatDate(_lastDayBeforePause!)
                                  : 'Toque para selecionar a data...',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.violet,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Atalhos rápidos para o término da cartela:',
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final days in [1, 2, 3, 5, 7, 10, 14]) ...[
                      ChoiceChip(
                        label: Text(days == 1 ? 'Termina hoje' : 'Faltam $days dias'),
                        selected: _lastDayBeforePause != null &&
                            _daysBetween(today, _lastDayBeforePause!) == days - 1,
                        onSelected: (_) {
                          setState(() {
                            _lastDayBeforePause =
                                today.add(Duration(days: days - 1));
                            _updateCalculatedStartDate();
                          });
                        },
                        labelStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: (_lastDayBeforePause != null &&
                                  _daysBetween(today, _lastDayBeforePause!) ==
                                      days - 1)
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        selectedColor: AppColors.violet,
                      ),
                      const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_lastDayBeforePause != null) ...[
          const SizedBox(height: 10),
          _buildCycleSummaryCard(),
        ],
      ],
    );
  }

  Widget _buildCycleSummaryCard() {
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final usage = int.tryParse(_usageDaysController.text) ?? 21;
    final pause = int.tryParse(_pauseDaysController.text) ?? 7;
    final lastDay = _lastDayBeforePause!;

    final daysLeft = lastDay.difference(today).inDays + 1;
    final currentPill = (usage - daysLeft + 1).clamp(1, usage);
    final pauseStart = lastDay.add(const Duration(days: 1));
    final pauseEnd = lastDay.add(Duration(days: pause));
    final nextCycleStart = pauseEnd.add(const Duration(days: 1));

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 18),
              SizedBox(width: 8),
              Text(
                'Ciclo sincronizado automaticamente',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF047857),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Hoje você toma o comprimido nº $currentPill de $usage da cartela.',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF065F46)),
          ),
          const SizedBox(height: 3),
          Text(
            '• Último comprimido antes da pausa: ${_formatDate(lastDay)} (${daysLeft == 1 ? "último comprimido é hoje!" : "faltam $daysLeft dias"}).',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF065F46)),
          ),
          const SizedBox(height: 3),
          Text(
            '• Pausa de $pause dias: de ${_formatDate(pauseStart)} a ${_formatDate(pauseEnd)}.',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF065F46)),
          ),
          const SizedBox(height: 3),
          Text(
            '• Início da próxima cartela: ${_formatDate(nextCycleStart)}.',
            style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.bold,
                color: Color(0xFF047857)),
          ),
        ],
      ),
    );
  }

  Widget _buildDurationTakingSection() {
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final duration = int.tryParse(_durationDaysController.text) ?? 7;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.violet.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.violet.withValues(alpha: 0.25)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.flag_rounded, color: AppColors.violet, size: 20),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Qual será o último dia do tratamento?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13.5,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              InkWell(
                onTap: _pickLastDayBeforePause,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                        color: AppColors.violet.withValues(alpha: 0.35)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.event_available_rounded,
                          color: AppColors.violet, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Último dia do tratamento:',
                              style: TextStyle(
                                  fontSize: 11.5,
                                  color: AppColors.textSecondary),
                            ),
                            Text(
                              _lastDayBeforePause != null
                                  ? _formatDate(_lastDayBeforePause!)
                                  : 'Toque para selecionar a data...',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                                color: AppColors.violet,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.arrow_forward_ios_rounded,
                          size: 14, color: AppColors.textSecondary),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Atalhos rápidos:',
                style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary),
              ),
              const SizedBox(height: 6),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    for (final days in [1, 2, 3, 5, 7, 10]) ...[
                      ChoiceChip(
                        label: Text(days == 1 ? 'Termina hoje' : 'Faltam $days dias'),
                        selected: _lastDayBeforePause != null &&
                            _daysBetween(today, _lastDayBeforePause!) == days - 1,
                        onSelected: (_) {
                          setState(() {
                            _lastDayBeforePause =
                                today.add(Duration(days: days - 1));
                            _updateCalculatedStartDate();
                          });
                        },
                        labelStyle: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                          color: (_lastDayBeforePause != null &&
                                  _daysBetween(today, _lastDayBeforePause!) ==
                                      days - 1)
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                        selectedColor: AppColors.violet,
                      ),
                      const SizedBox(width: 6),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
        if (_lastDayBeforePause != null) ...[
          const SizedBox(height: 10),
          _buildDurationSummaryCard(duration),
        ],
      ],
    );
  }

  Widget _buildDurationSummaryCard(int duration) {
    final today =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final lastDay = _lastDayBeforePause!;
    final daysLeft = lastDay.difference(today).inDays + 1;
    final currentDay = (duration - daysLeft + 1).clamp(1, duration);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.successSoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 18),
              SizedBox(width: 8),
              Text(
                'Duração calculada',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF047857),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '• Hoje você está no dia $currentDay de $duration do tratamento.',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF065F46)),
          ),
          const SizedBox(height: 3),
          Text(
            '• Término em: ${_formatDate(lastDay)} (${daysLeft == 1 ? "último dia é hoje!" : "faltam $daysLeft dias"}).',
            style: const TextStyle(fontSize: 12.5, color: Color(0xFF065F46)),
          ),
        ],
      ),
    );
  }

  Widget _buildContinuousTakingSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.violet.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.violet.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time_rounded,
                  color: AppColors.violet, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Desde quando você já toma este medicamento?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: _pickCustomStartDate,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.violet.withValues(alpha: 0.35)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month_rounded,
                      color: AppColors.violet, size: 22),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Data aproximada que você começou:',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: AppColors.textSecondary),
                        ),
                        Text(
                          _formatDate(_startDate),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                            color: AppColors.violet,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.edit_calendar_rounded,
                      size: 18, color: AppColors.violet),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.violet : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.violet : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.violet.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  )
                ]
              : null,
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : AppColors.violet,
              size: 24,
            ),
            const SizedBox(height: 6),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isSelected ? Colors.white : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 10.5,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.85)
                    : AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
