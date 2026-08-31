import 'package:cyber_sleuth/assets/contracts/contract_01.dart';
import 'package:cyber_sleuth/providers/global_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({super.key});

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> {
  final contracts = [InsiderThreatContract()];

  void acceptContract(String id) {
    ref.read(globalStateProvider.notifier).setActiveContractId(id);
    ref.read(globalStateProvider.notifier).setScreen(AppScreen.os);
  }

  final currentContractIndex = 0;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
              Padding(
                padding: const EdgeInsets.all(12),
                child: Text("Messages", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),),
              ),
              ...contracts.map((it) {
              return Container(
                height: 60,
                width: double.infinity,
                margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8)
                ),
                child:Text(it.sender));
            }).toList()]),
          ),
          Expanded(
            flex: 4,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Expanded(
                    child: ListView.builder(
                      itemCount: contracts[currentContractIndex].chats.length,
                      itemBuilder: (context, idx) {
                        final chat = contracts[currentContractIndex].chats[idx];
                        return Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            constraints: BoxConstraints(
                              maxWidth:
                                  MediaQuery.of(context).size.width * 0.55,
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(150),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              chat,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () {
                        acceptContract(contracts[currentContractIndex].id);
                      },
                      child: Container(
                        decoration: BoxDecoration(color: colorScheme.primaryContainer),
                        alignment: Alignment.center,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 10,
                        ),
                        child: Text("Accept Contract"),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
