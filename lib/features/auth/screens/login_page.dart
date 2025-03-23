import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:workout_prediction_system_mobile/utils/text_utils.dart';
import 'package:workout_prediction_system_mobile/widgets/custom_button.dart';
import 'package:workout_prediction_system_mobile/widgets/custom_text_field.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.2),
            SvgPicture.asset('assets/icons/logo.svg'),
            SizedBox(height: MediaQuery.of(context).size.height * 0.15),

            Container(
              height: MediaQuery.of(context).size.height * 0.6,
              padding: EdgeInsets.symmetric(vertical: 24.h),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(50.r)),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  children: [
                    Text('Login', style: TextUtils.kHeading(context)),
                    SizedBox(height: 24.h),
                    CustomTextField(
                      title: 'Username',
                      hintText: 'example@example.com',
                      controller: _usernameController,
                      keyboardType: TextInputType.emailAddress,
                      obscureText: false,
                    ),
                    CustomTextField(
                      title: 'Password',
                      hintText: '********',
                      suffixText: 'Forgot Password?',
                      controller: _passwordController,
                      keyboardType: TextInputType.text,
                      obscureText: true,
                    ),
                    CustomButton(height: 48.h, text: 'Login', onPressed: () {}),
                    SizedBox(height: 16.h),
                    TextButton(
                      onPressed: () {},
                      child: Text(
                        'Create an account',
                        style: TextUtils.kHeading(context).copyWith(
                          fontSize: 14.sp,
                          color: Theme.of(context).colorScheme.surface,
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
