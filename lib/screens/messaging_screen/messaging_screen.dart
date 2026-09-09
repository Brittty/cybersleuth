import 'package:cyber_sleuth/providers/contract_provider.dart';
import 'package:cyber_sleuth/providers/chain_of_custody_provider.dart';
import 'package:cyber_sleuth/providers/investigation_provider.dart';
import 'package:cyber_sleuth/providers/os_screen_provider.dart';
import 'package:cyber_sleuth/providers/global_state_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MessagingScreen extends ConsumerStatefulWidget {
  const MessagingScreen({super.key});

  @override
  ConsumerState<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends ConsumerState<MessagingScreen> {
  void acceptContract(String id) {
    ref.invalidate(investigationProvider);
    ref.invalidate(chainOfCustodyProvider);
    ref.invalidate(osScreenProvider);
    ref.read(globalStateProvider.notifier).setActiveContractId(id);
    ref.read(globalStateProvider.notifier).setScreen(AppScreen.chainOfCustody);
  }

  int currentContractIndex = 0;

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
                  padding: const EdgeInsets.only(
                    top: 12,
                    bottom: 0,
                    left: 12,
                    right: 0,
                  ),
                  child: Text(
                    "Messages",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  ),
                ),
                Expanded(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.onSurface.withAlpha(70),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ListView.builder(
                      itemCount: contracts.length,
                      itemBuilder: (context, index) {
                        final contract = contracts[index];
                        return Padding(
                          padding: const EdgeInsets.all(6),
                          child: Material(
                            color: currentContractIndex == index
                                ? colorScheme.primaryContainer
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(8),
                            child: ListTile(
                              selected: currentContractIndex == index,
                              title: Text(
                                contract.sender,
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer
                                      .withAlpha(200),
                                ),
                              ),
                              subtitle: Text(
                                contract.time,
                                style: TextStyle(
                                  color: colorScheme.onPrimaryContainer
                                      .withAlpha(200),
                                ),
                              ),
                              textColor: colorScheme.onPrimaryContainer,
                              onTap: () =>
                                  setState(() => currentContractIndex = index),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 4,
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: const Color.fromARGB(255, 194, 194, 194),
              ),
              clipBehavior: Clip.hardEdge,
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
                              color: colorScheme.secondaryContainer,
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                                bottomRight: Radius.circular(16),
                                bottomLeft: Radius.circular(2),
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withAlpha(10),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              chat,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: colorScheme.onSecondaryContainer,
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
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                        ),
                        alignment: Alignment.center,
                        width: double.infinity,
                        padding: EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 10,
                        ),
                        child: Text(
                          "Accept Contract",
                          style: TextStyle(
                            color: colorScheme.onPrimaryContainer,
                          ),
                        ),
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
