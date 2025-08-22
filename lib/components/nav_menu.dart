import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/app_state.dart';
import 'package:photos/models/fragment_index.dart';
import 'package:photos/providers/providers.dart';

const double navMenuHeight = 100;

class NavMenu extends ConsumerStatefulWidget {
  const NavMenu({super.key});

  @override
  NavMenuState createState() => NavMenuState();
}

class NavMenuState extends ConsumerState<NavMenu> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: navMenuHeight,
      decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor),
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).padding.bottom),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            LabeledIconButton(icon: Icons.photo_library_outlined, fragmentIndex: FragmentIndex.photos, label: AppLocalizations.of(context).get("@library")),
            LabeledIconButton(icon: Icons.photo_album, fragmentIndex: FragmentIndex.albums, label: AppLocalizations.of(context).get("@albums")),
            LabeledIconButton(icon: Icons.delete, fragmentIndex: FragmentIndex.trash, label: AppLocalizations.of(context).get("@trash")),
            LabeledIconButton(icon: Icons.settings, fragmentIndex: FragmentIndex.settings, label: AppLocalizations.of(context).get("@settings")),
          ],
        ),
      ),
    );
  }
}

class LabeledIconButton extends ConsumerWidget {
  final IconData icon;
  final String label;
  final int fragmentIndex;

  const LabeledIconButton({super.key, required this.icon, required this.label, required this.fragmentIndex});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeData = Theme.of(context);
    final color = ref.watch(fragmentIndexProvider) == fragmentIndex ? themeData.highlightColor : themeData.dividerColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          appState.pageController.jumpToPage(fragmentIndex);
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: color,
                size: 30,
              ),
              const SizedBox(height: 4),
              Text(label, style: TextStyle(color: color, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }
}
