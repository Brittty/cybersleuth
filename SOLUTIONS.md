# CyberSleuth case solutions

Answer key for the three current cases. Evidence IDs refer to the case fixtures; the tool may display a filename, email subject, or log action instead of the scoring title.

## Completing a case

1. Complete chain of custody for all three disks: inspect labels and seals, sign the receipt, compute and compare original hashes, enable write protection, create clones, and compare clone hashes.
2. Each cloning attempt has an independent 20% chance of a simulated copy error. Reject mismatched copies, re-image them, and verify again until all copies match. Correctly handling an error preserves the custody points.
3. Select the implicated disk in the investigation report.
4. Mark the five scored evidence items listed for the case. The supporting items listed below can also be marked without a penalty. Unrelated items still incur false-positive penalties.
5. Add the five items to the report timeline in the submission order shown below, then submit.

The maximum score is 100: device identification (30), evidence (50), timeline (15), and custody (5). Each unrelated evidence item costs 5 points. Supporting evidence earns no extra points and incurs no penalty. Timeline credit is based on correctly ordered pairs out of all ten expected pairs; two correct events earn 2 of 15 points, while the complete correct sequence earns 15. The debug custody skip does not award custody points.

## Case 1: Insider Threat at NovaTech

**Message sender:** IT Operations Manager  
**Case ID:** `contract_01`  
**Select disk:** `DISK-NVT-0217`  
**Workstation:** `SYS-DEV-042`, Senior Developer  
**Implicated employee:** Priya Menon

Priya accessed the restricted R&D source directory after hours, staged the source files, and prepared an encrypted archive. A personal email and a matching outbound SMTP transfer support the conclusion that the archive left the organization.

### Evidence to mark

All five items are on `DISK-NVT-0217`.

| Tool | Item to select | Evidence ID | Significance |
| --- | --- | --- | --- |
| Access Logs | `SSH_LOGIN` to `rd-server-03.internal`, August 14 at 23:45 | `priya_access_01` | Establishes the after-hours connection to the R&D server. |
| Access Logs | `FILE_COPY` from `/projects/ml-core/src/` to `/tmp/export/`, August 15 at 00:30 | `priya_access_copy` | Records the source files being staged for export. |
| File Explorer | `/home/priya/Downloads/export_script.sh` | `priya_file_01` | Archives the ML source directory and encrypts it with GPG. |
| Email Viewer | Subject `backup`, sent to `priya.personal.372@gmail.com` at 01:05 | `priya_email_03` | Attaches `ml_model_v3_FINAL.tar.gz.enc` to an email sent to a personal account. |
| Network Analyzer | SMTP to `142.250.185.109`, 47 MB transfer | `priya_net_03` | Corroborates the encrypted archive transfer to Gmail. |

### Artifact chronology

| Date | Time | Event |
| --- | --- | --- |
| 2026-08-14 | 23:45:00 | SSH login to `rd-server-03.internal`. |
| 2026-08-15 | 00:12:00 | Access to `/projects/ml-core/src/`. |
| 2026-08-15 | 00:30:00 | Bulk copy to `/tmp/export/`, recorded separately as `priya_access_copy`. |
| 2026-08-15 | 00:45:00 | Modification timestamp of `export_script.sh`, which packages and encrypts the source. |
| 2026-08-15 | 01:04:30 | SMTP capture for the 47 MB transfer to Gmail. |
| 2026-08-15 | 01:05:00 | Email with the encrypted archive sent to the personal Gmail address. |

### Timeline order to submit

1. `priya_access_01`: SSH login.
2. `priya_access_copy`: Bulk copy to the export directory.
3. `priya_file_01`: Export script.
4. `priya_net_03`: Outbound SMTP transfer at 01:04:30.
5. `priya_email_03`: Email to personal Gmail at 01:05.

The submission order follows the artifact timestamps. The 00:12 directory-access record (`priya_access_02`) is accepted as supporting evidence. Mark the separate 00:30 file-copy record (`priya_access_copy`) instead.

