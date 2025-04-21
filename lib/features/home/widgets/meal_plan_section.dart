import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workout_prediction_system_mobile/features/home/bloc/home_bloc.dart';
import 'package:workout_prediction_system_mobile/features/home/bloc/home_event.dart';
import 'package:workout_prediction_system_mobile/features/home/models/meal_plan.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MealPlanSection extends StatelessWidget {
  final MealPlan mealPlan;
  final bool isGeneratingNewPlan;

  const MealPlanSection({
    super.key,
    required this.mealPlan,
    required this.isGeneratingNewPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Text('🍽️ ', style: TextStyle(fontSize: 24)),
                  Text(
                    'Your Meal Plan',
                    style: TextUtils.kSubHeading(
                      context,
                    ).copyWith(fontSize: 20.sp, color: Colors.white),
                  ),
                ],
              ),
              ElevatedButton(
                onPressed:
                    isGeneratingNewPlan
                        ? null
                        : () => context.read<HomeBloc>().add(
                          const GenerateNewMealPlanEvent(),
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00C896),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 8.h,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child:
                    isGeneratingNewPlan
                        ? SizedBox(
                          width: 16.w,
                          height: 16.h,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.w,
                          ),
                        )
                        : Text(
                          'Generate New',
                          style: TextStyle(
                            fontSize: 12.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildMealItem(
            context,
            'Breakfast',
            mealPlan.breakfast,
            () => context.read<HomeBloc>().add(
              const SwapMealEvent(mealType: 'breakfast'),
            ),
          ),
          _buildMealItem(
            context,
            'Lunch',
            mealPlan.lunch,
            () => context.read<HomeBloc>().add(
              const SwapMealEvent(mealType: 'lunch'),
            ),
          ),
          _buildMealItem(
            context,
            'Dinner',
            mealPlan.dinner,
            () => context.read<HomeBloc>().add(
              const SwapMealEvent(mealType: 'dinner'),
            ),
          ),
          if (mealPlan.snacks.isNotEmpty) ...[
            SizedBox(height: 8.h),
            Text(
              'Snacks',
              style: TextUtils.kBodyText(context).copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 8.h),
            ...mealPlan.snacks.asMap().entries.map((entry) {
              return _buildMealItem(
                context,
                'Snack ${entry.key + 1}',
                entry.value,
                () => context.read<HomeBloc>().add(
                  SwapMealEvent(mealType: 'snack', snackIndex: entry.key),
                ),
                isSnack: true,
              );
            }).toList(),
          ],
        ],
      ),
    );
  }

  Widget _buildMealItem(
    BuildContext context,
    String title,
    Meal meal,
    VoidCallback onSwap, {
    bool isSnack = false,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(12.h),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isSnack) ...[
            Text(
              title,
              style: TextUtils.kBodyText(context).copyWith(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white70,
              ),
            ),
            SizedBox(height: 8.h),
          ],
          Row(
            children: [
              // Image placeholder (would be an actual image in a real app)
              Container(
                width: 60.w,
                height: 60.h,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  _getMealIcon(title),
                  color: Colors.white,
                  size: 28.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      meal.name,
                      style: TextUtils.kBodyText(context).copyWith(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      meal.description,
                      style: TextStyle(color: Colors.white60, fontSize: 12.sp),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        _buildMacroIndicator(
                          'Cal',
                          '${meal.calories}',
                          Colors.orange,
                        ),
                        SizedBox(width: 8.w),
                        _buildMacroIndicator(
                          'P',
                          '${meal.macros['protein']?.toInt() ?? 0}g',
                          Colors.red,
                        ),
                        SizedBox(width: 8.w),
                        _buildMacroIndicator(
                          'C',
                          '${meal.macros['carbs']?.toInt() ?? 0}g',
                          Colors.blue,
                        ),
                        SizedBox(width: 8.w),
                        _buildMacroIndicator(
                          'F',
                          '${meal.macros['fats']?.toInt() ?? 0}g',
                          Colors.yellow,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onSwap,
                icon: Icon(
                  Icons.refresh,
                  color: const Color(0xFF00C896),
                  size: 24.sp,
                ),
                tooltip: 'Swap meal',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroIndicator(String label, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(4.r),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            ': $value',
            style: TextStyle(color: Colors.white, fontSize: 10.sp),
          ),
        ],
      ),
    );
  }

  IconData _getMealIcon(String mealType) {
    switch (mealType.toLowerCase()) {
      case 'breakfast':
        return Icons.breakfast_dining;
      case 'lunch':
        return Icons.lunch_dining;
      case 'dinner':
        return Icons.dinner_dining;
      default:
        return Icons.restaurant;
    }
  }
}
