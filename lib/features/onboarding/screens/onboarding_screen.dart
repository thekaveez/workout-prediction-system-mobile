import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:workout_prediction_system_mobile/features/auth/screens/login_page.dart';
import 'package:workout_prediction_system_mobile/features/onboarding/screens/reusable_page.dart';
import 'package:workout_prediction_system_mobile/home_page.dart';
import 'package:workout_prediction_system_mobile/utils/helpers.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  bool isLastPage = false;

  //content
  final List<Map<String, String>> _pageData = [
    {
      'image': 'assets/images/page1.jpeg',
      'title': 'Personalized Health at Your Fingertips',
      'description':
          'AI-powered meal plans and fitness reminders, tailored to your lifestyle.',
    },
    {
      'image': 'assets/images/page2.jpeg',
      'title': 'Smart Meal & Activity Planning',
      'description':
          'Get AI-generated meal plans and posture reminders to stay healthy at work.',
    },
    {
      'image': 'assets/images/page3.jpeg',
      'title': 'Track & Improve Your Health',
      'description':
          'Monitor your nutrition, fitness, and daily habits with real-time insights.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            onPageChanged: (index) {
              setState(() {
                isLastPage = index == _pageData.length - 1;
              });
            },
            itemCount: _pageData.length,
            itemBuilder: (context, index) {
              return ReusablePage(
                imagePath: _pageData[index]['image']!,
                title: _pageData[index]['title']!,
                description: _pageData[index]['description']!,
              );
            },
          ),

          Container(
            alignment: Alignment(0, 0.9),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                //Skip
                TextButton(
                  onPressed: () {
                    isLastPage
                        ? Navigator.pushReplacement(
                          context,
                          Helpers.routeNavigation(context, LoginPage()),
                        )
                        : _controller.jumpToPage(2);
                  },
                  child: Text('Skip', style: TextUtils.kBodyText(context)),
                ),
                SmoothPageIndicator(
                  controller: _controller,
                  count: 3,
                  effect: ExpandingDotsEffect(
                    radius: 8,
                    dotWidth: 8,
                    dotHeight: 8,
                    dotColor: Theme.of(
                      context,
                    ).colorScheme.primary.withAlpha(100),
                    activeDotColor: Theme.of(context).colorScheme.secondary,
                  ),
                ),

                //Next or Done
                isLastPage
                    ? TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          Helpers.routeNavigation(context, LoginPage()),
                        );
                      },
                      child: InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            Helpers.routeNavigation(context, LoginPage()),
                          );
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: Color(0xFF63F2C5),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'Get Started',
                            style: TextUtils.kBodyText(context).copyWith(
                              color: Theme.of(context).colorScheme.surface,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    )
                    : TextButton(
                      onPressed: () {
                        _controller.nextPage(
                          duration: const Duration(milliseconds: 500),
                          curve: Curves.easeIn,
                        );
                      },
                      child: Text(
                        'Next',
                        style: TextUtils.kBodyText(context).copyWith(
                          color: Theme.of(context).colorScheme.secondary,
                        ),
                      ),
                    ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
