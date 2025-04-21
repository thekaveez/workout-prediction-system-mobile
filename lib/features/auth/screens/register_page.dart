import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:workout_prediction_system_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:workout_prediction_system_mobile/features/auth/bloc/auth_event.dart';
import 'package:workout_prediction_system_mobile/features/auth/bloc/auth_state.dart';
import 'package:workout_prediction_system_mobile/features/auth/screens/login_page.dart';
import 'package:workout_prediction_system_mobile/features/home/screens/home_screen.dart';
import 'package:workout_prediction_system_mobile/utils/helpers.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';
import 'package:workout_prediction_system_mobile/widgets/custom_button.dart';
import 'package:workout_prediction_system_mobile/widgets/custom_text_field.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String? _validateName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Name is required';
    }
    if (value.length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

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

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  void _handleRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignUpRequested(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.isAuthenticated) {
          Navigator.of(context).pushAndRemoveUntil(
            Helpers.routeNavigation(context, const HomeScreen()),
            (route) => false,
          );
        } else if (state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage ?? 'Registration failed'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),
              // Logo
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: SvgPicture.asset('assets/icons/logo.svg'),
              ),
              SizedBox(height: MediaQuery.of(context).size.height * 0.1),

              // Registration Form
              Container(
                padding: EdgeInsets.all(24.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.r),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          'Register',
                          style: TextUtils.kHeading(context),
                        ),
                      ),
                      SizedBox(height: 32.h),

                      // Name Field
                      CustomTextField(
                        title: 'Name',
                        hintText: 'John Doe',
                        controller: _nameController,
                        keyboardType: TextInputType.name,
                        obscureText: false,
                        validator: _validateName,
                      ),

                      // Email Field
                      CustomTextField(
                        title: 'Email',
                        hintText: 'example@example.com',
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        obscureText: false,
                        validator: _validateEmail,
                      ),

                      // Password Field
                      CustomTextField(
                        title: 'Password',
                        hintText: '********',
                        controller: _passwordController,
                        keyboardType: TextInputType.text,
                        obscureText: true,
                        validator: _validatePassword,
                      ),

                      SizedBox(height: 24.h),

                      // Register Button
                      BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, state) {
                          return CustomButton(
                            height: 56.h,
                            text:
                                state.isAuthenticating
                                    ? 'Creating Account...'
                                    : 'Register',
                            onPressed:
                                state.isAuthenticating
                                    ? () {}
                                    : _handleRegister,
                          );
                        },
                      ),

                      SizedBox(height: 24.h),

                      // Already have an account link
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Already have an account?',
                              style: TextUtils.kBodyText(context).copyWith(
                                fontSize: 14.sp,
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  Helpers.routeNavigation(
                                    context,
                                    const LoginPage(),
                                  ),
                                );
                              },
                              child: Text(
                                'Login',
                                style: TextUtils.kHeading(context).copyWith(
                                  fontSize: 14.sp,
                                  color: Theme.of(context).colorScheme.surface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      if (!BlocProvider.of<AuthBloc>(context).state.isConnected)
                        Padding(
                          padding: EdgeInsets.only(top: 16.h),
                          child: Text(
                            'No internet connection',
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.error,
                              fontSize: 14.sp,
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
      ),
    );
  }
}
