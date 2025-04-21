import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workout_prediction_system_mobile/features/home/models/daily_summary.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';

class DailySummaryCard extends StatelessWidget {
  final String title;
  final String value;
  final String? subtitle;
  final double progress;
  final IconData icon;
  final Color accentColor;

  const DailySummaryCard({
    super.key,
    required this.title,
    required this.value,
    this.subtitle,
    required this.progress,
    required this.icon,
    required this.accentColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 160.w,
      padding: EdgeInsets.all(16.h),
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(color: accentColor.withOpacity(0.3), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: accentColor, size: 24.sp),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  title,
                  style: TextStyle(
                    color: accentColor,
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Text(
            value,
            style: TextUtils.kSubHeading(
              context,
            ).copyWith(fontSize: 20.sp, color: Colors.white),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(color: Colors.white70, fontSize: 12.sp),
            ),
          SizedBox(height: 12.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: LinearProgressIndicator(
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: AlwaysStoppedAnimation<Color>(accentColor),
              minHeight: 8.h,
            ),
          ),
        ],
      ),
    );
  }
}

class DailySummaryList extends StatelessWidget {
  final DailySummary dailySummary;

  const DailySummaryList({super.key, required this.dailySummary});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 170.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        children: [
          // Calories Card
          DailySummaryCard(
            title: 'Calories',
            value: '${dailySummary.caloriesConsumed} kcal',
            subtitle: 'of ${dailySummary.caloriesGoal} kcal',
            progress: dailySummary.caloriesProgress,
            icon: Icons.local_fire_department_outlined,
            accentColor: const Color(0xFFFF6B6B),
          ),

          // Steps Card
          DailySummaryCard(
            title: 'Steps',
            value: '${dailySummary.stepsTaken}',
            subtitle: 'of ${dailySummary.stepsGoal} steps',
            progress: dailySummary.stepsProgress,
            icon: Icons.directions_walk_outlined,
            accentColor: const Color(0xFF4ECDC4),
          ),

          // Sitting Time Card
          DailySummaryCard(
            title: 'Sitting Time',
            value: dailySummary.formattedSittingTime,
            subtitle: 'Max ${dailySummary.sittingGoalMinutes ~/ 60}h goal',
            progress: dailySummary.sittingProgress,
            icon: Icons.chair_outlined,
            accentColor: const Color(0xFFFFD166),
          ),
        ],
      ),
    );
  }
}
