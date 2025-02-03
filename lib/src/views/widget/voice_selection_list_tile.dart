import 'package:flutter/material.dart';
import 'package:survey_kit/src/views/decorations/gradient_box_border.dart';
import 'package:survey_kit/src/theme_extensions.dart';
import 'package:survey_kit/src/widgets/kuluko_audio_visualizer.dart';
import 'package:just_audio/just_audio.dart';

class VoiceSelectionListTile extends StatefulWidget {
  final String text;
  final Function onTap;
  final bool isSelected;
  final String imageURL;
  final String? sample;
  final Function? onAudioComplete;

  const VoiceSelectionListTile({
    Key? key,
    required this.text,
    required this.onTap,
    this.isSelected = false,
    this.imageURL = "",
    this.sample,
    this.onAudioComplete,
  }) : super(key: key);

  @override
  State<VoiceSelectionListTile> createState() => _VoiceSelectionListTileState();
}

class _VoiceSelectionListTileState extends State<VoiceSelectionListTile> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isPlaying = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        stopPlaying();
      }
    });
  }

  @override
  void dispose() {
    stopPlaying();
    _audioPlayer.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(VoiceSelectionListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isSelected && !oldWidget.isSelected && widget.sample != null) {
      startPlaying();
    } else if (!widget.isSelected && oldWidget.isSelected) {
      stopPlaying();
    }
  }

  Future<void> startPlaying() async {
    if (widget.sample != null) {
      try {
        await _audioPlayer.stop();
        setState(() => _isPlaying = false);
        await _audioPlayer.setUrl(widget.sample!);
        setState(() => _isPlaying = true);
        _animationController.forward();
        await _audioPlayer.play();
      } catch (e) {
        print('Error playing audio: $e');
        stopPlaying();
      }
    }
  }

  void stopPlaying() {
    if (_isPlaying) {
      _audioPlayer.stop();
      setState(() => _isPlaying = false);
      _animationController.reverse().then((_) {
        if (widget.onAudioComplete != null) {
          widget.onAudioComplete!();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final parts = widget.text.split('\n');
    final hasName = parts.length > 1;
    final name = hasName ? parts[0] : null;
    final description = hasName ? parts[1] : widget.text;

    final shouldShowVisualizer = widget.sample != null && 
                               widget.isSelected && 
                               widget.imageURL != "" && 
                               _isPlaying;

    final border = (widget.isSelected || _isPlaying)
        ? GradientBoxBorder(
            gradient: context.buttonGradient,
            width: 2.0,
          )
        : Border.all(
            color: Colors.transparent,
            width: 2.0,
          );

    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: context.standard.value, horizontal: context.medium.value),
        child: InkWell(
          onTap: () => widget.onTap.call(),
          borderRadius: BorderRadius.circular(14.0),
          child: Stack(
            children: [
              Container(
                padding: EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 24.0,
                ),
                constraints: BoxConstraints(
                  minHeight: context.screenHeight * 0.14,
                  maxHeight: widget.imageURL != "" ? context.screenHeight * 0.14 : double.infinity,
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: context.card,
                  borderRadius: BorderRadius.circular(14.0),
                  border: border,
                  image: widget.imageURL != "" ? DecorationImage(
                    image: NetworkImage(widget.imageURL),
                    fit: BoxFit.fitHeight,
                    alignment: Alignment.centerRight,
                    colorFilter: shouldShowVisualizer
                        ? ColorFilter.mode(
                            Colors.black.withOpacity(0.6),
                            BlendMode.srcOver,
                          )
                        : null,
                  ) : null,
                ),
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasName) 
                        Text(
                          name!,
                          style: context.body.copyWith(
                            color: Color(widget.isSelected ? context.textPrimary.value : context.textSecondary.value),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      Text(
                        description,
                        style: context.body.copyWith(
                          color: Color(widget.isSelected ? context.textPrimary.value : context.textSecondary.value),
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        textAlign: TextAlign.start,
                      ),
                    ],
                  ),
                  trailing: widget.imageURL != "" ? Container(width: context.screenWidth * 0.2, color: Colors.transparent) : null,
                ),
              ),
              if (shouldShowVisualizer)
                Positioned(
                  right: context.screenWidth * 0.03,
                  top: 0,
                  bottom: 0,
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Container(
                      width: context.screenWidth * 0.2,
                      alignment: Alignment.center,
                      child: KulukoAudioVisualizer(
                        isPlaying: _isPlaying,
                        height: context.screenHeight * 0.03,
                        width: context.screenWidth * 0.1,
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
