# 🛡️ Safety Guard

A personal safety and emergency-assistance app built with **Flutter** using an **MVVM architecture**. This repository contains **Modules 1–4**: the app foundation and design system, Firebase-backed authentication and trusted contacts, Safety Timer & Check-In, and Emergency Dispatch with location, SMS, calling, and local notifications.

---

## Table of Contents

* [Module Roadmap](#module-roadmap)
* [What's Included](#whats-included)
* [Module 4 Limitations](#module-4-limitations)
* [Required Permissions](#required-permissions)
* [Tech Stack](#tech-stack)
* [Prerequisites](#prerequisites)
* [Connecting Firebase](#connecting-firebase)
* [Getting Started](#getting-started)
* [Project Structure](#project-structure)
* [Architecture: MVVM + Repositories](#architecture-mvvm--repositories)
* [The Session Controller](#the-session-controller)
* [Design System](#design-system)
* [Widget Catalog](#widget-catalog)
* [Navigation Map](#navigation-map)
* [Known Limitations](#known-limitations)
* [Troubleshooting](#troubleshooting)
* [Roadmap](#roadmap)

---

## Module Roadmap

| Module                               | Scope                                                                | Status     |
| ------------------------------------ | -------------------------------------------------------------------- | ---------- |
| 1. Foundation, UX & Architecture     | Design system, navigation shell, MVVM scaffolding                    | ✅ Done     |
| 2. Authentication & Contacts         | Firebase Auth, Firestore, trusted contacts CRUD                      | ✅ Done     |
| 3. Safety Timer & Check-In           | Countdown session, check-in flow, escalation                         | ✅ Done     |
| 4. Emergency Dispatch                | GPS location, SMS/call launching, local notifications, Emergency Hub | ✅ Done     |
| 5. History, Settings & Accessibility | Safety History, Settings/Profile, accessibility improvements         | 🔜 Planned |
| 6. Testing & Release Hardening       | Unit/widget tests, error handling, release preparation               | 🔜 Planned |

---

## What's Included

### Module 1 — Foundation

* Flutter application foundation and navigation shell
* Custom design system with reusable colors, typography, spacing, and components
* MVVM architecture scaffolding
* `go_router` based navigation
* Reusable widget library
* Splash → Login → Registration → Home navigation flow
* Material 3 based UI

### Module 2 — Authentication & Trusted Contacts

* `AuthRepository` backed by **Firebase Authentication**
* User registration and login
* Logout functionality
* Password reset support
* User-friendly authentication error handling
* `ContactsRepository` backed by **Cloud Firestore**
* Add trusted contacts
* Edit trusted contacts
* Delete trusted contacts
* Primary emergency contact support
* Contact Call and SMS actions

### Module 3 — Safety Timer & Check-In

* `SafetySessionModel` for representing safety sessions
* `SessionRepository` for Firebase/Firestore session persistence
* Shared `SessionController` for managing live session state
* Safety session duration presets:

  * 15 minutes
  * 30 minutes
  * 60 minutes
  * Custom duration
* Optional session notes
* Guardian/emergency-contact selection
* Live countdown timer
* Active session status
* **I'm Safe** action
* **I Need Help** escalation action
* **Cancel Session** action
* Confirmation dialogs for important session actions
* Home dashboard reflects the current session status

### Module 4 — Emergency Dispatch

* `LocationRepository` using `geolocator`
* GPS permission handling
* Capture of the user's current location
* Periodic location refresh while the session is active
* `ContactLauncher` service for:

  * Phone calls
  * SMS
  * Google Maps
* `NotificationService` for local notifications
* Emergency Hub screen
* SOS workflow
* Call Primary Contact
* Call Emergency Services
* Location Status screen
* View last known coordinates
* Manually refresh location
* Open current location in Maps
* Prefilled emergency SMS containing a Google Maps location link
* Swipe-to-delete for trusted contacts

---

# Module 4 Limitations

Module 4 is intentionally implemented as a **client-side emergency dispatch flow**. There is currently no dedicated backend/server responsible for automatically contacting guardians.

### SMS is not silently sent

When a session is escalated, the application opens the user's SMS application with a prefilled message.

The user must still press **Send**.

A completely automatic SMS would require additional native Android/iOS functionality and appropriate platform permissions, or a backend service capable of sending messages.

### No push notification is sent directly to the guardian

The current `NotificationService` provides **local notifications on the user's device**.

It does not send push notifications to another person's phone.

A future backend implementation could use Firebase Cloud Messaging (FCM) to notify registered emergency contacts.

### Emergency number

The Emergency Hub currently uses a configured emergency number.

The number should be adjusted according to the country or region where the application is being deployed.

### Foreground location

Location updates currently operate while the application is running in the foreground.

True background location tracking would require additional Android/iOS background execution configuration and permissions.

---

# Required Permissions

## Android

Add the following permissions to:

```text
android/app/src/main/AndroidManifest.xml
```

Inside the `<manifest>` element:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

These permissions support:

* GPS location
* Approximate location
* Notification functionality

## iOS

Add the following to:

```text
ios/Runner/Info.plist
```

Inside the outer `<dict>`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>Safety Guard uses your location to share it with your emergency contact during a safety session.</string>
```

The application may also require appropriate notification permissions depending on the notification configuration.

---

# Tech Stack

| Layer            | Technology                    |
| ---------------- | ----------------------------- |
| Framework        | Flutter                       |
| Language         | Dart                          |
| Architecture     | MVVM                          |
| State Management | `provider` / `ChangeNotifier` |
| Navigation       | `go_router`                   |
| Authentication   | Firebase Authentication       |
| Database         | Cloud Firestore               |
| Location         | `geolocator`                  |
| Calling/SMS/Maps | `url_launcher`                |
| Notifications    | `flutter_local_notifications` |
| IDs              | `uuid`                        |
| UI               | Material 3                    |
| Version Control  | Git & GitHub                  |

---

# Prerequisites

Before running the application, make sure the following are installed:

* **Flutter SDK 3.22 or later**
* Dart SDK 3.3.0 or later
* Android Studio
* Android SDK
* Android Emulator or physical Android device
* Git
* A Firebase project

Verify the Flutter installation:

```bash
flutter doctor
```

---

# Connecting Firebase

The application uses Firebase for authentication, Firestore data storage, and other Firebase-supported functionality.

## 1. Create a Firebase Project

Create a Firebase project through the Firebase Console.

Enable the required Firebase services for the application.

## 2. Enable Email/Password Authentication

In Firebase:

```text
Authentication
    ↓
Sign-in method
    ↓
Email/Password
    ↓
Enable
```

## 3. Create Firestore Database

Open:

```text
Firestore Database
```

Create a database for development.

Before deploying to production, configure appropriate Firestore Security Rules.

## 4. Install FlutterFire CLI

If FlutterFire CLI is not already installed:

```bash
dart pub global activate flutterfire_cli
```

## 5. Configure Firebase

From the project root:

```bash
flutterfire configure
```

Select the Firebase project and the required platforms.

This generates the Firebase configuration used by the Flutter application.

## 6. Run the Application

After Firebase configuration:

```bash
flutter pub get
flutter run
```

---

# Getting Started

## 1. Clone the Repository

```bash
git clone https://github.com/Sehlarazzak/Personal_Safety_App.git
```

## 2. Navigate to the Project

```bash
cd Personal_Safety_App
```

## 3. Install Dependencies

```bash
flutter pub get
```

## 4. Configure Firebase

Run:

```bash
flutterfire configure
```

Make sure the correct Firebase project is selected.

## 5. Run the Application

Start an Android emulator or connect a physical device:

```bash
flutter devices
```

Then:

```bash
flutter run
```

## 6. Test the Main Flow

After launching the application:

1. Create a new account.
2. Log in using the created account.
3. Open the **Contacts** section.
4. Add a trusted emergency contact.
5. Set a primary emergency contact if required.
6. Return to **Home**.
7. Start a **Safety Session**.
8. Select a duration.
9. Select a guardian/emergency contact.
10. Start the session.
11. Test the countdown.
12. Test **I'm Safe**.
13. Test **I Need Help**.
14. Test **Cancel Session**.
15. Open the **Emergency Hub**.
16. Test location functionality.
17. Test Call/SMS actions.

---

# Project Structure

```text
Personal_Safety_App/
│
├── android/
├── ios/
├── test/
│
├── lib/
│   │
│   ├── main.dart
│   ├── app.dart
│   ├── firebase_options.dart
│   │
│   ├── core/
│   │   ├── theme/
│   │   ├── routing/
│   │   ├── session/
│   │   │   └── session_controller.dart
│   │   └── services/
│   │       └── notification_service.dart
│   │
│   ├── data/
│   │   ├── models/
│   │   │   ├── user_model.dart
│   │   │   ├── trusted_contact_model.dart
│   │   │   ├── safety_session_model.dart
│   │   │   └── safety_session_status.dart
│   │   │
│   │   └── repositories/
│   │       ├── auth_repository.dart
│   │       ├── contacts_repository.dart
│   │       ├── session_repository.dart
│   │       └── location_repository.dart
│   │
│   └── presentation/
│       │
│       ├── viewmodels/
│       │   ├── splash_viewmodel.dart
│       │   ├── login_viewmodel.dart
│       │   ├── registration_viewmodel.dart
│       │   ├── home_viewmodel.dart
│       │   ├── contacts_viewmodel.dart
│       │   ├── add_edit_contact_viewmodel.dart
│       │   ├── start_session_viewmodel.dart
│       │   └── active_session_viewmodel.dart
│       │
│       ├── views/
│       │   ├── splash/
│       │   ├── auth/
│       │   ├── home/
│       │   ├── contacts/
│       │   ├── session/
│       │   ├── emergency/
│       │   └── location/
│       │
│       └── widgets/
│
├── pubspec.yaml
├── analysis_options.yaml
├── firebase.json
└── README.md
```

---

# Architecture: MVVM + Repositories

Safety Guard follows an **MVVM architecture with a Repository layer**.

| Layer          | Responsibility                                  |
| -------------- | ----------------------------------------------- |
| **Model**      | Represents application data                     |
| **Repository** | Handles data access and external services       |
| **ViewModel**  | Manages screen state and application logic      |
| **View**       | Displays the user interface                     |
| **Service**    | Provides reusable platform/application services |

### Model

Models are located in:

```text
lib/data/models/
```

Examples include:

```text
UserModel
TrustedContactModel
SafetySessionModel
SafetySessionStatus
```

Models are responsible for representing application data and converting data to/from Firestore-compatible structures.

### Repository

Repositories are located in:

```text
lib/data/repositories/
```

Repositories separate data access from the UI.

Examples:

```text
AuthRepository
ContactsRepository
SessionRepository
LocationRepository
```

### ViewModel

ViewModels use `ChangeNotifier` to manage UI state.

For example:

```text
LoginViewModel
ContactsViewModel
StartSessionViewModel
ActiveSessionViewModel
```

### View

Views contain the Flutter UI and interact with their corresponding ViewModels.

This keeps business logic out of individual widgets and makes the application easier to maintain and test.

---

# The Session Controller

The application uses a shared `SessionController` to manage the active safety session.

The controller is responsible for maintaining:

* Current session
* Session status
* Remaining time
* Countdown updates
* Location updates
* Safe status
* Escalation status
* Session cancellation

The general flow is:

```text
Start Session Screen
        │
        ▼
SessionController
        │
        ├── Countdown
        │
        ├── Session Status
        │
        ├── Location
        │
        └── Emergency Escalation
        │
        ▼
Session Repository
        │
        ▼
Cloud Firestore
```

The Home screen and Active Session screen can therefore display the same live session state.

---

# Design System

Safety Guard uses a custom Material 3 design system.

| Element             | Purpose                                            |
| ------------------- | -------------------------------------------------- |
| Primary color       | Main actions and branding                          |
| Emergency color     | Emergency/SOS actions                              |
| Safe state          | Indicates a successfully completed safety check-in |
| Material 3          | Base UI system                                     |
| Consistent spacing  | Maintains visual hierarchy                         |
| Reusable components | Keeps the UI consistent                            |

Emergency styling is reserved for actions that require immediate attention, such as SOS and **I Need Help**.

---

# Widget Catalog

| Widget               | Purpose                                |
| -------------------- | -------------------------------------- |
| `AppPrimaryButton`   | Standard primary action                |
| `AppEmergencyButton` | Emergency/SOS action                   |
| `AppTextField`       | Reusable text input                    |
| `AppShieldLogo`      | Application branding                   |
| `SafetyStatusCard`   | Displays current safety-session status |
| `TrustedContactTile` | Displays a trusted contact             |
| `ContactCard`        | Full contact card with actions         |
| `SectionHeader`      | Consistent section headings            |
| `AppTopBar`          | Application top navigation             |
| `AppBottomNavBar`    | Main bottom navigation                 |

---

# Navigation Map

```text
/
└── Splash
      │
      ▼
/login
      │
      ├── /register
      │
      ▼
/home
      │
      ├── Home
      │
      ├── Contacts
      │      ├── Add Contact
      │      └── Edit Contact
      │
      ├── History
      │
      └── Settings

/session/start
      │
      ▼
/session/active
      │
      ├── I'm Safe
      ├── I Need Help
      └── Cancel Session

/emergency
      │
      ├── Call Primary Contact
      ├── Call Emergency Services
      └── Location Status

/session/location
      │
      ├── View Coordinates
      ├── Refresh Location
      └── Open in Maps
```

---

# Known Limitations

### Guardian notification

The current emergency escalation flow opens a prefilled SMS rather than silently sending an SMS.

The user must confirm and send the message.

### Guardian push notifications

The current application does not automatically send Firebase push notifications to a guardian's device.

This would require a backend service and registered guardian devices.

### Background location

Location updates currently operate while the application is active.

Continuous background tracking requires additional platform-specific configuration.

### Emergency number

The configured emergency number may need to be changed depending on the country where the application is deployed.

### History and Settings

History and Settings functionality may require additional implementation depending on the current application build.

---

# Troubleshooting

| Problem                                                      | Possible Solution                                       |
| ------------------------------------------------------------ | ------------------------------------------------------- |
| Login or registration fails                                  | Verify Firebase Authentication is enabled               |
| Firebase configuration error                                 | Run `flutterfire configure`                             |
| `[core/no-app] No Firebase App '[DEFAULT]' has been created` | Check Firebase initialization and configuration         |
| Invalid Firebase API key                                     | Verify Firebase project configuration and API key       |
| Firestore `PERMISSION_DENIED`                                | Check Firestore Security Rules                          |
| Location permission denied                                   | Enable location permission on the device                |
| Notifications do not appear                                  | Check notification permissions                          |
| Stale Flutter build errors                                   | Run `flutter clean && flutter pub get`                  |
| Dependencies are missing                                     | Run `flutter pub get`                                   |
| Emulator is not detected                                     | Run `flutter devices` and check Android Studio emulator |
| Build problems after dependency changes                      | Run `flutter clean`, then `flutter pub get`             |

---

# Roadmap

## Module 5 — History, Settings & Accessibility

Planned improvements:

* Safety History screen
* Display previous safety sessions
* User profile/settings
* Sign-out functionality
* Notification preferences
* Emergency-number configuration
* Accessibility improvements
* Screen-reader labels
* Larger touch targets
* Improved contrast

## Module 6 — Testing & Release Hardening

Planned improvements:

* Unit tests
* Widget tests
* Repository tests
* ViewModel tests
* Improved error handling
* Firebase security-rule review
* Performance testing
* Release build testing
* Production deployment preparation

---

# Security Considerations

Because Safety Guard works with personal and emergency-related information, security should be considered throughout development.

* Never commit passwords or private credentials.
* Do not commit Firebase service-account private keys.
* Configure Firestore Security Rules before production deployment.
* Restrict Google Cloud API keys where appropriate.
* Avoid storing sensitive information unnecessarily.
* Regenerate credentials if a sensitive key is accidentally exposed.
* Use authenticated Firebase users to control access to user-specific data.

---

# Developer

**Sehla Razzak**

BS Computer Science
FAST NUCES, Karachi, Pakistan

---

## License

This project is developed for educational and development purposes.
