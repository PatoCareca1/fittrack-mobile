import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/widgets.dart';
import '../../../mock/mock_data.dart';

/// Templates públicos importados viram cópia independente (RN11).
class ExploreTemplatesScreen extends StatelessWidget {
  const ExploreTemplatesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          ScreenHeader(title: 'Explorar Rotinas', onBack: () => context.pop()),
          const SizedBox(height: 18),
          const Text('Templates prontos para importar e adaptar',
              style: TextStyle(fontSize: 13.5, color: AppColors.textSecondary)),
          const SizedBox(height: 18),
          for (final t in MockData.templates) ...[
            FtCard(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
              child: Row(children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: t.$4.withValues(alpha: .12),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: Icon(Icons.fitness_center, size: 22, color: t.$4),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(t.$1,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                      const SizedBox(height: 3),
                      Text('${t.$2} · ${t.$3}',
                          style: const TextStyle(
                              fontSize: 12.5, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
                OutlinedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text('"${t.$1}" importado para seus treinos')));
                    context.pop();
                  },
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.primaryDark),
                    backgroundColor: AppColors.greenBgSoft,
                    foregroundColor: AppColors.primary,
                    textStyle:
                        const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(17)),
                  ),
                  child: const Text('Importar'),
                ),
              ]),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
