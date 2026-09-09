import 'contract_02_files.dart';

import 'package:cyber_sleuth/models/case_data_model.dart';
import 'package:cyber_sleuth/models/contract_model.dart';
import 'package:cyber_sleuth/models/disk_image_model.dart';
import 'package:cyber_sleuth/models/evidence_model.dart';
import 'package:cyber_sleuth/models/file_node_model.dart';
import 'package:cyber_sleuth/models/forensic_models.dart';

// Fictional training scenario. All timestamps use the same local timezone.
class RansomwareContract extends ContractModel {
  RansomwareContract()
    : super(
        id: 'contract_02',
        sender: 'Meridian Incident Response',
        time: '11:00 AM',
        chats: [
          'Ransomware at Meridian Logistics',
          'Shared invoices became unreadable shortly after a supplier message arrived. Identify the initial compromised workstation and reconstruct the infection; its owner may be a victim.',
          'Three disk images are ready. Verify their hashes, compare files, email, access logs and network captures, then submit the implicated disk and an evidence timeline.',
          'An internal backup and an audit review occurred nearby. Check their approvals before treating routine activity as evidence.',
        ],
        caseData: _caseData,
      );
}

const _caseData = CaseData(
  internalEmailDomains: {'company.example'},
  supportingEvidenceIds: {
    'case02_sys_2:/Work/restore_test.txt',
    'case02_sys_3:/Work/aggregate_totals.csv',
    'case02_sys_3:/Work/audit_minutes.txt',
    'sys-fin-014_file_02',
    'sys-fin-014:/Work/supplier_directory.csv',
    'case02_sys_2_file_01',
    'case02_sys_2_email_01',
    'case02_sys_2_access_02',
    'case02_sys_2_net_01',
    'case02_sys_2:/Work/CHG-204.txt',
    'case02_sys_3_file_01',
    'case02_sys_3_email_01',
    'case02_sys_3_access_02',
    'case02_sys_3_net_01',
    'case02_sys_3:/Work/AUD-318.txt',
  },
  suspectDiskId: 'DISK-02-014',
  diskImages: [
    DiskImage(
      diskId: 'DISK-02-014',
      ownerName: 'SYS-FIN-014',
      ownerRole: 'Accounts Payable Analyst',
      originalHash:
          '78e3b3e669abcfc14f10454098e97657c34c2c12fea31740bb9d65391609019d',
      rootDirectory: FileNode(
        id: 'sys-fin-014:/',
        name: '/',
        isDirectory: true,
        children: [
          ...case02Disk1ExtraFolders,
          FileNode(
            id: 'sys-fin-014:/Documents',
            name: 'Documents',
            isDirectory: true,
            children: [
              FileNode(
                id: 'sys-fin-014_file_01',
                name: 'endpoint_events.txt',
                sizeBytes: 193,
                lastModified: '2026-08-21 09:15:00',
                textContent: '2026-08-21 09:15:00 invoice-helper.exe began rewriting /shares/invoices/*.pdf with extension .locked.\n2026-08-21 09:15:40 214 files changed; process parent WINWORD; no approved encryption job.\n',
                hexPreview:
                    '00000000  32 30 32 36 2D 30 38 2D 32 31 20 30 39 3A 31 35',
              ),
              FileNode(
                id: 'sys-fin-014_file_02',
                name: 'READ_ME.txt',
                sizeBytes: 99,
                lastModified: '2026-08-21 09:18:00',
                textContent: 'Your invoice files have been locked. Incident token: MD-214. Contact recovery@locked-help.example.\n',
                hexPreview:
                    '00000000  59 6F 75 72 20 69 6E 76 6F 69 63 65 20 66 69 6C',
              ),
              FileNode(
                id: 'sys-fin-014_file_notes',
                name: 'meeting_notes.txt',
                sizeBytes: 87,
                lastModified: '2026-08-21 08:30:00',
                textContent: 'Weekly review: reconcile outstanding invoices and confirm the internal audit schedule.\n',
                hexPreview:
                    '00000000  57 65 65 6B 6C 79 20 72 65 76 69 65 77 3A 20 72',
              ),
            ],
          ),
        ],
      ),
      accessLogs: [
        AccessLogEntry(
          id: 'sys-fin-014_access_00',
          timestamp: '2026-08-21 08:45:00',
          user: 'sys-fin-014',
          action: 'LOGIN',
          target: 'Local workstation',
          status: 'SUCCESS',
        ),
        AccessLogEntry(
          id: 'sys-fin-014_access_01',
          timestamp: '2026-08-21 09:10:00',
          user: 'sys-fin-014',
          action: 'DOCUMENT_OPEN',
          target: 'Downloads/Invoice_August.docm; WINWORD launched invoice-helper.exe',
          status: 'SUCCESS',
        ),
        AccessLogEntry(
          id: 'sys-fin-014_access_02',
          timestamp: '2026-08-21 09:18:00',
          user: 'sys-fin-014',
          action: 'FILE_CREATE',
          target: '/shares/invoices/READ_ME.txt; invoice-helper.exe',
          status: 'SUCCESS',
        ),
      ],
      emailRecords: [
        EmailRecord(
          id: 'sys-fin-014_email_01',
          timestamp: '2026-08-21 09:00:00',
          from: 'billing@supplier-review.example',
          to: 'sys-fin-014@company.example',
          subject: 'Overdue invoice — review required',
          body: 'Please open Invoice_August.docm and enable editing to review the overdue balance.',
          attachments: ['Invoice_August.docm'],
          headers: {'Message-ID': '<sys-fin-014_email_01@mail.example>'},
        ),
        EmailRecord(
          id: 'sys-fin-014_email_02',
          timestamp: '2026-08-21 08:20:00',
          from: 'manager@company.example',
          to: 'sys-fin-014@company.example',
          subject: 'Daily priorities',
          body: 'Please finish reconciliation on the internal systems before noon.',
          attachments: [],
          headers: {'Message-ID': '<sys-fin-014_email_02@mail.example>'},
        ),
      ],
      networkCaptures: [
        NetworkCapture(
          id: 'sys-fin-014_net_00',
          timestamp: '2026-08-21 08:46:00',
          sourceIp: '10.20.0.14',
          destIp: '10.20.0.2',
          protocol: 'HTTPS',
          bytes: 2048,
          info: 'Internal intranet dashboard',
        ),
        NetworkCapture(
          id: 'sys-fin-014_net_01',
          timestamp: '2026-08-21 09:12:00',
          sourceIp: '10.20.0.14',
          destIp: '198.51.100.42',
          protocol: 'HTTPS',
          bytes: 98304,
          info: 'Endpoint-correlated HTTPS download from supplier-review.example/invoice-helper.exe; process WINWORD; 98304 bytes received',
        ),
      ],
    ),
    DiskImage(
      diskId: 'DISK-02-002',
      ownerName: 'CASE02_SYS_2',
      ownerRole: 'Backup Operator',
      originalHash:
          '808984a7e170a152ad37d389289dbe23f8235be853c5f023d4068c78883171d6',
      rootDirectory: FileNode(
        id: 'case02_sys_2:/',
        name: '/',
        isDirectory: true,
        children: [
          ...case02Disk2ExtraFolders,
          FileNode(
            id: 'case02_sys_2:/Documents',
            name: 'Documents',
            isDirectory: true,
            children: [
              FileNode(
                id: 'case02_sys_2_file_01',
                name: 'backup_receipt.txt',
                sizeBytes: 151,
                lastModified: '2026-08-21 09:08:00',
                textContent: 'Change CHG-204 approved: 09:05 internal backup to 10.20.0.50. 524288000 bytes copied; restore check passed. No external destination or file encryption.',
                hexPreview:
                    '00000000  43 68 61 6E 67 65 20 43 48 47 2D 32 30 34 20 61',
              ),
              FileNode(
                id: 'case02_sys_2_file_02',
                name: 'work_notes.txt',
                sizeBytes: 85,
                lastModified: '2026-08-21 08:30:00',
                textContent: 'Follow the approved retention schedule. Document all changes in the internal ticket.\n',
                hexPreview:
                    '00000000  46 6F 6C 6C 6F 77 20 74 68 65 20 61 70 70 72 6F',
              ),
            ],
          ),
        ],
      ),
      accessLogs: [
        AccessLogEntry(
          id: 'case02_sys_2_access_01',
          timestamp: '2026-08-21 08:50:00',
          user: 'case02_sys_2',
          action: 'LOGIN',
          target: 'Internal workstation',
          status: 'SUCCESS',
        ),
        AccessLogEntry(
          id: 'case02_sys_2_access_02',
          timestamp: '2026-08-21 09:05:00',
          user: 'case02_sys_2',
          action: 'BACKUP',
          target: 'Internal backup share; CHG-204',
          status: 'SUCCESS',
        ),
      ],
      emailRecords: [
        EmailRecord(
          id: 'case02_sys_2_email_01',
          timestamp: '2026-08-21 08:00:00',
          from: 'manager@company.example',
          to: 'case02_sys_2@company.example',
          subject: 'Approved backup window',
          body: 'Change CHG-204 is approved for 09:00 to 09:10. Start the internal backup to 10.20.0.50 at 09:05, then perform a restore check and record the result. External destinations and file encryption are not authorized.',
          attachments: [],
          headers: {'Message-ID': '<case02_sys_2_email_01@mail.example>'},
        ),
      ],
      networkCaptures: [
        NetworkCapture(
          id: 'case02_sys_2_net_01',
          timestamp: '2026-08-21 09:05:00',
          sourceIp: '10.20.0.2',
          destIp: '10.20.0.50',
          protocol: 'HTTPS',
          bytes: 524288000,
          info: 'Internal backup upload; CHG-204',
        ),
      ],
    ),
    DiskImage(
      diskId: 'DISK-02-003',
      ownerName: 'CASE02_SYS_3',
      ownerRole: 'Internal Auditor',
      originalHash:
          '973220a6d5ab0b7cc117e2d69e710487f4355a8b1e19c31042a3d7a8e36d6914',
      rootDirectory: FileNode(
        id: 'case02_sys_3:/',
        name: '/',
        isDirectory: true,
        children: [
          ...case02Disk3ExtraFolders,
          FileNode(
            id: 'case02_sys_3:/Documents',
            name: 'Documents',
            isDirectory: true,
            children: [
              FileNode(
                id: 'case02_sys_3_file_01',
                name: 'audit_scope.txt',
                sizeBytes: 123,
                lastModified: '2026-08-21 09:08:00',
                textContent: 'Audit AUD-318 authorizes aggregate totals only, stored on 10.20.0.60. No employee bank details or source invoices included.',
                hexPreview:
                    '00000000  41 75 64 69 74 20 41 55 44 2D 33 31 38 20 61 75',
              ),
              FileNode(
                id: 'case02_sys_3_file_02',
                name: 'work_notes.txt',
                sizeBytes: 85,
                lastModified: '2026-08-21 08:30:00',
                textContent: 'Follow the approved retention schedule. Document all changes in the internal ticket.\n',
                hexPreview:
                    '00000000  46 6F 6C 6C 6F 77 20 74 68 65 20 61 70 70 72 6F',
              ),
            ],
          ),
        ],
      ),
      accessLogs: [
        AccessLogEntry(
          id: 'case02_sys_3_access_01',
          timestamp: '2026-08-21 08:50:00',
          user: 'case02_sys_3',
          action: 'LOGIN',
          target: 'Internal workstation',
          status: 'SUCCESS',
        ),
        AccessLogEntry(
          id: 'case02_sys_3_access_02',
          timestamp: '2026-08-21 09:05:00',
          user: 'case02_sys_3',
          action: 'REPORT_READ',
          target: 'Aggregate audit dashboard; AUD-318',
          status: 'SUCCESS',
        ),
      ],
      emailRecords: [
        EmailRecord(
          id: 'case02_sys_3_email_01',
          timestamp: '2026-08-21 08:00:00',
          from: 'manager@company.example',
          to: 'case02_sys_3@company.example',
          subject: 'Audit scope approved',
          body: 'Audit AUD-318 authorizes aggregate totals only, stored on 10.20.0.60. No employee bank details or source invoices included.',
          attachments: [],
          headers: {'Message-ID': '<case02_sys_3_email_01@mail.example>'},
        ),
      ],
      networkCaptures: [
        NetworkCapture(
          id: 'case02_sys_3_net_01',
          timestamp: '2026-08-21 09:05:00',
          sourceIp: '10.20.0.3',
          destIp: '10.20.0.60',
          protocol: 'HTTPS',
          bytes: 4096,
          info: 'Aggregate report download; AUD-318',
        ),
      ],
    ),
  ],
  correctEvidence: [
    CorrectEvidence(
      id: 'sys-fin-014_email_01',
      category: 'email',
      title: 'Overdue invoice — review required',
      explanation: 'The supplier lure carried the document later opened on this workstation.',
    ),
    CorrectEvidence(
      id: 'sys-fin-014_access_01',
      category: 'access_log',
      title: 'DOCUMENT_OPEN',
      explanation: 'The document spawned an unexpected executable, linking the lure to execution.',
    ),
    CorrectEvidence(
      id: 'sys-fin-014_net_01',
      category: 'network',
      title: 'Payload download',
      explanation: 'The endpoint-correlated download identifies the payload source and process.',
    ),
    CorrectEvidence(
      id: 'sys-fin-014_file_01',
      category: 'file',
      title: 'Invoice files encrypted',
      explanation:
          'Endpoint events show the same process encrypting the invoice share.',
    ),
    CorrectEvidence(
      id: 'sys-fin-014_access_02',
      category: 'access_log',
      title: 'FILE_CREATE',
      explanation:
          'The process deposited a ransom note after rewriting the files.',
    ),
  ],
  correctTimeline: [
    TimelineEvent(
      date: '2026-08-21',
      time: '09:00',
      description: 'Overdue invoice — review required',
      evidenceId: 'sys-fin-014_email_01',
    ),
    TimelineEvent(
      date: '2026-08-21',
      time: '09:10',
      description: 'DOCUMENT_OPEN',
      evidenceId: 'sys-fin-014_access_01',
    ),
    TimelineEvent(
      date: '2026-08-21',
      time: '09:12',
      description: 'Payload download',
      evidenceId: 'sys-fin-014_net_01',
    ),
    TimelineEvent(
      date: '2026-08-21',
      time: '09:15',
      description: 'Invoice files encrypted',
      evidenceId: 'sys-fin-014_file_01',
    ),
    TimelineEvent(
      date: '2026-08-21',
      time: '09:18',
      description: 'FILE_CREATE',
      evidenceId: 'sys-fin-014_access_02',
    ),
  ],
);
