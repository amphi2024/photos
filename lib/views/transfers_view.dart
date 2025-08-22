import 'package:amphi/models/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/providers/transfers_provider.dart';
import 'package:photos/utils/bytes_utils.dart';

class TransfersView extends ConsumerWidget {
  const TransfersView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(transfersProvider);
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final transfer = list[index];
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Text(transfer.title),
              Visibility(
                  visible: transfer.error,
                  child: Text(
                      transfer.upload ? AppLocalizations.of(context).get("@upload_failed") : AppLocalizations.of(context).get("@download_failed"))),
              LinearProgressIndicator(value: transfer.received / transfer.total),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [Text(formatBytes(transfer.received)), Text(formatBytes(transfer.total))],
              )
            ],
          ),
        );
      },
    );
  }
}
