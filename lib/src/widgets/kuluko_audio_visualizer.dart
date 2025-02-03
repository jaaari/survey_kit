import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:survey_kit/src/theme_extensions.dart';

class KulukoAudioVisualizer extends StatefulWidget {
  final bool isPlaying;
  final double height;
  final double width;
  
  const KulukoAudioVisualizer({
    super.key,
    required this.isPlaying,
    this.height = 30,
    this.width = 60,
  });

  @override
  State<KulukoAudioVisualizer> createState() => _KulukoAudioVisualizerState();
}

class _KulukoAudioVisualizerState extends State<KulukoAudioVisualizer> with TickerProviderStateMixin {
  late final List<AnimationController> _controllers;
  final List<double> _barHeights = List.filled(4, 0.3);
  
  @override
  void initState() {
    super.initState();
    
    // Create individual controllers with different durations
    _controllers = List.generate(
      4,
      (index) => AnimationController(
        vsync: this,
        duration: Duration(milliseconds: _getDuration(index)),
      )..addListener(() {
        if (mounted) {
          setState(() {
            _barHeights[index] = _getHeight(index, _controllers[index].value);
          });
        }
      }),
    );
    
    if (widget.isPlaying) {
      _startAnimations();
    }
  }

  // Get different durations for each bar
  int _getDuration(int index) {
    const baseDuration = 600;
    switch (index) {
      case 0: return baseDuration + 200; // 800ms
      case 1: return baseDuration - 100; // 500ms
      case 2: return baseDuration + 100; // 700ms
      case 3: return baseDuration;       // 600ms
      default: return baseDuration;
    }
  }

  // Get different height patterns for each bar
  double _getHeight(int index, double value) {
    const minHeight = 0.3;
    const maxHeight = 0.9;
    final range = maxHeight - minHeight;
    
    switch (index) {
      case 0:
        // Smooth sine wave
        return minHeight + range * (math.sin(value * math.pi * 2) + 1) / 2;
      case 1:
        // Quick rises, slow falls
        return minHeight + range * math.pow(math.sin(value * math.pi), 2);
      case 2:
        // Bouncy pattern
        return minHeight + range * (1 - math.pow(math.cos(value * math.pi), 2));
      case 3:
        // Sharp peaks
        return minHeight + range * math.sin(value * math.pi).abs();
      default:
        return minHeight;
    }
  }

  void _startAnimations() {
    for (var i = 0; i < _controllers.length; i++) {
      _controllers[i].repeat(reverse: true);
    }
  }

  void _stopAnimations() {
    for (final controller in _controllers) {
      controller.stop();
    }
  }

  @override
  void didUpdateWidget(KulukoAudioVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPlaying != oldWidget.isPlaying) {
      if (widget.isPlaying) {
        _startAnimations();
      } else {
        _stopAnimations();
      }
    }
  }

  @override
  void dispose() {
    for (final controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      opacity: widget.isPlaying ? 1.0 : 0.0,
      child: ShaderMask(
        shaderCallback: (Rect bounds) {
          return context.buttonGradient.createShader(bounds);
        },
        child: SizedBox(
          width: widget.width,
          height: widget.height,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              _barHeights.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 50), 
                width: widget.width / (_barHeights.length * 4),
                height: widget.height * _barHeights[index],
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(widget.width / 16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
} 