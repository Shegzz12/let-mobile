import 'package:flutter/cupertino.dart';
import 'package:let_store/screens/admin_panel/add_product.dart';

import '/controllers/auth_controller.dart';
import '/utils/app_textstyles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

import 'forgot_password_screen.dart';
import 'main_screen.dart';
import 'sign_up_screen.dart';
import '../features/widgets/custom_textfield.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  bool _isLoading = false;
  String? _token;
  String? _responseMessage;
  String? _profile_image;
  String? _email;
  String? _firstname;
  String? _name;
  String? _lastname;

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            body: LayoutBuilder(
              builder: (context, constraints) {
                // Desktop or Tablet view
                // Inside: builder: (context, constraints) { ... }
                if (constraints.maxWidth > 900) {
                  final isDark =
                      Theme.of(context).brightness == Brightness.dark;

                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 1100,
                      ), // Overall desktop max width
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            // Left: hero/branding section (flexible, not too tall)
                            Expanded(
                              flex: 3,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: SizedBox(
                                  height:
                                      560, // Keeps desktop height reasonable
                                  child: Stack(
                                    fit: StackFit.expand,
                                    children: [
                                      Image.asset(
                                        'assets/images/elect_store.jpg',
                                        fit: BoxFit.cover,
                                      ),
                                      // Bottom gradient + title
                                      Positioned(
                                        left: 0,
                                        right: 0,
                                        bottom: 0,
                                        child: Container(
                                          padding: const EdgeInsets.all(16),
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                            // ),
                                            //   // gradient: LinearGradient(
                                            //   //   // begin: Alignment.bottomCenter,
                                            //   //   // end: Alignment.topCenter,
                                            //   //   colors: [
                                            //   //     Colors.black.withOpacity(0.6),
                                            //   //     // Colors.transparent,
                                            //   //   ],
                                          ),
                                          child: Text(
                                            'Welcome to Let Store',
                                            textAlign: TextAlign.center,
                                            style: AppTextStyle.withColor(
                                              AppTextStyle.h1,
                                              Theme.of(context).primaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 32),

                            // Right: form section with a max width (prevents stretching)
                            Expanded(
                              flex: 2,
                              child: Center(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(
                                    maxWidth: 500,
                                  ), // Form max width
                                  child: Card(
                                    elevation: isDark ? 0 : 2,
                                    color: Theme.of(context).cardColor,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                      side: BorderSide(
                                        color: isDark
                                            ? Colors.white.withOpacity(0.06)
                                            : Colors.black.withOpacity(0.06),
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 20,
                                        vertical: 20,
                                      ),
                                      child: SingleChildScrollView(
                                        child: _buildFormContent(isDark),
                                      ),
                                    ),
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

                // Mobile view
                return ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 700),
                  child: SingleChildScrollView(
                    // padding: const EdgeInsets.symmetric(
                    //   horizontal: 15,
                    //   vertical: 0,
                    // ),
                    child: Column(
                      children: [
                        Image.asset(
                          'assets/images/elect_store.jpg',
                          width: double.infinity,
                          height: 170,
                          fit: BoxFit.cover,
                        ),
                        const SizedBox(height: 25),

                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 15.0,
                              // vertical: 5,
                            ),
                            child: _buildFormContent(isDark),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(
                child: CupertinoActivityIndicator(radius: 15),
              ),
            ),
        ],
      ),
    );
  }

  // Extracted sign-in form widget for reuse
  Widget _buildFormContent(bool isDark) {
    return Form(
      key: _formKey,

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Your Reliable Electronics Store!',
            style: AppTextStyle.withColor(
              AppTextStyle.h1,
              Theme.of(context).textTheme.bodyLarge!.color!,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Sign in to continue shopping',
            style: AppTextStyle.withColor(
              AppTextStyle.bodyLarge,
              isDark ? Colors.grey[400]! : Colors.grey[600]!,
            ),
          ),
          const SizedBox(height: 30),

          // Email field
          CustomTextfield(
            label: 'Email',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!GetUtils.isEmail(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Password field
          CustomTextfield(
            label: 'Password',
            prefixIcon: Icons.lock_outline,
            keyboardType: TextInputType.visiblePassword,
            isPassword: true,
            controller: _passwordController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your password';
              }
              if (value.trim().length < 6) {
                return 'Passwords must be at least 6 characters';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => Get.to(() => ForgotPasswordScreen()),
              child: Text(
                'Forgot Password?',
                style: AppTextStyle.withColor(
                  AppTextStyle.buttonMedium,
                  Theme.of(context).primaryColor,
                ),
              ),
            ),
          ),
          const SizedBox(height: 26),

          // Log In Button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _handleSignIn();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Log In',
                style: AppTextStyle.withColor(
                  AppTextStyle.buttonMedium,
                  Colors.white,
                ),
              ),
            ),
          ),

          if (_responseMessage != null)
            Padding(
              padding: const EdgeInsets.only(top: 20),
              child: Text(
                _responseMessage!,
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

          const SizedBox(height: 24),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Don't have an account?",
                style: AppTextStyle.withColor(
                  AppTextStyle.bodyMedium,
                  isDark ? Colors.grey[400]! : Colors.grey[600]!,
                ),
              ),
              TextButton(
                onPressed: () => Get.to(() => SignUpScreen()),
                child: Text(
                  'Sign up',
                  style: AppTextStyle.withColor(
                    AppTextStyle.bodyMedium,
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Sign in logic
  Future<void> _handleSignIn() async {
    final url = Uri.parse('https://let-commerce.onrender.com/api/auth/signin');

    final body = {
      "email": _emailController.text,
      "password": _passwordController.text,
    };

    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      setState(() {
        _responseMessage = data['message'];
        _profile_image = data['user']['profile_image'];
        _email = data['user']['email'];
        _lastname = data['user']['lastname'];
        _firstname = data['user']['firstname'];
        _name = '$_firstname $_lastname';
        _token = data['token'];
      });

      final AuthController authController = Get.find<AuthController>();
      authController.login();

      if (_email == "admin@letshopify.com") {
        if (context.mounted) {
          Get.off(() => AddProductPage(bearerToken: _token!));
        }
      } else {
        if (context.mounted) {
          Get.off(
            () => MainScreen(
              bearerToken: _token!,
              avatar: _profile_image,
              name: _name,
            ),
          );
        }
      }

      print('API Response: $data');
    } catch (e) {
      setState(() {
        _responseMessage = 'Invalid Login Credentials';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
