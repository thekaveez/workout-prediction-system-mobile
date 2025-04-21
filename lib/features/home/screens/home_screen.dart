import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import 'package:workout_prediction_system_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:workout_prediction_system_mobile/features/auth/repository/auth_repository.dart';
import 'package:workout_prediction_system_mobile/features/home/bloc/home_bloc.dart';
import 'package:workout_prediction_system_mobile/features/home/bloc/home_event.dart';
import 'package:workout_prediction_system_mobile/features/home/bloc/home_state.dart';
import 'package:workout_prediction_system_mobile/features/home/widgets/daily_summary_card.dart';
import 'package:workout_prediction_system_mobile/features/home/widgets/health_tip_card.dart';
import 'package:workout_prediction_system_mobile/features/home/widgets/meal_plan_section.dart';
import 'package:workout_prediction_system_mobile/features/home/widgets/quick_actions.dart';
import 'package:workout_prediction_system_mobile/features/profile/screens/profile_screen.dart';
import 'package:workout_prediction_system_mobile/features/profile/widgets/profile_provider.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create:
          (context) => HomeBloc(
            authBloc: BlocProvider.of<AuthBloc>(context),
            authRepository: RepositoryProvider.of<AuthRepository>(context),
          )..add(const HomeInitialLoadEvent()),
      child: const HomeScreenContent(),
    );
  }
}

class HomeScreenContent extends StatelessWidget {
  const HomeScreenContent({super.key});

  void _navigateToProfile(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const ProfileProvider(child: ProfileScreen()),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SafeArea(
        child: BlocBuilder<HomeBloc, HomeState>(
          builder: (context, state) {
            if (state is HomeInitialState || state is HomeLoadingState) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF00C896)),
              );
            } else if (state is HomeLoadedState) {
              return RefreshIndicator(
                color: const Color(0xFF00C896),
                onRefresh: () async {
                  context.read<HomeBloc>().add(const HomeRefreshDataEvent());
                  // Wait for refresh to complete
                  await Future.delayed(const Duration(milliseconds: 800));
                },
                child: _buildHomeContent(context, state),
              );
            } else if (state is HomeErrorState) {
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
                      'Error: ${state.message}',
                      style: TextUtils.kBodyText(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24.h),
                    ElevatedButton(
                      onPressed: () {
                        context.read<HomeBloc>().add(
                          const HomeInitialLoadEvent(),
                        );
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

  Widget _buildHomeContent(BuildContext context, HomeLoadedState state) {
    // Format the date string (e.g., "Today - Apr 6")
    final dateFormat = DateFormat('MMM d');
    final formattedDate = 'Today – ${dateFormat.format(state.date)}';

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // App Bar / Header
          _buildHeader(context, state.username, formattedDate),

          SizedBox(height: 24.h),

          // Daily Summary Cards
          DailySummaryList(dailySummary: state.dailySummary),

          SizedBox(height: 32.h),

          // Meal Plan Section
          MealPlanSection(
            mealPlan: state.mealPlan,
            isGeneratingNewPlan: state.isGeneratingNewMealPlan,
          ),

          SizedBox(height: 32.h),

          // Quick Actions
          const QuickActions(),

          SizedBox(height: 32.h),

          // Health Tips
          HealthTipsSection(tips: state.healthTips),

          SizedBox(height: 32.h),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    String username,
    String dateString,
  ) {
    // Get the photoUrl from the HomeBloc state
    final state = context.read<HomeBloc>().state;
    final String? photoUrl = state is HomeLoadedState ? state.photoUrl : null;

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
