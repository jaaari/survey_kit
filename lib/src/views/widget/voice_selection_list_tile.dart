import 'dart:async';
import 'package:flutter/material.dart';
import 'package:survey_kit/src/views/decorations/gradient_box_border.dart';
import 'package:survey_kit/src/theme_extensions.dart';
import 'package:survey_kit/src/widgets/kuluko_audio_visualizer.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';

class VoiceSelectionListTile extends StatefulWidget {
  final String text;
  final Function onTap;
  final bool isSelected;
  final String imageURL;
  final String? sample;
  final Function? onAudioComplete;
  final Function? stopAudio;

  // Modify static AudioPlayer initialization
  static AudioPlayer? _sharedAudioPlayer;
  static final BehaviorSubject<String?> _currentlyPlayingSample = BehaviorSubject.seeded(null);
  static final BehaviorSubject<bool> _isLoading = BehaviorSubject.seeded(false);
  static const _debounceMs = 50;

  // Add method to get or create player
  static Future<AudioPlayer> _getPlayer() async {
    if (_sharedAudioPlayer == null) {
      try {
        _sharedAudioPlayer = AudioPlayer();
      } catch (e) {
        print('Error creating audio player: $e');
        // If player creation fails, dispose and try again
        await _sharedAudioPlayer?.dispose();
        _sharedAudioPlayer = AudioPlayer();
      }
    }
    return _sharedAudioPlayer!;
  }

  // Add cleanup method
  static Future<void> cleanup() async {
    try {
      await _sharedAudioPlayer?.stop();
      await _sharedAudioPlayer?.dispose();
      _sharedAudioPlayer = null;
      _currentlyPlayingSample.add(null);
      _isLoading.add(false);
    } catch (e) {
      print('Error cleaning up audio player: $e');
    }
  }

  const VoiceSelectionListTile({
    Key? key,
    required this.text,
    required this.onTap,
    this.isSelected = false,
    this.imageURL = "",
    this.sample,
    this.onAudioComplete,
    this.stopAudio,
  }) : super(key: key);

  @override
  State<VoiceSelectionListTile> createState() => _VoiceSelectionListTileState();
}

class _VoiceSelectionListTileState extends State<VoiceSelectionListTile> with SingleTickerProviderStateMixin {
  final BehaviorSubject<bool> _isPlayingSubject = BehaviorSubject.seeded(false);
  final BehaviorSubject<bool> _visualizerActiveSubject = BehaviorSubject.seeded(false);
  bool _isHandlingTap = false;
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _processingStateSubscription;
  StreamSubscription? _currentSampleSubscription;

  Timer? _debounceTimer;
  StreamSubscription? _loadingSubscription;
  DateTime _lastTapTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    _initializeAudioPlayer();
    
    _loadingSubscription = VoiceSelectionListTile._isLoading.listen((loading) {
      if (!loading && mounted) {
        _isHandlingTap = false;
      }
    });

    _currentSampleSubscription = VoiceSelectionListTile._currentlyPlayingSample.listen((playingSample) {
      if (mounted && widget.sample != null) {
        final isThisSamplePlaying = playingSample == widget.sample;
        _isPlayingSubject.add(isThisSamplePlaying);
        _visualizerActiveSubject.add(isThisSamplePlaying);
      }
    });

