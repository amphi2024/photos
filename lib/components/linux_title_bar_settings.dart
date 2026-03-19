import 'dart:convert';
import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:amphi/utils/path_utils.dart';
import 'package:amphi/widgets/dialogs/confirmation_dialog.dart';
import 'package:amphi/widgets/window/adaptive_linux_window_buttons.dart';
import 'package:amphi/widgets/window/adwaita_window_buttons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_context_menu/flutter_context_menu.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:linux_csd_buttons/linux_csd_buttons.dart';
import 'package:photos/models/app_storage.dart';
import 'package:photos/providers/csd_themes_provider.dart';
import 'package:photos/utils/generated_id.dart';
import 'package:photos/utils/toast.dart';
import 'package:window_manager/window_manager.dart';

import '../main.dart';
import '../models/app_settings.dart';

class LinuxTitleBarSettings extends ConsumerStatefulWidget {
  const LinuxTitleBarSettings({super.key});

  @override
  LinuxTitleBarSettingsState createState() => LinuxTitleBarSettingsState();
}

class LinuxTitleBarSettingsState extends ConsumerState<LinuxTitleBarSettings> {
  @override
  Widget build(BuildContext context) {
    if (!Platform.isLinux) return const SizedBox.shrink();

    final csdThemesState = ref.watch(csdThemesProvider);
    final themes = csdThemesState.themes;
    final idList = csdThemesState.idList;

    final selectedThemeId = appSettings.selectedWindowButtonsTheme;
    final selectedThemeIndex = selectedThemeId != null ? idList.indexOf(selectedThemeId) + 1 : 0;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10),
          child: Row(
            children: [
              Text(AppLocalizations.of(context).get("prefers_custom_title_bar")),
              Checkbox(
                  value: appSettings.prefersCustomTitleBar,
                  onChanged: (value) {
                    if (value != null) {
                      mainScreenKey.currentState?.setState(() {
                        appSettings.prefersCustomTitleBar = value;
                        windowManager.setTitleBarStyle(appSettings.prefersCustomTitleBar ? TitleBarStyle.hidden : TitleBarStyle.normal);
                      });
                      setState(() {});
                    }
                  })
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 10.0, right: 10),
          child: Row(
            children: [
              Text(AppLocalizations.of(context).get("window_controls_on_left")),
              Checkbox(
                  value: appSettings.windowButtonsOnLeft,
                  onChanged: (value) {
                    if (value != null) {
                      mainScreenKey.currentState?.setState(() {
                        appSettings.windowButtonsOnLeft = value;
                      });
                      setState(() {});
                    }
                  })
            ],
          ),
        ),
        Visibility(
            visible: appSettings.prefersCustomTitleBar,
            child: SizedBox(
              height: 90,
              child: GridView.builder(
                  itemCount: idList.length + 2,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 3),
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onSecondaryTapUp: (details) {
                        if (index == 0 || index == idList.length + 1) {
                          return;
                        }
                        final pointerPosition = details.globalPosition;
                        showContextMenu(context,
                            contextMenu: ContextMenu(padding: EdgeInsets.zero, position: pointerPosition, entries: [
                              TextMenuItem(
                                  onSelected: (value) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          return ConfirmationDialog(
                                              title: AppLocalizations.of(context).get("@dialog_title_delete_theme"), onConfirmed: () async {
                                                final id = idList[index - 1];
                                                final file = File(PathUtils.join(appStorage.selectedUser.storagePath, "window_button_themes", id));
                                                await file.delete();
                                                ref.read(csdThemesProvider.notifier).deleteTheme(id);
                                          });
                                        });
                                  },
                                  label: Text(AppLocalizations.of(context).get("delete")))
                            ]));
                      },
                      onTap: () async {
                        if (index == idList.length + 1) {
                          final result = await FilePicker.platform.pickFiles(allowMultiple: true, type: FileType.any);
                          if (result == null) {
                            return;
                          }
                          for (var xFile in result.xFiles) {
                            try {
                              final fileContent = await xFile.readAsString();
                              final theme = CsdTheme.fromJson(jsonDecode(fileContent));
                              final themesDirectory = Directory(PathUtils.join(appStorage.selectedUser.storagePath, "window_button_themes"));
                              final id = await generatedCsdThemeId();
                              if (!await themesDirectory.exists()) {
                                await themesDirectory.create();
                              }
                              final file = File(PathUtils.join(appStorage.selectedUser.storagePath, "window_button_themes", id));
                              await file.writeAsString(fileContent);
                              ref.read(csdThemesProvider.notifier).insertTheme(id, theme);
                            } catch (e) {
                              if (context.mounted) {
                                showToast(context, AppLocalizations.of(context).get("failed_to_parse_theme"));
                              }
                            }
                          }
                        } else if (index == 0) {
                          mainScreenKey.currentState?.setState(() {
                            appSettings.selectedWindowButtonsTheme = null;
                          });
                          setState(() {});
                        } else {
                          mainScreenKey.currentState?.setState(() {
                            appSettings.selectedWindowButtonsTheme = idList[index - 1];
                          });
                          setState(() {});
                        }
                      },
                      child: Container(
                        decoration:
                            index == selectedThemeIndex ? BoxDecoration(border: Border.all(color: Theme.of(context).highlightColor, width: 2)) : null,
                        child: Center(
                            child: _Item(
                          index: index,
                          idList: idList,
                          themes: themes,
                        )),
                      ),
                    );
                  }),
            ))
      ],
    );
  }
}

class _Item extends StatelessWidget {
  final int index;
  final List<String> idList;
  final Map<String, CsdTheme> themes;

  const _Item({required this.index, required this.idList, required this.themes});

  @override
  Widget build(BuildContext context) {
    if (index == 0) {
      return Stack(
        children: [
          Center(
            child: IgnorePointer(
              ignoring: true,
              child: AdwaitaWindowButtons(
                onClose: () async {},
                padding: 0,
                windowButtonsOnLeft: appSettings.windowButtonsOnLeft,
              ),
            ),
          ),
          const Positioned.fill(child: MouseRegion())
        ],
      );
    }
    if (index == idList.length + 1) {
      return const Icon(Icons.add_circle_outline);
    }
    return Stack(
      children: [
        Center(
          child: IgnorePointer(
            ignoring: true,
            child: AdaptiveLinuxWindowButtons(
              theme: themes[idList[index - 1]],
              onClose: () async {},
              windowButtonsOnLeft: appSettings.windowButtonsOnLeft,
              padding: 0,
            ),
          ),
        ),
        const Positioned.fill(child: MouseRegion())
      ],
    );
  }
}
