# SmartAttendanceApp

Flutter client for **SmartAttendanceAPI**: login with JWT (secure storage), role-based home (**Admin** vs **User**), admin user management, and GPS-gated attendance (office radius + check-out after 17:00 local time).

## Requirements

- Flutter stable (SDK ^3.11)
- Android / iOS device or emulator with location permission

## API base URL

Set the API root **without** a trailing slash. Defaults are in `lib/config/app_config.dart`.

| Target | Example base URL |
|--------|------------------|
| **Web (Chrome / Edge)** | `http://localhost:5291/api` (automatic when `API_BASE_URL` is unset) |
| Android emulator → API on host | `http://10.0.2.2:5291/api` (default on mobile) |
| iOS simulator → API on Mac | `http://localhost:5291/api` |
| Physical phone → API on PC | `http://<your-pc-lan-ip>:5291/api` |

Override when running:

```bash
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5291/api
```

Ensure the API port matches `Properties/launchSettings.json` (this repo uses **5291** for the `http` profile).

## Run

```bash
cd SmartAttendanceApp
flutter pub get
flutter run
```

## API CORS (web only)

The ASP.NET API enables CORS (`AllowAnyOrigin` / headers / methods) so the Flutter **web** app on another port (e.g. `localhost:8090`) can call `localhost:5291`. Restart the API after pulling changes if login from the browser still fails with a CORS error in DevTools.

## Backend alignment

- **POST** `/api/auth/login` — stores `token`, `username`, `role`.
- **Admin:** `GET /api/admin/users`, `POST /api/admin/create-user`.
- **User:** `POST /api/attendance/check-in`, `POST /api/attendance/check-out`, `GET /api/attendance/my-records` with `Authorization: Bearer <token>`.

Office GPS check: latitude **11.5564**, longitude **104.9282**, radius **100 m** (`lib/config/app_config.dart`).

## Windows / symlinks

If `flutter pub get` warns about symlinks, enable **Developer Mode** on Windows (see Flutter’s message) so plugin builds work correctly.
