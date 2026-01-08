import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:photos/channels/app_web_channel.dart';
import 'package:photos/models/photo.dart';

class VideoPlayer extends ConsumerStatefulWidget {

  final Photo photo;
  const VideoPlayer({super.key, required this.photo});

  @override
  ConsumerState<VideoPlayer> createState() => _VideoPlayerState();

  static void prepare() async {
    WidgetsFlutterBinding.ensureInitialized();
    MediaKit.ensureInitialized();
  }
}

class _VideoPlayerState extends ConsumerState<VideoPlayer> {

  final Player player = Player();
  late VideoController videoController;
  bool errorCaused = false;
  bool downloading = false;

  @override
  void dispose() {
    player.dispose();
    super.dispose();
  }

  @override
  void initState() {
    videoController = VideoController(player);
    player.open(Media(widget.photo.photoPath), play: false);
    player.stream.error.listen((event) {
      if(event.contains("file")) {
        player.open(Media("${appWebChannel.serverAddress}/photos/${widget.photo.id}", httpHeaders: {
          "Authorization": appWebChannel.token
        }), play: false);
      }
      else {
        setState(() {
          errorCaused = true;
        });
      }
    });
    super.initState();
  }

  @override
  void didUpdateWidget(covariant VideoPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.photo.photoPath != widget.photo.photoPath) {
      player.stop();
      player.open(Media(widget.photo.photoPath), play: false);
    }
  }


  @override
  Widget build(BuildContext context) {
    double width = MediaQuery
        .of(context)
        .size
        .width;

    if(errorCaused) {
      return Text(AppLocalizations.of(context).get("@video_error"));
    }

    return Video(
      height: width / (16 / 9),
      controller: videoController
    );
  }
}
