import 'package:cyber_sleuth/models/case_data_model.dart';
import 'package:cyber_sleuth/models/contract_model.dart';
import 'package:cyber_sleuth/models/evidence_model.dart';

import 'package:cyber_sleuth/assets/contracts/contract_01/sys_dev_042.dart';
import 'package:cyber_sleuth/assets/contracts/contract_01/sys_ops_089.dart';
import 'package:cyber_sleuth/assets/contracts/contract_01/sys_qa_112.dart';

// ============================================================
// CONTRACT 01 — Insider Threat: Data Exfiltration at NovaTech
// ============================================================
// Scenario: Senior developer Priya Menon accessed restricted R&D
// servers after hours, exfiltrated proprietary ML model source
// code by emailing encrypted archives to her personal Gmail.
// ============================================================

class InsiderThreatContract extends ContractModel {
  InsiderThreatContract()
      : super(
          id: 'contract_01',
          sender: 'IT Operations Manager',
          time: '10:30 AM',
          chats: const [
            'Urgent Notice: We have detected an active insider data theft occurrence within our organization.',
            'A rogue employee with elevated credentials has exfiltrated confidential database files and intellectual property.',
            'I have granted your team administrative access to our internal network to investigate.',
            'Your objective is to gather the disk forensic data collected from the compromised target systems.',
            'We have imaged drives from three employees with access to the affected R&D servers.',
            'Please analyze the forensic artifacts immediately before the perpetrator attempts to wipe the evidence.',
          ],
          caseData: _caseData,
        );
}

// ──────────────────────────────────────────────────────────────
//  CASE DATA
// ──────────────────────────────────────────────────────────────

const _caseData = CaseData(
  suspectDiskId: 'DISK-NVT-0217',
  diskImages: [priyaDisk, rajDisk, ananyaDisk],
  correctEvidence: _correctEvidence,
  correctTimeline: _correctTimeline,
);

// ──────────────────────────────────────────────────────────────
//  CORRECT EVIDENCE & TIMELINE
// ──────────────────────────────────────────────────────────────

const _correctEvidence = [
  CorrectEvidence(
    id: 'priya_access_01',
    category: 'access_log',
    title: 'After-hours SSH to R&D server',
    explanation:
        'Priya SSH\'d into rd-server-03.internal at 11:45 PM — well outside business hours and targeting a restricted R&D server she had no deployment reason to access.',
  ),
  CorrectEvidence(
    id: 'priya_access_02',
    category: 'access_log',
    title: 'File copy from R&D source directory',
    explanation:
        'Bulk file copy from /projects/ml-core/src/ to /tmp/export/ at 12:30 AM indicates deliberate exfiltration of source code.',
  ),
  CorrectEvidence(
    id: 'priya_email_03',
    category: 'email',
    title: 'Encrypted archive sent to personal email',
    explanation:
        'Email to priya.personal.372@gmail.com with ml_model_v3_FINAL.tar.gz.enc attachment — sending encrypted proprietary data to personal email is a clear exfiltration vector.',
  ),
  CorrectEvidence(
    id: 'priya_file_01',
    category: 'file',
    title: 'Exfiltration script (export_script.sh)',
    explanation:
        'A bash script that tars the ML source directory and encrypts it with GPG — purpose-built tooling for data theft.',
  ),
  CorrectEvidence(
    id: 'priya_net_03',
    category: 'network',
    title: 'SMTP traffic to external Gmail servers',
    explanation:
        'Outbound SMTP connection to 142.250.185.109 (Gmail) carrying 47 MB — matches the encrypted archive size and confirms data left the network.',
  ),
];

const _correctTimeline = [
  TimelineEvent(
    date: '2026-08-14',
    time: '23:45',
    description: 'SSH login to rd-server-03.internal',
    evidenceId: 'priya_access_01',
  ),
  TimelineEvent(
    date: '2026-08-15',
    time: '00:12',
    description: 'Accessed /projects/ml-core/src/ directory',
    evidenceId: 'priya_access_02',
  ),
  TimelineEvent(
    date: '2026-08-15',
    time: '00:30',
    description: 'Bulk file copy to /tmp/export/',
    evidenceId: 'priya_access_02',
  ),
  TimelineEvent(
    date: '2026-08-15',
    time: '00:45',
    description: 'Created export_script.sh and ran encryption',
    evidenceId: 'priya_file_01',
  ),
  TimelineEvent(
    date: '2026-08-15',
    time: '01:05',
    description:
        'Emailed ml_model_v3_FINAL.tar.gz.enc to personal Gmail',
    evidenceId: 'priya_email_03',
  ),
  TimelineEvent(
    date: '2026-08-15',
    time: '01:05',
    description:
        'SMTP transfer of 47 MB to 142.250.185.109 (smtp.gmail.com)',
    evidenceId: 'priya_net_03',
  ),
];

// ============================================================
//  DISK 1 — Priya Menon (SUSPECT)
// ============================================================

