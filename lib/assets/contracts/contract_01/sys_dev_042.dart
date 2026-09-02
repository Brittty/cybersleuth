import 'package:cyber_sleuth/models/disk_image_model.dart';
import 'package:cyber_sleuth/models/file_node_model.dart';
import 'package:cyber_sleuth/models/forensic_models.dart';

const priyaDisk = DiskImage(
  diskId: 'DISK-NVT-0217',
  ownerName: 'SYS-DEV-042',
  ownerRole: 'Senior Developer',
  originalHash:
      'a3f7c9e2b1d4056f8a9e3c7d2b5f1a8e4d6c9b2a5f8e1d4c7b0a3f6e9d2c5b8',
  rootDirectory: priyaRoot,
  accessLogs: priyaAccessLogs,
  emailRecords: priyaEmails,
  networkCaptures: priyaNetworkCaptures,
);

// ── Priya's File System ──────────────────────────────────────

const priyaRoot = FileNode(
  id: 'priya:/',
  name: '/',
  isDirectory: true,
  lastModified: '2026-08-22 03:00:00',
  children: [
    FileNode(
      id: 'priya:/home',
      name: 'home',
      isDirectory: true,
      lastModified: '2026-08-22 03:00:00',
      children: [
        FileNode(
          id: 'priya:/home/priya',
          name: 'priya',
          isDirectory: true,
          lastModified: '2026-08-22 03:00:00',
          children: [
            // ── Documents ──
            FileNode(
              id: 'priya:/home/priya/Documents',
              name: 'Documents',
              isDirectory: true,
              lastModified: '2026-08-15 14:22:00',
              children: [
                FileNode(
                  id: 'priya_file_notes',
                  name: 'project_notes.txt',
                  sizeBytes: 1847,
                  lastModified: '2026-08-10 16:30:00',
                  textContent:
                      'ML Core v3 Development Notes\n'
                      '============================\n'
                      'Sprint 14 objectives:\n'
                      '- Optimize transformer attention layers\n'
                      '- Reduce inference latency to <50ms\n'
                      '- Integrate new tokenizer from research team\n\n'
                      'Architecture decisions:\n'
                      '- Using PyTorch 2.1 with compiled mode\n'
                      '- Custom CUDA kernels for attention\n'
                      '- Model checkpoint: /projects/ml-core/checkpoints/v3.2/\n\n'
                      'TODO:\n'
                      '- Write unit tests for new tokenizer\n'
                      '- Benchmark against v2 baseline\n'
                      '- Update API documentation\n',
                  hexPreview:
                      '00000000  4D 4C 20 43 6F 72 65 20  76 33 20 44 65 76 65 6C  |ML Core v3 Devel|\n'
                      '00000010  6F 70 6D 65 6E 74 20 4E  6F 74 65 73 0A 3D 3D 3D  |opment Notes.===|\n'
                      '00000020  3D 3D 3D 3D 3D 3D 3D 3D  3D 3D 3D 3D 3D 3D 3D 3D  |================|\n'
                      '00000030  3D 3D 3D 3D 3D 3D 3D 3D  3D 0A 53 70 72 69 6E 74  |=========.Sprint|\n',
                ),
                FileNode(
                  id: 'priya_file_meeting',
                  name: 'meeting_minutes_aug15.txt',
                  sizeBytes: 3291,
                  lastModified: '2026-08-15 14:22:00',
                  textContent:
                      'Team Standup — August 15, 2026\n'
                      '------------------------------\n'
                      'Attendees: Priya, Vikram, Neha, Arjun\n\n'
                      'Updates:\n'
                      '- Priya: Working on attention layer optimization\n'
                      '- Vikram: API gateway migration in progress\n'
                      '- Neha: Dataset preprocessing pipeline complete\n'
                      '- Arjun: Security audit findings review\n\n'
                      'Action Items:\n'
                      '- Priya to share benchmark results by EOW\n'
                      '- Vikram to coordinate with DevOps on staging\n'
                      '- Neha to validate tokenizer integration\n',
                  hexPreview:
                      '00000000  54 65 61 6D 20 53 74 61  6E 64 75 70 20 E2 80 94  |Team Standup ...|\n'
                      '00000010  20 41 75 67 75 73 74 20  31 35 2C 20 32 30 32 36  | August 15, 2026|\n'
                      '00000020  0A 2D 2D 2D 2D 2D 2D 2D  2D 2D 2D 2D 2D 2D 2D 2D  |.---------------|\n',
                ),
              ],
            ),
            // ── Downloads (SUSPICIOUS) ──
            FileNode(
              id: 'priya:/home/priya/Downloads',
              name: 'Downloads',
              isDirectory: true,
              lastModified: '2026-08-15 00:50:00',
              children: [
                FileNode(
                  id: 'priya_file_01',
                  name: 'export_script.sh',
                  sizeBytes: 246,
                  lastModified: '2026-08-15 00:45:00',
                  textContent:
                      '#!/bin/bash\n'
                      '# Quick backup script\n'
                      'TIMESTAMP=\$(date +%Y%m%d_%H%M%S)\n'
                      'SRC_DIR="/projects/ml-core/src"\n'
                      'OUT_DIR="/tmp/export"\n'
                      'mkdir -p \$OUT_DIR\n\n'
                      'tar -czf \$OUT_DIR/ml_model_v3_FINAL.tar.gz \$SRC_DIR\n'
                      'gpg --batch --yes --symmetric --cipher-algo AES256 \\\n'
                      '    --passphrase "N0v4T3ch#2026!" \\\n'
                      '    -o ~/Downloads/ml_model_v3_FINAL.tar.gz.enc \\\n'
                      '    \$OUT_DIR/ml_model_v3_FINAL.tar.gz\n\n'
                      'rm -rf \$OUT_DIR\n'
                      'echo "Export complete."\n',
                  hexPreview:
                      '00000000  23 21 2F 62 69 6E 2F 62  61 73 68 0A 23 20 51 75  |#!/bin/bash.# Qu|\n'
                      '00000010  69 63 6B 20 62 61 63 6B  75 70 20 73 63 72 69 70  |ick backup scrip|\n'
                      '00000020  74 0A 54 49 4D 45 53 54  41 4D 50 3D 24 28 64 61  |t.TIMESTAMP=\$(da|\n'
                      '00000030  74 65 20 2B 25 59 25 6D  25 64 5F 25 48 25 4D 25  |te +%Y%m%d_%H%M%|\n',
                ),
                FileNode(
                  id: 'priya_file_enc',
                  name: 'ml_model_v3_FINAL.tar.gz.enc',
                  sizeBytes: 49283072,
                  lastModified: '2026-08-15 00:50:00',
                  hexPreview:
                      '00000000  8C 0D 04 09 03 08 C3 D5  A1 6E 2F B8 D2 01 0C 24  |.........n/....\$|\n'
                      '00000010  E7 3A 9B F0 12 45 67 89  AB CD EF 01 23 45 67 89  |.:...Eg.....#Eg.|\n'
                      '00000020  D4 A3 8F 2C 71 E5 B9 06  4D 82 C6 FA 3E 7B 1A 5E  |...,q...M...>{.^|\n'
                      '00000030  90 D3 17 4B 8E C2 F6 2A  5D 81 B5 E9 3C 70 A4 D8  |...K...*]...<p..|\n'
                      '00000040  0B 3F 73 A7 DB 1E 52 86  BA ED 21 55 89 BD F0 24  |.?s...R...!U...\$|\n'
                      '00000050  57 8B BF 02 36 6A 9E D1  14 48 7C AF E3 27 5B 8F  |W...6j...H|..\'[.|\n'
                      '\n[GPG/OpenPGP symmetrically encrypted data — AES-256-CFB]\n'
                      '[File size: 47.0 MB — likely a compressed archive]\n',
                ),
              ],
            ),
            // ── .ssh ──
            FileNode(
              id: 'priya:/home/priya/.ssh',
              name: '.ssh',
              isDirectory: true,
              lastModified: '2026-07-20 09:00:00',
              children: [
                FileNode(
                  id: 'priya_file_known_hosts',
                  name: 'known_hosts',
                  sizeBytes: 412,
                  lastModified: '2026-08-14 23:45:00',
                  textContent:
                      'dev-server-01.internal ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKx...\n'
                      'rd-server-03.internal ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBm...\n'
                      'git.internal.novatech.com ssh-rsa AAAAB3NzaC1yc2EAAAADAQAB...\n',
                  hexPreview:
                      '00000000  64 65 76 2D 73 65 72 76  65 72 2D 30 31 2E 69 6E  |dev-server-01.in|\n'
                      '00000010  74 65 72 6E 61 6C 20 73  73 68 2D 65 64 32 35 35  |ternal ssh-ed255|\n',
                ),
                FileNode(
                  id: 'priya_file_pubkey',
                  name: 'id_rsa.pub',
                  sizeBytes: 571,
                  lastModified: '2026-03-12 10:15:00',
                  textContent: 'ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDK7m... priya.menon@novatech.com\n',
                  hexPreview: '00000000  73 73 68 2D 72 73 61 20  41 41 41 41 42 33 4E 7A  |ssh-rsa AAAAB3Nz|\n',
                ),
              ],
            ),
            // ── .bash_history (SUSPICIOUS) ──
            FileNode(
              id: 'priya_file_bash',
              name: '.bash_history',
              sizeBytes: 2156,
              lastModified: '2026-08-22 02:50:00',
              textContent:
                  'cd ~/projects/ml-core\n'
                  'git pull origin main\n'
                  'python train.py --config configs/v3.yaml\n'
                  'ssh priya.menon@rd-server-03.internal\n'
                  'ls /projects/ml-core/src/\n'
                  'du -sh /projects/ml-core/src/\n'
                  'tar -czf /tmp/export/ml_model_v3_FINAL.tar.gz /projects/ml-core/src/\n'
                  'gpg --batch --yes --symmetric --cipher-algo AES256 --passphrase "N0v4T3ch#2026!" -o ~/Downloads/ml_model_v3_FINAL.tar.gz.enc /tmp/export/ml_model_v3_FINAL.tar.gz\n'
                  'rm -rf /tmp/export\n'
                  'ls -la ~/Downloads/\n'
                  'python benchmark.py --model v3\n'
                  'git status\n',
              hexPreview:
                  '00000000  63 64 20 7E 2F 70 72 6F  6A 65 63 74 73 2F 6D 6C  |cd ~/projects/ml|\n'
                  '00000010  2D 63 6F 72 65 0A 67 69  74 20 70 75 6C 6C 20 6F  |-core.git pull o|\n'
                  '00000020  72 69 67 69 6E 20 6D 61  69 6E 0A 70 79 74 68 6F  |rigin main.pytho|\n',
            ),
          ],
        ),
      ],
    ),
    // ── /var/log ──
    FileNode(
      id: 'priya:/var',
      name: 'var',
      isDirectory: true,
      lastModified: '2026-08-22 03:00:00',
      children: [
        FileNode(
          id: 'priya:/var/log',
          name: 'log',
          isDirectory: true,
          lastModified: '2026-08-22 03:00:00',
          children: [
            FileNode(
              id: 'priya_file_authlog',
              name: 'auth.log',
              sizeBytes: 8934,
              lastModified: '2026-08-22 03:00:00',
              textContent:
                  'Aug 12 09:14:52 workstation-0217 sshd[4821]: Accepted publickey for priya.menon from 10.0.1.50 port 52341\n'
                  'Aug 12 14:29:11 workstation-0217 sshd[5102]: Accepted publickey for priya.menon from 10.0.1.50 port 52890\n'
                  'Aug 14 23:44:38 workstation-0217 sshd[6719]: Accepted publickey for priya.menon from 10.0.1.50 port 53201\n'
                  'Aug 15 00:11:55 workstation-0217 sudo: priya.menon : TTY=pts/2 ; PWD=/projects/ml-core ; COMMAND=/bin/tar\n'
                  'Aug 15 00:29:43 workstation-0217 sudo: priya.menon : TTY=pts/2 ; PWD=/home/priya ; COMMAND=/usr/bin/gpg\n'
                  'Aug 18 23:29:10 workstation-0217 sshd[7842]: Accepted publickey for priya.menon from 10.0.1.50 port 54102\n'
                  'Aug 22 23:14:22 workstation-0217 sshd[8901]: Accepted publickey for priya.menon from 10.0.1.50 port 55430\n',
              hexPreview:
                  '00000000  41 75 67 20 31 32 20 30  39 3A 31 34 3A 35 32 20  |Aug 12 09:14:52 |\n'
                  '00000010  77 6F 72 6B 73 74 61 74  69 6F 6E 2D 30 32 31 37  |workstation-0217|\n',
            ),
          ],
        ),
      ],
    ),
  ],
);

