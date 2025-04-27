import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:workout_prediction_system_mobile/features/home/screens/home_screen.dart';
import 'package:workout_prediction_system_mobile/features/user_setup/providers/user_setup_provider.dart';
import 'package:workout_prediction_system_mobile/utils/helpers.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';
import 'package:workout_prediction_system_mobile/widgets/custom_button.dart';

class UserSetupScreen extends ConsumerStatefulWidget {
  const UserSetupScreen({super.key});

  @override
  ConsumerState<UserSetupScreen> createState() => _UserSetupScreenState();
}

class _UserSetupScreenState extends ConsumerState<UserSetupScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Form controllers
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  String _gender = 'male'; // Default value
  String _activityLevel = 'Moderately Active'; // Default value

  // Form keys for validation
  final _ageFormKey = GlobalKey<FormState>();
  final _weightFormKey = GlobalKey<FormState>();
  final _heightFormKey = GlobalKey<FormState>();

  final List<String> activityLevels = [
    'Sedentary',
    'Lightly Active',
    'Moderately Active',
    'Very Active',
    'Extra Active',
  ];

  @override
  void dispose() {
    _pageController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  void _nextPage() {
    // Validate current page before proceeding
    if (_currentPage == 0 && !_ageFormKey.currentState!.validate()) return;
    if (_currentPage == 1 && !_weightFormKey.currentState!.validate()) return;
    if (_currentPage == 2 && !_heightFormKey.currentState!.validate()) return;

    if (_currentPage < 4) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitData();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _submitData() async {
    // Get values from controllers
    final age = int.parse(_ageController.text);
    final weight = double.parse(_weightController.text);
    final height = double.parse(_heightController.text);

    // Save data using the provider
    await ref
        .read(userSetupProvider.notifier)
        .saveUserSetupData(
          age: age,
          weight: weight,
          height: height,
          gender: _gender,
          activityLevel: _activityLevel,
        );

    // Navigate to home screen after data is saved
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        Helpers.routeNavigation(context, const HomeScreen()),
        (route) => false,
      );
    }
  }

  void _skipSetup() {
    Navigator.of(context).pushAndRemoveUntil(
      Helpers.routeNavigation(context, const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final setupState = ref.watch(userSetupProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Complete Your Profile',
          style: TextUtils.kSubHeading(
            context,
          ).copyWith(color: Theme.of(context).colorScheme.primary),
        ),
        backgroundColor: Theme.of(context).colorScheme.surface,
        elevation: 0,
        leading:
            _currentPage > 0
                ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: _previousPage,
                )
                : null,
        actions: [
          TextButton(
            onPressed: _skipSetup,
            child: Text(
              'Skip',
              style: TextUtils.kBodyText(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.secondary),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
              child: LinearProgressIndicator(
                value: (_currentPage + 1) / 5,
                backgroundColor: Colors.grey[800],
                valueColor: AlwaysStoppedAnimation<Color>(
                  Theme.of(context).colorScheme.secondary,
                ),
                minHeight: 8.h,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                children: [
                  _buildAgeStep(),
                  _buildWeightStep(),
                  _buildHeightStep(),
                  _buildGenderStep(),
                  _buildActivityLevelStep(),
                ],
              ),
            ),

            // Error message if any
            if (setupState.errorMessage != null)
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Container(
                  constraints: BoxConstraints(maxHeight: 80.h),
                  child: SingleChildScrollView(
                    child: Text(
                      setupState.errorMessage!,
                      style: TextUtils.kBodyText(
                        context,
                      ).copyWith(color: Theme.of(context).colorScheme.error),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),

            // Navigation buttons
            Padding(
              padding: EdgeInsets.all(24.w),
              child: CustomButton(
                text: _currentPage == 4 ? 'Finish' : 'Next',
                onPressed: setupState.isLoading ? null : _nextPage,
                height: 56.h,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAgeStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Form(
        key: _ageFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.h),
            Text(
              'How old are you?',
              style: TextUtils.kHeading(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              'This helps us customize your fitness and nutrition recommendations.',
              style: TextUtils.kBodyText(
                context,
              ).copyWith(color: Colors.grey[400]),
            ),
            SizedBox(height: 48.h),
            TextFormField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              style: TextUtils.kSubHeading(context),
              decoration: InputDecoration(
                labelText: 'Age',
                labelStyle: TextStyle(color: Colors.grey[400]),
                suffixText: 'years',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your age';
                }
                final age = int.tryParse(value);
                if (age == null || age <= 0 || age > 120) {
                  return 'Please enter a valid age (1-120)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeightStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Form(
        key: _weightFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.h),
            Text(
              'What is your weight?',
              style: TextUtils.kHeading(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              'Your weight helps us calculate calorie needs and exercise recommendations.',
              style: TextUtils.kBodyText(
                context,
              ).copyWith(color: Colors.grey[400]),
            ),
            SizedBox(height: 48.h),
            TextFormField(
              controller: _weightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextUtils.kSubHeading(context),
              decoration: InputDecoration(
                labelText: 'Weight',
                labelStyle: TextStyle(color: Colors.grey[400]),
                suffixText: 'kg',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your weight';
                }
                final weight = double.tryParse(value);
                if (weight == null || weight <= 0 || weight > 500) {
                  return 'Please enter a valid weight (1-500 kg)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeightStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Form(
        key: _heightFormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 32.h),
            Text(
              'What is your height?',
              style: TextUtils.kHeading(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.primary),
            ),
            SizedBox(height: 16.h),
            Text(
              'Your height helps us calculate your BMI and personalize your plan.',
              style: TextUtils.kBodyText(
                context,
              ).copyWith(color: Colors.grey[400]),
            ),
            SizedBox(height: 48.h),
            TextFormField(
              controller: _heightController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              style: TextUtils.kSubHeading(context),
              decoration: InputDecoration(
                labelText: 'Height',
                labelStyle: TextStyle(color: Colors.grey[400]),
                suffixText: 'cm',
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.secondary.withOpacity(0.5),
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.secondary,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                errorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.error,
                    width: 2,
                  ),
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter your height';
                }
                final height = double.tryParse(value);
                if (height == null || height <= 0 || height > 300) {
                  return 'Please enter a valid height (1-300 cm)';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGenderStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32.h),
          Text(
            'What is your gender?',
            style: TextUtils.kHeading(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            'This helps us calculate your BMR (Basal Metabolic Rate) more accurately.',
            style: TextUtils.kBodyText(
              context,
            ).copyWith(color: Colors.grey[400]),
          ),
          SizedBox(height: 48.h),
          _buildGenderSelectTile('male', 'Male'),
          SizedBox(height: 16.h),
          _buildGenderSelectTile('female', 'Female'),
        ],
      ),
    );
  }

  Widget _buildGenderSelectTile(String value, String title) {
    final bool isSelected = _gender == value;

    return InkWell(
      onTap: () {
        setState(() {
          _gender = value;
        });
      },
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(
            color:
                isSelected
                    ? Theme.of(context).colorScheme.secondary
                    : Colors.grey[700]!,
            width: isSelected ? 2 : 1,
          ),
          color:
              isSelected
                  ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                  : Colors.transparent,
        ),
        child: Row(
          children: [
            Container(
              width: 24.w,
              height: 24.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color:
                      isSelected
                          ? Theme.of(context).colorScheme.secondary
                          : Colors.grey[600]!,
                  width: 2,
                ),
              ),
              child:
                  isSelected
                      ? Center(
                        child: Container(
                          width: 12.w,
                          height: 12.w,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      )
                      : null,
            ),
            SizedBox(width: 16.w),
            Text(
              title,
              style: TextUtils.kSubHeading(
                context,
              ).copyWith(color: Theme.of(context).colorScheme.primary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityLevelStep() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32.h),
          Text(
            'What is your activity level?',
            style: TextUtils.kHeading(
              context,
            ).copyWith(color: Theme.of(context).colorScheme.primary),
          ),
          SizedBox(height: 16.h),
          Text(
            'This helps us calculate your daily calorie needs and exercise recommendations.',
            style: TextUtils.kBodyText(
              context,
            ).copyWith(color: Colors.grey[400]),
          ),
          SizedBox(height: 32.h),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children:
                    activityLevels
                        .map((level) => _buildActivityLevelTile(level))
                        .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelTile(String level) {
    final bool isSelected = _activityLevel == level;

    return Padding(
      padding: EdgeInsets.only(bottom: 16.h),
      child: InkWell(
        onTap: () {
          setState(() {
            _activityLevel = level;
          });
        },
        borderRadius: BorderRadius.circular(12.r),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color:
                  isSelected
                      ? Theme.of(context).colorScheme.secondary
                      : Colors.grey[700]!,
              width: isSelected ? 2 : 1,
            ),
            color:
                isSelected
                    ? Theme.of(context).colorScheme.secondary.withOpacity(0.1)
                    : Colors.transparent,
          ),
          child: Row(
            children: [
              Container(
                width: 24.w,
                height: 24.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color:
                        isSelected
                            ? Theme.of(context).colorScheme.secondary
                            : Colors.grey[600]!,
                    width: 2,
                  ),
                ),
                child:
                    isSelected
                        ? Center(
                          child: Container(
                            width: 12.w,
                            height: 12.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                        )
                        : null,
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      level,
                      style: TextUtils.kSubHeading(
                        context,
                      ).copyWith(color: Theme.of(context).colorScheme.primary),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _getActivityLevelDescription(level),
                      style: TextUtils.kBodyText(
                        context,
                      ).copyWith(color: Colors.grey[400], fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getActivityLevelDescription(String level) {
    switch (level) {
      case 'Sedentary':
        return 'Little or no exercise, desk job';
      case 'Lightly Active':
        return 'Light exercise or sports 1-3 days/week';
      case 'Moderately Active':
        return 'Moderate exercise or sports 3-5 days/week';
      case 'Very Active':
        return 'Hard exercise or sports 6-7 days/week';
      case 'Extra Active':
        return 'Very hard exercise, physical job or training twice a day';
      default:
        return '';
    }
  }
}
