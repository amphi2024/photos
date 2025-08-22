import 'package:amphi/models/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/providers/transfers_provider.dart';
import 'package:photos/views/transfers_view.dart';

class TransfersButton extends ConsumerWidget {

  final double? iconSize;
  const TransfersButton({super.key, this.iconSize});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Visibility(
        visible: ref.watch(transfersProvider).isNotEmpty,
        child: IconButton(onPressed: () {
          if(App.isWideScreen(context) || App.isDesktop()) {
            showDialog(context: context, builder: (context) {
              return Dialog(
                child: SizedBox(
                  width: 450,
                  height: 500,
                  child: Column(
                    children: [
                      Align(
                        alignment: Alignment.topRight,
                        child: IconButton(onPressed: () {
                          Navigator.pop(context);
                        }, icon: const Icon(Icons.cancel_outlined)),
                      ),
                      const Expanded(child: TransfersView()),
                    ],
                  ),
                ),
              );
            }).then((value) {
              ref.read(transfersProvider.notifier).refresh();
            });
          }
          else {
            showModalBottomSheet(context: context, builder: (context) {
             return const TransfersView();
            });
          }
        }, icon: Icon(Icons.downloading, size: iconSize)));
  }
}
