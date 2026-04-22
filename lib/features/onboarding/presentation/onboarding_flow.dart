import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/l10n/strings_ar.dart';
import '../../../core/providers.dart';
import '../../planner/application/plan_controller.dart';
import '../../planner/data/user_settings.dart';
import '../../planner/domain/models/position.dart';
import 'surah_ayah_picker.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final _pageController = PageController();
  int _step = 0;

  Position _startingPoint = const Position(1, 1);
  double _dailyAmount = 1;
  Set<int> _weekdays = {1, 2, 3, 4, 7};
  int _rabtCount = 5;
  TimeOfDay _notifyTime = const TimeOfDay(hour: 6, minute: 0);

  static const _totalSteps = 5;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next() {
    if (_step == _totalSteps - 1) {
      _finish();
      return;
    }
    setState(() => _step++);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  void _back() {
    if (_step == 0) return;
    setState(() => _step--);
    _pageController.previousPage(
      duration: const Duration(milliseconds: 240),
      curve: Curves.easeOut,
    );
  }

  Future<void> _finish() async {
    final settings = UserSettings(
      dailyAmountWajh: _dailyAmount,
      memorizationWeekdays: _weekdays,
      rabtCount: _rabtCount,
      currentPosition: _startingPoint,
      notifyHour: _notifyTime.hour,
      notifyMinute: _notifyTime.minute,
      onboarded: true,
    );
    await ref.read(planControllerProvider.notifier).completeOnboarding(settings);
    if (!mounted) return;
    context.go('/dashboard');
  }

  @override
  Widget build(BuildContext context) {
    final metaAsync = ref.watch(quranMetaProvider);

    return Scaffold(
      appBar: AppBar(title: const Text(Ar.appTitle)),
      body: metaAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('خطأ: $e')),
        data: (meta) => SafeArea(
          child: Column(
            children: [
              _Progress(step: _step, total: _totalSteps),
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    _WelcomeStep(),
                    _StartingPointStep(
                      meta: meta,
                      initial: _startingPoint,
                      onChanged: (p) => _startingPoint = p,
                    ),
                    _AmountStep(
                      initial: _dailyAmount,
                      onChanged: (v) => _dailyAmount = v,
                    ),
                    _WeekdaysStep(
                      initial: _weekdays,
                      onChanged: (v) => _weekdays = v,
                    ),
                    _RabtAndNotifyStep(
                      initialRabt: _rabtCount,
                      initialTime: _notifyTime,
                      onRabtChanged: (v) => _rabtCount = v,
                      onTimeChanged: (v) => _notifyTime = v,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _back,
                          child: const Text(Ar.previous),
                        ),
                      ),
                    if (_step > 0) const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            _weekdays.isEmpty && _step == 3 ? null : _next,
                        child: Text(
                          _step == _totalSteps - 1 ? Ar.finish : Ar.next,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Progress extends StatelessWidget {
  final int step;
  final int total;
  const _Progress({required this.step, required this.total});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: LinearProgressIndicator(
        value: (step + 1) / total,
        minHeight: 6,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

class _WelcomeStep extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            Ar.onboardingWelcomeTitle,
            style: Theme.of(context).textTheme.headlineMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            Ar.onboardingWelcomeSubtitle,
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _StartingPointStep extends StatelessWidget {
  final dynamic meta;
  final Position initial;
  final ValueChanged<Position> onChanged;

  const _StartingPointStep({
    required this.meta,
    required this.initial,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Ar.onboardingStartingPointTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            Ar.onboardingStartingPointSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          SurahAyahPicker(
            meta: meta,
            initial: initial,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class _AmountStep extends StatefulWidget {
  final double initial;
  final ValueChanged<double> onChanged;
  const _AmountStep({required this.initial, required this.onChanged});

  @override
  State<_AmountStep> createState() => _AmountStepState();
}

class _AmountStepState extends State<_AmountStep> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final options = [
      (0.5, Ar.amountHalfWajh),
      (1.0, Ar.amountOneWajh),
      (2.0, Ar.amountOnePage),
      (4.0, Ar.amountTwoPages),
    ];

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Ar.onboardingAmountTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            Ar.onboardingAmountSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          for (final (v, label) in options)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: RadioListTile<double>(
                value: v,
                groupValue: _value,
                onChanged: (nv) {
                  if (nv == null) return;
                  setState(() => _value = nv);
                  widget.onChanged(nv);
                },
                title: Text(label),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _WeekdaysStep extends StatefulWidget {
  final Set<int> initial;
  final ValueChanged<Set<int>> onChanged;
  const _WeekdaysStep({required this.initial, required this.onChanged});

  @override
  State<_WeekdaysStep> createState() => _WeekdaysStepState();
}

class _WeekdaysStepState extends State<_WeekdaysStep> {
  late Set<int> _selected;

  @override
  void initState() {
    super.initState();
    _selected = {...widget.initial};
  }

  void _toggle(int wd) {
    setState(() {
      if (_selected.contains(wd)) {
        _selected.remove(wd);
      } else {
        _selected.add(wd);
      }
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Ar.onboardingWeekdaysTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            Ar.onboardingWeekdaysSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (var wd = 1; wd <= 7; wd++)
                FilterChip(
                  label: Text(Ar.weekdays[wd - 1]),
                  selected: _selected.contains(wd),
                  onSelected: (_) => _toggle(wd),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RabtAndNotifyStep extends StatefulWidget {
  final int initialRabt;
  final TimeOfDay initialTime;
  final ValueChanged<int> onRabtChanged;
  final ValueChanged<TimeOfDay> onTimeChanged;

  const _RabtAndNotifyStep({
    required this.initialRabt,
    required this.initialTime,
    required this.onRabtChanged,
    required this.onTimeChanged,
  });

  @override
  State<_RabtAndNotifyStep> createState() => _RabtAndNotifyStepState();
}

class _RabtAndNotifyStepState extends State<_RabtAndNotifyStep> {
  late int _rabt;
  late TimeOfDay _time;

  @override
  void initState() {
    super.initState();
    _rabt = widget.initialRabt;
    _time = widget.initialTime;
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked == null) return;
    setState(() => _time = picked);
    widget.onTimeChanged(picked);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            Ar.onboardingRabtTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            Ar.onboardingRabtSubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text('$_rabt', style: Theme.of(context).textTheme.titleLarge),
              Expanded(
                child: Slider(
                  value: _rabt.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: '$_rabt',
                  onChanged: (v) {
                    setState(() => _rabt = v.round());
                    widget.onRabtChanged(_rabt);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Text(
            Ar.onboardingNotifyTitle,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            Ar.onboardingNotifySubtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          ListTile(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Theme.of(context).dividerColor),
              borderRadius: BorderRadius.circular(12),
            ),
            title: Text('${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}'),
            trailing: const Icon(Icons.access_time),
            onTap: _pickTime,
          ),
        ],
      ),
    );
  }
}
