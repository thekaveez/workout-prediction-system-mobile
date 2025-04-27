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
      width: 165.w,
      padding: EdgeInsets.all(16.h),
      margin: EdgeInsets.only(right: 12.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: accentColor.withOpacity(0.15),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
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
              Container(
                padding: EdgeInsets.all(8.h),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(icon, color: accentColor, size: 20.sp),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.15),
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
            style: TextUtils.kSubHeading(context).copyWith(
              fontSize: 22.sp,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (subtitle != null)
            Text(
              subtitle!,
              style: TextStyle(color: Colors.white70, fontSize: 12.sp),
            ),
          SizedBox(height: 16.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Goal',
                    style: TextStyle(color: Colors.white60, fontSize: 11.sp),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(8.r),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: Colors.white.withOpacity(0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(accentColor),
                  minHeight: 8.h,
                ),
              ),
            ],
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
      height: 185.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        physics: const BouncingScrollPhysics(),
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
          // DailySummaryCard(
          //   title: 'Sitting Time',
          //   value: dailySummary.formattedSittingTime,
          //   subtitle: 'Max ${dailySummary.sittingGoalMinutes ~/ 60}h goal',
          //   progress: dailySummary.sittingProgress,
          //   icon: Icons.chair_outlined,
          //   accentColor: const Color(0xFFFFD166),
          // ),

          // Water Intake Card
          DailySummaryCard(
            title: 'Water',
            value: '1.2 L',
            subtitle: 'of 2.5 L goal',
            progress: 0.48,
            icon: Icons.water_drop_outlined,
            accentColor: const Color(0xFF3A86FF),
          ),
        ],
      ),
    );
  }
}
