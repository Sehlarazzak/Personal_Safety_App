# 🛡️ Safety Guard

A personal safety and emergency-assistance app built with **Flutter** using an **MVVM architecture**. This repository contains **Modules 1–3**: the app shell and design system, real Firebase-backed authentication and trusted contacts, and a working Safety Timer & Check-In session flow.

---

## Table of Contents

- [Module Roadmap](#module-roadmap)
- [What's Included](#whats-included)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Connecting Firebase](#connecting-firebase)
- [Getting Started](#getting-started)
- [Project Structure](#project-structure)
- [Architecture: MVVM + Repositories](#architecture-mvvm--repositories)
- [The Session Controller](#the-session-controller)
- [Design System](#design-system)
- [Widget Catalog](#widget-catalog)
- [Navigation Map](#navigation-map)
- [Known Limitations](#known-limitations)
- [Troubleshooting](#troubleshooting)
- [Roadmap: What's Next](#roadmap-whats-next)

---

## Module Roadmap

| Module | Scope | Status |
|---|---|---|
| 1. Foundation, UX & Architecture | Design system, navigation shell, MVVM scaffolding | ✅ Done |
| 2. Authentication & Contacts | Firebase Auth, Firestore, real Trusted Contacts CRUD | ✅ **Done — this repo** |
| 3. Safety Timer & Check-In | Countdown session, check-in flow, escalation | ✅ **Done — this repo** |
| 4. Emergency Dispatch | Live GPS sharing, push notifications, background execution | 🔜 Not started |
| 5. History, Settings & Accessibility | Safety History log, Settings/Profile, a11y pass | 🔜 Not started |
| 6. Testing & Release Hardening | Unit/widget tests, error handling, store readiness | 🔜 Not started |

---

## What's Included

**Module 1 — Foundation**
- Design system (colors, type, spacing, radius) ported from the Guardian Standard UI kit
- MVVM scaffolding, `go_router` navigation, reusable widget library
- Splash → Login → Registration → Home shell, fully navigable

**Module 2 — Authentication & Contacts**
- `AuthRepository` backed by real **Firebase Authentication** — sign in, register, password reset, friendly error messages
- `ContactsRepository` backed by real **Cloud Firestore** — live-streamed CRUD for trusted contacts, with primary-contact handling
- Real **Emergency Contacts** list screen (empty state, per-contact Edit/SMS/Call actions)
- Real **Add/Edit Contact** screen (name, phone, relationship, "Primary Emergency Contact" toggle, delete)

**Module 3 — Safety Timer & Check-In**
- `SafetySessionModel` + `SessionRepository` (Firestore-backed, ready for Module 5's History screen to reuse)
- A shared `SessionController` that owns the live countdown so Home, Start Session, and Active Session all agree on state
- Real **Start Session** screen — duration presets (15/30/60/custom), optional notes, guardian-contact picker
- Real **Active Session** screen — pulsing countdown ring, live status, "I'm Safe" / "I Need Help" / "Cancel Session", each with a confirmation dialog
- The Home Dashboard's "Start Safety Session" and "Emergency Assistance" buttons are now fully wired (Emergency Assistance is a Module-4 stand-in that jumps straight into an escalated session)

---

## Tech Stack

| Layer | Choice |
|---|---|
| Framework | Flutter (Dart ≥ 3.3.0) |
| State management | [`provider`](https://pub.dev/packages/provider) (`ChangeNotifier` ViewModels) |
| Routing | [`go_router`](https://pub.dev/packages/go_router) |
| Auth | [`firebase_auth`](https://pub.dev/packages/firebase_auth) |
| Database | [`cloud_firestore`](https://pub.dev/packages/cloud_firestore) |
| IDs | [`uuid`](https://pub.dev/packages/uuid) |
| Design | Material 3, custom design tokens, "Inter" typeface |

---

## Prerequisites

- **Flutter SDK 3.22 or later**
- Dart ≥ 3.3.0 (bundled with Flutter)
- A **Firebase project** (see below) — Modules 2 and 3 require one to actually sign in, save contacts, or start a session
- Verify your setup:
  ```bash
  flutter doctor
  ```

---

## Connecting Firebase

Modules 2 and 3 talk to real Firebase services, so you need a Firebase project before `flutter run` will get past the Login screen.

1. **Create a Firebase project** at [console.firebase.google.com](https://console.firebase.google.com).
2. **Enable Email/Password sign-in**: Authentication → Sign-in method → Email/Password → Enable.
3. **Create a Firestore database**: Firestore Database → Create database → start in test mode for development (lock it down with real security rules before shipping — see below).
4. **Install the FlutterFire CLI** (one-time, if you don't already have it):
   ```bash
   dart pub global activate flutterfire_cli
   ```
5. **Generate your real `firebase_options.dart`:**
   ```bash
   flutterfire configure
   ```
   This logs you into Firebase, lets you pick (or create) the project from step 1, asks which platforms to target (Android/iOS/web/etc.), and **overwrites `lib/firebase_options.dart`** with your project's real credentials — registering each platform app with Firebase automatically along the way. `main.dart` already calls `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)`, so no other code changes are needed.

   ⚠️ **The `firebase_options.dart` shipped in this repo is a placeholder** with dummy `REPLACE_ME` values — it exists only so the project compiles before you've connected Firebase. Running the app without regenerating it fails with an invalid-api-key error, not the native "Failed to load FirebaseOptions from resource" error you'd get from the older `google-services.json`-only approach.
6. **Run the app:**
   ```bash
   flutter run
   ```

**Suggested Firestore security rules** for development (tighten before production):
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

---

## Getting Started

1. **Unzip / clone the project**, then move into it:
   ```bash
   cd safety_guard_app
   ```

2. **Install dependencies:**
   ```bash
   flutter pub get
   ```

3. **Connect Firebase** — see [Connecting Firebase](#connecting-firebase) above. Without this, Login/Registration will show a network/config error.

4. **Run the app:**
   ```bash
   flutter run
   ```

5. **Try the flow:**
   - Register a new account (real Firebase account is created)
   - Add a trusted contact from the **Contacts** tab
   - From **Home**, tap **Start Safety Session** → pick a duration and a guardian contact → start it
   - Watch the countdown on the **Active Session** screen; try **I'm Safe**, **I Need Help**, and **Cancel Session**
   - Back on **Home**, the status card reflects whatever you just did

---

## Project Structure

```
safety_guard_app/
├── pubspec.yaml
├── analysis_options.yaml
├── README.md
└── lib/
    ├── main.dart                        # Entry point — Firebase.initializeApp()
    ├── app.dart                         # Composition root: providers + theme + router
    │
    ├── core/
    │   ├── theme/                       # Design tokens + assembled ThemeData
    │   ├── routing/                     # go_router config + route path constants
    │   └── session/
    │       └── session_controller.dart  # Shared countdown/session state (see below)
    │
    ├── data/
    │   ├── models/
    │   │   ├── user_model.dart
    │   │   ├── trusted_contact_model.dart
    │   │   ├── safety_session_model.dart
    │   │   └── safety_session_status.dart
    │   └── repositories/                # Interface + Firebase/Firestore implementation, per concern
    │       ├── auth_repository.dart
    │       ├── contacts_repository.dart
    │       └── session_repository.dart
    │
    └── presentation/
        ├── viewmodels/                  # One ChangeNotifier per screen
        │   ├── splash_viewmodel.dart
        │   ├── login_viewmodel.dart
        │   ├── registration_viewmodel.dart
        │   ├── home_viewmodel.dart
        │   ├── main_shell_viewmodel.dart
        │   ├── contacts_viewmodel.dart
        │   ├── add_edit_contact_viewmodel.dart
        │   ├── start_session_viewmodel.dart
        │   └── active_session_viewmodel.dart
        │
        ├── views/
        │   ├── splash/, auth/, home/, shell/    # Module 1
        │   ├── contacts/                        # Module 2: list + add/edit
        │   ├── session/                         # Module 3: start + active
        │   └── placeholder/                     # Stand-ins for History/Settings (Module 5)
        │
        └── widgets/                     # Shared, presentation-only components
```

---

## Architecture: MVVM + Repositories

Same MVVM contract as Module 1, extended with a **Repository layer** now that there's real data to fetch:

| Layer | Lives in | Rules |
|---|---|---|
| **Model** | `data/models/` | Plain Dart classes with `toMap`/`fromMap` for Firestore. No Flutter/UI imports. |
| **Repository** | `data/repositories/` | An abstract interface (e.g. `ContactsRepository`) plus a concrete Firebase/Firestore implementation. ViewModels depend on the interface, never the implementation. |
| **ViewModel** | `presentation/viewmodels/` | `ChangeNotifier`. Requests a repository via constructor injection, owns UI state and validation, exposes only what the View needs. |
| **View** | `presentation/views/` | `StatelessWidget`. Builds its ViewModel in a `ChangeNotifierProvider`, pulling repositories from `context.read<T>()` (see `app.dart`). |

**Example — how a repository reaches a ViewModel:**

```dart
// app.dart — composition root
Provider<ContactsRepository>(create: (_) => FirestoreContactsRepository()),

// contacts_list_screen.dart — View
ChangeNotifierProvider(
  create: (context) => ContactsViewModel(
    repository: context.read<ContactsRepository>(),
    userId: userId,
  ),
  child: const _ContactsListView(),
)
```

This is the seam Module 6 (testing) uses: swap `FirestoreContactsRepository` for an in-memory fake in a test's provider tree, and every ViewModel/View above it works identically, untouched.

---

## The Session Controller

Three different screens all need to agree on "is there a session running right now, and what state is it in": the Home dashboard's status card, the Start Session screen, and the Active Session screen. Rather than pass that state around via navigation results, `SessionController` (in `core/session/`) is provided **once, at the app root** (`app.dart`), so every screen reads the same live countdown.

```
StartSessionScreen  ──▶ SessionController.startSession(...)
                              │  (1-second Timer.periodic ticks here)
                              ▼
HomeDashboardScreen  ◀── watches status/remaining ──▶  ActiveSessionScreen
                              │
                              ▼
                    SessionRepository (Firestore)
```

`StartSessionViewModel` and `ActiveSessionViewModel` are thin, screen-specific wrappers around this controller — they expose formatted/View-friendly getters (like `formattedRemaining`) and delegate actions (`markSafe()`, `escalate()`, `cancelSession()`) to it, keeping the MVVM boundary intact while the controller plays the role of a shared domain service.

---

## Design System

Ported from the **Guardian Standard** UI kit — see `core/theme/`.

| Token | Value | Usage |
|---|---|---|
| Primary | `#004152` | Buttons, links, brand marks |
| Error / Emergency | `#BA1A1A` | **Reserved exclusively** for `AppEmergencyButton` and the "I Need Help" action |
| Safe | `#1E8E3E` | "Marked safe" states |
| Font | Inter | See Module 1's font-loading note in `pubspec.yaml` |
| Min touch target | 48px | Enforced on all primary/emergency buttons |

---

## Widget Catalog

| Widget | Purpose |
|---|---|
| `AppPrimaryButton` | Standard filled CTA |
| `AppEmergencyButton` | The one "danger" button style — reserved red |
| `AppTextField` | Labeled input with leading icon |
| `AppShieldLogo` | Circular brand mark |
| `SafetyStatusCard` | Dashboard hero card reflecting live `SafetySessionStatus` |
| `TrustedContactTile` | Compact contact row (dashboard summary) |
| `ContactCard` | Full contact card with Edit/SMS/Call (Contacts list screen) |
| `SectionHeader` | Uppercase label with an optional trailing action |
| `AppTopBar` / `AppBottomNavBar` | Persistent shell chrome |

---

## Navigation Map

```
/                 Splash        → /login after boot
/login            Login         → /home on success, or push /register
/register         Registration  → /home on success, or pop back
/home             MainShellScreen (bottom nav)
  ├─ Home            HomeDashboardScreen
  ├─ Contacts         ContactsListScreen              (Module 2)
  ├─ History           placeholder                     (Module 5)
  └─ Settings          placeholder                      (Module 5)

/contacts/add      AddEditContactScreen (create)        (Module 2)
/contacts/edit      AddEditContactScreen (edit, extra: TrustedContactModel)

/session/start      StartSessionScreen                  (Module 3)
/session/active      ActiveSessionScreen
```

---

## Known Limitations

- **No live GPS or push notifications yet.** Escalation updates session state and marks the guardian as "notified" in the data model, but doesn't yet send an SMS/push or share live location — that's Module 4.
- **Call/SMS buttons are stubbed.** Tapping Call/SMS on a contact doesn't yet launch the platform dialer/composer (`url_launcher` integration lands in Module 4).
- **No background execution.** The countdown only ticks while the app is open in the foreground; backgrounding the app pauses the visible timer (it recalculates correctly from `startTime` when you return, but no background notification fires yet).
- **"Emergency Assistance" is a Module‑4 stand-in.** It starts a 1-minute session and immediately escalates it, just to exercise the same Active Session screen end-to-end — the real dedicated Emergency Hub UI is a Module 4 deliverable.
- **History and Settings tabs are still placeholders**, per the Module 5 plan — though `SessionRepository.watchRecentSessions()` already exists for History to consume directly.

Every one of these is marked in code with a `// TODO(Module N): ...` comment.

---

## Troubleshooting

| Issue | Fix |
|---|---|
| Login/Registration fails immediately with a network or configuration error | You haven't connected Firebase yet — see [Connecting Firebase](#connecting-firebase). |
| `[core/no-app] No Firebase App '[DEFAULT]' has been created` | `google-services.json` / `GoogleService-Info.plist` is missing or in the wrong location. |
| `Failed to load FirebaseOptions from resource. Check that you have defined values.xml correctly.` | You haven't run `flutterfire configure` yet, so `lib/firebase_options.dart` still has placeholder `REPLACE_ME` values — see [Connecting Firebase](#connecting-firebase). |
| `[core/invalid-api-key]` or similar after running the app | Same cause as above — `flutterfire configure` hasn't been run (or was cancelled partway through). Re-run it. |
| `PERMISSION_DENIED` reading/writing Firestore | Your security rules don't allow it yet — see the suggested rules above, or confirm you're signed in. |
| `The getter 'surfaceContainerLowest' isn't defined for the class 'ColorScheme'` | Upgrade Flutter — this project needs **3.22+**. |
| `Target of URI doesn't exist: 'package:<something>/main.dart'` in `test/widget_test.dart` | Your `pubspec.yaml`'s `name:` field doesn't match the package name that file imports. Either rename `pubspec.yaml`'s `name:` to match your project folder, or use the `test/widget_test.dart` included in this repo (already correct for `name: safety_guard_app`). Then `flutter pub get` again. |
| Stale build errors after pulling changes | `flutter clean && flutter pub get` |

---


