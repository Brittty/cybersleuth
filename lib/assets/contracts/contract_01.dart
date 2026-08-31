import 'package:cyber_sleuth/models/contract_model.dart';

class InsiderThreatContract extends ContractModel {
  InsiderThreatContract({
    super.id = 'contract_01',
    super.sender = 'IT Operations Manager',
    super.time = '10:30 AM',
    super.chats = const [
      'Urgent Notice: We have detected an active insider data theft occurrence within our organization.',
      'A rogue employee with elevated credentials has exfiltrated confidential database files and intellectual property.',
      'I have granted your team administrative access to our internal network to investigate.',
      'Your objective is to gather the disk forensic data collected from the compromised target systems.',
      'Please analyze the forensic artifacts immediately before the perpetrator attempts to wipe the evidence.',
    ],
  });
}
