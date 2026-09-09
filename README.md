# CyberSleuth

A Flutter/Riverpod forensic investigation game. Select a message to accept a case, verify and clone its disk images, inspect artifacts, and submit an evidence timeline and implicated disk for scoring.

## Investigation cases

- **Insider Threat at NovaTech** — investigate proprietary source-code exfiltration.
- **Ransomware at Meridian Logistics** — trace a supplier email through document execution, a payload download, and encrypted invoice files. Identify the compromised workstation without assuming its owner acted maliciously.
- **Payroll Leak at Aster Analytics** — correlate a payroll export, archive manifest, external upload, and cleanup activity.

Each case includes three disk images with files and hex previews, access logs, emails, and network captures. Compare corroborating artifacts against routine activity before marking evidence.

## Classroom demonstration

The two newer cases each have 37 files across three disks, including Work, System, Personal, and Documents folders. Background files include reconciliation sheets, payroll calendars, backup approvals, restore checks, audit scopes, network settings, and training notes.

1. Enter an examiner name and check each package label and intact seal.
2. Compute original hashes and explicitly compare them with the manifest.
3. Enable the write blocker and create working copies.
4. Create working copies. Each imaging attempt has an independent 20% chance of a simulated copy error, including replacement attempts.
5. Compare clone hashes. Reject a damaged copy, choose **Re-image safely**, and verify the replacement.
6. Review the timestamped custody activity log and begin investigation.

Incorrect comparisons cannot approve evidence. Successfully detecting and replacing a damaged clone retains the custody bonus. The log is held in memory for the current case; it is an educational simulation, not a real acquisition record.

## Project structure

- `lib/assets/contracts/`: case briefings, disk artifacts, correct evidence, and timelines. The new scenarios use fictional organizations and reserved example network destinations.
- `lib/providers/contract_provider.dart`: shared case catalog and active-case lookup.
- `lib/providers/`: navigation, chain of custody, selected forensic tool, and investigation state. Accepting a case resets the previous investigation.
- `lib/screens/`: messaging → chain of custody → forensic desktop → report → scoring. The scoring screen returns to the case list.
- `lib/models/`: contracts, disks, files, forensic records, and evidence structures.

The app uses in-memory fixtures; disk hashing and cloning are simulated. Scores award 30 points for disk identification, 50 for five key evidence items, 15 for timeline ordering, and 5 for custody checks, with penalties for unrelated evidence. Curated supporting evidence is accepted without a bonus or penalty. Timeline credit uses all expected event pairs, so omitted events reduce the score.

## Development

```sh
flutter pub get
flutter run
flutter analyze
flutter test
```

Tests exercise intake prerequisites, incorrect comparisons, damaged-clone recovery, and write protection. They also check new-case artifact references and chronology, plus selection, custody initialization, screen transitions, perfect-answer scoring, and state isolation across all three cases.
