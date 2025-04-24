import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_prediction_system_mobile/features/home/providers/home_provider.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';

class QuickActionItem {
  final String title;
  final IconData icon;
  final Color accentColor;
  final void Function(WidgetRef ref) onAction;

  QuickActionItem({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.onAction,
  });
}

class QuickActions extends ConsumerWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<QuickActionItem> actions = [
      QuickActionItem(
        title: 'Log Meal',
        icon: Icons.restaurant_menu,
        accentColor: const Color(0xFF00C896),
        onAction: (_) {
          // In a real app, this would navigate to a meal logging screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Log Meal feature coming soon!')),
          );
        },
      ),
      QuickActionItem(
        title: 'Add Activity',
        icon: Icons.fitness_center,
        accentColor: const Color(0xFF4ECDC4),
        onAction: (_) {
          // In a real app, this would navigate to an activity logging screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add Activity feature coming soon!')),
          );
        },
      ),
      QuickActionItem(
        title: 'View Progress',
        icon: Icons.bar_chart,
        accentColor: const Color(0xFFFF6B6B),
        onAction: (_) {
          // In a real app, this would navigate to a progress tracking screen
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('View Progress feature coming soon!')),
          );
        },
      ),
      QuickActionItem(
        title: 'AI Suggestion',
        icon: Icons.lightbulb_outline,
        accentColor: const Color(0xFFFFD166),
        onAction: (ref) => ref.read(homeProvider.notifier).refreshData(),
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Quick Actions',
            style: TextUtils.kSubHeading(
              context,
            ).copyWith(fontSize: 20.sp, color: Colors.white),
          ),
          SizedBox(height: 16.h),
          SizedBox(
            height: 120.h,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: actions.length,
              itemBuilder: (context, index) {
                final action = actions[index];
                return _buildQuickActionCard(context, action, ref);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    BuildContext context,
    QuickActionItem action,
    WidgetRef ref,
  ) {
    return GestureDetector(
      onTap: () => action.onAction(ref),
      child: Container(
        width: 110.w,
        margin: EdgeInsets.only(right: 16.w),
        padding: EdgeInsets.all(16.h),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: action.accentColor.withOpacity(0.2),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
          border: Border.all(
            color: action.accentColor.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(7.h),
              decoration: BoxDecoration(
                color: action.accentColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, color: action.accentColor, size: 22.sp),
            ),
            SizedBox(height: 6.h),
            Text(
              action.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
