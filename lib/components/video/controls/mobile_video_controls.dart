import 'dart:async';

import 'video_backward_seek_indicator.dart';
import 'video_forward_seek_indicator.dart';
import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:media_kit_video/media_kit_video_controls/src/controls/methods/video_state.dart';

MaterialVideoControlsThemeData _theme(BuildContext context) =>
    FullscreenInheritedWidget.maybeOf(context) == null
        ? MaterialVideoControlsTheme.maybeOf(context)?.normal ??
        kDefaultMaterialVideoControlsThemeData
        : MaterialVideoControlsTheme.maybeOf(context)?.fullscreen ??
        kDefaultMaterialVideoControlsThemeDataFullscreen;

VideoController controller(BuildContext context) =>
    VideoStateInheritedWidget.of(context).state.widget.controller;

class MobileVideoControls extends StatefulWidget {
  const MobileVideoControls({super.key});

  @override
  State<MobileVideoControls> createState() => _MobileVideoControlsState();
}

class _MobileVideoControlsState extends State<MobileVideoControls> {
  late bool mount = _theme(context).visibleOnMount;
  late bool visible = _theme(context).visibleOnMount;
  Timer? _timer;

  final double _brightnessValue = 0.0;
  final bool _brightnessIndicator = false;
  //Timer? _brightnessTimer;

  final double _volumeValue = 0.0;
  final bool _volumeIndicator = false;
  //Timer? _volumeTimer;
  // The default event stream in package:volume_controller is buggy.
  //bool _volumeInterceptEventStream = false;

  Offset _dragInitialDelta =
      Offset.zero; // Initial position for horizontal drag
  int swipeDuration = 0; // Duration to seek in video
  bool showSwipeDuration = false; // Whether to show the seek duration overlay

  bool _speedUpIndicator = false;
  late /* private */ var playlist = controller(context).player.state.playlist;
  late bool buffering = controller(context).player.state.buffering;

  bool _mountSeekBackwardButton = false;
  bool _mountSeekForwardButton = false;
  bool _hideSeekBackwardButton = false;
  bool _hideSeekForwardButton = false;
  Timer? _timerSeekBackwardButton;
  Timer? _timerSeekForwardButton;

  final ValueNotifier<Duration> _seekBarDeltaValueNotifier =
  ValueNotifier<Duration>(Duration.zero);

  final List<StreamSubscription> subscriptions = [];

  double get subtitleVerticalShiftOffset =>
      (_theme(context).padding?.bottom ?? 0.0) +
          (_theme(context).bottomButtonBarMargin.vertical) +
          (_theme(context).bottomButtonBar.isNotEmpty
              ? _theme(context).buttonBarHeight
              : 0.0);
  Offset? _tapPosition;

  void _handleDoubleTapDown(TapDownDetails details) {
    setState(() {
      _tapPosition = details.localPosition;
    });
  }

  void _handleLongPress() {
    setState(() {
      _speedUpIndicator = true;
    });
    controller(context).player.setRate(_theme(context).speedUpFactor);
  }

  void _handleLongPressEnd(LongPressEndDetails details) {
    setState(() {
      _speedUpIndicator = false;
    });
    controller(context).player.setRate(1.0);
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (subscriptions.isEmpty) {
      subscriptions.addAll(
        [
          controller(context).player.stream.playlist.listen(
                (event) {
              setState(() {
                playlist = event;
              });
            },
          ),
          controller(context).player.stream.buffering.listen(
                (event) {
              setState(() {
                buffering = event;
              });
            },
          ),
        ],
      );

      if (_theme(context).visibleOnMount) {
        _timer = Timer(
          _theme(context).controlsHoverDuration,
              () {
            if (mounted) {
              setState(() {
                visible = false;
              });
              unshiftSubtitle();
            }
          },
        );
      }
    }
  }