// ── Priya's Access Logs ──────────────────────────────────────

const priyaAccessLogs = [
  AccessLogEntry(
    id: 'priya_access_norm_01',
    timestamp: '2026-08-12 09:15:00',
    user: 'priya.menon',
    action: 'SSH_LOGIN',
    target: 'dev-server-01.internal',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'priya_access_norm_02',
    timestamp: '2026-08-12 14:30:00',
    user: 'priya.menon',
    action: 'SSH_LOGIN',
    target: 'dev-server-01.internal',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'priya_access_norm_03',
    timestamp: '2026-08-13 10:00:00',
    user: 'priya.menon',
    action: 'SSH_LOGIN',
    target: 'dev-server-01.internal',
    status: 'SUCCESS',
  ),
  // ── SUSPICIOUS ──
  AccessLogEntry(
    id: 'priya_access_01',
    timestamp: '2026-08-14 23:45:00',
    user: 'priya.menon',
    action: 'SSH_LOGIN',
    target: 'rd-server-03.internal',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'priya_access_02',
    timestamp: '2026-08-15 00:12:00',
    user: 'priya.menon',
    action: 'FILE_ACCESS',
    target: '/projects/ml-core/src/',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'priya_access_copy',
    timestamp: '2026-08-15 00:30:00',
    user: 'priya.menon',
    action: 'FILE_COPY',
    target: '/projects/ml-core/src/ → /tmp/export/',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'priya_access_logout',
    timestamp: '2026-08-15 03:00:00',
    user: 'priya.menon',
    action: 'SSH_LOGOUT',
    target: 'rd-server-03.internal',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'priya_access_night2',
    timestamp: '2026-08-18 23:30:00',
    user: 'priya.menon',
    action: 'SSH_LOGIN',
    target: 'rd-server-03.internal',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'priya_access_night2_file',
    timestamp: '2026-08-19 00:15:00',
    user: 'priya.menon',
    action: 'FILE_ACCESS',
    target: '/projects/ml-core/models/',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'priya_access_night3',
    timestamp: '2026-08-22 23:15:00',
    user: 'priya.menon',
    action: 'SSH_LOGIN',
    target: 'rd-server-03.internal',
    status: 'SUCCESS',
  ),
];

