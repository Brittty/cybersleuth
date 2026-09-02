import 'package:cyber_sleuth/models/disk_image_model.dart';
import 'package:cyber_sleuth/models/file_node_model.dart';
import 'package:cyber_sleuth/models/forensic_models.dart';

const rajDisk = DiskImage(
  diskId: 'DISK-NVT-0094',
  ownerName: 'SYS-OPS-089',
  ownerRole: 'DevOps Engineer',
  originalHash:
      'b8d2e5f1a4c7093e6b9d2f5a8c1e4d7b0a3f6e9c2d5b8a1e4f7c0d3a6b9e2f5',
  rootDirectory: rajRoot,
  accessLogs: rajAccessLogs,
  emailRecords: rajEmails,
  networkCaptures: rajNetworkCaptures,
);

// ── Raj's File System ────────────────────────────────────────

const rajRoot = FileNode(
  id: 'raj:/',
  name: '/',
  isDirectory: true,
  lastModified: '2026-08-18 02:00:00',
  children: [
    FileNode(
      id: 'raj:/home',
      name: 'home',
      isDirectory: true,
      lastModified: '2026-08-18 02:00:00',
      children: [
        FileNode(
          id: 'raj:/home/raj',
          name: 'raj',
          isDirectory: true,
          lastModified: '2026-08-18 02:00:00',
          children: [
            FileNode(
              id: 'raj:/home/raj/Documents',
              name: 'Documents',
              isDirectory: true,
              lastModified: '2026-08-17 14:00:00',
              children: [
                FileNode(
                  id: 'raj_file_checklist',
                  name: 'deployment_checklist.md',
                  sizeBytes: 2103,
                  lastModified: '2026-08-17 14:00:00',
                  textContent:
                      '# Production Deployment Checklist — v2.3.1\n\n'
                      '## Pre-deployment\n'
                      '- [x] All CI/CD pipelines green\n'
                      '- [x] Staging environment validated\n'
                      '- [x] Database migration scripts reviewed\n'
                      '- [x] Rollback plan documented\n\n'
                      '## Deployment Steps\n'
                      '1. Enable maintenance mode\n'
                      '2. Run database migrations\n'
                      '3. Deploy containers via Kubernetes\n'
                      '4. Validate health checks\n'
                      '5. Disable maintenance mode\n'
                      '6. Monitor error rates for 30 min\n\n'
                      '## Post-deployment\n'
                      '- [x] Verify API response times\n'
                      '- [x] Check log aggregation\n'
                      '- [x] Notify stakeholders\n',
                  hexPreview:
                      '00000000  23 20 50 72 6F 64 75 63  74 69 6F 6E 20 44 65 70  |# Production Dep|\n'
                      '00000010  6C 6F 79 6D 65 6E 74 20  43 68 65 63 6B 6C 69 73  |loyment Checklis|\n',
                ),
                FileNode(
                  id: 'raj_file_infra',
                  name: 'infra_diagram.txt',
                  sizeBytes: 1456,
                  lastModified: '2026-08-10 11:00:00',
                  textContent:
                      'NovaTech Infrastructure Layout\n'
                      '==============================\n\n'
                      'Production:\n'
                      '  Load Balancer → nginx (prod-lb-01)\n'
                      '  App Servers   → k8s cluster (prod-k8s-01..03)\n'
                      '  Database      → PostgreSQL (prod-db-01, prod-db-02)\n'
                      '  Cache         → Redis (prod-cache-01)\n\n'
                      'Staging:\n'
                      '  Single node   → staging-01.internal\n\n'
                      'CI/CD:\n'
                      '  Jenkins       → ci-server-01.internal\n'
                      '  Registry      → registry.internal.novatech.com\n',
                  hexPreview:
                      '00000000  4E 6F 76 61 54 65 63 68  20 49 6E 66 72 61 73 74  |NovaTech Infrast|\n'
                      '00000010  72 75 63 74 75 72 65 20  4C 61 79 6F 75 74 0A 3D  |ructure Layout.=|\n',
                ),
              ],
            ),
            FileNode(
              id: 'raj:/home/raj/Scripts',
              name: 'Scripts',
              isDirectory: true,
              lastModified: '2026-08-17 22:00:00',
              children: [
                FileNode(
                  id: 'raj_file_deploy',
                  name: 'deploy_prod.sh',
                  sizeBytes: 891,
                  lastModified: '2026-08-17 22:00:00',
                  textContent:
                      '#!/bin/bash\n'
                      '# Production deployment script\n'
                      'set -euo pipefail\n\n'
                      'VERSION=\$1\n'
                      'echo "Deploying NovaTech Platform v\$VERSION to production..."\n\n'
                      'kubectl set image deployment/novatech-api \\\n'
                      '  api=registry.internal.novatech.com/novatech-api:\$VERSION\n\n'
                      'kubectl rollout status deployment/novatech-api --timeout=300s\n\n'
                      'echo "Deployment complete. Running health checks..."\n'
                      'curl -sf http://prod-lb-01.internal/health || exit 1\n'
                      'echo "All health checks passed."\n',
                  hexPreview:
                      '00000000  23 21 2F 62 69 6E 2F 62  61 73 68 0A 23 20 50 72  |#!/bin/bash.# Pr|\n'
                      '00000010  6F 64 75 63 74 69 6F 6E  20 64 65 70 6C 6F 79 6D  |oduction deploym|\n',
                ),
                FileNode(
                  id: 'raj_file_backup',
                  name: 'backup_routine.sh',
                  sizeBytes: 567,
                  lastModified: '2026-08-05 16:00:00',
                  textContent:
                      '#!/bin/bash\n'
                      '# Weekly database backup routine\n'
                      'BACKUP_DIR="/backups/\$(date +%Y%m%d)"\n'
                      'mkdir -p \$BACKUP_DIR\n\n'
                      'pg_dump -h prod-db-01.internal -U novatech_admin novatech_prod \\\n'
                      '  | gzip > \$BACKUP_DIR/novatech_prod.sql.gz\n\n'
                      'echo "Backup complete: \$BACKUP_DIR/novatech_prod.sql.gz"\n',
                  hexPreview:
                      '00000000  23 21 2F 62 69 6E 2F 62  61 73 68 0A 23 20 57 65  |#!/bin/bash.# We|\n'
                      '00000010  65 6B 6C 79 20 64 61 74  61 62 61 73 65 20 62 61  |ekly database ba|\n',
                ),
              ],
            ),
            FileNode(
              id: 'raj:/home/raj/.docker',
              name: '.docker',
              isDirectory: true,
              lastModified: '2026-08-01 09:00:00',
              children: [
                FileNode(
                  id: 'raj_file_docker',
                  name: 'config.json',
                  sizeBytes: 234,
                  lastModified: '2026-08-01 09:00:00',
                  textContent:
                      '{\n'
                      '  "auths": {\n'
                      '    "registry.internal.novatech.com": {\n'
                      '      "auth": "cmFqLmthcG9vcjpOdjRUZWNo"\n'
                      '    }\n'
                      '  },\n'
                      '  "credsStore": "secretservice"\n'
                      '}\n',
                  hexPreview:
                      '00000000  7B 0A 20 20 22 61 75 74  68 73 22 3A 20 7B 0A 20  |{.  "auths": {. |\n'
                      '00000010  20 20 20 22 72 65 67 69  73 74 72 79 2E 69 6E 74  |   "registry.int|\n',
                ),
              ],
            ),
            FileNode(
              id: 'raj_file_bash',
              name: '.bash_history',
              sizeBytes: 1890,
              lastModified: '2026-08-18 01:30:00',
              textContent:
                  'kubectl get pods -n production\n'
                  'docker pull registry.internal.novatech.com/novatech-api:2.3.1\n'
                  'docker images | grep novatech\n'
                  'ssh raj.kapoor@prod-deploy-01.internal\n'
                  'kubectl rollout status deployment/novatech-api\n'
                  'curl http://prod-lb-01.internal/health\n'
                  'docker system prune -f\n'
                  'kubectl logs -f deployment/novatech-api --tail=100\n',
              hexPreview:
                  '00000000  6B 75 62 65 63 74 6C 20  67 65 74 20 70 6F 64 73  |kubectl get pods|\n'
                  '00000010  20 2D 6E 20 70 72 6F 64  75 63 74 69 6F 6E 0A 64  | -n production.d|\n',
            ),
          ],
        ),
      ],
    ),
    FileNode(
      id: 'raj:/var',
      name: 'var',
      isDirectory: true,
      lastModified: '2026-08-18 02:00:00',
      children: [
        FileNode(
          id: 'raj:/var/log',
          name: 'log',
          isDirectory: true,
          lastModified: '2026-08-18 02:00:00',
          children: [
            FileNode(
              id: 'raj_file_authlog',
              name: 'auth.log',
              sizeBytes: 5621,
              lastModified: '2026-08-18 02:00:00',
              textContent:
                  'Aug 13 09:01:22 workstation-0094 sshd[3201]: Accepted publickey for raj.kapoor from 10.0.2.30 port 48201\n'
                  'Aug 13 22:00:45 workstation-0094 sshd[3890]: Accepted publickey for raj.kapoor from 10.0.2.30 port 48502\n'
                  'Aug 14 09:15:00 workstation-0094 sshd[4102]: Accepted publickey for raj.kapoor from 10.0.2.30 port 49001\n'
                  'Aug 17 22:58:30 workstation-0094 sshd[5430]: Accepted publickey for raj.kapoor from 10.0.2.30 port 49800\n'
                  'Aug 18 01:30:12 workstation-0094 sshd[5430]: Disconnected from user raj.kapoor 10.0.2.30 port 49800\n',
              hexPreview:
                  '00000000  41 75 67 20 31 33 20 30  39 3A 30 31 3A 32 32 20  |Aug 13 09:01:22 |\n'
                  '00000010  77 6F 72 6B 73 74 61 74  69 6F 6E 2D 30 30 39 34  |workstation-0094|\n',
            ),
          ],
        ),
      ],
    ),
  ],
);

