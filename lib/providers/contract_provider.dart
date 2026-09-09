import 'package:cyber_sleuth/assets/contracts/contract_01.dart';
import 'package:cyber_sleuth/assets/contracts/contract_02.dart';
import 'package:cyber_sleuth/assets/contracts/contract_03.dart';
import 'package:cyber_sleuth/models/contract_model.dart';
import 'package:cyber_sleuth/providers/global_state_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final contracts = List<ContractModel>.unmodifiable([
  InsiderThreatContract(),
  RansomwareContract(),
  PayrollTheftContract(),
]);

final activeContractProvider = Provider<ContractModel>((ref) {
  final id = ref.watch(
    globalStateProvider.select((state) => state.activeContractId),
  );
  return contracts.firstWhere((contract) => contract.id == id);
});
