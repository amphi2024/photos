import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/components/album_preview.dart';
import 'package:photos/components/nav_menu.dart';
import 'package:photos/pages/album_page.dart';
import 'package:photos/providers/albums_provider.dart';
import 'package:photos/providers/providers.dart';
import 'package:photos/views/fragment_view_mixin.dart';

import '../models/app_storage.dart';

class AlbumsView extends ConsumerStatefulWidget {
  const AlbumsView({super.key});

  @override
  ConsumerState<AlbumsView> createState() => _AlbumsViewState();
}

class _AlbumsViewState extends ConsumerState<AlbumsView> with FragmentViewMixin {
  Future<void> refresh() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    appStorage.refreshDataWithServer(ref);
  }

  @override
  Widget build(BuildContext context) {
    final idList = ref.watch(albumsProvider).idList;
    if (idList.isEmpty) {
      return RefreshIndicator(
        onRefresh: refresh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          children: [
            Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(AppLocalizations.of(context).get("@no_albums")),
              ),
            ),
          ],
        ),
      );
    }

    int axisCount = (MediaQuery.of(context).size.width / 150).toInt();
    if (axisCount < 0) {
      axisCount = 1;
    }

    return RefreshIndicator(
      onRefresh: refresh,
      child: GridView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          controller: scrollController,
          itemCount: idList.length,
          padding: EdgeInsets.only(
              top: 4, left: 8, right: 8, bottom: MediaQuery.of(context).padding.bottom + navMenuHeight),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: axisCount, mainAxisSpacing: 8, crossAxisSpacing: 8),
          itemBuilder: (context, index) {
            final id = idList[index];
            return Stack(
              children: [
                Positioned.fill(
                  child: AlbumPreview(
                      id: id,
                      onLongPressed: () {
                        if(ref.read(selectedItemsProvider) == null) {
                          ref.read(selectedItemsProvider.notifier).startSelection();
                        }
                      },
                      onPressed: () {
                        Navigator.push(context, CupertinoPageRoute(builder: (context) => AlbumPage(id: id)));
                      }),
                ),
                Positioned(
                  left: 0,
                    top: 0,
                    child: AnimatedOpacity(
                      opacity: ref.watch(selectedItemsProvider) != null ? 1 : 0,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutQuint,
                      child: Checkbox(value: ref.watch(selectedItemsProvider)?.contains(id) ?? false, onChanged: (value) {
                        if(value == true) {
                          ref.read(selectedItemsProvider.notifier).addId(id);
                        }
                        else {
                          ref.read(selectedItemsProvider.notifier).removeId(id);
                        }
                      }),
                    )
                )
              ],
            );
          }),
    );
  }
}