// ── Raj's Access Logs ────────────────────────────────────────

const rajAccessLogs = [
  AccessLogEntry(
    id: 'raj_access_01',
    timestamp: '2026-08-13 09:00:00',
    user: 'raj.kapoor',
    action: 'SSH_LOGIN',
    target: 'prod-deploy-01.internal',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'raj_access_02',
    timestamp: '2026-08-13 14:00:00',
    user: 'raj.kapoor',
    action: 'SSH_LOGIN',
    target: 'ci-server-01.internal',
    status: 'SUCCESS',
  ),
  // Late-night activity (RED HERRING — legitimate deployment)
  AccessLogEntry(
    id: 'raj_access_03',
    timestamp: '2026-08-13 22:00:00',
    user: 'raj.kapoor',
    action: 'SSH_LOGIN',
    target: 'prod-deploy-01.internal',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'raj_access_04',
    timestamp: '2026-08-13 22:15:00',
    user: 'raj.kapoor',
    action: 'SERVICE_RESTART',
    target: 'nginx @ prod-lb-01.internal',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'raj_access_05',
    timestamp: '2026-08-14 02:00:00',
    user: 'raj.kapoor',
    action: 'SSH_LOGOUT',
    target: 'prod-deploy-01.internal',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'raj_access_06',
    timestamp: '2026-08-17 23:00:00',
    user: 'raj.kapoor',
    action: 'SSH_LOGIN',
    target: 'prod-deploy-01.internal',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'raj_access_07',
    timestamp: '2026-08-17 23:45:00',
    user: 'raj.kapoor',
    action: 'DEPLOY',
    target: 'novatech-api v2.3.1 → prod-k8s-01',
    status: 'SUCCESS',
  ),
  AccessLogEntry(
    id: 'raj_access_08',
    timestamp: '2026-08-18 01:30:00',
    user: 'raj.kapoor',
    action: 'SSH_LOGOUT',
    target: 'prod-deploy-01.internal',
    status: 'SUCCESS',
  ),
];