// ── Priya's Emails ───────────────────────────────────────────

const priyaEmails = [
  EmailRecord(
    id: 'priya_email_01',
    timestamp: '2026-08-12 10:30:00',
    from: 'vikram.shah@novatech.com',
    to: 'priya.menon@novatech.com',
    subject: 'Re: Sprint 14 Planning',
    body:
        'Hi Priya,\n\n'
        'Sounds good — let\'s target the attention layer optimization for this sprint.\n'
        'I\'ll handle the API gateway migration on my end.\n\n'
        'Can you share the benchmark configs by Wednesday?\n\n'
        'Thanks,\nVikram',
    headers: {
      'From': 'vikram.shah@novatech.com',
      'To': 'priya.menon@novatech.com',
      'Date': 'Mon, 12 Aug 2026 10:30:00 +0530',
      'Message-ID': '<20260812103000.GA1234@novatech.com>',
      'Subject': 'Re: Sprint 14 Planning',
      'X-Mailer': 'NovaTech Mail Server 4.2',
      'Content-Type': 'text/plain; charset=UTF-8',
    },
  ),
  EmailRecord(
    id: 'priya_email_02',
    timestamp: '2026-08-13 15:45:00',
    from: 'priya.menon@novatech.com',
    to: 'neha.gupta@novatech.com',
    subject: 'Code Review: Tokenizer Integration',
    body:
        'Hi Neha,\n\n'
        'I\'ve pushed the tokenizer integration branch. Could you review the\n'
        'changes in /src/tokenizer/v2_adapter.py?\n\n'
        'Main changes:\n'
        '- New vocabulary mapping layer\n'
        '- Backwards-compatible API\n'
        '- Unit tests in /tests/tokenizer/\n\n'
        'Thanks!\nPriya',
    headers: {
      'From': 'priya.menon@novatech.com',
      'To': 'neha.gupta@novatech.com',
      'Date': 'Tue, 13 Aug 2026 15:45:00 +0530',
      'Message-ID': '<20260813154500.GB5678@novatech.com>',
      'Subject': 'Code Review: Tokenizer Integration',
      'X-Mailer': 'NovaTech Mail Server 4.2',
      'Content-Type': 'text/plain; charset=UTF-8',
    },
  ),
  // ── SUSPICIOUS ──
  EmailRecord(
    id: 'priya_email_03',
    timestamp: '2026-08-15 01:05:00',
    from: 'priya.menon@novatech.com',
    to: 'priya.personal.372@gmail.com',
    subject: 'backup',
    body: 'See attached.',
    attachments: ['ml_model_v3_FINAL.tar.gz.enc'],
    headers: {
      'From': 'priya.menon@novatech.com',
      'To': 'priya.personal.372@gmail.com',
      'Date': 'Thu, 15 Aug 2026 01:05:00 +0530',
      'Message-ID': '<20260815010500.GX9012@novatech.com>',
      'Subject': 'backup',
      'X-Mailer': 'NovaTech Mail Server 4.2',
      'Content-Type': 'multipart/mixed; boundary="----=_Part_9012"',
      'MIME-Version': '1.0',
      'X-Attachment-Count': '1',
    },
  ),
  EmailRecord(
    id: 'priya_email_04',
    timestamp: '2026-08-19 01:30:00',
    from: 'priya.menon@novatech.com',
    to: 'priya.personal.372@gmail.com',
    subject: 'docs',
    body: '',
    attachments: ['rd_specs_export.tar.gz.enc'],
    headers: {
      'From': 'priya.menon@novatech.com',
      'To': 'priya.personal.372@gmail.com',
      'Date': 'Mon, 19 Aug 2026 01:30:00 +0530',
      'Message-ID': '<20260819013000.GY3456@novatech.com>',
      'Subject': 'docs',
      'X-Mailer': 'NovaTech Mail Server 4.2',
      'Content-Type': 'multipart/mixed; boundary="----=_Part_3456"',
      'MIME-Version': '1.0',
      'X-Attachment-Count': '1',
    },
  ),
];

