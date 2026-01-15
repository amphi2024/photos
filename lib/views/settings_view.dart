import 'dart:io';

import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/app_settings.dart';
import 'package:photos/views/fragment_view_mixin.dart';

import '../channels/app_method_channel.dart';
import '../components/server_setting_component.dart';

class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> with FragmentViewMixin {

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(
        left: 8,
        right: 8
      ),
      children: [
        Row(
          children: [
            Text(AppLocalizations.of(context).get("@use_my_own_server")),
            Checkbox(value: appSettings.useOwnServer, onChanged: (value) {
              if(value != null) {
                setState(() {
                  appSettings.useOwnServer = value;
                });
              }
            })
          ],
        ),
        Visibility(
            visible: appSettings.useOwnServer,
            child: const ServerSettingComponent()),
        Visibility(
            visible: appSettings.useOwnServer,
            child: TitledCheckBox(
                title: AppLocalizations.of(context).get("automatically_check_server_updates"),
                value: appSettings.autoCheckServerUpdate,
                onChanged: (value) {
                  setState(() {
                    appSettings.autoCheckServerUpdate = value;
                  });
                })),
        Visibility(
            visible: Platform.isAndroid &&
                appMethodChannel.systemVersion >= 29,
            child: TitledCheckBox(
                title: AppLocalizations.of(context).get("@transparent_navigation_bar"),
                value: appSettings.transparentNavigationBar,
                onChanged: (value) {
                  setState(() {
                    appSettings.transparentNavigationBar = value!;
                  });
                })),
        TitledCheckBox(
            title: AppLocalizations.of(context).get("automatically_check_updates"),
            value: appSettings.autoCheckUpdate,
            onChanged: (value) {
              setState(() {
                appSettings.autoCheckUpdate = value;
              });
            }),
      ],
    );
  }
}

class TitledCheckBox extends StatelessWidget {
  final String title;
  final bool value;
  final Function onChanged;
  const TitledCheckBox({super.key, required this.title, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Padding(
            padding: const EdgeInsets.only(left: 10, top: 5),
            child: Text(
              title,
              textAlign: TextAlign.left,
            ),
          ),
        ),
        Checkbox(
            value: value, onChanged: (value) {
          onChanged(value);
        }),
      ],
    );
  }
}