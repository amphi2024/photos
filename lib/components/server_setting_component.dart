import 'package:flutter/material.dart';
import 'package:amphi/models/app_localizations.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:photos/models/app_settings.dart';

import '../channels/app_web_channel.dart';
import '../utils/bytes_utils.dart';

class ServerSettingComponent extends StatefulWidget {

  const ServerSettingComponent({super.key});

  @override
  State<ServerSettingComponent> createState() => _ServerSettingComponentState();
}

class _ServerSettingComponentState extends State<ServerSettingComponent> {
  int? totalSpace;
  int? usableSpace;
  int? usedSpace;
  bool pending = true;
  final controller = TextEditingController(text: appSettings.serverAddress);

  void testConnection() {
    appSettings.serverAddress = controller.text;
    if(appWebChannel.serverAddress.isNotEmpty) {
      appWebChannel.getStorageInfo(onSuccess: (map) {
        setState(() {
          totalSpace = map["total"];
          usableSpace = map["usable"];
          usedSpace = map["used"];
          pending = false;
        });
      }, onFailed: () {
        setState(() {
          totalSpace = null;
          usableSpace = null;
          usedSpace = null;
          pending = false;
        });
      });
    }
    else {
      pending = false;
    }

  }

  @override
  void initState() {
    testConnection();
    super.initState();
  }

  bool connectionSuccess() {
    return totalSpace != null && usableSpace != null && usedSpace != null;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15.0, bottom: 15.0),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: CircularPercentIndicator(
              radius: 60.0,
              lineWidth: 13.0,
              animation: true,
              percent: connectionSuccess()
                  ? usableSpace! / totalSpace!
                  : 0.3,
              center: pending
                  ? const CircularProgressIndicator() : Text(
                connectionSuccess()
                    ? "${formatBytes(usableSpace!)} /\n${formatBytes(totalSpace!)}"
                    : "",
                style: const TextStyle(fontWeight: FontWeight.bold),
                softWrap: true,
                maxLines: 3,
              ),
              circularStrokeCap: CircularStrokeCap.round,
              progressColor: connectionSuccess()
                  ? Theme.of(context).highlightColor
                  : Theme.of(context).colorScheme.error,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      hintText: AppLocalizations.of(context)
                          .get("@hint_server_address"),
                    )),
                TextButton(
                    onPressed: () {
                      setState(() {
                        pending = true;
                      });
                      testConnection();
                    },
                    child: Text(AppLocalizations.of(context)
                        .get("@test_connection"))),
                Visibility(
                  visible: !connectionSuccess(),
                  child: Text(AppLocalizations.of(context).get("@connection_failed"),
                      style: TextStyle(
                          fontSize: 12,
                          color: connectionSuccess()
                              ? Theme.of(context).highlightColor
                              : Theme.of(context).colorScheme.error)),
                ),

              ],
            ),
          )
        ],
      ),
    );
  }
}