  @override
  void dispose() {
    for (final subscription in subscriptions) {
      subscription.cancel();
    }
    // --------------------------------------------------
    // package:screen_brightness
    // Future.microtask(() async {
    //   try {
    //     await ScreenBrightness().resetScreenBrightness();
    //   } catch (_) {}
    // });
    // --------------------------------------------------
    _timerSeekBackwardButton?.cancel();
    _timerSeekForwardButton?.cancel();
    super.dispose();
  }

  void shiftSubtitle() {
    if (_theme(context).shiftSubtitlesOnControlsVisibilityChange) {
      state(context).setSubtitleViewPadding(
        state(context).widget.subtitleViewConfiguration.padding +
            EdgeInsets.fromLTRB(
              0.0,
              0.0,
              0.0,
              subtitleVerticalShiftOffset,
            ),
      );
    }
  }

  void unshiftSubtitle() {
    if (_theme(context).shiftSubtitlesOnControlsVisibilityChange) {
      state(context).setSubtitleViewPadding(
        state(context).widget.subtitleViewConfiguration.padding,
      );
    }
  }

  void onTap() {
    if (!visible) {
      setState(() {
        mount = true;
        visible = true;
      });
      shiftSubtitle();
      _timer?.cancel();
      _timer = Timer(_theme(context).controlsHoverDuration, () {
        if (mounted) {
          setState(() {
            visible = false;
          });
          unshiftSubtitle();
        }
      });
    } else {
      setState(() {
        visible = false;
      });
      unshiftSubtitle();
      _timer?.cancel();
    }
  }

  void onDoubleTapSeekBackward() {
    setState(() {
      _mountSeekBackwardButton = true;
    });
  }

  void onDoubleTapSeekForward() {
    setState(() {
      _mountSeekForwardButton = true;
    });
  }

  void onHorizontalDragUpdate(DragUpdateDetails details) {
    if (_dragInitialDelta == Offset.zero) {
      _dragInitialDelta = details.localPosition;
      return;
    }

    final diff = _dragInitialDelta.dx - details.localPosition.dx;
    final duration = controller(context).player.state.duration.inSeconds;
    final position = controller(context).player.state.position.inSeconds;

    final seconds =
    -(diff * duration / _theme(context).horizontalGestureSensitivity)
        .round();
    final relativePosition = position + seconds;

    if (relativePosition <= duration && relativePosition >= 0) {
      setState(() {
        swipeDuration = seconds;
        showSwipeDuration = true;
        _seekBarDeltaValueNotifier.value = Duration(seconds: seconds);
      });
    }
  }

  void onHorizontalDragEnd() {
    if (swipeDuration != 0) {
      Duration newPosition = controller(context).player.state.position +
          Duration(seconds: swipeDuration);
      newPosition = newPosition.clamp(
        Duration.zero,
        controller(context).player.state.duration,
      );
      controller(context).player.seek(newPosition);
    }

    setState(() {
      _dragInitialDelta = Offset.zero;
      showSwipeDuration = false;
    });
  }

  bool _isInSegment(double localX, int segmentIndex) {
    // Local variable with the list of ratios
    List<int> segmentRatios = _theme(context).seekOnDoubleTapLayoutTapsRatios;

    int totalRatios = segmentRatios.reduce((a, b) => a + b);

    double segmentWidthMultiplier = widgetWidth(context) / totalRatios;
    double start = 0;
    double end;

    for (int i = 0; i < segmentRatios.length; i++) {
      end = start + (segmentWidthMultiplier * segmentRatios[i]);

      // Check if the current index matches the segmentIndex and if localX falls within it
      if (i == segmentIndex && localX >= start && localX <= end) {
        return true;
      }

      // Set the start of the next segment
      start = end;
    }

    // If localX does not fall within the specified segment
    return false;
  }

  bool _isInRightSegment(double localX) {
    return _isInSegment(localX, 2);
  }

  bool _isInCenterSegment(double localX) {
    return _isInSegment(localX, 1);
  }

