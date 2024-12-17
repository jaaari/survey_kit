import 'package:flutter/material.dart';
import 'package:survey_kit/src/theme_extensions.dart';

class KSnackbar {
  static void show({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    bool isError = false,
  }) {
    // Remove any existing snackbars
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: SizedBox(
          height: context.screenHeight * 0.13, // Fixed height for the content
          child: Center(
            child: Text(
              message,
              style: context.body.copyWith(
                color: context.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 2, // Limit to single line
              overflow: TextOverflow.ellipsis, // Add ellipsis for overflow
            ),
          ),
        ),
        backgroundColor: isError ? const Color.fromARGB(255, 244, 73, 54) : context.border,
        behavior: SnackBarBehavior.fixed,
        animation: CurvedAnimation(
          parent: const AlwaysStoppedAnimation(1),
          curve: Curves.easeOutCirc,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: context.medium.value, // Consistent vertical padding
          horizontal: context.medium.value,
        ),
        duration: duration,
        elevation: 0,
      ),
    );
  }

  // Helper method for error messages
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context: context,
      message: message,
      duration: duration,
      isError: true,
    );
  }
} 