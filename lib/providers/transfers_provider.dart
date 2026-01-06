
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:photos/models/transfer.dart';

class TransfersNotifier extends Notifier<List<Transfer>> {

  @override
  List<Transfer> build() {
    return [];
  }

  void insertItem(Transfer transfer) {
    final index = state.indexWhere((e) => e.id == transfer.id);
    if (index == -1) {
      state = [...state, transfer];
    } else {
      final newState = [...state];
      newState[index] = transfer;
      state = newState;
    }
  }

  void removeItem(String id) {
    state = state.where((e) => e.id != id).toList();
  }

  void refresh() {
    state = state.where((e) => e.error == false || e.total - e.received < 1000 || e.received - e.total < 1000).toList();
  }

}

final transfersProvider = NotifierProvider<TransfersNotifier, List<Transfer>>(TransfersNotifier.new);