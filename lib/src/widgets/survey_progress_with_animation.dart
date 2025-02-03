
import 'package:flutter/material.dart';

class SurveyProgressWithAnimation extends StatefulWidget {
  final int currentStep;
  final int totalSteps;

  const SurveyProgressWithAnimation({
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  _SurveyProgressWithAnimationState createState() => _SurveyProgressWithAnimationState();
}

class _SurveyProgressWithAnimationState extends State<SurveyProgressWithAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize the AnimationController with duration for the animation
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize the progress animation starting at 0
    _progressAnimation = Tween<double>(
      begin: 1 / widget.totalSteps,
      end: widget.currentStep / widget.totalSteps,
    ).animate(_animationController);
  }

  @override
  void didUpdateWidget(SurveyProgressWithAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);

    // If the step has changed, animate the progress bar to the new value
    if (oldWidget.currentStep != widget.currentStep) {
      _progressAnimation = Tween<double>(
        begin: _progressAnimation.value,
        end: widget.currentStep / widget.totalSteps,
      ).animate(CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ));

      // Start the animation
      _animationController.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _progressAnimation,
      builder: (context, child) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0), // Adjust horizontal padding
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.0), // Rounded corners
            child: LinearProgressIndicator(
              value: _progressAnimation.value, // Animated progress value
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).colorScheme.secondary),
              minHeight: 8, // Adjust thickness
            ),
          ),
        );
      },
    );
  }
}
