import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:workout_prediction_system_mobile/features/home/bloc/home_bloc.dart';
import 'package:workout_prediction_system_mobile/features/home/bloc/home_event.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';

class QuickActionItem {
  final String title;
  final IconData icon;
  final Color accentColor;
  final HomeEvent event;

  QuickActionItem({
    required this.title,
    required this.icon,
    required this.accentColor,
    required this.event,
  });
}

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    final List<QuickActionItem> actions = [
      QuickActionItem(
        title: 'Log Meal',
        icon: Icons.restaurant_menu,
        accentColor: const Color(0xFF00C896),
        event: const LogMealEvent(),
      ),
      QuickActionItem(
        title: 'Add Activity',
        icon: Icons.fitness_center,
        accentColor: const Color(0xFF4ECDC4),
        event: const AddActivityEvent(),
      ),
      QuickActionItem(
        title: 'View Progress',
        icon: Icons.bar_chart,
        accentColor: const Color(0xFFFF6B6B),
        event: const ViewProgressEvent(),
      ),
      QuickActionItem(
        title: 'AI Suggestion',
        icon: Icons.lightbulb_outline,
        accentColor: const Color(0xFFFFD166),
        event: const HomeRefreshDataEvent(),
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
                return _buildQuickActionCard(context, action);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(BuildContext context, QuickActionItem action) {
    return GestureDetector(
      onTap: () => context.read<HomeBloc>().add(action.event),
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
