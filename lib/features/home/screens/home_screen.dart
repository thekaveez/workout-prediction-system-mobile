import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:workout_prediction_system_mobile/features/home/providers/home_provider.dart';
import 'package:workout_prediction_system_mobile/features/home/widgets/daily_summary_card.dart';
import 'package:workout_prediction_system_mobile/features/home/widgets/health_tip_card.dart';
import 'package:workout_prediction_system_mobile/features/home/widgets/meal_plan_section.dart';
import 'package:workout_prediction_system_mobile/features/home/widgets/quick_actions.dart';
import 'package:workout_prediction_system_mobile/features/profile/screens/profile_screen.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize data when widget is first created
    Future.microtask(() => ref.read(homeProvider.notifier).initialLoad());
  }

  void _navigateToProfile(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (context) => const ProfileScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final homeState = ref.watch(homeProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (homeState.status == HomeStatus.initial ||
                homeState.status == HomeStatus.loading) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00C896)),
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
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 48,
                    ),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: const Color(0xFF00C896),
        unselectedItemColor: Colors.white60,
        backgroundColor: Theme.of(context).colorScheme.surface,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Plans',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Activity',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Progress',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildHomeContent(BuildContext context, HomeState state) {
    // Format the date string (e.g., "Today - Apr 6")
    final dateFormat = DateFormat('MMM d');
    final formattedDate = 'Today – ${dateFormat.format(state.date)}';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // App Bar / Header
          _buildHeader(context, state.username, formattedDate, state.photoUrl),

          SizedBox(height: 24.h),

          // Daily Summary Cards
          DailySummaryList(dailySummary: state.dailySummary!),

          SizedBox(height: 32.h),

          // Meal Plan Section
          MealPlanSection(
            mealPlan: state.mealPlan!,
            isGeneratingNewPlan: state.isGeneratingNewMealPlan,
          ),

          SizedBox(height: 32.h),

          // Quick Actions
          const QuickActions(),

          SizedBox(height: 32.h),

          // Health Tips
          HealthTipsSection(tips: state.healthTips!),

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
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
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
                    style: TextUtils.kSubHeading(
                      context,
                    ).copyWith(fontSize: 24.sp, color: Colors.white),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Text(
                dateString,
                style: TextStyle(color: Colors.white60, fontSize: 14.sp),
              ),
            ],
          ),
          GestureDetector(
            onTap: () => _navigateToProfile(context),
            child: Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: const Color(0xFF00C896).withOpacity(0.5),
                  width: 2,
                ),
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
                        : Icon(Icons.person, color: Colors.white, size: 28.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
