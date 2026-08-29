# 🛡️ Safety Guard

A personal safety and emergency-assistance app built with **Flutter** using an **MVVM architecture**. This repository currently contains **Module 1: Product Foundation, UX & Project Architecture** — the app shell, navigation, design system, data models, and screen scaffolding, built and fully navigable end-to-end before any backend is connected.

---

## Table of Contents

- [Module Roadmap](#module-roadmap)
- [What's Included in Module 1](#whats-included-in-module-1)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Architecture: MVVM](#architecture-mvvm)
- [Design System](#design-system)
- [Widget Catalog](#widget-catalog)
- [Navigation Map](#navigation-map)
- [Known Limitations (Module 1 Scope)](#known-limitations-module-1-scope)
- [Adding the Inter Font](#adding-the-inter-font)
- [Troubleshooting](#troubleshooting)
- [Roadmap: What's Next](#roadmap-whats-next)

---

## Module Roadmap

| Module | Scope | Status |
|---|---|---|
| **1. Foundation, UX & Architecture** | Design system, navigation shell, MVVM scaffolding, auth screens (stubbed) | ✅ **This repo** |
| 2. Authentication & Contacts | Firebase Auth, Firestore, real Trusted Contacts CRUD | 🔜 Not started |
| 3. Safety Timer & Check-In | Countdown session, background execution, check-in flow | 🔜 Not started |
| 4. Emergency Dispatch | Live GPS sharing, push notifications, "I Need Help" escalation | 🔜 Not started |
| 5. History, Settings & Accessibility | Safety History log, Settings/Profile, a11y pass | 🔜 Not started |
| 6. Testing & Release Hardening | Unit/widget tests, error handling, store readiness | 🔜 Not started |

---

## What's Included in Module 1

- ✅ A **navigable, agreed product shell** — every screen in the UX kit exists and can be reached
- ✅ A centralized **design system** (colors, type, spacing, radius) ported from the Guardian Standard UI kit
- ✅ **MVVM structure** with `ChangeNotifier` ViewModels and `provider` for state management
- ✅ **Declarative routing** via `go_router`
- ✅ A **reusable widget library** so every screen looks and behaves consistently
- ✅ Splash → Login → Registration → Home Dashboard flow, with form validation and simulated (stubbed) auth
- ✅ A persistent bottom-nav shell (Home / Contacts / History / Settings) with placeholder tabs where later modules attach
- ✅ `// TODO(Module N): ...` comments at every point where Firebase, sessions, GPS, or notifications will be wired in

---

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Dart ≥ 3.3.0) |
| State management | [`provider`](https://pub.dev/packages/provider) (`ChangeNotifier` ViewModels) |
| Routing | [`go_router`](https://pub.dev/packages/go_router) |
| Design | Material 3, custom design tokens, "Inter" typeface |
| Backend | None yet — arrives in Module 2 (Firebase Auth + Firestore) |

---

## Prerequisites

- **Flutter SDK 3.22 or later** (this project uses Material 3's `ColorScheme.surfaceContainer*` roles, which require a recent Flutter version)
- Dart ≥ 3.3.0 (bundled with the Flutter SDK above)
- A configured platform target: Android Studio / Xcode / Chrome, depending on where you want to run it
- Verify your setup:
  ```bash
  flutter doctor
  ```

---

## Getting Started

1. **Unzip / clone the project**, then move into it:
   ```bash
   cd personal_safety_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Run the app** (pick a connected device/emulator, or omit `-d` to be prompted):
   ```bash
   flutter run
   ```

4. **Try the flow:**
   - Splash screen boots automatically → lands on **Login**
   - Tap **Sign up** to try **Registration** (live password-strength meter, terms checkbox)
   - Submitting either form is simulated (~900ms delay, no real account created) and drops you into the **Home Dashboard**
   - Use the bottom nav to explore **Contacts / History / Settings** placeholder tabs

---

## Project Structure

```
personal_safety_app/
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
└── lib/
    ├── main.dart                        # Entry point
    ├── app.dart                         # MaterialApp.router + theme wiring
    │
    ├── core/
    │   ├── theme/
    │   │   ├── app_colors.dart          # Color tokens (Guardian Standard palette)
    │   │   ├── app_text_styles.dart     # Type scale (Inter)
    │   │   ├── app_dimens.dart          # Spacing / radius / touch-target tokens
    │   │   └── app_theme.dart           # Assembled Material 3 ThemeData
    │   └── routing/
    │       ├── app_routes.dart          # Route path constants
    │       └── app_router.dart          # go_router configuration
    │
    ├── data/
    │   └── models/
    │       ├── user_model.dart
    │       ├── trusted_contact_model.dart
    │       └── safety_session_status.dart   # Session state-machine enum
    │
    └── presentation/
        ├── viewmodels/                  # One ChangeNotifier per screen/shell
        │   ├── splash_viewmodel.dart
        │   ├── login_viewmodel.dart
        │   ├── registration_viewmodel.dart
        │   ├── home_viewmodel.dart
        │   └── main_shell_viewmodel.dart
        │
        ├── views/
        │   ├── splash/splash_screen.dart
        │   ├── auth/login_screen.dart
        │   ├── auth/registration_screen.dart
        │   ├── home/home_dashboard_screen.dart
        │   ├── shell/main_shell_screen.dart        # Persistent top bar + bottom nav
        │   └── placeholder/                        # Stand-ins for Modules 2 & 5
        │       ├── placeholder_screen.dart
        │       ├── contacts_placeholder_screen.dart
        │       ├── history_placeholder_screen.dart
        │       └── settings_placeholder_screen.dart
        │
        └── widgets/                     # Shared, presentation-only components
            ├── app_primary_button.dart
            ├── app_emergency_button.dart
            ├── app_text_field.dart
            ├── app_shield_logo.dart
            ├── safety_status_card.dart
            ├── trusted_contact_tile.dart
            ├── section_header.dart
            ├── app_top_bar.dart
            └── app_bottom_nav_bar.dart
```

---

## Architecture: MVVM

This project follows a strict **Model–View–ViewModel** contract:

| Layer | Lives in | Rules |
|---|---|---|
| **Model** | `data/models/` | Plain Dart classes. No Flutter/UI imports. Just data + simple derived getters. |
| **ViewModel** | `presentation/viewmodels/` | Extends `ChangeNotifier`. Owns all mutable state, form validation, and async calls (currently stubbed). Exposes only what the View needs — never a raw data source. |
| **View** | `presentation/views/` | `StatelessWidget`. Wraps itself in a `ChangeNotifierProvider` that creates its ViewModel, reads it with `context.watch<T>()`, and renders. **Contains no business logic.** |

**Example — how a screen is wired:**

```dart
class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => LoginViewModel(),
      child: const _LoginView(),   // reads LoginViewModel via context.watch<T>()
    );
  }
}
```

This keeps every screen swappable and testable in isolation: a ViewModel can be unit-tested with zero widgets, and a View can be redesigned without touching validation or business logic.

---

## Design System

Design tokens in `core/theme/` are ported from the provided **Guardian Standard** UI kit (`DESIGN.md` + Stitch mockups), so any screen built later stays visually consistent by construction.

| Token | Value | Usage |
|---|---|---|
| Primary | `#004152` | Buttons, links, brand marks — calm, trustworthy |
| Error / Emergency | `#BA1A1A` | **Reserved exclusively** for `AppEmergencyButton` — never used decoratively, so it keeps its meaning |
| Safe | `#1E8E3E` | "Marked safe" states |
| Surface | `#F8F9FB` | App background |
| Font | Inter | Full type scale in `app_text_styles.dart` — see [Adding the Inter Font](#adding-the-inter-font) |
| Radius | 4 / 8 / 12 / 16 / 24 / full | `AppRadius` — buttons use 8, cards use 16, pills use `full` |
| Min touch target | 48px | `AppA11y.minTouchTarget` — enforced on all primary/emergency buttons |

All values live in `app_colors.dart`, `app_text_styles.dart`, and `app_dimens.dart` — change them once, and every screen updates.

---

## Widget Catalog

| Widget | Purpose |
|---|---|
| `AppPrimaryButton` | Standard filled CTA (Log In, Create Account, Start Safety Session) |
| `AppEmergencyButton` | The one and only "danger" button style — reserved red, used for Emergency Assistance / I Need Help |
| `AppTextField` | Labeled input with leading icon, used across Login/Registration forms |
| `AppShieldLogo` | The circular brand mark shown on Splash/Login/Registration |
| `SafetyStatusCard` | Dashboard hero card reflecting the current `SafetySessionStatus` |
| `TrustedContactTile` | A contact row with name, role, and a quick-call button (64px min height) |
| `SectionHeader` | Small uppercase label with an optional trailing action (e.g. "+ Add Contact") |
| `AppTopBar` | Persistent top bar with avatar, app name, and settings shortcut |
| `AppBottomNavBar` | Four-tab bottom navigation with pill-highlighted active state |

---

## Navigation Map

```
/            Splash        → auto-navigates to /login after the boot sequence
/login       Login         → /home on success, or push /register
/register    Registration  → /home on success, or pop back to /login
/home        MainShellScreen (persistent bottom nav)
  ├─ Home       → HomeDashboardScreen
  │                 • Safety status card
  │                 • "Start Safety Session" CTA        (stub → Module 3)
  │                 • "Emergency Assistance" CTA          (stub → Module 4)
  │                 • Trusted Contacts summary
  ├─ Contacts   → placeholder                             (real screen → Module 2)
  ├─ History    → placeholder                             (real screen → Module 5)
  └─ Settings   → placeholder                              (real screen → Module 5)
```

---

## Known Limitations (Module 1 Scope)

These are intentional — they mark exactly what the next modules will replace:

- **No real authentication.** Login/Registration simulate a ~900ms network call and always "succeed" once the form validates. No account is created, no credentials are stored.
- **No persistence.** All state (user, session status, contacts) resets on app restart.
- **Mock dashboard data.** `HomeViewModel` seeds itself with one hardcoded user and one hardcoded contact.
- **Primary actions are stubbed.** "Start Safety Session" and "Emergency Assistance" show a `SnackBar` instead of navigating, since those flows belong to Modules 3 and 4.
- **Contacts / History / Settings are placeholders.** They exist as real, tappable destinations so the shell is complete, but their content is a stand-in screen, not the final UI.

Every one of these is marked in code with a comment like:
```dart
// TODO(Module 2): replace with FirebaseAuth.signInWithEmailAndPassword.
```

---

## Adding the Inter Font

The design system specifies **Inter** as the typeface, but the `.ttf` files aren't bundled in this deliverable (to keep the repo lightweight). Until they're added, the app falls back to the platform default font — all sizes, weights, and line-heights in `app_text_styles.dart` still apply.

To add the real font:

1. Download the [Inter](https://fonts.google.com/specimen/Inter) font files (Regular/400, SemiBold/600, Bold/700).
2. Place them under `assets/fonts/`.
3. In `pubspec.yaml`, uncomment the `fonts:` and `assets:` blocks (already scaffolded at the bottom of the file).
4. Run `flutter pub get` again.

---

## Troubleshooting

| Issue | Fix |
|---|---|
| `The getter 'surfaceContainerLowest' isn't defined for the class 'ColorScheme'` | Upgrade Flutter — this project needs **3.22+** for the newer Material 3 surface roles. Run `flutter upgrade`. |
| Fonts look like the system default | Expected until you add Inter — see [Adding the Inter Font](#adding-the-inter-font). |
| `flutter run` can't find a device | Run `flutter devices`, or launch an emulator/simulator first. |
| Stale build errors after pulling changes | `flutter clean && flutter pub get` |

---

## Roadmap: What's Next

**Module 2 — Authentication & Contacts** picks up directly from this shell:
- Wire `LoginViewModel.submit()` and `RegistrationViewModel.submit()` to Firebase Auth
- Replace `HomeViewModel`'s mock data with a real Firestore-backed repository
- Build the real Contacts tab (Add/Edit/Delete Trusted Contacts) in place of `ContactsPlaceholderScreen`

No View code in this module should need to change structurally — only the ViewModel internals swap from stubs to real repository calls, which is the entire point of the MVVM boundary.
