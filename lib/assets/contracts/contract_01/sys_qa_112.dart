import 'package:cyber_sleuth/models/disk_image_model.dart';
import 'package:cyber_sleuth/models/file_node_model.dart';
import 'package:cyber_sleuth/models/forensic_models.dart';

const ananyaDisk = DiskImage(
  diskId: 'DISK-NVT-0331',
  ownerName: 'SYS-QA-112',
  ownerRole: 'QA Lead',
  originalHash:
      'c1e4d7b0a3f6e9c2d5b8a1e4f7c0d3a6b9e2f5b8d2e5f1a4c7093e6b9d2f5a8',
  rootDirectory: ananyaRoot,
  accessLogs: ananyaAccessLogs,
  emailRecords: ananyaEmails,
  networkCaptures: ananyaNetworkCaptures,
);

// ── Ananya's File System ─────────────────────────────────────

const ananyaRoot = FileNode(
  id: 'ananya:/',
  name: '/',
  isDirectory: true,
  lastModified: '2026-08-16 18:00:00',
  children: [
    FileNode(
      id: 'ananya:/home',
      name: 'home',
      isDirectory: true,
      lastModified: '2026-08-16 18:00:00',
      children: [
        FileNode(
          id: 'ananya:/home/ananya',
          name: 'ananya',
          isDirectory: true,
          lastModified: '2026-08-16 18:00:00',
          children: [
            FileNode(
              id: 'ananya:/home/ananya/Documents',
              name: 'Documents',
              isDirectory: true,
              lastModified: '2026-08-16 17:30:00',
              children: [
                FileNode(
                  id: 'ananya:/home/ananya/Documents/test_plans',
                  name: 'test_plans',
                  isDirectory: true,
                  lastModified: '2026-08-14 10:00:00',
                  children: [
                    FileNode(
                      id: 'ananya_file_regression',
                      name: 'regression_v2.txt',
                      sizeBytes: 4521,
                      lastModified: '2026-08-14 10:00:00',
                      textContent:
                          'Regression Test Plan — v2.3.1\n'
                          '=============================\n\n'
                          'Scope: API endpoints, authentication, data export\n\n'
                          'Test Cases:\n'
                          '  TC-001: User login with valid credentials → 200 OK\n'
                          '  TC-002: User login with invalid password → 401\n'
                          '  TC-003: API rate limiting → 429 after 100 req/min\n'
                          '  TC-004: Data export CSV format validation\n'
                          '  TC-005: Concurrent session handling\n'
                          '  TC-006: Password reset flow\n\n'
                          'Environment: staging-01.internal\n'
                          'Estimated duration: 4 hours\n',
                      hexPreview:
                          '00000000  52 65 67 72 65 73 73 69  6F 6E 20 54 65 73 74 20  |Regression Test |\n'
                          '00000010  50 6C 61 6E 20 E2 80 94  20 76 32 2E 33 2E 31 0A  |Plan ... v2.3.1.|\n',
                    ),
                  ],
                ),
                FileNode(
                  id: 'ananya:/home/ananya/Documents/bug_reports',
                  name: 'bug_reports',
                  isDirectory: true,
                  lastModified: '2026-08-16 17:30:00',
                  children: [
                    FileNode(
                      id: 'ananya_file_bug412',
                      name: 'bug_412.txt',
                      sizeBytes: 1203,
                      lastModified: '2026-08-15 11:30:00',
                      textContent:
                          'Bug #412 — Login page regression\n'
                          'Severity: High\n'
                          'Status: Open\n\n'
                          'Steps to reproduce:\n'
                          '1. Navigate to /login\n'
                          '2. Enter valid credentials\n'
                          '3. Click "Sign In"\n'
                          '4. Observe: Page refreshes but does not redirect\n\n'
                          'Expected: Redirect to /dashboard\n'
                          'Actual: Stays on /login, session cookie not set\n\n'
                          'Root cause: Session middleware not initializing\n'
                          'after the v2.3.0 API gateway migration.\n',
                      hexPreview:
                          '00000000  42 75 67 20 23 34 31 32  20 E2 80 94 20 4C 6F 67  |Bug #412 ... Log|\n'
                          '00000010  69 6E 20 70 61 67 65 20  72 65 67 72 65 73 73 69  |in page regressi|\n',
                    ),
                    FileNode(
                      id: 'ananya_file_bug415',
                      name: 'bug_415.txt',
                      sizeBytes: 987,
                      lastModified: '2026-08-16 17:30:00',
                      textContent:
                          'Bug #415 — CSV export missing headers\n'
                          'Severity: Medium\n'
                          'Status: Open\n\n'
                          'Steps to reproduce:\n'
                          '1. Navigate to /reports/export\n'
                          '2. Select date range and click "Export CSV"\n'
                          '3. Open downloaded file\n\n'
                          'Expected: First row contains column headers\n'
                          'Actual: First row is data, no headers\n\n'
                          'Likely related to the CSV serializer refactor.\n',
                      hexPreview:
                          '00000000  42 75 67 20 23 34 31 35  20 E2 80 94 20 43 53 56  |Bug #415 ... CSV|\n'
                          '00000010  20 65 78 70 6F 72 74 20  6D 69 73 73 69 6E 67 20  | export missing |\n',
                    ),
                  ],
                ),
              ],
            ),
            FileNode(
              id: 'ananya:/home/ananya/Downloads',
              name: 'Downloads',
              isDirectory: true,
              lastModified: '2026-08-10 14:00:00',
              children: [
                FileNode(
                  id: 'ananya_file_selenium',
                  name: 'selenium_guide.pdf',
                  sizeBytes: 2457600,
                  lastModified: '2026-08-10 14:00:00',
                  hexPreview:
                      '00000000  25 50 44 46 2D 31 2E 37  0A 25 E2 E3 CF D3 0A 31  |%PDF-1.7.%.....1|\n'
                      '00000010  20 30 20 6F 62 6A 0A 3C  3C 2F 54 79 70 65 2F 43  | 0 obj.<</Type/C|\n'
                      '00000020  61 74 61 6C 6F 67 2F 50  61 67 65 73 20 32 20 30  |atalog/Pages 2 0|\n',
                ),
              ],
            ),
            FileNode(
              id: 'ananya_file_bash',
              name: '.bash_history',
              sizeBytes: 1102,
              lastModified: '2026-08-16 17:45:00',
              textContent:
                  'cd ~/Documents/test_plans\n'
                  'cat regression_v2.txt\n'
                  'ssh ananya.desai@qa-server-01.internal\n'
                  'python -m pytest tests/ -v\n'
                  'python -m pytest tests/test_login.py -v\n'
                  'curl http://staging-01.internal/health\n'
                  'git log --oneline -10\n',
              hexPreview:
                  '00000000  63 64 20 7E 2F 44 6F 63  75 6D 65 6E 74 73 2F 74  |cd ~/Documents/t|\n'
                  '00000010  65 73 74 5F 70 6C 61 6E  73 0A 63 61 74 20 72 65  |est_plans.cat re|\n',
            ),
          ],
        ),
      ],
    ),
    FileNode(
      id: 'ananya:/var',
      name: 'var',
      isDirectory: true,
      lastModified: '2026-08-16 18:00:00',
      children: [
        FileNode(
          id: 'ananya:/var/log',
          name: 'log',
          isDirectory: true,
          lastModified: '2026-08-16 18:00:00',
          children: [
            FileNode(
              id: 'ananya_file_authlog',
              name: 'auth.log',
              sizeBytes: 3201,
              lastModified: '2026-08-16 18:00:00',
              textContent:
                  'Aug 12 09:05:10 workstation-0331 sshd[2101]: Accepted publickey for ananya.desai from 10.0.3.15 port 41201\n'
                  'Aug 13 09:10:22 workstation-0331 sshd[2340]: Accepted publickey for ananya.desai from 10.0.3.15 port 41502\n'
                  'Aug 14 09:08:45 workstation-0331 sshd[2580]: Accepted publickey for ananya.desai from 10.0.3.15 port 41890\n'
                  'Aug 15 09:12:30 workstation-0331 sshd[2790]: Accepted publickey for ananya.desai from 10.0.3.15 port 42100\n'
                  'Aug 16 09:07:55 workstation-0331 sshd[3010]: Accepted publickey for ananya.desai from 10.0.3.15 port 42350\n',
              hexPreview:
                  '00000000  41 75 67 20 31 32 20 30  39 3A 30 35 3A 31 30 20  |Aug 12 09:05:10 |\n'
                  '00000010  77 6F 72 6B 73 74 61 74  69 6F 6E 2D 30 33 33 31  |workstation-0331|\n',
            ),
          ],
        ),
      ],
    ),
  ],
);