// ── Raj's Emails ─────────────────────────────────────────────

const rajEmails = [
  EmailRecord(
    id: 'raj_email_01',
    timestamp: '2026-08-13 22:30:00',
    from: 'raj.kapoor@novatech.com',
    to: 'ops-team@novatech.com',
    subject: 'Hotfix deployment — prod nginx restart',
    body:
        'Team,\n\n'
        'Deploying an urgent nginx config fix to prod-lb-01 tonight.\n'
        'Expected downtime: ~2 minutes.\n\n'
        'Will monitor until stable.\n\n'
        '— Raj',
    headers: {
      'From': 'raj.kapoor@novatech.com',
      'To': 'ops-team@novatech.com',
      'Date': 'Tue, 13 Aug 2026 22:30:00 +0530',
      'Message-ID': '<20260813223000.GA7890@novatech.com>',
      'Subject': 'Hotfix deployment — prod nginx restart',
      'X-Mailer': 'NovaTech Mail Server 4.2',
    },
  ),
  EmailRecord(
    id: 'raj_email_02',
    timestamp: '2026-08-18 00:05:00',
    from: 'raj.kapoor@novatech.com',
    to: 'ops-team@novatech.com',
    subject: 'Deployment v2.3.1 complete',
    body:
        'Team,\n\n'
        'v2.3.1 has been deployed to production.\n'
        'All health checks passing. Error rates nominal.\n\n'
        'Changes in this release:\n'
        '- API rate limiting improvements\n'
        '- Database connection pool fix\n'
        '- Updated monitoring dashboards\n\n'
        '— Raj',
    headers: {
      'From': 'raj.kapoor@novatech.com',
      'To': 'ops-team@novatech.com',
      'Date': 'Sun, 18 Aug 2026 00:05:00 +0530',
      'Message-ID': '<20260818000500.GB1234@novatech.com>',
      'Subject': 'Deployment v2.3.1 complete',
      'X-Mailer': 'NovaTech Mail Server 4.2',
    },
  ),
  EmailRecord(
    id: 'raj_email_03',
    timestamp: '2026-08-16 11:00:00',
    from: 'cto@novatech.com',
    to: 'raj.kapoor@novatech.com',
    subject: 'Re: Infra migration timeline',
    body:
        'Raj,\n\n'
        'Thanks for the detailed plan. Let\'s proceed with the AWS migration\n'
        'in Q4 as proposed. Please prepare the cost analysis for the board\n'
        'meeting next month.\n\n'
        'Best,\nSuresh Nair\nCTO, NovaTech Solutions',
    headers: {
      'From': 'cto@novatech.com',
      'To': 'raj.kapoor@novatech.com',
      'Date': 'Fri, 16 Aug 2026 11:00:00 +0530',
      'Message-ID': '<20260816110000.GC5678@novatech.com>',
      'Subject': 'Re: Infra migration timeline',
      'X-Mailer': 'NovaTech Mail Server 4.2',
    },
  ),
];

