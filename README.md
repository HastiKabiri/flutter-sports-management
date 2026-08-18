# jm_hockey

# JM Hockey Academy App

A Flutter prototype for a hockey academy management platform, supporting five distinct user roles with tailored dashboards — built as a single-file app (`main.dart`) with in-memory mock data (no backend yet).

## Overview

JM Hockey is a role-based mobile app for a hockey academy. Visitors can browse a public marketing page before signing in, and once authenticated, each role (Admin, Coach, Player, Parent, Performance Analyst) gets its own dashboard, navigation, and feature set — all sharing a common design system, chat system, and attendance engine.

## Features

### Public / Onboarding
- Two-page onboarding flow (skip or step through)
- Public home page: academy "About" text, image gallery, and a news feed — visible without an account
- Sign in / Sign up flow with role selection at registration

### Core App (post-login)
- **Role-based dashboards** — each role sees a different grid of modules (e.g. Admin gets Analytics, Users, Security, CMS; Player gets Profile, Attendance, Performance, Achievements)
- **Chat** — group chats (with per-member typing permissions) and 1:1 direct messages, filtered by what each role is allowed to see/message
- **Attendance system** — coach/admin generate a rotating 3-digit code (with expiry); players redeem it to mark themselves present; manual override and monthly history views are also available
- **Settings** — light/dark theme, adjustable text size, granular notification toggles, and 4-language localization (English, Hindi, Bahasa Melayu, Chinese)
- **Profile views** — role-specific profile layouts (e.g. detailed stats/attendance for players, simpler cards for other roles)

### Role-specific modules
| Role | Sample modules |
|---|---|
| Admin | Admin Panel (users, payments, tournaments, sponsors, broadcasts), Analytics, Player Roster, User Management, CMS, Public Page Editor, Security/Permissions, Operations |
| Coach | Attendance taking, Session planning & templates, Drill library, Tactical board, Player grading, Match analysis upload, Injury reports, Team selection, Lineup builder |
| Player | Profile, Attendance, Performance, Achievements, E-Commerce |
| Parent | Dashboard, Child progress, Attendance, Payments, E-Commerce |
| Performance Analyst | Match tagging, Analytics (heatmaps, passing, possession), Video system |

Most detail screens are reached via a shared `DetailPage` that switches its content based on the tapped module's title, backed by reusable UI components (`_PanelCard`, `_ChartCard`, `_StatChip`, `_AttendanceCard`, etc.).

## Tech Stack

- **Framework:** Flutter (Material 3)
- **State management:** Built-in `StatefulWidget` / `setState` — no external state package
- **Persistence:** None — all data (users, chats, attendance, news, gallery) lives in in-memory lists/maps and resets on app restart
- **Localization:** Custom lightweight `L10n` class with a string map per `AppLanguage`, rather than Flutter's `intl`/ARB tooling

## Project Structure

Everything currently lives in a single file:

```
lib/
└── main.dart   — entire app: models, mock data, theming, and all screens/widgets
```

Key building blocks inside `main.dart`:
- **Enums/Models:** `UserRole`, `AppLanguage`, `AppUser`, `AppSettings`, `PublicNewsItem`
- **Global mock state:** `_sharedTeamChats`, `_sharedPrivateChats`, `_globalAttendanceCode`/`_globalAttendanceRecords`
- **App shell:** `MyApp` (theme, routing between onboarding/public/auth/logged-in states)
- **Screens:** `OnboardingScreen`, `PublicHomeScreen`, `LoginScreen`, `RoleHomeScreen`, `DetailPage`, `AttendanceDetailPage`
- **Chat:** `_ChatListPage`, `_ChatThreadPage`

## Getting Started

```bash
flutter pub get
flutter run
```

### Test accounts

| Role | Email | Password |
|---|---|---|
| Admin | admin@jmhockey.com | admin123 |
| Coach | coach@jmhockey.com | coach123 |
| Player | player@jmhockey.com | player123 |
| Parent | parent@jmhockey.com | parent123 |
| Performance Analyst | analyst@jmhockey.com | analyst123 |

You can also sign up as a new user from the login screen.

## Known Limitations

- **No backend/persistence** — all data is mock/in-memory and resets when the app restarts; passwords are stored and compared in plain text
- **Single-file architecture** — `main.dart` is very large; splitting into feature folders/files would improve maintainability
- **Placeholder content** — several modules (e-commerce, payments, tournaments, video playback) show static or mocked data rather than real integrations
- **No automated tests**

## Suggested Next Steps

- Extract models, screens, and shared widgets into separate files/folders (e.g. `lib/models/`, `lib/screens/<role>/`, `lib/widgets/`)
- Replace in-memory state with a backend (Firebase, REST API, etc.) and a state management solution (Provider/Riverpod/Bloc)
- Add real authentication and password hashing
- Write widget/unit tests for core flows (login, attendance marking, chat)