// ── Ananya's Access Logs ─────────────────────────────────────

const ananyaAccessLogs = [
  AccessLogEntry(
    id: 'ananya_access_01',
    timestamp: '2026-08-12 09:05:00',
    user: 'ananya.desai',
    action: 'SSH_LOGIN',
    target: 'qa-server-01.internal',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'ananya_access_02',
    timestamp: '2026-08-13 09:10:00',
    user: 'ananya.desai',
    action: 'SSH_LOGIN',
    target: 'qa-server-01.internal',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'ananya_access_03',
    timestamp: '2026-08-14 09:08:00',
    user: 'ananya.desai',
    action: 'SSH_LOGIN',
    target: 'qa-server-01.internal',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'ananya_access_04',
    timestamp: '2026-08-14 10:30:00',
    user: 'ananya.desai',
    action: 'SSH_LOGIN',
    target: 'staging-01.internal',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'ananya_access_05',
    timestamp: '2026-08-15 09:12:00',
    user: 'ananya.desai',
    action: 'SSH_LOGIN',
    target: 'qa-server-01.internal',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'ananya_access_06',
    timestamp: '2026-08-16 09:08:00',
    user: 'ananya.desai',
    action: 'SSH_LOGIN',
    target: 'qa-server-01.internal',
    status: 'SUCCESS',
  ),
];

