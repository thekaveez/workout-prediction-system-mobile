import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:workout_prediction_system_mobile/features/auth/screens/login_page.dart';
import 'package:workout_prediction_system_mobile/features/auth/screens/register_page.dart';
import 'package:workout_prediction_system_mobile/utils/helpers.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';
import 'package:workout_prediction_system_mobile/widgets/custom_button.dart';
import 'package:workout_prediction_system_mobile/widgets/custom_text_field.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    if (!emailRegex.hasMatch(value)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      // Proceed with password reset logic
      // This would typically call your authentication service
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset link sent to your email')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            // Logo
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: SvgPicture.asset('assets/icons/logo.svg'),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),

            // Forgot Password Form
            Container(
              height: MediaQuery.of(context).size.height,
              padding: EdgeInsets.all(24.h),
              decoration: BoxDecoration(
                color:
                    Theme.of(
                      context,
                    ).colorScheme.secondary, // Mint green container
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50.r)),
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(height: 8.h),
                    // Title
                    Text(
                      'Forgot Password?',
                      style: TextUtils.kHeading(context),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 16.h),

                    // Description
                    Text(
                      'Enter your email address to get the password reset link.',
                      style: TextUtils.kBodyText(context).copyWith(
                        fontSize: 16.sp,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 40.h),

                    // Email Field
                    CustomTextField(
                      title: 'Email Address',
                      hintText: 'example@example.com',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                      validator: _validateEmail,
                    ),
                    SizedBox(height: 40.h),

                    // Reset Button
                    CustomButton(
                      height: 56.h,
                      text: 'Reset Password',
                      onPressed: _handleResetPassword,
                    ),
                    SizedBox(height: 40.h),

                    // Create account link
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            Helpers.routeNavigation(
                              context,
                              const RegisterPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Create an account',
                          style: TextUtils.kHeading(context).copyWith(
                            fontSize: 14.sp,
                            color: Theme.of(context).colorScheme.surface,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
