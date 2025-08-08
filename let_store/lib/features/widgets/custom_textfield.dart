import '/utils/app_textstyles.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/widgets.dart';

class CustomTextfield extends StatefulWidget {
  final String label;
  final IconData prefixIcon;
  final TextInputType keyboardType;
  final bool isPassword;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? initialValue;

  const CustomTextfield({
    super.key,
    required this.label,
    required this.prefixIcon,
    this.keyboardType = TextInputType.text,
    this.isPassword = false,
    // this.keyboardType = TextInputType.text,
    // this.isPassword = false,
    this.controller,
    this.validator,
    this.onChanged,
    this.initialValue,
  });

  @override
  State<CustomTextfield> createState() => _CustomTextfieldState();
}

class _CustomTextfieldState extends State<CustomTextfield>
    with SingleTickerProviderStateMixin {
  bool _obscureText = true;
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return TextFormField(
      initialValue: widget.initialValue,
      controller: widget.controller,
      obscureText: widget.isPassword && _obscureText,
      keyboardType: widget.keyboardType,
      validator: widget.validator,
      onChanged: widget.onChanged,
      style: AppTextStyle.withColor(
        AppTextStyle.bodyMedium,
        Theme.of(context).textTheme.bodyLarge!.color!,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        labelStyle: AppTextStyle.withColor(
          AppTextStyle.bodyMedium,
          isDark
              ? Colors.grey[400]!
              : Colors
                    .grey[600]!, // Theme.of(context).textTheme.bodyLarge!.color!,
        ),
        prefixIcon: Icon(
          widget.prefixIcon,
          color: isDark ? Colors.grey[400]! : Colors.grey[600]!,
        ),
        suffixIcon: widget.isPassword
            ? IconButton(
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).primaryColor),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Theme.of(context).colorScheme.error),
        ),
      ),
    );
  }
}

// import '/utils/app_textstyles.dart';
// import 'package:flutter/material.dart';
// // import 'package:flutter/widgets.dart';

// class CustomTextfield extends StatefulWidget {
//   final String label;
//   final IconData prefixIcon;
//   final TextInputType keyboardType;
//   final bool isPassword;
//   final TextEditingController? controller;
//   final String? Function(String?)? validator;
//   final void Function(String)? onChanged;
//   final String? initialValue;

//   const CustomTextfield({
//     super.key,
//     required this.label,
//     required this.prefixIcon,
//     this.keyboardType = TextInputType.text,
//     this.isPassword = false,
//     // this.keyboardType = TextInputType.text,
//     // this.isPassword = false,
//     this.controller,
//     this.validator,
//     this.onChanged,
//     this.initialValue,
//   });

//   @override
//   State<CustomTextfield> createState() => _CustomTextfieldState();
// }

// class _CustomTextfieldState extends State<CustomTextfield>
//     with SingleTickerProviderStateMixin {
//   String? _errorText;

//   bool _obscureText = true;
//   late AnimationController _controller;

//   @override
//   void initState() {
//     super.initState();
//     _controller = AnimationController(vsync: this);
//   }

//   @override
//   void dispose() {
//     _controller.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     return IntrinsicHeight(
//       child: Padding(
//         padding: const EdgeInsets.symmetric(vertical: 8.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             TextFormField(
//               initialValue: widget.initialValue == null
//                   ? widget.initialValue
//                   : null,
//               controller: widget.controller,
//               obscureText: widget.isPassword && _obscureText,
//               keyboardType: widget.keyboardType,
//               validator: (value) {
//                 final result = widget.validator?.call(value);
//                 setState(() {
//                   _errorText = result;
//                 });
//                 return ''; // Return empty string to suppress default error space
//               },
//               onChanged: widget.onChanged,
//               style: AppTextStyle.withColor(
//                 AppTextStyle.bodyMedium,
//                 Theme.of(context).textTheme.bodyLarge!.color!,
//               ),
//               decoration: InputDecoration(
//                 contentPadding: EdgeInsets.symmetric(
//                   vertical: 12,
//                   horizontal: 16,
//                 ),
//                 // errorStyle: TextStyle(height: 0),
//                 labelText: widget.label,
//                 labelStyle: AppTextStyle.withColor(
//                   AppTextStyle.bodyMedium,
//                   isDark
//                       ? Colors.grey[400]!
//                       : Colors
//                             .grey[600]!, // Theme.of(context).textTheme.bodyLarge!.color!,
//                 ),
//                 prefixIcon: Icon(
//                   widget.prefixIcon,
//                   color: isDark ? Colors.grey[400]! : Colors.grey[600]!,
//                 ),
//                 suffixIcon: widget.isPassword
//                     ? IconButton(
//                         onPressed: () {
//                           setState(() {
//                             _obscureText = !_obscureText;
//                           });
//                         },
//                         icon: Icon(
//                           _obscureText
//                               ? Icons.visibility_off
//                               : Icons.visibility,
//                         ),
//                       )
//                     : null,
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(
//                     color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
//                   ),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(color: Theme.of(context).primaryColor),
//                 ),
//                 errorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(
//                     color: Theme.of(context).colorScheme.error,
//                   ),
//                 ),
//                 focusedErrorBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(12),
//                   borderSide: BorderSide(
//                     color: Theme.of(context).colorScheme.error,
//                   ),
//                 ),
//               ),
//             ),
//             AnimatedSize(
//               duration: const Duration(milliseconds: 200),
//               clipBehavior: Clip.none,
//               curve: Curves.easeInOut,
//               child: _errorText != null && _errorText!.isNotEmpty
//                   ? Padding(
//                       padding: const EdgeInsets.only(top: 4, left: 12),
//                       child: Semantics(
//                         label: 'Error: ${_errorText!}',
//                         child: Text(
//                           _errorText!,
//                           style: TextStyle(
//                             color: Theme.of(context).colorScheme.error,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ),
//                     )
//                   : const SizedBox.shrink(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
