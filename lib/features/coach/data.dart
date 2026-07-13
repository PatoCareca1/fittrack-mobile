import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../auth/providers.dart';
import '../diet/data.dart';

/// Issue reportada pelo agente crítico (`severity`: "blocker" ou "warning").
class CoachIssue {
  const CoachIssue({required this.severity, required this.message, this.mealOrder});

  final String severity;
  final String message;
  final int? mealOrder;

  bool get isBlocker => severity == 'blocker';

  factory CoachIssue.fromJson(Map<String, dynamic> json) => CoachIssue(
        severity: json['severity'] as String? ?? 'warning',
        message: json['message'] as String? ?? '',
        mealOrder: json['meal_order'] as int?,
      );
}

/// Resposta de `POST /coach/messages/`. Ou vem com `jobId` (202 — pedido de
/// dieta, assíncrono) ou com `message` (200 — resposta textual imediata).
class SendMessageResult {
  const SendMessageResult({
    this.jobId,
    required this.conversationId,
    required this.intent,
    this.message,
  });

  final int? jobId;
  final int conversationId;
  final String intent;
  final String? message;

  bool get isJob => jobId != null;

  factory SendMessageResult.fromJson(Map<String, dynamic> json) => SendMessageResult(
        jobId: json['job_id'] as int?,
        conversationId: json['conversation_id'] as int,
        intent: json['intent'] as String,
        message: json['message'] as String?,
      );
}

/// Resultado de `GET /coach/jobs/{id}/`. `mealPlan` só vem preenchido quando
/// o plano foi aprovado e persistido — `succeeded` sem `mealPlan` é uma
/// reprovação normal do pipeline, não um erro de sistema.
class CoachJobResult {
  const CoachJobResult({
    required this.id,
    required this.status,
    required this.error,
    this.mealPlan,
    this.totals,
    this.criticSummary,
    this.issues = const [],
    this.errors = const [],
  });

  final int id;
  final String status; // pending | running | succeeded | failed
  final String error;
  final MealPlanModel? mealPlan;
  final Macros? totals;
  final String? criticSummary;
  final List<CoachIssue> issues;
  final List<String> errors;

  bool get isPending => status == 'pending' || status == 'running';
  bool get isFailed => status == 'failed';
  bool get isApproved => status == 'succeeded' && mealPlan != null;
  bool get isRejected => status == 'succeeded' && mealPlan == null;

  factory CoachJobResult.fromJson(Map<String, dynamic> json) => CoachJobResult(
        id: json['id'] as int,
        status: json['status'] as String,
        error: json['error'] as String? ?? '',
        mealPlan: json['meal_plan'] == null
            ? null
            : MealPlanModel.fromJson(json['meal_plan'] as Map<String, dynamic>),
        totals: json['totals'] == null
            ? null
            : Macros.fromJson(json['totals'] as Map<String, dynamic>),
        criticSummary: json['critic_summary'] as String?,
        issues: (json['issues'] as List? ?? [])
            .map((i) => CoachIssue.fromJson(i as Map<String, dynamic>))
            .toList(),
        // "errors" não é exposto por toda versão do backend — parse
        // defensivo, nunca inventa conteúdo se o campo não vier.
        errors: (json['errors'] as List? ?? []).map((e) => '$e').toList(),
      );
}

class CoachMessageModel {
  const CoachMessageModel({
    required this.role,
    required this.content,
    this.agent,
    required this.createdAt,
  });

  final String role; // user | assistant
  final String content;
  final String? agent;
  final DateTime createdAt;

  bool get isMine => role == 'user';

  factory CoachMessageModel.fromJson(Map<String, dynamic> json) => CoachMessageModel(
        role: json['role'] as String,
        content: json['content'] as String,
        agent: json['agent'] as String?,
        createdAt: DateTime.parse(json['created_at'] as String),
      );
}

/// Persiste o id da conversa ativa com o Coach — mesmo padrão de storage do
/// `TokenStorage` (FlutterSecureStorage) — para retomar o histórico ao
/// reabrir o chat.
class CoachStorage {
  CoachStorage([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  static const _conversationIdKey = 'coach_conversation_id';

  Future<int?> get conversationId async {
    final raw = await _storage.read(key: _conversationIdKey);
    return raw == null ? null : int.tryParse(raw);
  }

  Future<void> saveConversationId(int id) =>
      _storage.write(key: _conversationIdKey, value: '$id');

  Future<void> clear() => _storage.delete(key: _conversationIdKey);
}

final coachStorageProvider = Provider<CoachStorage>((ref) => CoachStorage());

/// Cliente para os 3 endpoints do Coach. Sem lógica de UI aqui.
class CoachRepository {
  CoachRepository(this._ref);

  final Ref _ref;

  Future<SendMessageResult> sendMessage(String message, {int? conversationId}) async {
    final res = await _ref.read(apiClientProvider).dio.post('/coach/messages/', data: {
      'message': message,
      'conversation_id': conversationId,
    });
    return SendMessageResult.fromJson(res.data as Map<String, dynamic>);
  }

  Future<CoachJobResult> fetchJob(int jobId) async {
    final res = await _ref.read(apiClientProvider).dio.get('/coach/jobs/$jobId/');
    return CoachJobResult.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<CoachMessageModel>> fetchMessages(int conversationId) async {
    final res = await _ref
        .read(apiClientProvider)
        .dio
        .get('/coach/conversations/$conversationId/messages/');
    return (res.data as List)
        .map((m) => CoachMessageModel.fromJson(m as Map<String, dynamic>))
        .toList();
  }
}

final coachRepositoryProvider = Provider((ref) => CoachRepository(ref));