    if (widget.stopAudio != null) {
      widget.stopAudio!(() => _stopPlaying());
    }
  }

  Future<void> _initializeAudioPlayer() async {
    try {
      final player = await VoiceSelectionListTile._getPlayer();
      
      _playerStateSubscription = player.playingStream.listen((playing) {
        if (VoiceSelectionListTile._currentlyPlayingSample.value == widget.sample) {
          _isPlayingSubject.add(playing);
          _visualizerActiveSubject.add(playing);
        }
      });

      _processingStateSubscription = player.processingStateStream.listen((state) {
        if (state == ProcessingState.completed && 
            VoiceSelectionListTile._currentlyPlayingSample.value == widget.sample) {
          _handlePlaybackComplete();
        }
      });

      if (widget.sample != null) {
        _preloadSample();
      }
    } catch (e) {
      print('Error initializing audio player: $e');
    }
  }

  Future<void> _preloadSample() async {
    try {
      final player = await VoiceSelectionListTile._getPlayer();
      await player.setUrl(widget.sample!);
    } catch (e) {
      print('Error preloading sample: $e');
    }
  }

  void _handlePlaybackComplete() {
    if (mounted) {
      _stopPlaying();
      widget.onAudioComplete?.call();
    }
  }

  Future<void> _stopPlaying() async {
    try {
      final player = await VoiceSelectionListTile._getPlayer();
      await player.stop();
      VoiceSelectionListTile._currentlyPlayingSample.add(null);
      await Future.delayed(const Duration(milliseconds: 50));
    } catch (e) {
      print('Error stopping playback: $e');
    }
  }

  Future<void> _handleTap() async {
    final now = DateTime.now();
    if (_isHandlingTap || 
        now.difference(_lastTapTime).inMilliseconds < VoiceSelectionListTile._debounceMs) {
      return;
    }
    
    _lastTapTime = now;
    _isHandlingTap = true;
    VoiceSelectionListTile._isLoading.add(true);
    
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: VoiceSelectionListTile._debounceMs), () async {
      try {
        widget.onTap();
        
        if (widget.sample != null) {
          final isCurrentlyPlaying = VoiceSelectionListTile._currentlyPlayingSample.value == widget.sample;
          final player = await VoiceSelectionListTile._getPlayer();
          
          if (isCurrentlyPlaying) {
            await _stopPlaying();
          } else if (!widget.isSelected) {
            // Ensure previous sample is fully stopped
            await player.stop();
            VoiceSelectionListTile._currentlyPlayingSample.add(null);
            
            // Small delay to ensure clean state
            await Future.delayed(const Duration(milliseconds: 50));
            
            if (!mounted) return;
            
            // Start new sample
            await player.setUrl(widget.sample!);
            final duration = await player.duration;
            
            if (!mounted) return;
            
            VoiceSelectionListTile._currentlyPlayingSample.add(widget.sample);
            await player.play();
            
            if (duration != null && mounted) {
              Future.delayed(duration + const Duration(milliseconds: 100), () {
                if (mounted && VoiceSelectionListTile._currentlyPlayingSample.value == widget.sample) {
                  _handlePlaybackComplete();
                }
              });
            }
          }
        }
      } catch (e) {
        print('Error handling tap: $e');
        await _stopPlaying();
      } finally {
        if (mounted) {
          _isHandlingTap = false;
          VoiceSelectionListTile._isLoading.add(false);
        }
      }
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _loadingSubscription?.cancel();
    _playerStateSubscription?.cancel();
    _processingStateSubscription?.cancel();
    _currentSampleSubscription?.cancel();
    _isPlayingSubject.close();
    _visualizerActiveSubject.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final parts = widget.text.split('\n');
    final hasName = parts.length > 1;
    final name = hasName ? parts[0] : null;
    final description = hasName ? parts[1] : widget.text;

    return StreamBuilder<bool>(
      stream: _visualizerActiveSubject.stream,
      builder: (context, snapshot) {
        final showVisualizer = snapshot.data ?? false;
        
        final shouldShowVisualizer = widget.sample != null && 
                                   widget.isSelected && 
                                   widget.imageURL != "" && 
                                   showVisualizer;

        final border = (widget.isSelected || showVisualizer)
            ? GradientBoxBorder(
                gradient: context.buttonGradient,
                width: 2.0,
              )
            : Border.all(
                color: Colors.transparent,
                width: 2.0,
              );

        return GestureDetector(
          onTap: _handleTap,
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: context.standard.value, horizontal: context.medium.value),
            child: Container(
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
              child: Stack(
                children: [
                  ListTile(
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
                  if (shouldShowVisualizer)
                    Positioned(
                      right: -context.screenWidth * 0.018,
                      top: 0,
                      bottom: 0,
                      child: Container(
                        width: context.screenWidth * 0.15,
                        child: Center(
                          child: KulukoAudioVisualizer(
                            isPlaying: showVisualizer,
                            height: context.screenHeight * 0.05,
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
      },
    );
  }
}