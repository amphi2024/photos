import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'mobile_video_controls.dart';

Widget videoControls(VideoState state) {
  switch (Theme.of(state.context).platform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      // return const CustomVideoControlsThemeDataInjector(
      //   child: MobileVideoControls(),
      // );
    case TargetPlatform.macOS:
    case TargetPlatform.windows:
    case TargetPlatform.linux:
      return MaterialDesktopVideoControls(state);
    default:
      return NoVideoControls(state);
  }
}