// ── Priya's Network Captures ─────────────────────────────────

const priyaNetworkCaptures = [
  NetworkCapture(
    id: 'priya_net_01',
    timestamp: '2026-08-12 09:14:50',
    sourceIp: '10.0.1.50',
    destIp: '10.0.5.10',
    protocol: 'SSH',
    bytes: 2048,
    info: 'SSH handshake → dev-server-01.internal',
  ),
  NetworkCapture(
    id: 'priya_net_norm_02',
    timestamp: '2026-08-12 09:20:00',
    sourceIp: '10.0.1.50',
    destIp: '10.0.5.20',
    protocol: 'HTTPS',
    bytes: 15360,
    info: 'TLS 1.3 → git.internal.novatech.com (git pull)',
  ),
  NetworkCapture(
    id: 'priya_net_norm_03',
    timestamp: '2026-08-14 10:00:00',
    sourceIp: '10.0.1.50',
    destIp: '10.0.0.2',
    protocol: 'DNS',
    bytes: 72,
    info: 'Standard query A internal.novatech.com',
  ),
  // ── SUSPICIOUS ──
  NetworkCapture(
    id: 'priya_net_02',
    timestamp: '2026-08-15 01:02:00',
    sourceIp: '10.0.1.50',
    destIp: '8.8.8.8',
    protocol: 'DNS',
    bytes: 64,
    info: 'Standard query A smtp.gmail.com',
  ),
  NetworkCapture(
    id: 'priya_net_03',
    timestamp: '2026-08-15 01:04:30',
    sourceIp: '10.0.1.50',
    destIp: '142.250.185.109',
    protocol: 'SMTP',
    bytes: 49283072,
    info: 'SMTP STARTTLS → smtp.gmail.com:587 [47.0 MB transfer]',
  ),
  NetworkCapture(
    id: 'priya_net_04',
    timestamp: '2026-08-19 01:28:00',
    sourceIp: '10.0.1.50',
    destIp: '8.8.8.8',
    protocol: 'DNS',
    bytes: 64,
    info: 'Standard query A smtp.gmail.com',
  ),
  NetworkCapture(
    id: 'priya_net_05',
    timestamp: '2026-08-19 01:30:15',
    sourceIp: '10.0.1.50',
    destIp: '142.250.185.109',
    protocol: 'SMTP',
    bytes: 31457280,
    info: 'SMTP STARTTLS → smtp.gmail.com:587 [30.0 MB transfer]',
  ),
];
