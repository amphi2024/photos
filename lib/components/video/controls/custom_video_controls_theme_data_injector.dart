import 'package:flutter/material.dart';
import 'package:media_kit_video/media_kit_video.dart';

class CustomVideoControlsThemeDataInjector extends StatefulWidget {

  final Widget child;
  final BuildContext? context;
  const CustomVideoControlsThemeDataInjector({
    super.key,
    required this.child,
    this.context,
  });

  @override
  State<CustomVideoControlsThemeDataInjector> createState() => _CustomVideoControlsThemeDataInjectorState();
}

class _CustomVideoControlsThemeDataInjectorState extends State<CustomVideoControlsThemeDataInjector> {
  late final builders = <Widget Function(Widget)>[
    // CupertinoVideoControlsTheme
        (child) {
      final theme = CupertinoVideoControlsTheme.maybeOf(
        widget.context ?? context,
      );
      final normal = theme?.normal ?? kDefaultCupertinoVideoControlsThemeData;
      final fullscreen = theme?.fullscreen ??
          kDefaultCupertinoVideoControlsThemeDataFullscreen;
      return CupertinoVideoControlsTheme(
        normal: normal,
        fullscreen: fullscreen,
        child: child,
      );
    },
    // MaterialVideoControlsTheme
        (child) {
      final theme = MaterialVideoControlsTheme.maybeOf(
        widget.context ?? context,
      );
      final normal = theme?.normal ?? kDefaultMaterialVideoControlsThemeData;
      final fullscreen =
          theme?.fullscreen ?? kDefaultMaterialVideoControlsThemeDataFullscreen;
      return MaterialVideoControlsTheme(
        normal: normal,
        fullscreen: fullscreen,
        child: child,
      );
    },
    // MaterialDesktopVideoControlsTheme
        (child) {
      final theme = MaterialDesktopVideoControlsTheme.maybeOf(
        widget.context ?? context,
      );
      final normal =
          theme?.normal ?? kDefaultMaterialDesktopVideoControlsThemeData;
      final fullscreen = theme?.fullscreen ??
          kDefaultMaterialDesktopVideoControlsThemeDataFullscreen;
      return MaterialDesktopVideoControlsTheme(
        normal: normal,
        fullscreen: fullscreen,
        child: child,
      );
    },
    // NOTE: Add more builders if more *VideoControlsTheme are implemented.
  ];

  @override
  Widget build(BuildContext context) {
    return builders.fold<Widget>(
      widget.child,
          (child, builder) => builder(child),
    );
  }
}