### Avoid false positives

Raj's deployment activity and Ananya's QA activity provide alternative explanations for routine access. The archive and the supporting items listed below are accepted without penalty. Unrelated activity should not be marked.

### Accepted supporting evidence IDs

These provide corroboration or help rule out alternative explanations. They are not required for full marks and do not replace the five key timeline events.

- `raj_file_checklist`
- `raj_file_deploy`
- `raj_email_01`
- `raj_email_02`
- `raj_access_03`
- `raj_access_04`
- `priya_access_02`
- `priya_file_enc`
- `priya_file_bash`
- `priya_file_authlog`
- `priya_file_known_hosts`

## Case 2: Ransomware at Meridian Logistics

**Message sender:** Meridian Incident Response  
**Case ID:** `contract_02`  
**Select disk:** `DISK-02-014`  
**Workstation:** `SYS-FIN-014`, Accounts Payable Analyst

The initial compromised workstation opened a supplier-themed document. Word launched an unexpected executable, followed by a payload download, invoice encryption, and ransom-note creation. Identifying the compromised workstation does not establish that its owner acted maliciously.

### Evidence to mark

All five items are on `DISK-02-014`.

| Tool | Item to select | Evidence ID | Significance |
| --- | --- | --- | --- |
| Email Viewer | Overdue invoice email from `billing@supplier-review.example`, with `Invoice_August.docm` | `sys-fin-014_email_01` | Delivers the document used in the infection. |
| Access Logs | `DOCUMENT_OPEN` for `Downloads/Invoice_August.docm` | `sys-fin-014_access_01` | Records `WINWORD` launching `invoice-helper.exe`. |
| Network Analyzer | HTTPS download from `198.51.100.42` | `sys-fin-014_net_01` | Correlates Word with a 98,304-byte download from `supplier-review.example/invoice-helper.exe`. |
| File Explorer | `/Documents/endpoint_events.txt` | `sys-fin-014_file_01` | Records `invoice-helper.exe` rewriting invoice PDFs with the `.locked` extension; 214 files changed. |
| Access Logs | `FILE_CREATE` for `/shares/invoices/READ_ME.txt` | `sys-fin-014_access_02` | Records the same executable creating a ransom note. |

### Timeline and submission order

All events occur on **2026-08-21**. Add these five evidence items in this order.

| Order | Time | Event | Evidence ID |
| --- | --- | --- | --- |
| 1 | 09:00 | Supplier lure arrives with the document attachment. | `sys-fin-014_email_01` |
| 2 | 09:10 | Document opens and Word launches the unexpected executable. | `sys-fin-014_access_01` |
| 3 | 09:12 | Payload download is recorded. | `sys-fin-014_net_01` |
| 4 | 09:15 | Invoice files begin being encrypted. | `sys-fin-014_file_01` |
| 5 | 09:18 | Ransom note is created. | `sys-fin-014_access_02` |

### Avoid false positives

The backup operation has approval `CHG-204` and uses internal destination `10.20.0.50`. The audit activity has approval `AUD-318` and uses `10.20.0.60` for aggregate reports. Neither is part of the scored infection chain. Routine login, intranet traffic, and daily-priorities emails are not scored evidence.

### Accepted supporting evidence IDs

These provide corroboration or help rule out alternative explanations. They are not required for full marks and do not replace the five key timeline events.

- `case02_sys_2:/Work/restore_test.txt`
- `case02_sys_3:/Work/aggregate_totals.csv`
- `case02_sys_3:/Work/audit_minutes.txt`
- `sys-fin-014_file_02`
- `sys-fin-014:/Work/supplier_directory.csv`
- `case02_sys_2_file_01`
- `case02_sys_2_email_01`
- `case02_sys_2_access_02`
- `case02_sys_2_net_01`
- `case02_sys_2:/Work/CHG-204.txt`
- `case02_sys_3_file_01`
- `case02_sys_3_email_01`
- `case02_sys_3_access_02`
- `case02_sys_3_net_01`
- `case02_sys_3:/Work/AUD-318.txt`

