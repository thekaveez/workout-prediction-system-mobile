import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:workout_prediction_system_mobile/features/meal_prediction/models/meal_plan.dart';
import 'package:workout_prediction_system_mobile/features/meal_prediction/providers/meal_prediction_provider.dart';
import 'package:workout_prediction_system_mobile/features/user_setup/providers/user_setup_provider.dart';
import 'package:workout_prediction_system_mobile/features/user_setup/screens/user_setup_screen.dart';
import 'package:workout_prediction_system_mobile/utils/helpers.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';
import 'package:workout_prediction_system_mobile/widgets/custom_button.dart';

class MealPredictionScreen extends ConsumerStatefulWidget {
  const MealPredictionScreen({super.key});

  @override
  ConsumerState<MealPredictionScreen> createState() =>
      _MealPredictionScreenState();
}

class _MealPredictionScreenState extends ConsumerState<MealPredictionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);

    // Load user setup data
    Future.microtask(() {
      // Check if user has completed setup
      ref.read(userSetupProvider.notifier).loadUserSetupData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userSetupState = ref.watch(userSetupProvider);
    final mealPredictionState = ref.watch(mealPredictionProvider);

    // If user has not completed setup, show setup prompt
    if (!userSetupState.hasCompletedSetup) {
      return _buildSetupPrompt(context);
    }

    // If initial state, trigger prediction
    if (mealPredictionState.status == MealPredictionStatus.initial &&
        userSetupState.setupData != null) {
      Future.microtask(() {
        ref.read(mealPredictionProvider.notifier).getMealPrediction();
      });
    }

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'AI Meal Plan',
          style: TextUtils.kSubHeading(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        bottom:
            mealPredictionState.status == MealPredictionStatus.loaded
                ? TabBar(
                  controller: _tabController,
                  indicatorColor: Theme.of(context).colorScheme.secondary,
                  labelColor: Theme.of(context).colorScheme.secondary,
                  unselectedLabelColor: Colors.grey,
                  tabs: const [
                    Tab(text: 'Breakfast'),
                    Tab(text: 'Lunch'),
                    Tab(text: 'Dinner'),
                  ],
                )
                : null,
      ),
      body: _buildBody(mealPredictionState, userSetupState),
    );
  }

  Widget _buildBody(MealPredictionState mealState, UserSetupState userState) {
    switch (mealState.status) {
      case MealPredictionStatus.loading:
        return _buildLoadingState();
      case MealPredictionStatus.loaded:
        return _buildLoadedState(mealState, userState);
      case MealPredictionStatus.error:
        return _buildErrorState(mealState.errorMessage);
      default:
        return const Center(child: CircularProgressIndicator());
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: Theme.of(context).colorScheme.secondary,
          ),
          SizedBox(height: 24.h),
          Text(
            'Generating your personalized meal plan...',
            style: TextUtils.kSubHeading(context),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(
    MealPredictionState mealState,
    UserSetupState userState,
  ) {
    if (mealState.mealPlan == null) {
      return _buildErrorState('No meal plan available. Please try again.');
    }

    return Column(
      children: [
        // Health metrics summary
        if (userState.setupData != null) _buildHealthMetrics(userState),

        // Meal tabs
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildMealList(mealState.mealPlan!.breakfast, 'breakfast'),
              _buildMealList(mealState.mealPlan!.lunch, 'lunch'),
              _buildMealList(mealState.mealPlan!.dinner, 'dinner'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: EdgeInsets.all(24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Theme.of(context).colorScheme.error,
              size: 64.sp,
            ),
            SizedBox(height: 24.h),
            Text(
              errorMessage ?? 'An error occurred. Please try again.',
              style: TextUtils.kSubHeading(context),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 32.h),
            CustomButton(
              text: 'Try Again',
              onPressed: () {
                ref.read(mealPredictionProvider.notifier).getMealPrediction();
              },
              height: 48.h,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSetupPrompt(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'AI Meal Plan',
          style: TextUtils.kSubHeading(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                color: Theme.of(context).colorScheme.secondary,
                size: 80.sp,
              ),
              SizedBox(height: 24.h),
              Text(
                'Complete Your Profile',
                style: TextUtils.kHeading(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'To generate personalized meal recommendations, we need some information about you.',
                style: TextUtils.kBodyText(context),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              CustomButton(
                text: 'Setup Profile',
                onPressed: () {
                  Navigator.push(
                    context,
                    Helpers.routeNavigation(context, const UserSetupScreen()),
                  );
                },
                height: 48.h,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHealthMetrics(UserSetupState userState) {
    final userData = userState.setupData!;

    // Get BMI category name
    String bmiCategory = 'Normal';
    if (userData.bmiTag == 0) {
      bmiCategory = 'Underweight';
    } else if (userData.bmiTag == 1) {
      bmiCategory = 'Normal';
    } else if (userData.bmiTag == 2) {
      bmiCategory = 'Overweight';
    } else if (userData.bmiTag == 3) {
      bmiCategory = 'Obese';
    }

    // Get BMI color
    Color bmiColor = Colors.green;
    if (userData.bmiTag == 0) {
      bmiColor = Colors.blue;
    } else if (userData.bmiTag == 1) {
      bmiColor = Colors.green;
    } else if (userData.bmiTag == 2) {
      bmiColor = Colors.orange;
    } else if (userData.bmiTag == 3) {
      bmiColor = Colors.red;
    }

    return Container(
      padding: EdgeInsets.all(16.w),
      margin: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(
          color: Theme.of(context).colorScheme.secondary.withOpacity(0.5),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Health Metrics',
            style: TextUtils.kSubHeading(context).copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(
                'BMI',
                userData.bmi.toStringAsFixed(1),
                bmiColor,
                subtitle: bmiCategory,
              ),
              _buildMetricItem(
                'BMR',
                '${userData.bmr.toInt()} kcal',
                Theme.of(context).colorScheme.secondary,
              ),
              _buildMetricItem(
                'Daily Calories',
                '${userData.caloriesNeeded.toInt()} kcal',
                Theme.of(context).colorScheme.secondary,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(
    String label,
    String value,
    Color color, {
    String? subtitle,
  }) {
    return Column(
      children: [
        Text(
          label,
          style: TextUtils.kBodyText(
            context,
          ).copyWith(color: Colors.grey[400], fontSize: 14.sp),
        ),
        SizedBox(height: 4.h),
        Text(
          value,
          style: TextUtils.kSubHeading(context).copyWith(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 18.sp,
          ),
        ),
        if (subtitle != null) ...[
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: TextUtils.kBodyText(
              context,
            ).copyWith(color: color, fontSize: 12.sp),
          ),
        ],
      ],
    );
  }

  Widget _buildMealList(List<MealItem> meals, String mealType) {
    if (meals.isEmpty) {
      return Center(
        child: Text(
          'No meals available for this category',
          style: TextUtils.kBodyText(context),
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.all(16.w),
      itemCount: meals.length,
      itemBuilder: (context, index) {
        final meal = meals[index];
        return _buildMealCard(meal);
      },
    );
  }

  Widget _buildMealCard(MealItem meal) {
    return Card(
      margin: EdgeInsets.only(bottom: 24.h),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Meal image with calorie overlay
          ClipRRect(
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(16.r),
              topRight: Radius.circular(16.r),
            ),
            child: Stack(
              children: [
                // Meal image(s) - Display image carousel if multiple images exist
                Container(
                  height: 200.h,
                  width: double.infinity,
                  color: Colors.grey[800],
                  child:
                      meal.images.isNotEmpty
                          ? _buildImageCarousel(meal.images)
                          : Icon(
                            Icons.restaurant,
                            size: 64.sp,
                            color: Colors.grey[600],
                          ),
                ),
                // Calorie badge
                Positioned(
                  top: 16.h,
                  right: 16.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      '${meal.calories} kcal',
                      style: TextUtils.kBodyText(context).copyWith(
                        color: Theme.of(context).colorScheme.surface,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Meal details
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Meal name
                Text(
                  meal.name,
                  style: TextUtils.kSubHeading(
                    context,
                  ).copyWith(fontSize: 20.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16.h),

                // Benefits section
                if (meal.benefits.isNotEmpty) ...[
                  Text(
                    'Benefits',
                    style: TextUtils.kSubHeading(
                      context,
                    ).copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                  SizedBox(height: 8.h),
                  ...meal.benefits.map((benefit) => _buildBulletPoint(benefit)),
                  SizedBox(height: 16.h),
                ],

                // Ingredients section
                if (meal.ingredients.isNotEmpty) ...[
                  Text(
                    'Ingredients',
                    style: TextUtils.kSubHeading(
                      context,
                    ).copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                  SizedBox(height: 8.h),
                  ...meal.ingredients.map(
                    (ingredient) => _buildBulletPoint(ingredient),
                  ),
                  SizedBox(height: 16.h),
                ],

                // Preparation section
                if (meal.instructions.isNotEmpty) ...[
                  Text(
                    'Preparation',
                    style: TextUtils.kSubHeading(
                      context,
                    ).copyWith(color: Theme.of(context).colorScheme.secondary),
                  ),
                  SizedBox(height: 8.h),
                  ...meal.instructions.map(
                    (instructions) => _buildBulletPoint(instructions),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // New method to build an image carousel
  Widget _buildImageCarousel(List<String> images) {
    // Filter out invalid image URLs
    final validImages =
        images
            .where(
              (url) =>
                  url.isNotEmpty &&
                  (url.startsWith('http://') || url.startsWith('https://')),
            )
            .toList();

    if (validImages.isEmpty) {
      return Center(
        child: Icon(Icons.restaurant, size: 64.sp, color: Colors.grey[600]),
      );
    }

    if (validImages.length == 1) {
      // If there's only one image, just display it with caching and error handling
      return CachedNetworkImage(
        imageUrl: validImages.first,
        fit: BoxFit.cover,
        placeholder:
            (context, url) => Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
        errorWidget:
            (context, url, error) => Center(
              child: Icon(
                Icons.restaurant,
                size: 64.sp,
                color: Colors.grey[600],
              ),
            ),
      );
    } else {
      // For multiple images, create a PageView for swiping
      return PageView.builder(
        itemCount: validImages.length,
        itemBuilder: (context, index) {
          return CachedNetworkImage(
            imageUrl: validImages[index],
            fit: BoxFit.cover,
            placeholder:
                (context, url) => Center(
                  child: CircularProgressIndicator(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
            errorWidget:
                (context, url, error) => Center(
                  child: Icon(
                    Icons.restaurant,
                    size: 64.sp,
                    color: Colors.grey[600],
                  ),
                ),
          );
        },
      );
    }
  }

  Widget _buildBulletPoint(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: TextUtils.kBodyText(context).copyWith(
              fontSize: 18.sp,
              color: Theme.of(context).colorScheme.secondary,
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(child: Text(text, style: TextUtils.kBodyText(context))),
        ],
      ),
    );
  }
}