  bool _isInLeftSegment(double localX) {
    return _isInSegment(localX, 0);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (!(_isInCenterSegment(event.position.dx))) {
      return;
    }

    onTap();
  }

  void _handleTapDown(TapDownDetails details) {
    if ((_isInCenterSegment(details.localPosition.dx))) {
      return;
    }

    onTap();
  }

  @override
  void initState() {
    super.initState();
    // --------------------------------------------------
    // package:volume_controller
    // Future.microtask(() async {
    //   try {
    //     VolumeController().showSystemUI = false;
    //     _volumeValue = await VolumeController().getVolume();
    //     VolumeController().listener((value) {
    //       if (mounted && !_volumeInterceptEventStream) {
    //         setState(() {
    //           _volumeValue = value;
    //         });
    //       }
    //     });
    //   } catch (_) {}
    // });
    // --------------------------------------------------
    // --------------------------------------------------
    // package:screen_brightness
    // Future.microtask(() async {
    //   try {
    //     _brightnessValue = await ScreenBrightness().current;
    //     ScreenBrightness().onCurrentBrightnessChanged.listen((value) {
    //       if (mounted) {
    //         setState(() {
    //           _brightnessValue = value;
    //         });
    //       }
    //     });
    //   } catch (_) {}
    // });
    // --------------------------------------------------
  }

  Future<void> setVolume(double value) async {
    // --------------------------------------------------
    // package:volume_controller
    // try {
    //   VolumeController().setVolume(value);
    // } catch (_) {}
    // setState(() {
    //   _volumeValue = value;
    //   _volumeIndicator = true;
    //   _volumeInterceptEventStream = true;
    // });
    // _volumeTimer?.cancel();
    // _volumeTimer = Timer(const Duration(milliseconds: 200), () {
    //   if (mounted) {
    //     setState(() {
    //       _volumeIndicator = false;
    //       _volumeInterceptEventStream = false;
    //     });
    //   }
    // });
    // --------------------------------------------------
  }

  Future<void> setBrightness(double value) async {
    // --------------------------------------------------
    // package:screen_brightness
    // try {
    //   await ScreenBrightness().setScreenBrightness(value);
    // } catch (_) {}
    // setState(() {
    //   _brightnessIndicator = true;
    // });
    // _brightnessTimer?.cancel();
    // _brightnessTimer = Timer(const Duration(milliseconds: 200), () {
    //   if (mounted) {
    //     setState(() {
    //       _brightnessIndicator = false;
    //     });
    //   }
    // });
    // --------------------------------------------------
  }

