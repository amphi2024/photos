
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/transfer.dart';

class TransfersNotifier extends Notifier<Map<String, Transfer>> {

  @override
  Map<String, Transfer> build() {
    return {};
  }

  void insertItem(Transfer transfer) {
    state = {...state, transfer.id: transfer};
  }

  void removeItem(String id) {
    final transfers = {...state};
    transfers.remove(id);
    state = transfers;
  }

}

final transfersProvider = NotifierProvider<TransfersNotifier, Map<String, Transfer>>(TransfersNotifier.new);