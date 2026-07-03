import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/widgets/widgets.dart';
import '../../mock/mock_data.dart';

/// Chat aluno-profissional. Mock local; tempo real via WebSocket
/// (django-channels) entra na fase de integração.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _messages = [...MockData.chatMessages];
  final _input = TextEditingController();

  @override
  void dispose() {
    _input.dispose();
    super.dispose();
  }

  void _send() {
    final text = _input.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(MockChatMessage(
        mine: true,
        text: text,
        time: TimeOfDay.now().format(context),
      ));
      _input.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(children: [
          // header
          Container(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.cardAlt)),
            ),
            child: Row(children: [
              SquareIconButton(
                  icon: Icons.arrow_back_ios_new,
                  size: 38,
                  onTap: () => context.pop()),
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
                  child: Text('R',
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(children: [
                      Text('Rafael Souza',
                          style: TextStyle(
                              fontSize: 15.5, fontWeight: FontWeight.w700)),
                      SizedBox(width: 7),
                      FtTag('CREF', color: AppColors.primary),
                    ]),
                    const SizedBox(height: 2),
                    Row(children: [
                      Container(
                        width: 7,
                        height: 7,
                        decoration: const BoxDecoration(
                            color: AppColors.primary, shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 5),
                      const Text('Personal · online',
                          style: TextStyle(
                              fontSize: 12, color: AppColors.textSecondary)),
                    ]),
                  ],
                ),
              ),
            ]),
          ),

          // mensagens
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(18),
              itemCount: _messages.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final m = _messages[i];
                return Column(
                  crossAxisAlignment:
                      m.mine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.sizeOf(context).width * .78),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 11),
                      decoration: BoxDecoration(
                        color: m.mine ? AppColors.primaryDark : AppColors.cardAlt,
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(16),
                          topRight: const Radius.circular(16),
                          bottomLeft: Radius.circular(m.mine ? 16 : 4),
                          bottomRight: Radius.circular(m.mine ? 4 : 16),
                        ),
                      ),
                      child: Text(m.text,
                          style: TextStyle(
                              fontSize: 14.5,
                              height: 1.45,
                              color: m.mine
                                  ? const Color(0xFFEAFFF1)
                                  : AppColors.textPrimary)),
                    ),
                    const SizedBox(height: 3),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: Text(m.time,
                          style: const TextStyle(
                              fontSize: 10.5, color: AppColors.textDisabled)),
                    ),
                  ],
                );
              },
            ),
          ),

          // input
          Container(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.cardAlt)),
            ),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _input,
                  onSubmitted: (_) => _send(),
                  decoration: InputDecoration(
                    hintText: 'Mensagem...',
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
                onTap: _send,
                borderRadius: BorderRadius.circular(23),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                      color: AppColors.primary, shape: BoxShape.circle),
                  child:
                      const Icon(Icons.send, size: 20, color: AppColors.onPrimary),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
