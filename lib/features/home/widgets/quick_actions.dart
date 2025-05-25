import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:workout_prediction_system_mobile/features/home/providers/home_provider.dart';
import 'package:workout_prediction_system_mobile/features/home/screens/water_balance_screen.dart';
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
    final quickActions = [
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
        title: 'Add Water',
        icon: Icons.water_drop,
        accentColor: const Color(0xFF3A86FF),
        onAction: (_) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const WaterBalanceScreen()),
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
      QuickActionItem(
        title: 'Notifications',
        icon: Icons.notifications_active,
        accentColor: const Color(0xFFFF6B6B),
        onAction: (_) {
          Navigator.of(context).pushNamed('/notification-settings');
        },
      ),
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.flash_on, color: const Color(0xFF00C896), size: 24.sp),
              SizedBox(width: 8.w),
              Text(
                'Quick Actions',
                style: TextUtils.kSubHeading(context).copyWith(
                  fontSize: 20.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16.w,
              mainAxisSpacing: 16.h,
              childAspectRatio: 1.6,
            ),
            itemCount: quickActions.length,
            itemBuilder: (context, index) {
              final action = quickActions[index];
              return _buildQuickActionCard(context, action, ref);
            },
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
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              action.accentColor.withOpacity(0.15),
              action.accentColor.withOpacity(0.05),
            ],
          ),
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: action.accentColor.withOpacity(0.15),
              blurRadius: 10,
              spreadRadius: 0,
              offset: const Offset(0, 2),
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
              padding: EdgeInsets.all(10.h),
              decoration: BoxDecoration(
                color: action.accentColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(action.icon, color: action.accentColor, size: 24.sp),
            ),
            SizedBox(height: 8.h),
            Text(
              action.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 14.sp,
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
