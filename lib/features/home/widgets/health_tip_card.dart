import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workout_prediction_system_mobile/features/home/models/health_tip.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';

class HealthTipCard extends StatelessWidget {
  final HealthTip tip;
  final VoidCallback? onNextTip;

  const HealthTipCard({Key? key, required this.tip, this.onNextTip})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFFC8C800).withOpacity(0.15),
            const Color(0xFFC8C800).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFC8C800).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
        border: Border.all(
          color: const Color(0xFFC8C800).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFC8C800).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconData(tip.icon),
                  color: const Color(0xFFC8C800),
                  size: 20.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  tip.title,
                  style: TextUtils.kBodyText(context).copyWith(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (onNextTip != null)
                Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFFC8C800).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    onPressed: onNextTip,
                    icon: const Icon(
                      Icons.arrow_forward_ios,
                      color: Color(0xFFC8C800),
                      size: 16,
                    ),
                    iconSize: 16.sp,
                    tooltip: 'Next tip',
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(12.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(
                color: const Color(0xFFC8C800).withOpacity(0.1),
                width: 1,
              ),
            ),
            child: Text(
              tip.description,
              style: TextStyle(
                color: Colors.white.withOpacity(0.85),
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'water_drop':
        return Icons.water_drop;
      case 'fitness_center':
        return Icons.fitness_center;
      case 'restaurant':
        return Icons.restaurant;
      default:
        return Icons.lightbulb_outline;
    }
  }
}

class HealthTipsSection extends StatefulWidget {
  final List<HealthTip> tips;

  const HealthTipsSection({Key? key, required this.tips}) : super(key: key);

  @override
  State<HealthTipsSection> createState() => _HealthTipsSectionState();
}

class _HealthTipsSectionState extends State<HealthTipsSection> {
  int _currentTipIndex = 0;

  void _nextTip() {
    setState(() {
      _currentTipIndex = (_currentTipIndex + 1) % widget.tips.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.tips.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: const Color(0xFFC8C800),
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Health Tips',
                style: TextUtils.kSubHeading(context).copyWith(
                  fontSize: 20.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        HealthTipCard(
          tip: widget.tips[_currentTipIndex],
          onNextTip: widget.tips.length > 1 ? _nextTip : null,
        ),
      ],
    );
  }
}
