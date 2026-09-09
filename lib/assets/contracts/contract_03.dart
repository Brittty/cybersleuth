import 'contract_03_files.dart';

import 'package:cyber_sleuth/models/case_data_model.dart';
import 'package:cyber_sleuth/models/contract_model.dart';
import 'package:cyber_sleuth/models/disk_image_model.dart';
import 'package:cyber_sleuth/models/evidence_model.dart';
import 'package:cyber_sleuth/models/file_node_model.dart';
import 'package:cyber_sleuth/models/forensic_models.dart';

// Fictional training scenario. All timestamps use the same local timezone.
class PayrollTheftContract extends ContractModel {
  PayrollTheftContract()
    : super(
        id: 'contract_03',
        sender: 'Aster HR Security',
        time: '12:15 PM',
        chats: [
          'Payroll Leak at Aster Analytics',
          'A payroll export containing employee bank details was reported outside the company. Compare three authorized users and identify the workstation used for the unauthorized transfer.',
          'Three disk images are ready. Verify their hashes, compare files, email, access logs and network captures, then submit the implicated disk and an evidence timeline.',
          'An internal backup and an audit review occurred nearby. Check their approvals before treating routine activity as evidence.',
        ],
        caseData: _caseData,
      );
}

const _caseData = CaseData(
  internalEmailDomains: {'company.example'},
  supportingEvidenceIds: {
    'case03_sys_2:/Work/restore_test.txt',
    'case03_sys_3:/Work/aggregate_totals.csv',
    'case03_sys_3:/Work/audit_minutes.txt',
    'sys-hr-027_file_02',
    'case03_sys_2_file_01',
    'case03_sys_2_email_01',
    'case03_sys_2_access_02',
    'case03_sys_2_net_01',
    'case03_sys_2:/Work/CHG-204.txt',
    'case03_sys_3_file_01',
    'case03_sys_3_email_01',
    'case03_sys_3_access_02',
    'case03_sys_3_net_01',
    'case03_sys_3:/Work/AUD-318.txt',
  },
  suspectDiskId: 'DISK-03-014',
  diskImages: [
    DiskImage(
      diskId: 'DISK-03-014',
      ownerName: 'SYS-HR-027',
      ownerRole: 'Payroll Administrator',
      originalHash:
          '631f2a18a8e5ef71a3a08aa7f88aa4a9b1da4a082b7b457bac4a13ed2639d063',
      rootDirectory: FileNode(
        id: 'sys-hr-027:/',
        name: '/',
        isDirectory: true,
        children: [
          ...case03Disk1ExtraFolders,
          FileNode(
            id: 'sys-hr-027:/Documents',
            name: 'Documents',
            isDirectory: true,
            children: [
              FileNode(
                id: 'sys-hr-027_file_01',
                name: 'archive_manifest.txt',
                sizeBytes: 216,
                lastModified: '2026-08-26 09:12:00',
                textContent: '2026-08-26 09:12:00 Archive created: /tmp/payroll_aug.zip\nSource: /tmp/payroll_aug.csv\nRows: 1842; fields: employee_id, salary, bank_account\nArchive size: 2097152 bytes\nDestination: drop.talent-market.example/upload\n',
                hexPreview:
                    '00000000  32 30 32 36 2D 30 38 2D 32 36 20 30 39 3A 31 32',
              ),
              FileNode(
                id: 'sys-hr-027_file_02',
                name: 'payroll_policy.txt',
                sizeBytes: 147,
                lastModified: '2026-08-26 09:18:00',
                textContent: 'Payroll exports must remain on payroll-db.internal or the approved internal audit share. External recruiting services are not approved recipients.\n',
                hexPreview:
                    '00000000  50 61 79 72 6F 6C 6C 20 65 78 70 6F 72 74 73 20',
              ),
              FileNode(
                id: 'sys-hr-027_file_notes',
                name: 'meeting_notes.txt',
                sizeBytes: 87,
                lastModified: '2026-08-26 08:30:00',
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
          id: 'sys-hr-027_access_00',
          timestamp: '2026-08-26 08:45:00',
          user: 'sys-hr-027',
          action: 'LOGIN',
          target: 'Local workstation',
          status: 'SUCCESS',
        ),
        AccessLogEntry(
          id: 'sys-hr-027_access_01',
          timestamp: '2026-08-26 09:10:00',
          user: 'sys-hr-027',
          action: 'DATABASE_EXPORT',
          target: 'payroll-db.internal / employees_bank_details -> /tmp/payroll_aug.csv; 1842 rows',
          status: 'SUCCESS',
        ),
        AccessLogEntry(
          id: 'sys-hr-027_access_02',
          timestamp: '2026-08-26 09:18:00',
          user: 'sys-hr-027',
          action: 'FILE_DELETE',
          target: '/tmp/payroll_aug.csv and /tmp/payroll_aug.zip; interactive user session',
          status: 'SUCCESS',
        ),
      ],
      emailRecords: [
        EmailRecord(
          id: 'sys-hr-027_email_01',
          timestamp: '2026-08-26 09:00:00',
          from: 'recruiting@talent-market.example',
          to: 'sys-hr-027@company.example',
          subject: 'Private payroll handoff',
          body: 'Send the full payroll roster through drop.talent-market.example this morning. Use the private upload link; company approval is not needed.',
          attachments: [],
          headers: {'Message-ID': '<sys-hr-027_email_01@mail.example>'},
        ),
        EmailRecord(
          id: 'sys-hr-027_email_02',
          timestamp: '2026-08-26 08:20:00',
          from: 'manager@company.example',
          to: 'sys-hr-027@company.example',
          subject: 'Daily priorities',
          body: 'Please finish reconciliation on the internal systems before noon.',
          attachments: [],
          headers: {'Message-ID': '<sys-hr-027_email_02@mail.example>'},
        ),
      ],
      networkCaptures: [
        NetworkCapture(
          id: 'sys-hr-027_net_00',
          timestamp: '2026-08-26 08:46:00',
          sourceIp: '10.20.0.14',
          destIp: '10.20.0.2',
          protocol: 'HTTPS',
          bytes: 2048,
          info: 'Internal intranet dashboard',
        ),
        NetworkCapture(
          id: 'sys-hr-027_net_01',
          timestamp: '2026-08-26 09:15:00',
          sourceIp: '10.20.0.14',
          destIp: '203.0.113.77',
          protocol: 'HTTPS',
          bytes: 2097152,
          info: 'DLP-correlated POST drop.talent-market.example/upload; payroll_aug.zip; 2097152 bytes sent; HTTP 201',
        ),
      ],
    ),
    DiskImage(
      diskId: 'DISK-03-002',
      ownerName: 'CASE03_SYS_2',
      ownerRole: 'Backup Operator',
      originalHash:
          '81d10ea63e91665576808c8904ff1ba348db84f4c6c31a998afad763688baebe',
      rootDirectory: FileNode(
        id: 'case03_sys_2:/',
        name: '/',
        isDirectory: true,
        children: [
          ...case03Disk2ExtraFolders,
          FileNode(
            id: 'case03_sys_2:/Documents',
            name: 'Documents',
            isDirectory: true,
            children: [
              FileNode(
                id: 'case03_sys_2_file_01',
                name: 'backup_receipt.txt',
                sizeBytes: 151,
                lastModified: '2026-08-26 09:08:00',
                textContent: 'Change CHG-204 approved: 09:05 internal backup to 10.20.0.50. 524288000 bytes copied; restore check passed. No external destination or file encryption.',
                hexPreview:
                    '00000000  43 68 61 6E 67 65 20 43 48 47 2D 32 30 34 20 61',
              ),
              FileNode(
                id: 'case03_sys_2_file_02',
                name: 'work_notes.txt',
                sizeBytes: 85,
                lastModified: '2026-08-26 08:30:00',
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
          id: 'case03_sys_2_access_01',
          timestamp: '2026-08-26 08:50:00',
          user: 'case03_sys_2',
          action: 'LOGIN',
          target: 'Internal workstation',
          status: 'SUCCESS',
        ),
        AccessLogEntry(
          id: 'case03_sys_2_access_02',
          timestamp: '2026-08-26 09:05:00',
          user: 'case03_sys_2',
          action: 'BACKUP',
          target: 'Internal backup share; CHG-204',
          status: 'SUCCESS',
        ),
      ],
      emailRecords: [
        EmailRecord(
          id: 'case03_sys_2_email_01',
          timestamp: '2026-08-26 08:00:00',
          from: 'manager@company.example',
          to: 'case03_sys_2@company.example',
          subject: 'Approved backup window',
          body: 'Change CHG-204 is approved for 09:00 to 09:10. Start the internal backup to 10.20.0.50 at 09:05, then perform a restore check and record the result. External destinations and file encryption are not authorized.',
          attachments: [],
          headers: {'Message-ID': '<case03_sys_2_email_01@mail.example>'},
        ),
      ],
      networkCaptures: [
        NetworkCapture(
          id: 'case03_sys_2_net_01',
          timestamp: '2026-08-26 09:05:00',
          sourceIp: '10.20.0.2',
          destIp: '10.20.0.50',
          protocol: 'HTTPS',
          bytes: 524288000,
          info: 'Internal backup upload; CHG-204',
        ),
      ],
    ),
    DiskImage(
      diskId: 'DISK-03-003',
      ownerName: 'CASE03_SYS_3',
      ownerRole: 'Internal Auditor',
      originalHash:
          '28450a7e4b4703cba1ea8bd0df0075ab88d5004cb9fda4a11d2c5416a72cdacd',
      rootDirectory: FileNode(
        id: 'case03_sys_3:/',
        name: '/',
        isDirectory: true,
        children: [
          ...case03Disk3ExtraFolders,
          FileNode(
            id: 'case03_sys_3:/Documents',
            name: 'Documents',
            isDirectory: true,
            children: [
              FileNode(
                id: 'case03_sys_3_file_01',
                name: 'audit_scope.txt',
                sizeBytes: 123,
                lastModified: '2026-08-26 09:08:00',
                textContent: 'Audit AUD-318 authorizes aggregate totals only, stored on 10.20.0.60. No employee bank details or source invoices included.',
                hexPreview:
                    '00000000  41 75 64 69 74 20 41 55 44 2D 33 31 38 20 61 75',
              ),
              FileNode(
                id: 'case03_sys_3_file_02',
                name: 'work_notes.txt',
                sizeBytes: 85,
                lastModified: '2026-08-26 08:30:00',
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
          id: 'case03_sys_3_access_01',
          timestamp: '2026-08-26 08:50:00',
          user: 'case03_sys_3',
          action: 'LOGIN',
          target: 'Internal workstation',
          status: 'SUCCESS',
        ),
        AccessLogEntry(
          id: 'case03_sys_3_access_02',
          timestamp: '2026-08-26 09:05:00',
          user: 'case03_sys_3',
          action: 'REPORT_READ',
          target: 'Aggregate audit dashboard; AUD-318',
          status: 'SUCCESS',
        ),
      ],
      emailRecords: [
        EmailRecord(
          id: 'case03_sys_3_email_01',
          timestamp: '2026-08-26 08:00:00',
          from: 'manager@company.example',
          to: 'case03_sys_3@company.example',
          subject: 'Audit scope approved',
          body: 'Audit AUD-318 authorizes aggregate totals only, stored on 10.20.0.60. No employee bank details or source invoices included.',
          attachments: [],
          headers: {'Message-ID': '<case03_sys_3_email_01@mail.example>'},
        ),
      ],
      networkCaptures: [
        NetworkCapture(
          id: 'case03_sys_3_net_01',
          timestamp: '2026-08-26 09:05:00',
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
      id: 'sys-hr-027_email_01',
      category: 'email',
      title: 'Private payroll handoff',
      explanation: 'The external message requests an unapproved transfer of the payroll roster.',
    ),
    CorrectEvidence(
      id: 'sys-hr-027_access_01',
      category: 'access_log',
      title: 'DATABASE_EXPORT',
      explanation: 'The database audit records the export of 1842 employee bank records.',
    ),
    CorrectEvidence(
      id: 'sys-hr-027_file_01',
      category: 'file',
      title: 'Payroll archive created',
      explanation: 'The archive manifest links the exported CSV to a 2097152-byte upload package.',
    ),
    CorrectEvidence(
      id: 'sys-hr-027_net_01',
      category: 'network',
      title: 'Payroll archive uploaded',
      explanation: 'The DLP-correlated outbound upload matches the archive and confirms successful delivery.',
    ),
    CorrectEvidence(
      id: 'sys-hr-027_access_02',
      category: 'access_log',
      title: 'FILE_DELETE',
      explanation:
          'The user deleted the staged files after the successful upload.',
    ),
  ],
  correctTimeline: [
    TimelineEvent(
      date: '2026-08-26',
      time: '09:00',
      description: 'Private payroll handoff',
      evidenceId: 'sys-hr-027_email_01',
    ),
    TimelineEvent(
      date: '2026-08-26',
      time: '09:10',
      description: 'DATABASE_EXPORT',
      evidenceId: 'sys-hr-027_access_01',
    ),
    TimelineEvent(
      date: '2026-08-26',
      time: '09:12',
      description: 'Payroll archive created',
      evidenceId: 'sys-hr-027_file_01',
    ),
    TimelineEvent(
      date: '2026-08-26',
      time: '09:15',
      description: 'Payroll archive uploaded',
      evidenceId: 'sys-hr-027_net_01',
    ),
    TimelineEvent(
      date: '2026-08-26',
      time: '09:18',
      description: 'FILE_DELETE',
      evidenceId: 'sys-hr-027_access_02',
    ),
  ],
);
