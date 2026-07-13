import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../body_metrics/data.dart';
import '../diet/data.dart';
import '../coach/data.dart';
import '../workouts/data.dart';

const _pollInterval = Duration(seconds: 2);
const _pollTimeout = Duration(minutes: 3);

/// Item do feed de chat. Sealed para o `switch` de renderização ser
/// exaustivo — cada novo tipo de resultado força tratar a UI dele.
sealed class _ChatItem {
  const _ChatItem();
}

class _UserMessageItem extends _ChatItem {
  const _UserMessageItem({required this.text, required this.time});
  final String text;
  final String time;
}

class _AssistantTextItem extends _ChatItem {
  const _AssistantTextItem({required this.text, required this.time});
  final String text;
  final String time;
}

/// Job de geração de plano em andamento. `progressLabel` é só uma
/// progressão honesta baseada em tempo decorrido — o backend não expõe
/// etapa granular do pipeline (gerador → validação → crítico).
class _PendingJobItem extends _ChatItem {
  const _PendingJobItem({
    required this.jobId,
    required this.progressLabel,
    required this.originalText,
  });
  final int jobId;
  final String progressLabel;
  final String originalText;
}

class _PlanResultItem extends _ChatItem {
  const _PlanResultItem({
    required this.plan,
    required this.totals,
    this.criticSummary,
    this.warnings = const [],
  });
  final MealPlanModel plan;
  final Macros totals;
  final String? criticSummary;
  final List<CoachIssue> warnings;
}

class _WorkoutResultItem extends _ChatItem {
  const _WorkoutResultItem({
    required this.workout,
    this.summary,
    this.criticSummary,
    this.warnings = const [],
  });
  final WorkoutModel workout;
  final WorkoutPlanSummary? summary;
  final String? criticSummary;
  final List<CoachIssue> warnings;
}

/// Pipeline rodou até o fim mas o plano foi reprovado — não é erro.
class _RejectedResultItem extends _ChatItem {
  const _RejectedResultItem({
    required this.issues,
    required this.errors,
    required this.originalText,
  });
  final List<CoachIssue> issues;
  final List<String> errors;
  final String originalText;
}

class _FailedResultItem extends _ChatItem {
  const _FailedResultItem({required this.errorText, required this.originalText});
  final String errorText;
  final String originalText;
}

class _TimeoutResultItem extends _ChatItem {
  const _TimeoutResultItem({required this.originalText});
  final String originalText;
}

