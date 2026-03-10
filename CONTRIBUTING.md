# Contributing to Scagen

Thank you for your interest in contributing! This document covers how to get the project running locally, the conventions we follow, and how to submit changes.

---

## Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [Code Conventions](#code-conventions)
- [Localization](#localization)
- [Submitting a Pull Request](#submitting-a-pull-request)
- [Reporting Bugs](#reporting-bugs)
- [Feature Requests](#feature-requests)

---

## Getting Started

### Prerequisites

- [Flutter](https://docs.flutter.dev/get-started/install) ≥ 3.3.3
- An [Appwrite](https://appwrite.io) project (cloud or self-hosted) — see [README.md](README.md#appwrite-setup) for the required schema
- Optional: a [PostHog](https://posthog.com) project for analytics

### Setup

```bash
git clone https://github.com/oluwasniper/Stagen.git
cd Stagen
flutter pub get
cp .env.example .env          # fill in your Appwrite / PostHog values
cp .vscode/launch.json.example .vscode/launch.json   # optional, for VS Code
```

Run the app:

```bash
make run
# or
flutter run --dart-define-from-file=.env
```

---

## Development Workflow

1. **Fork** the repository and clone your fork.
2. Create a branch from `main` with a descriptive name:

   ```bash
   git checkout -b fix/scanner-crash
   git checkout -b feat/export-csv
   ```

3. Make your changes (see conventions below).
4. Run the analyzer and tests before pushing:

   ```bash
   flutter analyze
   flutter test
   ```

5. Open a pull request against `main`.

---

## Code Conventions

| Area | Convention |
| --- | --- |
| State management | `flutter_riverpod` — `StateNotifier` for mutable state, `Provider` for services |
| Inside notifiers | `_ref.read(provider)` — never `watch` |
| Routing | `go_router`; path constants in `lib/utils/route/app_path.dart`, name constants in `lib/utils/route/app_name.dart` |
| Secrets | Never commit secrets. All credentials are passed via `--dart-define-from-file=.env` at build time |
| Constant namespaces | `abstract final class` (e.g. `TelemetryEvents`) |
| Secure storage keys | Define as constants in a private `_Keys` class inside the relevant file |
| Telemetry calls | Always fire-and-forget with `.catchError` — never let analytics crash the app |
| PR scope | One feature or bug fix per PR |

Follow the existing style in the file you are editing. Run `flutter analyze` and fix any warnings before opening a PR.

---

## Localization

The app supports English, Spanish, French, and Portuguese via Flutter's `gen-l10n` tooling.

- ARB files live in [lib/l10n/](lib/l10n/).
- `app_en.arb` is the source of truth — add new strings there first.
- Add the corresponding translations to the other ARB files in the same PR.
- After editing ARB files, regenerate the localization classes:

  ```bash
  flutter gen-l10n
  ```

- Do not edit `lib/l10n/app_localizations*.dart` directly — these are generated.

If you are not able to provide a translation, add the English string as a placeholder and note it in your PR description.

---

## Submitting a Pull Request

- Base your branch on `main`.
- Keep the PR focused — one feature or fix per PR.
- Write a clear PR description:
  - **What** changed
  - **Why** it was needed
  - Any **testing** you did (device / OS, steps to reproduce the original problem)
- Link any related issue (e.g. `Closes #42`).
- PRs that break `flutter analyze` or existing tests will not be merged until fixed.

---

## Reporting Bugs

Open a [GitHub issue](https://github.com/oluwasniper/Stagen/issues) and include:

- Device model and OS version
- App version (shown in Settings)
- Steps to reproduce
- What you expected vs. what happened
- Relevant logs or screenshots if available

---

## Feature Requests

Open a [GitHub issue](https://github.com/oluwasniper/Stagen/issues) with the `enhancement` label. Describe the use case and the problem it solves. Discussion is welcome before implementation begins.

---

## Code of Conduct

All contributors are expected to follow the [Code of Conduct](CODE_OF_CONDUCT.md). Please read it before participating.

---

## License

By contributing you agree that your changes will be licensed under the project's [MIT License](LICENSE).
