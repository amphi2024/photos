import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/components/photo_widget.dart';
import 'package:photos/providers/current_photo_id_provider.dart';

class DesktopPhotoPage extends ConsumerStatefulWidget {
  final String? id;

  const DesktopPhotoPage({super.key, this.id});

  @override
  DesktopPhotoPageState createState() => DesktopPhotoPageState();
}

class DesktopPhotoPageState extends ConsumerState<DesktopPhotoPage> {
  bool thumbnail = true;
  final photoTransformController = TransformationController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      setState(() {
        thumbnail = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final String photoId = widget.id ?? ref.watch(currentPhotoIdProvider);
    ref.listen(currentPhotoIdProvider, (previous, next) {
      if (next.isEmpty) {
        Navigator.pop(context);
      }
    });
    return Scaffold(
      backgroundColor: Theme
          .of(context)
          .cardColor,
      body: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              maxScale: 30,
              transformationController: photoTransformController,
              scaleEnabled: true,
              panEnabled: true,
              minScale: 0.5,
              child: Hero(
                  tag: photoId,
                  child: PhotoWidget(id: photoId, thumbnail: thumbnail)),
            ),
          )
        ],
      ),
    );
  }
}