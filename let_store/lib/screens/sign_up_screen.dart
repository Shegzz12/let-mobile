// import 'package:flutter/rendering.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '/screens/signin_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';

import '../utils/app_textstyles.dart';
import '../features/widgets/custom_textfield.dart';
import 'main_screen.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late String _token;
  String? _responseMessage;
  String? _avatar;
  // String? _email;
  // String? _id;
  String? _name;
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _streetController = TextEditingController();
  final _cityController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SafeArea(
      child: Stack(
        children: [
          Scaffold(
            resizeToAvoidBottomInset: true,
            body: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 600;

                return Row(
                  children: [
                    if (isWide)
                      Expanded(
                        flex: 1,
                        child: Container(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          child: Center(
                            child: Padding(
                              padding: const EdgeInsets.all(18),
                              child: Stack(
                                children: [
                                  Image.asset(
                                    'assets/images/elect_store.jpg',
                                    height: double.infinity,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                  Text(
                                    'Join Us Today!\nExplore the best deals.',
                                    textAlign: TextAlign.center,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineMedium,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 600),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.all(20),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  IconButton(
                                    onPressed: () => Get.back(),
                                    icon: Icon(
                                      Icons.arrow_back_ios,
                                      color: isDark
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Signup to get started',
                                    style: AppTextStyle.withColor(
                                      AppTextStyle.bodyLarge,
                                      isDark
                                          ? Colors.grey[400]!
                                          : Colors.grey[600]!,
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  // Full Name
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextfield(
                                          label: 'First Name',
                                          prefixIcon: CupertinoIcons
                                              .person_2_square_stack,
                                          keyboardType: TextInputType.name,
                                          controller: _firstNameController,
                                          validator: (value) =>
                                              value == null || value.isEmpty
                                              ? 'Enter first name'
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: CustomTextfield(
                                          label: 'Last Name',
                                          prefixIcon:
                                              CupertinoIcons.person_crop_circle,
                                          keyboardType: TextInputType.name,
                                          controller: _lastNameController,
                                          validator: (value) =>
                                              value == null || value.isEmpty
                                              ? 'Enter last name'
                                              : null,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  CustomTextfield(
                                    label: 'Email',
                                    prefixIcon: CupertinoIcons.mail,
                                    keyboardType: TextInputType.emailAddress,
                                    controller: _emailController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter email';
                                      }
                                      if (!GetUtils.isEmail(value)) {
                                        return 'Enter valid email';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 15),
                                  Text(
                                    'Shipping Address (Optional)',
                                    style: AppTextStyle.withColor(
                                      AppTextStyle.bodyLarge,
                                      isDark
                                          ? Colors.grey[400]!
                                          : Colors.grey[600]!,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  CustomTextfield(
                                    label: 'Street',
                                    prefixIcon: CupertinoIcons.location_solid,
                                    keyboardType: TextInputType.streetAddress,
                                    controller: _streetController,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextfield(
                                          label: 'City',
                                          prefixIcon:
                                              CupertinoIcons.map_pin_ellipse,
                                          keyboardType: TextInputType.name,
                                          controller: _cityController,
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: CustomTextfield(
                                          label: 'State',
                                          prefixIcon: CupertinoIcons.map,
                                          keyboardType: TextInputType.name,
                                          controller: _stateController,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: CustomTextfield(
                                          label: 'Zip Code',
                                          prefixIcon: CupertinoIcons.mail_solid,
                                          keyboardType: TextInputType.number,
                                          controller: _zipCodeController,
                                        ),
                                      ),
                                      const SizedBox(width: 7),
                                      Expanded(
                                        child: CustomTextfield(
                                          label: 'Country',
                                          prefixIcon: CupertinoIcons.globe,
                                          keyboardType: TextInputType.name,
                                          controller: _countryController,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  CustomTextfield(
                                    label: 'Password',
                                    prefixIcon: CupertinoIcons.lock,
                                    keyboardType: TextInputType.visiblePassword,
                                    isPassword: true,
                                    controller: _passwordController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Enter password';
                                      }
                                      if (value.length < 6) {
                                        return 'Min 6 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                  CustomTextfield(
                                    label: 'Confirm Password',
                                    prefixIcon: CupertinoIcons.lock_shield,
                                    keyboardType: TextInputType.visiblePassword,
                                    isPassword: true,
                                    controller: _confirmPasswordController,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Confirm password';
                                      }
                                      if (value != _passwordController.text) {
                                        return 'Passwords don’t match';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 25),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 56,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        if (_formKey.currentState!.validate()) {
                                          _signUp();
                                        }
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(
                                          context,
                                        ).primaryColor,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        'Sign Up',
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
                                  const SizedBox(height: 15),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Already have an account?',
                                        style: AppTextStyle.withColor(
                                          AppTextStyle.bodyMedium,
                                          isDark
                                              ? Colors.grey[400]!
                                              : Colors.grey[600]!,
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () =>
                                            Get.off(() => const SigninScreen()),
                                        child: Text(
                                          'Sign In',
                                          style: AppTextStyle.withColor(
                                            AppTextStyle.labelMedium,
                                            Theme.of(context).primaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 70),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
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

  Future<void> _signUp() async {
    final url = Uri.parse('https://let-commerce.onrender.com/api/users/signup');

    final body = {
      "firstname": _firstNameController.text,
      "lastname": _lastNameController.text,
      "email": _emailController.text,
      "password": _passwordController.text,
      "confirm_password": _confirmPasswordController.text,
      "shipping_address": {
        "street": _streetController.text,
        "city": _cityController.text,
        "zip_code": _zipCodeController.text,
        "state": _stateController.text,
        "country": _countryController.text,
      },
    };
    setState(() {
      _isLoading = true;
    });
    //
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      setState(() {
        _responseMessage = response.body;
        _avatar = data['user']['avatar'];
        // _email = data['user']['email'];
        // _id = data['user']['id'];
        _name = data['user']['name'];
        _token = data['token'] ?? '';
      });
      if (context.mounted) {
        Get.off(
          () => MainScreen(
            avatar: _avatar,
            // id: _id,
            // email: _email,
            name: _name,
            bearerToken: _token,
          ),
        );
      }

      print('API Response: $data');
    } catch (e) {
      setState(() {
        _responseMessage = 'Invalid Input';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
}
//       final data = jsonDecode(response.body);

//       setState(() {
//         _responseMessage = response.body;
//         _avatar = data['user']['avatar'];
//         // _email = data['user']['email'];
//         // _id = data['user']['id'];
//         _name = data['user']['name'];
//         _token = data['token'] ?? '';
//       });
//       if (context.mounted) {
//         Get.off(
//           () => MainScreen(
//             avatar: _avatar,
//             // id: _id,
//             // email: _email,
//             name: _name,
//             bearerToken: _token,
//           ),
//         );
//       }

//       print('API Response: $data');
//     } catch (e) {
//       setState(() {
//         _responseMessage = 'Invalid Input';
//       });
//     } finally {
//       setState(() {
//         _isLoading = false;
//       });
//     }
//   }
// }

// }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;

//     return SafeArea(
//       child: Stack(
//         children: [
//           Scaffold(
//             resizeToAvoidBottomInset: false,
//             body: SingleChildScrollView(
//               padding: EdgeInsets.all(20),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     IconButton(
//                       onPressed: () => Get.back(),
//                       icon: Icon(
//                         Icons.arrow_back_ios,
//                         color: isDark ? Colors.white : Colors.black,
//                       ),
//                     ),
//                     SizedBox(height: 8),
//                     Text(
//                       'Signup to get started',
//                       style: AppTextStyle.withColor(
//                         AppTextStyle.bodyLarge,
//                         isDark ? Colors.grey[400]! : Colors.grey[600]!,
//                       ),
//                     ),

//                     SizedBox(height: 20),

//                     // full name textfield
//                     Row(
//                       children: [
//                         Expanded(
//                           child: CustomTextfield(
//                             label: 'First Name',
//                             prefixIcon: CupertinoIcons.person_2_square_stack,
//                             keyboardType: TextInputType.name,
//                             controller: _firstNameController,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter your first name';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                         SizedBox(width: 10),
//                         Expanded(
//                           child: CustomTextfield(
//                             label: 'Last Name',
//                             prefixIcon: CupertinoIcons.person_crop_circle,
//                             keyboardType: TextInputType.name,
//                             controller: _lastNameController,
//                             validator: (value) {
//                               if (value == null || value.isEmpty) {
//                                 return 'Please enter your last name';
//                               }
//                               return null;
//                             },
//                           ),
//                         ),
//                       ],
//                     ),

//                     SizedBox(height: 10),
//                     CustomTextfield(
//                       label: 'Email',
//                       prefixIcon: CupertinoIcons.mail, // Icons.email_outlined,
//                       keyboardType: TextInputType.emailAddress,
//                       controller: _emailController,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your email';
//                         }
//                         if (!GetUtils.isEmail(value)) {
//                           return 'Please enter a valid email';
//                         }
//                         return null;
//                       },
//                     ),
//                     // email address text field
//                     SizedBox(height: 15),
//                     Text(
//                       'Shipping Address (Optional)',
//                       style: AppTextStyle.withColor(
//                         AppTextStyle.bodyLarge,
//                         isDark ? Colors.grey[400]! : Colors.grey[600]!,
//                       ),
//                     ),
//                     SizedBox(height: 10),
//                     CustomTextfield(
//                       label: 'Street',
//                       prefixIcon: CupertinoIcons.location_solid,
//                       keyboardType: TextInputType.streetAddress,
//                       controller: _streetController,
//                     ),

//                     SizedBox(height: 10),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: CustomTextfield(
//                             label: 'City',
//                             prefixIcon: CupertinoIcons.map_pin_ellipse,
//                             keyboardType: TextInputType.name,
//                             controller: _cityController,
//                           ),
//                         ),
//                         SizedBox(width: 7),
//                         Expanded(
//                           child: CustomTextfield(
//                             label: 'State',
//                             prefixIcon:
//                                 CupertinoIcons.map, //Icons.map_outlined,
//                             keyboardType: TextInputType.name,
//                             controller: _stateController,
//                           ),
//                         ),
//                       ],
//                     ),

//                     SizedBox(height: 10),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: CustomTextfield(
//                             label: 'Zip Code',
//                             prefixIcon: CupertinoIcons
//                                 .mail_solid, // Icons.pin_outlined,
//                             keyboardType: TextInputType.number,
//                             controller: _zipCodeController,
//                           ),
//                         ),
//                         SizedBox(width: 7),
//                         Expanded(
//                           child: CustomTextfield(
//                             label: 'Country',
//                             prefixIcon:
//                                 CupertinoIcons.globe, // Icons.public_outlined,
//                             keyboardType: TextInputType.name,
//                             controller: _countryController,
//                           ),
//                         ),
//                       ],
//                     ),
//                     // set password text field
//                     SizedBox(height: 10),
//                     CustomTextfield(
//                       label: 'Password',
//                       prefixIcon: CupertinoIcons.lock, // Icons.lock_outline,
//                       keyboardType: TextInputType.visiblePassword,
//                       isPassword: true,
//                       controller: _passwordController,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please enter your password';
//                         }
//                         if (value.trim().length < 2) {
//                           return 'Passwords must be at least 6 characters';
//                         }
//                         return null;
//                       },
//                     ),
//                     // confirm password text field
//                     SizedBox(height: 10),
//                     CustomTextfield(
//                       label: 'Confirm Password',
//                       prefixIcon:
//                           CupertinoIcons.lock_shield, // Icons.lock_outline,
//                       keyboardType: TextInputType.visiblePassword,
//                       isPassword: true,
//                       controller: _confirmPasswordController,
//                       validator: (value) {
//                         if (value == null || value.isEmpty) {
//                           return 'Please confirm your password';
//                         }
//                         if (value != _passwordController.text) {
//                           return 'Passwords do not match';
//                         }
//                         return null;
//                       },
//                     ),
//                     SizedBox(height: 25),
//                     // Sign in Button
//                     SizedBox(
//                       width: double.infinity,
//                       height: 56,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           if (_formKey.currentState!.validate()) {
//                             _signUp();
//                           }
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Theme.of(context).primaryColor,
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         child: Text(
//                           'Sign Up',
//                           style: AppTextStyle.withColor(
//                             AppTextStyle.buttonMedium,
//                             Colors.white,
//                           ),
//                         ),
//                       ),
//                     ),
//                     SizedBox(height: 3),
//                     if (_responseMessage != null)
//                       Padding(
//                         padding: EdgeInsets.only(top: 20),
//                         child: Text(
//                           _responseMessage!,
//                           style: TextStyle(
//                             color: Colors.green,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                       ),
//                     SizedBox(height: 15),
//                     // signin textbutton
//                     Row(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Text(
//                           'Already have an account?',
//                           style: AppTextStyle.withColor(
//                             AppTextStyle.bodyMedium,
//                             isDark ? Colors.grey[400]! : Colors.grey[600]!,
//                           ),
//                         ),

//                         TextButton(
//                           onPressed: () => Get.off(() => SigninScreen()),
//                           child: Text(
//                             'Sign In',
//                             style: AppTextStyle.withColor(
//                               AppTextStyle.labelMedium,
//                               Theme.of(context).primaryColor,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: 70),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (_isLoading)
//             Container(
//               color: Colors.black.withOpacity(0.5),
//               child: const Center(
//                 child: CupertinoActivityIndicator(radius: 15),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
