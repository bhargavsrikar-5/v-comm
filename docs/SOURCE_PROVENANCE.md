# Source provenance and evidence

## Repositories reviewed

| Source | Role in project history | Use in this unified repository |
|---|---|---|
| `bhargavsrikar-5/v_comm` | Bhargav's fork of the older Firebase generation | Compared as one of the V1 source copies |
| `Rupesh42590/v_comm` | Older Firebase source repository | Compared with the V1 copies and local snapshot |
| `hithesh1120/v_comm` | Hithesh's older Firebase copy | Compared for shared/missing files |
| `Rupesh42590/VCOMM` | Later Flutter + Spring Boot generation | Active architecture starting point |
| `bhargavsrikar-5/v_com-app` | README-only repository at the time checked | Not used as an application source |

## Recovered files reviewed

- A Flutter + Spring Boot source ZIP.
- Two identical older Firebase ZIP snapshots.
- Hithesh's older Firebase source ZIP.
- A recovered `v_comm.zip` working copy containing a Git checkout and uncommitted changes.
- An ARM64 Android APK.
- The capstone report `V_COMM.pdf`.
- The V-COMM feature presentation PDF/PPTX and mobile application review decks.
- Separate Firebase admin panel HTML/CSS, preserved as a sanitized reference under `legacy/firebase-v1/admin-panel/`.

## Recovered local working-copy note

The recovered local working copy's Git HEAD was `45cd86a` (`fixed bugs`, authored November 3, 2025). Its working tree contained many line-ending/platform-generated diffs; after ignoring line-ending-only changes, the substantive tracked source difference was concentrated in `lib/HomePage/homepage.dart`. That file adds dashboard sections for today's/future events and a timetable image upload through Firebase Storage. The copy also contains a `lib/Notifications/notifications_service.dart` scheduler, but no call sites from the rest of the inspected app were found.

The local working copy also contains live Firebase platform configuration files. Those files were intentionally excluded from this repository's `legacy/firebase-v1` reference copy.

## APK note

The supplied APK was identified from its Android manifest and bundled Flutter artifacts as an ARM64 V1/Firebase-era build. It is not evidence that the newer Spring Boot migration currently builds or runs. The APK binary is not included in this repository baseline.

## Documentation caveat

The original report and presentation describe intended and claimed functionality. Source review was used to distinguish these claims from code found in the repositories. A feature is not considered runtime-verified until a test or device walkthrough confirms it.


## Unified candidate note

The active `mobile/` and `backend/` trees are a curated, security-remediated reconstruction based on the later Flutter + Spring Boot source and the shared project requirements. The legacy Firebase tree is kept inactive as a reference. No source repository is modified by this reconstruction. The current active source has not yet been build-verified.
