import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/channels/app_method_channel.dart';
import 'package:photos/components/nav_menu.dart';
import 'package:photos/models/app_settings.dart';
import 'package:photos/models/fragment_index.dart';
import 'package:photos/providers/photos_provider.dart';
import 'package:photos/providers/providers.dart';
import 'package:photos/views/albums_view.dart';
import 'package:photos/views/photos_view.dart';
import 'package:photos/models/app_state.dart';

import '../views/settings_view.dart';
import 'app_bar/app_bar_actions.dart';

class MainPage extends ConsumerWidget {
  const MainPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    appMethodChannel.setNavigationBarColor(Theme.of(context).scaffoldBackgroundColor);
    final fragmentIndex = ref.watch(fragmentIndexProvider);
    final selectingItems = ref.watch(selectedItemsProvider) != null;

    return PopScope(
      canPop: !selectingItems,
      onPopInvokedWithResult: (didPop, result) {
        if(selectingItems) {
          ref.read(selectedItemsProvider.notifier).endSelection();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 55,
          centerTitle: false,
          automaticallyImplyLeading: false,
          actions: appbarActions(
            fragmentIndex: fragmentIndex,
            context: context,
            ref: ref,
            selectingItems: selectingItems
          ),
        ),
        body: Stack(
          children: [
            Positioned.fill(
                child: PageView(
                  onPageChanged: (index) {
                    final previousIndex = ref.watch(fragmentIndexProvider);
                    if(previousIndex == FragmentIndex.settings) {
                      appSettings.save();
                    }
                    ref
                        .read(fragmentIndexProvider.notifier)
                        .state = index;

                    if(ref.read(selectedItemsProvider) != null) {
                      ref.read(selectedItemsProvider.notifier).endSelection();
                    }
                  },
                  controller: appState.pageController,
                  children: [
                    PhotosView(photos: ref.watch(photosProvider).idList, placeholder: AppLocalizations.of(context).get("@no_photos")),
                    const AlbumsView(),
                    PhotosView(photos: ref.watch(photosProvider).trash, itemClickEnabled: false, placeholder: AppLocalizations.of(context).get("@no_photos_trash")),
                    const SettingsView(),
                  ],)
            ),
            AnimatedPositioned(
                left: 0,
                right: 0,
                bottom: selectingItems ? -navMenuHeight : 0,
                duration: const Duration(milliseconds: 750),
                curve: Curves.easeOutQuint,
                child: const NavMenu())
          ],
        ),
      ),
    );
  }
}