/// Chat com o FitTrack Coach (IA). Envia mensagem, roteia via
/// `/coach/messages/` e, para pedido de dieta ou treino, faz polling do job
/// até aprovar, reprovar ou falhar.
class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, this.initialMessage});

  /// Mensagem enviada automaticamente ao abrir a tela — usada pelos pontos
  /// de entrada "Montar com o assistente" (dieta/treino), que já chegam com
  /// a intenção do aluno em vez de exigir digitar de novo.
  final String? initialMessage;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _items = <_ChatItem>[];
  final _input = TextEditingController();
  final _scrollController = ScrollController();

  int? _conversationId;
  bool _loadingHistory = true;
  bool _sending = false;
  int _pendingItemIndex = -1;

  Timer? _pollTimer;
  DateTime? _pollStartedAt;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    _input.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _bootstrap() async {
    final storage = ref.read(coachStorageProvider);
    final savedId = await storage.conversationId;
    if (savedId != null) {
      try {
        final messages =
            await ref.read(coachRepositoryProvider).fetchMessages(savedId);
        _conversationId = savedId;
        if (mounted) {
          setState(() {
            _items.addAll(messages.map(_itemFromMessage));
            _loadingHistory = false;
          });
          _scrollToBottom();
        }
        _sendInitialMessageIfAny();
        return;
      } catch (_) {
        // Conversa local pode ter sido apagada/pertencer a outra sessão —
        // não trava o chat, só começa uma nova.
        await storage.clear();
      }
    }
    if (mounted) setState(() => _loadingHistory = false);
    _sendInitialMessageIfAny();
  }

  void _sendInitialMessageIfAny() {
    final initial = widget.initialMessage?.trim();
    if (initial == null || initial.isEmpty) return;
    _send(initial);
  }

  _ChatItem _itemFromMessage(CoachMessageModel m) => m.isMine
      ? _UserMessageItem(text: m.content, time: _timeLabel(m.createdAt))
      : _AssistantTextItem(text: m.content, time: _timeLabel(m.createdAt));

  String _timeLabel(DateTime dt) => DateFormat('HH:mm').format(dt.toLocal());
  String get _nowLabel => DateFormat('HH:mm').format(DateTime.now());

  Future<void> _send([String? overrideText]) async {
    final text = (overrideText ?? _input.text).trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _items.add(_UserMessageItem(text: text, time: _nowLabel));
      if (overrideText == null) _input.clear();
      _sending = true;
    });
    _scrollToBottom();

    try {
      final result = await ref
          .read(coachRepositoryProvider)
          .sendMessage(text, conversationId: _conversationId);

      if (_conversationId != result.conversationId) {
        _conversationId = result.conversationId;
        await ref.read(coachStorageProvider).saveConversationId(result.conversationId);
      }
      if (!mounted) return;

      if (result.isJob) {
        setState(() {
          _pendingItemIndex = _items.length;
          _items.add(_PendingJobItem(
            jobId: result.jobId!,
            progressLabel: _progressLabelFor(Duration.zero),
            originalText: text,
          ));
        });
        _scrollToBottom();
        _startPolling(result.jobId!);
      } else {
        setState(() {
          _items.add(_AssistantTextItem(text: result.message ?? '', time: _nowLabel));
          _sending = false;
        });
        _scrollToBottom();
      }
    } on DioException catch (_) {
      if (!mounted) return;
      setState(() {
        _items.add(_FailedResultItem(
          errorText: 'Não foi possível enviar sua mensagem. Verifique sua conexão.',
          originalText: text,
        ));
        _sending = false;
      });
      _scrollToBottom();
    }
  }

  void _startPolling(int jobId) {
    _pollTimer?.cancel();
    _pollStartedAt = DateTime.now();
    _pollTimer = Timer.periodic(_pollInterval, (_) => _checkJob(jobId));
  }

  Future<void> _checkJob(int jobId) async {
    if (!mounted) {
      _pollTimer?.cancel();
      return;
    }
    final elapsed = DateTime.now().difference(_pollStartedAt!);
    if (elapsed > _pollTimeout) {
      _pollTimer?.cancel();
      _resolvePending((pending) => _TimeoutResultItem(originalText: pending.originalText));
      return;
    }

    final CoachJobResult job;
    try {
      job = await ref.read(coachRepositoryProvider).fetchJob(jobId);
    } catch (_) {
      // Falha pontual de rede durante o polling: tenta de novo no próximo
      // tick em vez de desistir na primeira soneca da conexão.
      return;
    }
    if (!mounted) return;

    if (job.isApproved) {
      _pollTimer?.cancel();
      final warnings = job.issues.where((i) => !i.isBlocker).toList();
      _resolvePending((_) => job.mealPlan != null
          ? _PlanResultItem(
              plan: job.mealPlan!,
              totals: job.totals ?? const Macros(),
              criticSummary: job.criticSummary,
              warnings: warnings,
            )
          : _WorkoutResultItem(
              workout: job.workout!,
              summary: job.summary,
              criticSummary: job.criticSummary,
              warnings: warnings,
            ));
    } else if (job.isRejected) {
      _pollTimer?.cancel();
      _resolvePending((pending) => _RejectedResultItem(
            issues: job.issues,
            errors: job.errors,
            originalText: pending.originalText,
          ));
    } else if (job.isFailed) {
      _pollTimer?.cancel();
      _resolvePending((pending) => _FailedResultItem(
            errorText:
                job.error.isNotEmpty ? job.error : 'Algo deu errado ao gerar seu plano.',
            originalText: pending.originalText,
          ));
    } else {
      // ainda pending/running
      setState(() {
        if (_pendingItemIndex >= 0 && _pendingItemIndex < _items.length) {
          final current = _items[_pendingItemIndex];
          if (current is _PendingJobItem) {
            _items[_pendingItemIndex] = _PendingJobItem(
              jobId: jobId,
              progressLabel: _progressLabelFor(elapsed),
              originalText: current.originalText,
            );
          }
        }
      });
    }
  }

  void _resolvePending(_ChatItem Function(_PendingJobItem pending) build) {
    setState(() {
      _sending = false;
      if (_pendingItemIndex >= 0 && _pendingItemIndex < _items.length) {
        final current = _items[_pendingItemIndex];
        if (current is _PendingJobItem) {
          _items[_pendingItemIndex] = build(current);
        }
      }
      _pendingItemIndex = -1;
    });
    _scrollToBottom();
  }

  String _progressLabelFor(Duration elapsed) {
    if (elapsed < const Duration(seconds: 15)) return 'Montando seu plano...';
    if (elapsed < const Duration(seconds: 35)) return 'Conferindo os macros...';
    if (elapsed < const Duration(seconds: 60)) return 'Revisando o plano...';
    return 'Ainda trabalhando nisso — planos mais elaborados levam um pouco mais...';
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          _header(context),
          Expanded(
            child: _loadingHistory
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.primary))
                : _items.isEmpty
                    ? const _EmptyChat()
                    : ListView.separated(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(18),
                        itemCount: _items.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, i) => switch (_items[i]) {
                          _UserMessageItem(:final text, :final time) =>
                            _textBubble(text: text, time: time, mine: true),
                          _AssistantTextItem(:final text, :final time) =>
                            _textBubble(text: text, time: time, mine: false),
                          final _PendingJobItem item => _pendingBubble(item),
                          final _PlanResultItem item => _planCard(item),
                          final _WorkoutResultItem item => _workoutCard(item),
                          final _RejectedResultItem item => _rejectedCard(item),
                          final _FailedResultItem item => _failedCard(
                              title: 'Não foi possível gerar o plano',
                              detail: item.errorText,
                              originalText: item.originalText,
                            ),
                          final _TimeoutResultItem item => _failedCard(
                              title: 'Isso está demorando demais',
                              detail:
                                  'A geração não terminou a tempo. Você pode tentar de novo.',
                              originalText: item.originalText,
                            ),
                        },
                      ),
          ),
          _inputBar(),
        ]),
      ),
    );
  }

  Widget _header(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.cardAlt)),
      ),
      child: Row(children: [
        SquareIconButton(
            icon: Icons.arrow_back_ios_new, size: 38, onTap: () => context.pop()),
        const SizedBox(width: 12),
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.greenBgSoft,
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: AppColors.primaryDark),
          ),
          child: const Center(
            child: Icon(Icons.smart_toy_outlined, size: 21, color: AppColors.primary),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Text('FitTrack Coach',
                    style: TextStyle(fontSize: 15.5, fontWeight: FontWeight.w700)),
                SizedBox(width: 7),
                FtTag('IA', color: AppColors.primary),
              ]),
              const SizedBox(height: 2),
              Text(_sending ? 'gerando resposta...' : 'assistente de dieta e treino',
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _textBubble({required String text, required String time, required bool mine}) {
    return Column(
      crossAxisAlignment: mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          decoration: BoxDecoration(
            color: mine ? AppColors.primaryDark : AppColors.cardAlt,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(mine ? 16 : 4),
              bottomRight: Radius.circular(mine ? 4 : 16),
            ),
          ),
          child: Text(text,
              style: TextStyle(
                  fontSize: 14.5,
                  height: 1.45,
                  color: mine ? const Color(0xFFEAFFF1) : AppColors.textPrimary)),
        ),
        const SizedBox(height: 3),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(time,
              style: const TextStyle(fontSize: 10.5, color: AppColors.textDisabled)),
        ),
      ],
    );
  }

  Widget _pendingBubble(_PendingJobItem item) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .78),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
        decoration: const BoxDecoration(
          color: AppColors.cardAlt,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
            bottomLeft: Radius.circular(4),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const SizedBox(
            width: 14,
            height: 14,
            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primary),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(item.progressLabel,
                style: const TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
          ),
        ]),
      ),
    );
  }

  Widget _planCard(_PlanResultItem item) {
    final target = ref.watch(latestMetricProvider).valueOrNull;
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .86),
        child: FtCard(
          borderColor: AppColors.primaryDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: Text('Plano alimentar gerado',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                ),
              ]),
              const SizedBox(height: 10),
              for (final meal in item.plan.meals)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    const Icon(Icons.restaurant, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        meal.timeLabel.isEmpty ? meal.name : '${meal.name} · ${meal.timeLabel}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ]),
                ),
              const SizedBox(height: 8),
              _MacroTotalsRow(totals: item.totals, target: target),
              if (item.warnings.isNotEmpty) ...[
                const SizedBox(height: 10),
                for (final warning in item.warnings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(warning.message,
                              style: const TextStyle(
                                  fontSize: 11.5, color: AppColors.textMuted)),
                        ),
                      ],
                    ),
                  ),
              ],
              if ((item.criticSummary ?? '').isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.rate_review_outlined,
                          size: 14, color: AppColors.blueAccent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(item.criticSummary!,
                            style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              PillButton(
                label: 'Ver plano completo',
                height: 42,
                onPressed: () {
                  ref.invalidate(myPlanProvider);
                  context.go('/dieta');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _workoutCard(_WorkoutResultItem item) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .86),
        child: FtCard(
          borderColor: AppColors.primaryDark,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.check_circle, color: AppColors.primary, size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: Text('Treino gerado',
                      style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w800)),
                ),
              ]),
              const SizedBox(height: 10),
              for (final exercise in item.workout.exercises)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(children: [
                    const Icon(Icons.fitness_center, size: 14, color: AppColors.textMuted),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        '${exercise.exercise.name} · ${exercise.scheme}',
                        style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                      ),
                    ),
                  ]),
                ),
              if (item.summary != null) ...[
                const SizedBox(height: 8),
                _WorkoutSummaryRow(summary: item.summary!),
              ],
              if (item.warnings.isNotEmpty) ...[
                const SizedBox(height: 10),
                for (final warning in item.warnings)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: AppColors.warning),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(warning.message,
                              style: const TextStyle(
                                  fontSize: 11.5, color: AppColors.textMuted)),
                        ),
                      ],
                    ),
                  ),
              ],
              if ((item.criticSummary ?? '').isNotEmpty) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.cardAlt,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.rate_review_outlined,
                          size: 14, color: AppColors.blueAccent),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(item.criticSummary!,
                            style: const TextStyle(
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                                color: AppColors.textSecondary)),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 12),
              PillButton(
                label: 'Ver treino completo',
                height: 42,
                onPressed: () {
                  ref.invalidate(workoutsProvider);
                  context.go('/treinos');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _rejectedCard(_RejectedResultItem item) {
    final reasons = [
      ...item.issues.map((i) => i.message),
      ...item.errors,
    ];
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .86),
        child: FtCard(
          borderColor: AppColors.warning,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(children: [
                Icon(Icons.report_gmailerrorred, color: AppColors.warning, size: 18),
                SizedBox(width: 6),
                Expanded(
                  child: Text('O plano não passou nos critérios de qualidade',
                      style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
                ),
              ]),
              const SizedBox(height: 8),
              if (reasons.isEmpty)
                const Text(
                  'O sistema não conseguiu montar um plano dentro dos seus alvos '
                  'nutricionais desta vez.',
                  style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                )
              else
                for (final reason in reasons)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text('•  $reason',
                        style:
                            const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
                  ),
              const SizedBox(height: 10),
              PillButton(
                label: 'Tentar novamente',
                height: 42,
                outlined: true,
                onPressed: () => _send(item.originalText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _failedCard({
    required String title,
    required String detail,
    required String originalText,
  }) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .86),
        child: FtCard(
          borderColor: AppColors.error,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                const Icon(Icons.error_outline, color: AppColors.error, size: 18),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(title,
                      style:
                          const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
                ),
              ]),
              const SizedBox(height: 6),
              Text(detail,
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
              const SizedBox(height: 10),
              PillButton(
                label: 'Tentar novamente',
                height: 42,
                outlined: true,
                onPressed: () => _send(originalText),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.cardAlt)),
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _input,
            enabled: !_sending,
            onSubmitted: (_) => _send(),
            decoration: InputDecoration(
              hintText: _sending ? 'Aguarde a resposta...' : 'Mensagem...',
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(23),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(23),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        InkWell(
          onTap: _sending ? null : _send,
          borderRadius: BorderRadius.circular(23),
          child: Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: _sending ? AppColors.textDisabled : AppColors.primary,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.send, size: 20, color: AppColors.onPrimary),
          ),
        ),
      ]),
    );
  }
}