// ── Raj's Network Captures ───────────────────────────────────

const rajNetworkCaptures = [
  NetworkCapture(
    id: 'raj_net_01',
    timestamp: '2026-08-13 09:00:30',
    sourceIp: '10.0.2.30',
    destIp: '10.0.10.5',
    protocol: 'SSH',
    bytes: 2048,
    info: 'SSH handshake → prod-deploy-01.internal',
  ),
  // Red herring: large Docker pull
  NetworkCapture(
    id: 'raj_net_02',
    timestamp: '2026-08-17 23:10:00',
    sourceIp: '10.0.2.30',
    destIp: '10.0.5.50',
    protocol: 'HTTPS',
    bytes: 524288000,
    info: 'Docker pull registry.internal.novatech.com/novatech-api:2.3.1 [500 MB]',
  ),
  NetworkCapture(
    id: 'raj_net_03',
    timestamp: '2026-08-17 23:30:00',
    sourceIp: '10.0.2.30',
    destIp: '10.0.10.5',
    protocol: 'SSH',
    bytes: 4096,
    info: 'SSH session → prod-deploy-01.internal (kubectl rollout)',
  ),
  NetworkCapture(
    id: 'raj_net_04',
    timestamp: '2026-08-18 00:00:00',
    sourceIp: '10.0.2.30',
    destIp: '10.0.10.1',
    protocol: 'HTTP',
    bytes: 256,
    info: 'GET /health → prod-lb-01.internal [200 OK]',
  ),
  NetworkCapture(
    id: 'raj_net_05',
    timestamp: '2026-08-13 22:05:00',
    sourceIp: '10.0.2.30',
    destIp: '10.0.10.5',
    protocol: 'SSH',
    bytes: 2048,
    info: 'SSH handshake → prod-deploy-01.internal',
  ),
];

// ============================================================
//  DISK 3 — Ananya Desai (CLEAN)
// ============================================================