## Case 3: Payroll Leak at Aster Analytics

**Message sender:** Aster HR Security  
**Case ID:** `contract_03`  
**Select disk:** `DISK-03-014`  
**Workstation:** `SYS-HR-027`, Payroll Administrator

An external request is followed by a database export containing employee bank details, archive creation, an outbound upload, and deletion of staged files. The archive size and filename match the successful upload, linking the export to the external transfer.

### Evidence to mark

All five items are on `DISK-03-014`.

| Tool | Item to select | Evidence ID | Significance |
| --- | --- | --- | --- |
| Email Viewer | `Private payroll handoff` from `recruiting@talent-market.example` | `sys-hr-027_email_01` | Requests an unapproved transfer of the full payroll roster. |
| Access Logs | `DATABASE_EXPORT` from `payroll-db.internal` | `sys-hr-027_access_01` | Records 1,842 employee bank records exported to `/tmp/payroll_aug.csv`. |
| File Explorer | `/Documents/archive_manifest.txt` | `sys-hr-027_file_01` | Links the CSV to `/tmp/payroll_aug.zip`, with a size of 2,097,152 bytes. |
| Network Analyzer | HTTPS upload to `203.0.113.77` | `sys-hr-027_net_01` | Records a DLP-correlated upload of `payroll_aug.zip` to `drop.talent-market.example/upload`; size matches and HTTP 201 indicates successful delivery. |
| Access Logs | `FILE_DELETE` for the staged CSV and ZIP | `sys-hr-027_access_02` | Records cleanup through an interactive user session after the upload. |

### Timeline and submission order

All events occur on **2026-08-26**. Add these five evidence items in this order.

| Order | Time | Event | Evidence ID |
| --- | --- | --- | --- |
| 1 | 09:00 | External payroll handoff request arrives. | `sys-hr-027_email_01` |
| 2 | 09:10 | Employee bank records are exported to CSV. | `sys-hr-027_access_01` |
| 3 | 09:12 | Payroll ZIP archive is created. | `sys-hr-027_file_01` |
| 4 | 09:15 | Archive is uploaded to the external destination. | `sys-hr-027_net_01` |
| 5 | 09:18 | Staged CSV and ZIP files are deleted. | `sys-hr-027_access_02` |

The email requests a transfer that morning, consistent with the recorded export and upload.

### Avoid false positives

The approved backup (`CHG-204`) and aggregate audit (`AUD-318`) use internal destinations. They do not establish an external transfer of employee bank details. `/Documents/payroll_policy.txt` supports the finding that the destination is unauthorized, and is accepted as supporting evidence.

### Accepted supporting evidence IDs

These provide corroboration or help rule out alternative explanations. They are not required for full marks and do not replace the five key timeline events.

- `case03_sys_2:/Work/restore_test.txt`
- `case03_sys_3:/Work/aggregate_totals.csv`
- `case03_sys_3:/Work/audit_minutes.txt`
- `sys-hr-027_file_02`
- `case03_sys_2_file_01`
- `case03_sys_2_email_01`
- `case03_sys_2_access_02`
- `case03_sys_2_net_01`
- `case03_sys_2:/Work/CHG-204.txt`
- `case03_sys_3_file_01`
- `case03_sys_3_email_01`
- `case03_sys_3_access_02`
- `case03_sys_3_net_01`
- `case03_sys_3:/Work/AUD-318.txt`

## Source references

- [Case catalog](lib/providers/contract_provider.dart)
- [NovaTech answer key](lib/assets/contracts/contract_01.dart)
- [Priya's artifacts](lib/assets/contracts/contract_01/sys_dev_042.dart)
- [Meridian artifacts and answer key](lib/assets/contracts/contract_02.dart)
- [Aster artifacts and answer key](lib/assets/contracts/contract_03.dart)
- [Scoring implementation](lib/models/investigation_score.dart)
- [Custody implementation](lib/providers/chain_of_custody_provider.dart)