class _MacroTotalsRow extends StatelessWidget {
  const _MacroTotalsRow({required this.totals, required this.target});

  final Macros totals;
  final BodyMetric? target;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        _macro('Kcal', totals.kcal.round(), target?.calorieGoal),
        _macro('Proteína', totals.proteinG.round(), target?.proteinG, suffix: 'g'),
        _macro('Carbo', totals.carbsG.round(), target?.carbsG, suffix: 'g'),
        _macro('Gordura', totals.fatG.round(), target?.fatG, suffix: 'g'),
      ],
    );
  }

  Widget _macro(String label, int value, int? goal, {String suffix = ''}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
        Text(
          goal == null ? '$value$suffix' : '$value$suffix / $goal$suffix',
          style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _WorkoutSummaryRow extends StatelessWidget {
  const _WorkoutSummaryRow({required this.summary});

  final WorkoutPlanSummary summary;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 16,
      runSpacing: 6,
      children: [
        _item('Exercícios', '${summary.exerciseCount}'),
        _item('Séries totais', '${summary.totalSets}'),
        if (summary.muscleGroups.isNotEmpty)
          _item('Grupos', summary.muscleGroups.join(', ')),
      ],
    );
  }

  Widget _item(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 10.5, color: AppColors.textMuted)),
        Text(value, style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
      ],
    );
  }
}

class _EmptyChat extends StatelessWidget {
  const _EmptyChat();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.smart_toy_outlined, size: 40, color: AppColors.textMuted),
            SizedBox(height: 14),
            Text('Pergunte sobre sua dieta ou treino',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text('Ex.: "monta um plano alimentar pra hoje"',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary)),
          ],
        ),
      ),
    );
  }
}
