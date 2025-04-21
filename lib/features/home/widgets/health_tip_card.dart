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
      padding: EdgeInsets.all(16.h),
      decoration: BoxDecoration(
        color: const Color(0xFF00C896).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00C896).withOpacity(0.1),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
        border: Border.all(
          color: const Color(0xFF00C896).withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFF00C896).withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Text(tip.icon, style: TextStyle(fontSize: 16.sp)),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Text(
                  tip.title,
                  style: TextUtils.kBodyText(context).copyWith(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
              if (onNextTip != null)
                IconButton(
                  onPressed: onNextTip,
                  icon: const Icon(
                    Icons.arrow_forward_ios,
                    color: Color(0xFF00C896),
                    size: 16,
                  ),
                  tooltip: 'Next tip',
                ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            tip.description,
            style: TextStyle(color: Colors.white70, fontSize: 14.sp),
          ),
        ],
      ),
    );
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
          child: Text(
            'Health Tips',
            style: TextUtils.kSubHeading(
              context,
            ).copyWith(fontSize: 20.sp, color: Colors.white),
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
