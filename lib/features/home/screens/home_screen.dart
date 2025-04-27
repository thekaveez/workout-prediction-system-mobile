import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:workout_prediction_system_mobile/features/exercise/screens/exercise_screen.dart';
import 'package:workout_prediction_system_mobile/features/home/providers/home_provider.dart';
import 'package:workout_prediction_system_mobile/features/home/widgets/daily_summary_card.dart';
import 'package:workout_prediction_system_mobile/features/home/widgets/health_tip_card.dart';
import 'package:workout_prediction_system_mobile/features/home/widgets/meal_plan_section.dart';
import 'package:workout_prediction_system_mobile/features/home/widgets/quick_actions.dart';
import 'package:workout_prediction_system_mobile/features/meal_prediction/screens/meal_prediction_screen.dart';
import 'package:workout_prediction_system_mobile/features/profile/screens/profile_screen.dart';
import 'package:workout_prediction_system_mobile/features/progress/screens/progress_tracking_screen.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with SingleTickerProviderStateMixin {
  int _currentIndex = 0;
  late AnimationController _animationController;
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _initializeScreens();
  }

  void _initializeScreens() {
    _screens = [
      HomeContent(onNavigateToTab: _navigateToTab),
      const MealPredictionScreen(),
      const ExerciseScreen(),
      const ProgressTrackingScreen(),
      const ProfileScreen(),
    ];
  }

  void _navigateToTab(int index) {
    if (_currentIndex != index) {
      _animationController.forward(from: 0.0);
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: _navigateToTab,
          selectedItemColor: Theme.of(context).colorScheme.secondary,
          unselectedItemColor: Colors.white60,
          backgroundColor: Theme.of(context).colorScheme.surface,
          type: BottomNavigationBarType.fixed,
          elevation: 8,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.restaurant_menu_outlined),
              activeIcon: Icon(Icons.restaurant_menu),
              label: 'Meals',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.fitness_center_outlined),
              activeIcon: Icon(Icons.fitness_center),
              label: 'Exercise',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.show_chart_outlined),
              activeIcon: Icon(Icons.show_chart),
              label: 'Progress',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends ConsumerStatefulWidget {
  final Function(int) onNavigateToTab;

  const HomeContent({super.key, required this.onNavigateToTab});

  @override
  ConsumerState<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends ConsumerState<HomeContent> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() => ref.read(homeProvider.notifier).initialLoad());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
  }

  void _handleMealCardTap() {
    widget.onNavigateToTab(1); // Navigate to meals tab
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    return SafeArea(
      child: Builder(
        builder: (context) {
          if (homeState.status == HomeStatus.initial ||
              homeState.status == HomeStatus.loading) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF00C896)),
                  SizedBox(height: 16.h),
                  Text(
                    'Loading your personalized dashboard...',
                    style: TextStyle(color: Colors.white70, fontSize: 14.sp),
                  ),
                ],
              ),
            );
          } else if (homeState.status == HomeStatus.loaded) {
            return RefreshIndicator(
              color: const Color(0xFF00C896),
              onRefresh: () async {
                ref.read(homeProvider.notifier).refreshData();
                // Wait for refresh to complete
                await Future.delayed(const Duration(milliseconds: 800));
              },
              child: _buildHomeContent(context, homeState),
            );
          } else if (homeState.status == HomeStatus.error) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 48),
                  SizedBox(height: 16.h),
                  Text(
                    'Error: ${homeState.errorMessage}',
                    style: TextUtils.kBodyText(context),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 24.h),
                  ElevatedButton(
                    onPressed: () {
                      ref.read(homeProvider.notifier).initialLoad();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00C896),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 12.h,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                    ),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, HomeState state) {
    final dateFormat = DateFormat('EEEE, MMM d');
    final formattedDate = dateFormat.format(state.date);

    return SingleChildScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // App Bar / Header
          _buildHeader(context, state.username, formattedDate, state.photoUrl),

          // Daily Stats Summary
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              children: [
                Icon(
                  Icons.insert_chart_outlined,
                  color: const Color(0xFF00C896),
                  size: 24.sp,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Daily Stats',
                  style: TextUtils.kSubHeading(context).copyWith(
                    fontSize: 18.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          // Daily Summary Cards
          DailySummaryList(dailySummary: state.dailySummary!),

          // Meal Summary Card
          SizedBox(height: 24.h),
          _buildMealSummaryCard(context),

          // Health Tips
          SizedBox(height: 24.h),
          HealthTipsSection(tips: state.healthTips!),

          // Exercise Section
          SizedBox(height: 24.h),
          _buildExerciseSection(context),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String username,
    String dateString,
    String? photoUrl,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF001612).withOpacity(0.8),
            Theme.of(context).colorScheme.surface,
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('👋 ', style: TextStyle(fontSize: 24)),
                      Text(
                        'Hello, $username',
                        style: TextUtils.kSubHeading(context).copyWith(
                          fontSize: 24.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 6.h),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today,
                        size: 14.sp,
                        color: const Color(0xFF00C896),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        dateString,
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              GestureDetector(
                onTap: () => _navigateToProfile(context),
                child: Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF00C896),
                      width: 2,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00C896).withOpacity(0.2),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: ClipOval(
                    child:
                        photoUrl != null
                            ? Image.network(
                              photoUrl,
                              fit: BoxFit.cover,
                              errorBuilder:
                                  (_, __, ___) => Icon(
                                    Icons.person,
                                    color: Colors.white,
                                    size: 28.sp,
                                  ),
                            )
                            : Icon(
                              Icons.person,
                              color: Colors.white,
                              size: 28.sp,
                            ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  Widget _buildMealSummaryCard(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.restaurant_menu,
                color: const Color(0xFF00C896),
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Meal Plan',
                style: TextUtils.kSubHeading(context).copyWith(
                  fontSize: 18.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          InkWell(
            onTap: _handleMealCardTap,
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.all(20.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00C896).withOpacity(0.15),
                    const Color(0xFF00C896).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C896).withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Meal Plan',
                            style: TextUtils.kBodyText(context).copyWith(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Tap to view your personalized meals',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C896).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: const Color(0xFF00C896),
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildMealIndicator(
                        'Breakfast',
                        Icons.breakfast_dining,
                        '420 kcal',
                      ),
                      _buildMealIndicator(
                        'Lunch',
                        Icons.lunch_dining,
                        '650 kcal',
                      ),
                      _buildMealIndicator(
                        'Dinner',
                        Icons.dinner_dining,
                        '580 kcal',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealIndicator(String title, IconData icon, String calories) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.h),
          decoration: BoxDecoration(
            color: const Color(0xFF00C896).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: const Color(0xFF00C896), size: 24.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          calories,
          style: TextStyle(color: Colors.white70, fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _buildExerciseSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.fitness_center,
                color: const Color(0xFF00C896),
                size: 24.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Exercise Plan',
                style: TextUtils.kSubHeading(context).copyWith(
                  fontSize: 18.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          InkWell(
            onTap: () => widget.onNavigateToTab(2), // Navigate to exercise tab
            borderRadius: BorderRadius.circular(16.r),
            child: Container(
              padding: EdgeInsets.all(20.h),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    const Color(0xFF00C896).withOpacity(0.15),
                    const Color(0xFF00C896).withOpacity(0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00C896).withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                    offset: const Offset(0, 2),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Today\'s Workout',
                            style: TextUtils.kBodyText(context).copyWith(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Tap to view your exercise routine',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14.sp,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(8.h),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00C896).withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward,
                          color: const Color(0xFF00C896),
                          size: 24.sp,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildExerciseIndicator(
                        'Cardio',
                        Icons.directions_run,
                        '30 min',
                      ),
                      _buildExerciseIndicator(
                        'Strength',
                        Icons.fitness_center,
                        '45 min',
                      ),
                      _buildExerciseIndicator(
                        'Flexibility',
                        Icons.self_improvement,
                        '15 min',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseIndicator(String title, IconData icon, String duration) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(10.h),
          decoration: BoxDecoration(
            color: const Color(0xFF00C896).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(icon, color: const Color(0xFF00C896), size: 24.sp),
        ),
        SizedBox(height: 8.h),
        Text(
          title,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12.sp,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          duration,
          style: TextStyle(color: Colors.white70, fontSize: 12.sp),
        ),
      ],
    );
  }
}