// ── Ananya's Emails ──────────────────────────────────────────

const ananyaEmails = [
  EmailRecord(
    id: 'ananya_email_01',
    timestamp: '2026-08-15 11:45:00',
    from: 'ananya.desai@novatech.com',
    to: 'vikram.shah@novatech.com',
    subject: 'Bug #412 — Login page regression',
    body:
        'Hi Vikram,\n\n'
        'Found a critical regression in the login flow after the v2.3.0\n'
        'API gateway migration. Sessions aren\'t being initialized.\n\n'
        'Details in the attached bug report. This is blocking QA sign-off\n'
        'for v2.3.1.\n\n'
        'Can you take a look ASAP?\n\n'
        'Thanks,\nAnanya',
    headers: {
      'From': 'ananya.desai@novatech.com',
      'To': 'vikram.shah@novatech.com',
      'Date': 'Thu, 15 Aug 2026 11:45:00 +0530',
      'Message-ID': '<20260815114500.GA4567@novatech.com>',
      'Subject': 'Bug #412 — Login page regression',
      'X-Mailer': 'NovaTech Mail Server 4.2',
    },
  ),
  EmailRecord(
    id: 'ananya_email_02',
    timestamp: '2026-08-16 14:00:00',
    from: 'priya.menon@novatech.com',
    to: 'ananya.desai@novatech.com',
    subject: 'Re: Test plan review',
    body:
        'Ananya,\n\n'
        'Looks good overall. One suggestion — add a test case for the\n'
        'new rate limiting behavior (100 req/min threshold).\n\n'
        'I\'ll check the tokenizer integration on my end.\n\n'
        '— Priya',
    headers: {
      'From': 'priya.menon@novatech.com',
      'To': 'ananya.desai@novatech.com',
      'Date': 'Fri, 16 Aug 2026 14:00:00 +0530',
      'Message-ID': '<20260816140000.GB8901@novatech.com>',
      'Subject': 'Re: Test plan review',
      'X-Mailer': 'NovaTech Mail Server 4.2',
    },
  ),
];

// ── Ananya's Network Captures ────────────────────────────────

const ananyaNetworkCaptures = [
  NetworkCapture(
    id: 'ananya_net_01',
    timestamp: '2026-08-12 09:05:30',
    sourceIp: '10.0.3.15',
    destIp: '10.0.8.5',
    protocol: 'SSH',
    bytes: 2048,
    info: 'SSH handshake → qa-server-01.internal',
  ),
  NetworkCapture(
    id: 'ananya_net_02',
    timestamp: '2026-08-14 10:30:15',
    sourceIp: '10.0.3.15',
    destIp: '10.0.9.1',
    protocol: 'SSH',
    bytes: 2048,
    info: 'SSH handshake → staging-01.internal',
  ),
  NetworkCapture(
    id: 'ananya_net_03',
    timestamp: '2026-08-15 09:15:00',
    sourceIp: '10.0.3.15',
    destIp: '10.0.0.2',
    protocol: 'DNS',
    bytes: 72,
    info: 'Standard query A jira.internal.novatech.com',
  ),
  NetworkCapture(
    id: 'ananya_net_04',
    timestamp: '2026-08-15 09:15:10',
    sourceIp: '10.0.3.15',
    destIp: '10.0.7.10',
    protocol: 'HTTPS',
    bytes: 8192,
    info: 'TLS 1.3 → jira.internal.novatech.com (ticket update)',
  ),
  NetworkCapture(
    id: 'ananya_net_05',
    timestamp: '2026-08-16 10:00:00',
    sourceIp: '10.0.3.15',
    destIp: '10.0.7.20',
    protocol: 'HTTPS',
    bytes: 4096,
    info: 'TLS 1.3 → confluence.internal.novatech.com',
  ),
];
