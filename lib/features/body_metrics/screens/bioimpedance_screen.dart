import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/widgets.dart';
import '../../../mock/mock_data.dart';

/// Nova medição de bioimpedância — inserção manual, salva com data (RN14:
/// peso e % gordura obrigatórios, demais opcionais).
class BioimpedanceScreen extends StatelessWidget {
  const BioimpedanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          children: [
            ScreenHeader(title: 'Bioimpedância', onBack: () => context.pop()),
            const Padding(
              padding: EdgeInsets.only(left: 54, top: 4),
              child: Text('Inserção manual · cada medição salva com data',
                  style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
            ),
            const SizedBox(height: 20),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2.1,
              children: [
                for (final f in MockData.bioFields)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.card,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.cardAlt),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(f.$1,
                            style: const TextStyle(
                                fontSize: 11.5, color: AppColors.textSecondary)),
                        const Spacer(),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Expanded(
                              child: TextField(
                                controller: TextEditingController(text: f.$2),
                                style: AppTheme.grotesk(fontSize: 22),
                                keyboardType: TextInputType.number,
                                decoration: const InputDecoration(
                                  isDense: true,
                                  filled: false,
                                  contentPadding: EdgeInsets.zero,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                ),
                              ),
                            ),
                            Text(f.$3,
                                style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: f.$4)),
                          ],
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 22),
            PillButton(
              label: 'Salvar medição de hoje',
              icon: Icons.save_outlined,
              color: AppColors.accent,
              foreground: AppColors.onAccent,
              height: 52,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Medição salva! Macros recalculados.')));
                context.pop();
              },
            ),
            const SizedBox(height: 26),
            const Text('Histórico',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            for (var i = 0; i < MockData.bioHistory.length; i++) ...[
              FtCard(
                radius: 14,
                borderColor: i == 0 ? AppColors.primaryDark : AppColors.cardAlt,
                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 13),
                child: Row(children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: i == 0 ? AppColors.greenBgSoft : AppColors.surfaceDeep,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Icon(Icons.calendar_today_outlined,
                        size: 17,
                        color: i == 0 ? AppColors.primary : AppColors.textMuted),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Text(MockData.bioHistory[i].$1,
                        style: const TextStyle(
                            fontSize: 13.5, fontWeight: FontWeight.w600)),
                  ),
                  GroteskText(MockData.bioHistory[i].$2,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.accent),
                  const SizedBox(width: 14),
                  GroteskText(MockData.bioHistory[i].$3,
                      fontSize: 13,
                      fontWeight: FontWeight.w400,
                      color: AppColors.blueAccent),
                ]),
              ),
              const SizedBox(height: 10),
            ],
          ],
        ),
      ),
    );
  }
}
