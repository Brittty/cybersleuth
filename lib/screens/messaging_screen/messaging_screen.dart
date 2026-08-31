import 'package:cyber_sleuth/assets/contracts/contract_01.dart';
import 'package:flutter/material.dart';

class MessagingScreen extends StatefulWidget {
  const MessagingScreen({super.key});

  @override
  State<MessagingScreen> createState() => _MessagingScreenState();
}

class _MessagingScreenState extends State<MessagingScreen> {
  final contracts = [InsiderThreatContract()];

  void acceptContract(String id) {
    print("Contract $id Accepted.");
  }

  final currentContractIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          Expanded(
            child: Column(children: [Text("Internal Pointer Variable")]),
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
                  InkWell(
                    onTap: () {
                      acceptContract(contracts[currentContractIndex].id);
                    },
                    child: Container(
                      decoration: BoxDecoration(color: Colors.indigo),
                      alignment: Alignment.center,
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(
                        vertical: 16,
                        horizontal: 10,
                      ),
                      child: Text("Accept Contract"),
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
