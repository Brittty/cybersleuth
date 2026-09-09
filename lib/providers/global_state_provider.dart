import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AppScreen {
  messaging,
  chainOfCustody,
  os,
  report,
  scoring,
}

class GlobalState {
  final AppScreen currentScreen;
  final String? activeContractId;

  const GlobalState({
    this.currentScreen = AppScreen.messaging,
    this.activeContractId, 
  });

  GlobalState copyWith({
    AppScreen? currentScreen,
    String? activeContractId,
  }) {
    return GlobalState(
      currentScreen: currentScreen ?? this.currentScreen,
      activeContractId: activeContractId,
    );
  }
}

class GlobalStateNotifier extends Notifier<GlobalState> {
  @override
  GlobalState build() {
    return const GlobalState();
  }

  void setScreen(AppScreen screen) {
    state = state.copyWith(
      currentScreen: screen,
      activeContractId: state.activeContractId,
    );
  }

  void setActiveContractId(String? contractId) {
    state = state.copyWith(activeContractId: contractId);
  }
}

final globalStateProvider = NotifierProvider<GlobalStateNotifier, GlobalState>(() {
  return GlobalStateNotifier();
});
