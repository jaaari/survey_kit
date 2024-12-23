import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class KLoadingDeer extends StatefulWidget {
  final bool isError;
  final String? errorMessage;
  final VoidCallback? onRetry;
  final double? size;
  final Duration fadeInDuration;

  const KLoadingDeer({
    super.key,
    this.isError = false,
    this.errorMessage,
    this.onRetry,
    this.size,
    this.fadeInDuration = const Duration(milliseconds: 300),
  });

  @override
  State<KLoadingDeer> createState() => _KLoadingDeerState();
}

class _KLoadingDeerState extends State<KLoadingDeer> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    // Trigger fade-in animation after frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: widget.fadeInDuration,
      curve: Curves.easeIn,
      child: Center(
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: Lottie.asset(
            'assets/lottie_animations/Animation_-_1702820920320.json',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
} 