  @override
  Widget build(BuildContext context) {
    var seekOnDoubleTapEnabledWhileControlsAreVisible =
    (_theme(context).seekOnDoubleTap &&
        _theme(context).seekOnDoubleTapEnabledWhileControlsVisible);
    assert(_theme(context).seekOnDoubleTapLayoutTapsRatios.length == 3,
    "The number of seekOnDoubleTapLayoutTapsRatios must be 3, i.e. [1, 1, 1]");
    assert(_theme(context).seekOnDoubleTapLayoutWidgetRatios.length == 3,
    "The number of seekOnDoubleTapLayoutWidgetRatios must be 3, i.e. [1, 1, 1]");
    return Theme(
      data: Theme.of(context).copyWith(
        focusColor: const Color(0x00000000),
        hoverColor: const Color(0x00000000),
        splashColor: const Color(0x00000000),
        highlightColor: const Color(0x00000000),
      ),
      child: Focus(
        autofocus: true,
        child: Material(
          elevation: 0.0,
          borderOnForeground: false,
          animationDuration: Duration.zero,
          color: const Color(0x00000000),
          shadowColor: const Color(0x00000000),
          surfaceTintColor: const Color(0x00000000),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.center,
            children: [
              // Controls:
              AnimatedOpacity(
                curve: Curves.easeInOut,
                opacity: visible ? 1.0 : 0.0,
                duration: _theme(context).controlsTransitionDuration,
                onEnd: () {
                  setState(() {
                    if (!visible) {
                      mount = false;
                    }
                  });
                },
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Positioned.fill(
                      child: Container(
                        color: _theme(context).backdropColor,
                      ),
                    ),
                    // We are adding 16.0 boundary around the actual controls (which contain the vertical drag gesture detectors).
                    // This will make the hit-test on edges (e.g. swiping to: show status-bar, show navigation-bar, go back in navigation) not activate the swipe gesture annoyingly.
                    Positioned.fill(
                      left: 16.0,
                      top: 16.0,
                      right: 16.0,
                      bottom: 16.0 + subtitleVerticalShiftOffset,
                      child: Listener(
                        onPointerDown: (event) => _handlePointerDown(event),
                        child: GestureDetector(
                          onTapDown: (details) => _handleTapDown(details),
                          onDoubleTapDown: _handleDoubleTapDown,
                          onLongPress: _theme(context).speedUpOnLongPress
                              ? _handleLongPress
                              : null,
                          onLongPressEnd: _theme(context).speedUpOnLongPress
                              ? _handleLongPressEnd
                              : null,
                          onDoubleTap: () {
                            if (_tapPosition == null) {
                              return;
                            }
                            if (_isInRightSegment(_tapPosition!.dx)) {
                              if ((!mount && _theme(context).seekOnDoubleTap) ||
                                  seekOnDoubleTapEnabledWhileControlsAreVisible) {
                                onDoubleTapSeekForward();
                              }
                            } else {
                              if (_isInLeftSegment(_tapPosition!.dx)) {
                                if ((!mount &&
                                    _theme(context).seekOnDoubleTap) ||
                                    seekOnDoubleTapEnabledWhileControlsAreVisible) {
                                  onDoubleTapSeekBackward();
                                }
                              }
                            }
                          },
                          onHorizontalDragUpdate: (details) {
                            if ((!mount && _theme(context).seekGesture) ||
                                (_theme(context).seekGesture &&
                                    _theme(context)
                                        .gesturesEnabledWhileControlsVisible)) {
                              onHorizontalDragUpdate(details);
                            }
                          },
                          onHorizontalDragEnd: (details) {
                            onHorizontalDragEnd();
                          },
                          onVerticalDragUpdate: (e) async {
                            final delta = e.delta.dy;
                            final Offset position = e.localPosition;

                            if (position.dx <= widgetWidth(context) / 2) {
                              // Left side of screen swiped
                              if ((!mount &&
                                  _theme(context).brightnessGesture) ||
                                  (_theme(context).brightnessGesture &&
                                      _theme(context)
                                          .gesturesEnabledWhileControlsVisible)) {
                                final brightness = _brightnessValue -
                                    delta /
                                        _theme(context)
                                            .verticalGestureSensitivity;
                                final result = brightness.clamp(0.0, 1.0);
                                setBrightness(result);
                              }
                            } else {
                              // Right side of screen swiped

                              if ((!mount && _theme(context).volumeGesture) ||
                                  (_theme(context).volumeGesture &&
                                      _theme(context)
                                          .gesturesEnabledWhileControlsVisible)) {
                                final volume = _volumeValue -
                                    delta /
                                        _theme(context)
                                            .verticalGestureSensitivity;
                                final result = volume.clamp(0.0, 1.0);
                                setVolume(result);
                              }
                            }
                          },
                          child: Container(
                            color: const Color(0x00000000),
                          ),
                        ),
                      ),
                    ),
                    if (mount)
                      Padding(
                        padding: _theme(context).padding ??
                            (
                                // Add padding in fullscreen!
                                isFullscreen(context)
                                    ? MediaQuery.of(context).padding
                                    : EdgeInsets.zero),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              height: _theme(context).buttonBarHeight,
                              margin: _theme(context).topButtonBarMargin,
                              child: Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: _theme(context).topButtonBar,
                              ),
                            ),
                            // Only display [primaryButtonBar] if [buffering] is false.
                            Expanded(
                              child: AnimatedOpacity(
                                curve: Curves.easeInOut,
                                opacity: buffering ? 0.0 : 1.0,
                                duration:
                                _theme(context).controlsTransitionDuration,
                                child: Center(
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: _theme(context).primaryButtonBar,
                                  ),
                                ),
                              ),
                            ),
                            Stack(
                              alignment: Alignment.bottomCenter,
                              children: [
                                if (_theme(context).displaySeekBar)
                                  MaterialSeekBar(
                                    onSeekStart: () {
                                      _timer?.cancel();
                                    },
                                    onSeekEnd: () {
                                      _timer = Timer(
                                        _theme(context).controlsHoverDuration,
                                            () {
                                          if (mounted) {
                                            setState(() {
                                              visible = false;
                                            });
                                            unshiftSubtitle();
                                          }
                                        },
                                      );
                                    },
                                  ),
                                Container(
                                  height: _theme(context).buttonBarHeight,
                                  margin: _theme(context).bottomButtonBarMargin,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: _theme(context).bottomButtonBar,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              // Double-Tap Seek Seek-Bar:
              if (!mount)
                if (_mountSeekBackwardButton ||
                    _mountSeekForwardButton ||
                    showSwipeDuration)
                  Column(
                    children: [
                      const Spacer(),
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          if (_theme(context).displaySeekBar)
                            MaterialSeekBar(
                              delta: _seekBarDeltaValueNotifier,
                            ),
                          Container(
                            height: _theme(context).buttonBarHeight,
                            margin: _theme(context).bottomButtonBarMargin,
                          ),
                        ],
                      ),
                    ],
                  ),
              // Buffering Indicator.
              IgnorePointer(
                child: Padding(
                  padding: _theme(context).padding ??
                      (
                          // Add padding in fullscreen!
                          isFullscreen(context)
                              ? MediaQuery.of(context).padding
                              : EdgeInsets.zero),
                  child: Column(
                    children: [
                      Container(
                        height: _theme(context).buttonBarHeight,
                        margin: _theme(context).topButtonBarMargin,
                      ),
                      Expanded(
                        child: Center(
                          child: TweenAnimationBuilder<double>(
                            tween: Tween<double>(
                              begin: 0.0,
                              end: buffering ? 1.0 : 0.0,
                            ),
                            duration:
                            _theme(context).controlsTransitionDuration,
                            builder: (context, value, child) {
                              // Only mount the buffering indicator if the opacity is greater than 0.0.
                              // This has been done to prevent redundant resource usage in [CircularProgressIndicator].
                              if (value > 0.0) {
                                return Opacity(
                                  opacity: value,
                                  child: _theme(context)
                                      .bufferingIndicatorBuilder
                                      ?.call(context) ??
                                      child!,
                                );
                              }
                              return const SizedBox.shrink();
                            },
                            child: const CircularProgressIndicator(
                              color: Color(0xFFFFFFFF),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        height: _theme(context).buttonBarHeight,
                        margin: _theme(context).bottomButtonBarMargin,
                      ),
                    ],
                  ),
                ),
              ),
              // Volume Indicator.
              IgnorePointer(
                child: AnimatedOpacity(
                  curve: Curves.easeInOut,
                  opacity: (!mount ||
                      _theme(context)
                          .gesturesEnabledWhileControlsVisible) &&
                      _volumeIndicator
                      ? 1.0
                      : 0.0,
                  duration: _theme(context).controlsTransitionDuration,
                  child: _theme(context)
                      .volumeIndicatorBuilder
                      ?.call(context, _volumeValue) ??
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0x88000000),
                          borderRadius: BorderRadius.circular(64.0),
                        ),
                        height: 52.0,
                        width: 108.0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 52.0,
                              width: 42.0,
                              alignment: Alignment.centerRight,
                              child: Icon(
                                _volumeValue == 0.0
                                    ? Icons.volume_off
                                    : _volumeValue < 0.5
                                    ? Icons.volume_down
                                    : Icons.volume_up,
                                color: const Color(0xFFFFFFFF),
                                size: 24.0,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                '${(_volumeValue * 100.0).round()}%',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                          ],
                        ),
                      ),
                ),
              ),
              // Brightness Indicator.
              IgnorePointer(
                child: AnimatedOpacity(
                  curve: Curves.easeInOut,
                  opacity: (!mount ||
                      _theme(context)
                          .gesturesEnabledWhileControlsVisible) &&
                      _brightnessIndicator
                      ? 1.0
                      : 0.0,
                  duration: _theme(context).controlsTransitionDuration,
                  child: _theme(context)
                      .brightnessIndicatorBuilder
                      ?.call(context, _volumeValue) ??
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0x88000000),
                          borderRadius: BorderRadius.circular(64.0),
                        ),
                        height: 52.0,
                        width: 108.0,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              height: 52.0,
                              width: 42.0,
                              alignment: Alignment.centerRight,
                              child: Icon(
                                _brightnessValue < 1.0 / 3.0
                                    ? Icons.brightness_low
                                    : _brightnessValue < 2.0 / 3.0
                                    ? Icons.brightness_medium
                                    : Icons.brightness_high,
                                color: const Color(0xFFFFFFFF),
                                size: 24.0,
                              ),
                            ),
                            const SizedBox(width: 8.0),
                            Expanded(
                              child: Text(
                                '${(_brightnessValue * 100.0).round()}%',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14.0,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16.0),
                          ],
                        ),
                      ),
                ),
              ),
              // Speedup Indicator.
              IgnorePointer(
                child: Padding(
                  padding: _theme(context).padding ??
                      (
                          // Add padding in fullscreen!
                          isFullscreen(context)
                              ? MediaQuery.of(context).padding
                              : EdgeInsets.zero),
                  child: Column(
                    children: [
                      Container(
                        height: _theme(context).buttonBarHeight,
                        margin: _theme(context).topButtonBarMargin,
                      ),
                      Expanded(
                        child: AnimatedOpacity(
                          duration: _theme(context).controlsTransitionDuration,
                          opacity: _speedUpIndicator ? 1 : 0,
                          child: _theme(context).speedUpIndicatorBuilder?.call(
                              context, _theme(context).speedUpFactor) ??
                              Container(
                                alignment: Alignment.topCenter,
                                child: Container(
                                  margin: const EdgeInsets.all(16.0),
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: const Color(0x88000000),
                                    borderRadius: BorderRadius.circular(64.0),
                                  ),
                                  height: 48.0,
                                  width: 108.0,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                    CrossAxisAlignment.center,
                                    children: [
                                      const SizedBox(width: 16.0),
                                      Expanded(
                                        child: Text(
                                          '${_theme(context).speedUpFactor.toStringAsFixed(1)}x',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            fontSize: 14.0,
                                            color: Color(0xFFFFFFFF),
                                          ),
                                        ),
                                      ),
                                      Container(
                                        height: 48.0,
                                        width: 48.0 - 16.0,
                                        alignment: Alignment.centerRight,
                                        child: const Icon(
                                          Icons.fast_forward,
                                          color: Color(0xFFFFFFFF),
                                          size: 24.0,
                                        ),
                                      ),
                                      const SizedBox(width: 16.0),
                                    ],
                                  ),
                                ),
                              ),
                        ),
                      ),
                      Container(
                        height: _theme(context).buttonBarHeight,
                        margin: _theme(context).bottomButtonBarMargin,
                      ),
                    ],
                  ),
                ),
              ),
              // Seek Indicator.
              IgnorePointer(
                child: AnimatedOpacity(
                  duration: _theme(context).controlsTransitionDuration,
                  opacity: showSwipeDuration ? 1 : 0,
                  child: _theme(context)
                      .seekIndicatorBuilder
                      ?.call(context, Duration(seconds: swipeDuration)) ??
                      Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: const Color(0x88000000),
                          borderRadius: BorderRadius.circular(64.0),
                        ),
                        height: 52.0,
                        width: 108.0,
                        child: Text(
                          swipeDuration > 0
                              ? "+ ${Duration(seconds: swipeDuration).label()}"
                              : "- ${Duration(seconds: swipeDuration).label()}",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 14.0,
                            color: Color(0xFFFFFFFF),
                          ),
                        ),
                      ),
                ),
              ),

              // Double-Tap Seek Button(s):
              if (!mount || seekOnDoubleTapEnabledWhileControlsAreVisible)
                if (_mountSeekBackwardButton || _mountSeekForwardButton)
                  Positioned.fill(
                    child: Row(
                      children: [
                        Expanded(
                          flex: _theme(context)
                              .seekOnDoubleTapLayoutWidgetRatios[0],
                          child: _mountSeekBackwardButton
                              ? AnimatedOpacity(
                            opacity: _hideSeekBackwardButton ? 0 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: VideoBackwardSeekIndicator(
                              onChanged: (value) {
                                _seekBarDeltaValueNotifier.value = -value;
                              },
                              onSubmitted: (value) {
                                _timerSeekBackwardButton?.cancel();
                                _timerSeekBackwardButton = Timer(
                                  const Duration(milliseconds: 200),
                                      () {
                                    setState(() {
                                      _hideSeekBackwardButton = false;
                                      _mountSeekBackwardButton = false;
                                    });
                                  },
                                );

                                setState(() {
                                  _hideSeekBackwardButton = true;
                                });
                                var result = controller(context)
                                    .player
                                    .state
                                    .position -
                                    value;
                                result = result.clamp(
                                  Duration.zero,
                                  controller(context)
                                      .player
                                      .state
                                      .duration,
                                );
                                controller(context).player.seek(result);
                              },
                            ),
                          )
                              : const SizedBox(),
                        ),
                        //Area in the middle where the double-tap seek buttons are ignored in
                        if (_theme(context)
                            .seekOnDoubleTapLayoutWidgetRatios[1] >
                            0)
                          Expanded(
                              flex: _theme(context)
                                  .seekOnDoubleTapLayoutWidgetRatios[1],
                              child: const SizedBox()),
                        Expanded(
                          flex: _theme(context)
                              .seekOnDoubleTapLayoutWidgetRatios[2],
                          child: _mountSeekForwardButton
                              ? AnimatedOpacity(
                            opacity: _hideSeekForwardButton ? 0 : 1.0,
                            duration: const Duration(milliseconds: 200),
                            child: VideoForwardSeekIndicator(
                              onChanged: (value) {
                                _seekBarDeltaValueNotifier.value = value;
                              },
                              onSubmitted: (value) {
                                _timerSeekForwardButton?.cancel();
                                _timerSeekForwardButton = Timer(
                                    const Duration(milliseconds: 200),
                                        () {
                                      if (_hideSeekForwardButton) {
                                        setState(() {
                                          _hideSeekForwardButton = false;
                                          _mountSeekForwardButton = false;
                                        });
                                      }
                                    });
                                setState(() {
                                  _hideSeekForwardButton = true;
                                });

                                var result = controller(context)
                                    .player
                                    .state
                                    .position +
                                    value;
                                result = result.clamp(
                                  Duration.zero,
                                  controller(context)
                                      .player
                                      .state
                                      .duration,
                                );
                                controller(context).player.seek(result);
                              },
                            ),
                          )
                              : const SizedBox(),
                        ),
                      ],
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }

  double widgetWidth(BuildContext context) =>
      (context.findRenderObject() as RenderBox).paintBounds.width;
}