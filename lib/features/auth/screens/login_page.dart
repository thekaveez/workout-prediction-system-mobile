import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:workout_prediction_system_mobile/features/auth/bloc/auth_bloc.dart';
import 'package:workout_prediction_system_mobile/features/auth/bloc/auth_event.dart';
import 'package:workout_prediction_system_mobile/features/auth/bloc/auth_state.dart';
import 'package:workout_prediction_system_mobile/features/auth/screens/forgot_password_page.dart';
import 'package:workout_prediction_system_mobile/features/auth/screens/register_page.dart';
import 'package:workout_prediction_system_mobile/features/home/screens/home_screen.dart';
import 'package:workout_prediction_system_mobile/utils/helpers.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';
import 'package:workout_prediction_system_mobile/widgets/custom_button.dart';
import 'package:workout_prediction_system_mobile/widgets/custom_text_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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

  void _handleLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(
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
              content: Text(state.errorMessage ?? 'Authentication failed'),
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
              SizedBox(height: MediaQuery.of(context).size.height * 0.2),
              SvgPicture.asset('assets/icons/logo.svg'),
              SizedBox(height: MediaQuery.of(context).size.height * 0.15),

              Container(
                padding: EdgeInsets.symmetric(vertical: 24.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(50.r),
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.w),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text('Login', style: TextUtils.kHeading(context)),
                        SizedBox(height: 24.h),
                        CustomTextField(
                          title: 'Email',
                          hintText: 'example@example.com',
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          obscureText: false,
                          validator: _validateEmail,
                        ),
                        CustomTextField(
                          title: 'Password',
                          hintText: '********',
                          suffixText: 'Forgot Password?',
                          suffixOnClick: () {
                            Navigator.push(
                              context,
                              Helpers.routeNavigation(
                                context,
                                const ForgotPasswordPage(),
                              ),
                            );
                          },
                          controller: _passwordController,
                          keyboardType: TextInputType.text,
                          obscureText: true,
                          validator: _validatePassword,
                        ),
                        BlocBuilder<AuthBloc, AuthState>(
                          builder: (context, state) {
                            return CustomButton(
                              height: 48.h,
                              text:
                                  state.isAuthenticating
                                      ? 'Signing In...'
                                      : 'Login',
                              onPressed:
                                  state.isAuthenticating ? () {} : _handleLogin,
                            );
                          },
                        ),
                        SizedBox(height: 16.h),
                        TextButton(
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
                        if (!BlocProvider.of<AuthBloc>(
                          context,
                        ).state.isConnected)
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
