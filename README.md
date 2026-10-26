# NestSplit

*Split the Bill, Share the Load.*

Shared-living app for housemates (chores first, expenses second) with a lightweight landlord view.
Built for BatStateU ENGG 405 (Technopreneurship).

> **Status: not yet compiled or run.** This code was written without access to a Flutter SDK, so it has
> never been built, run on an emulator, or tested. Expect a few small compile errors on the first run.
> See [First run checklist](#first-run-checklist). It also uses **temporary sample data**, not a real backend.

## What is inside

| Role | Screens |
|------|---------|
| Tenant | Login, Create account, Home, Chores (list, detail, add), Progress, Activity, More hub, Chore swaps, Weekly recap, House rules, Members, Quick Split, Profile |
| Landlord | Dashboard, Rooms, Rent tracker, Maintenance, Announcements, Rule templates, More hub, Profile |

Privacy rule: the landlord side never shows tenants' chores, fairness scores or expenses.

## Prerequisites

- Flutter SDK 3.19 or newer (Dart 3). Check with `flutter --version`. Install: https://docs.flutter.dev/get-started/install
- Android Studio (Android emulator) and/or Xcode (iOS simulator, macOS only), or a USB-connected phone.
- Git.

## Setup and run

The repo already contains the `android/` and `ios/` folders, so no `flutter create` is needed.

```bash
git clone https://github.com/eniemennie/NestSplit.git
cd NestSplit
flutter pub get
flutter run                              # pick an emulator or phone when asked
```

The launcher icon files (Android and iOS) are already committed. If you change `assets/images/logo.png`, regenerate them with `dart run flutter_launcher_icons`.
Uninstall any older copy of the app from the phone before running, so the old icon is not cached.

Other commands:

```bash
flutter analyze        # static checks
flutter test           # unit + widget tests
flutter run -d chrome  # quick look in a browser (web needs: flutter create . --platforms=web)
```

## First run checklist

1. `flutter pub get`
2. `flutter analyze` and fix anything reported (most likely small typos or missing imports).
3. `flutter test`
4. `flutter run`, then: Sign in -> Home -> Chores -> mark a chore done -> More -> Quick Split.
   Then log out (More -> Members -> Log out) and use "I'm a landlord".
5. Compare each screen with the mockups and note differences in an issue.

## Project structure

```
lib/
  main.dart                  entry point, creates AppServices with the mock repository
  app.dart                   MaterialApp, theme, role-based home
  core/
    theme/                   colors, text styles, ThemeData  (change the look here)
    utils/                   money formatting, split maths, time helpers
    widgets/                 reusable pieces (cards, buttons, pills, bars, nav, avatars)
  data/
    models/                  plain Dart classes (Member, Chore, Expense, Room, ...)
    repositories/            AppRepository (interface) + MockAppRepository (sample data)
  state/                     HouseholdState, PropertyState (ChangeNotifier), AppServices/AppScope
  features/                  one folder per screen group: auth, home, chores, progress, activity,
                             more, swaps, recap, rules, members, quick_split, shell, landlord
test/                        split maths tests and a widget smoke test
```

How it fits together: screens read state through `AppScope.of(context)`, state classes call the
`AppRepository`, and only the repository knows where data comes from.

## Design system

Colors (`core/theme/app_colors.dart`): blue `#6FB5E8`, pink `#F5A9E0`, lime `#DCE85C`, background `#F5F6F8`, navy `#1F2A44`.
Flat Memphis-style shapes, the blue/pink/lime "tri-band" on key buttons (`TriBandButton`), and a floating pill bottom bar.
Use the widgets in `core/widgets` instead of styling from scratch so screens stay consistent.

Interpretations worth knowing:
- The mockup's geometric icons are replaced with Material icons. Swap them in `chore_icons.dart` and the nav item lists.
- No custom font was identifiable, so the default font is used. Add one in `pubspec.yaml` and set `AppText.fontFamily`.
- The mockup shows a fairness score of 62; the sample data computes 67. Scores are calculated, not hardcoded.
- The mockup lists 6 chores; the sample data has 14 so the Home ring (9 of 14) and the recap (12 done) agree.
- Premium / subscription / B2B pricing screens are intentionally not in the prototype.

## Sign-in and accounts

The login screen asks for an email and password and checks them with `AuthRepository`.
Right now that is `MockAuthRepository` (local, in memory, **not secure**: accounts reset when the app restarts).

Demo accounts for testing (fake, password `Nest1234`):
- `ben@nestsplit.test` and `ana@nestsplit.test` (tenants): use **Sign in** on the first screen
- `landlord@nestsplit.test` (landlord): use **Landlord login** on the first screen

Each door only accepts its own kind of account.

"Create account" lets someone register as a tenant (needs the home invite code, `LKB-482` in the sample data) or as a landlord.
The Profile tab (both roles) shows the account and offers Edit name, Change password and Log out.

For real accounts, write a class that `implements AuthRepository` (for example with Firebase Authentication) and pass it:
`AppServices(MockAppRepository(), auth: FirebaseAuthRepository())`. Never store passwords yourself and never commit keys.

## Sample data (landlord side)

Three boarding houses with 30 rooms and 23 tenants are generated in `lib/data/repositories/sample_properties.dart`:
Lakbay Boarding House (8 rooms, code LKB-482), Sampaguita Residences (10 rooms, SMP-317) and Mabini Dormitory (12 rooms, MBN-905).
On the landlord Dashboard or Rooms tab, tap the property name to switch between them.
Tenants who register still join the single tenant household (invite code `LKB-482`).

## Splash screen

A simple static splash (`lib/features/splash/splash_screen.dart`): the logo centered on the brand blue (`#75B6E7`). It stays for 1.8 s,
then fades to the login screen. It has no animation on purpose, so it looks the same on every phone.
The phone's own start screen uses the same blue (`android/app/src/main/res/values/colors.xml`, `ios/Runner/Base.lproj/LaunchScreen.storyboard`),
so there is no flash between the two. The logo files are `assets/images/logo.png` and `assets/images/logo_foreground.png`.

## Backend

There is no backend yet. `MockAppRepository` returns sample data and keeps changes in memory only.
To connect Firebase or an API, write a class that `implements AppRepository`, then pass it in `main.dart`:

```dart
final services = AppServices(FirebaseAppRepository());
```

No screens need to change. Keep keys and config files out of git (see `.gitignore`).

## Git workflow for the group

**Owner (once):**
1. On github.com create a new empty repository (no README) named `nestsplit`.
2. Add teammates: repo -> Settings -> Collaborators -> Add people -> enter their GitHub usernames. They accept the email invite.
3. In this folder:
   ```bash
   git remote add origin https://github.com/<owner>/nestsplit.git
   git push -u origin main
   ```
   (Sign in when prompted. GitHub needs a personal access token or GitHub CLI login, not your password.)

**Each teammate:**
```bash
git clone https://github.com/<owner>/nestsplit.git
cd nestsplit
flutter pub get
git checkout -b feature/<short-name>      # e.g. feature/rent-tracker-polish
# edit files, then:
flutter analyze && flutter test
git add .
git commit -m "Add late-rent reminder button"
git push -u origin feature/<short-name>
```
Open a Pull Request on GitHub into `main`, ask one teammate to review, then merge.
Before starting new work: `git checkout main && git pull`.

Branch names: `feature/...`, `fix/...`, `docs/...`. Commit messages: short, present tense, one idea each.
Never commit passwords, API keys, `google-services.json`, `.env`, or keystores.

## Where to edit common things

| Want to change | File |
|----------------|------|
| Colors / text styles | `lib/core/theme/` |
| Sample people, chores, rooms | `lib/data/repositories/mock_app_repository.dart` |
| Fairness score rules | `lib/state/household_state.dart` |
| Split rounding | `lib/core/utils/split_calculator.dart` |
| Bottom tabs | `lib/features/shell/tenant_shell.dart`, `lib/features/landlord/landlord_shell.dart` |
