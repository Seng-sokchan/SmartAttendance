# SmartAttendance API

.NET 8 Web API using **ADO.NET** (`SqlConnection` / `SqlCommand`) and **SQL Server stored procedures** (no Entity Framework).

## Prerequisites

- SQL Server (LocalDB or full instance)
- .NET 8 SDK

## Database

1. Open `Database/SmartAttendance.sql` in SSMS or `sqlcmd` and execute it (creates database `SmartAttendance`, tables, and procedures).
2. Update `ConnectionStrings:DefaultConnection` in `appsettings.json` for your server.

## Run

```bash
dotnet run --project SmartAttendanceAPI.csproj
```

Swagger UI: `/swagger` (HTTPS URL from `launchSettings.json`).

## Default admin (seed)

On startup, if no user named `admin` exists, one is inserted using `SeedAdmin` in `appsettings.json` (default password `Admin@123`). Change these values in production.

## Security notes

- Replace `Jwt:SecretKey` with a long random secret in production.
- Password verification uses **BCrypt** in the API; `sp_LoginUser` returns the stored hash by username (plain `@Password` is not evaluated in SQL).

## Attendance rules (stored procedures)

- One check-in and one check-out per calendar day (SQL Server `GETDATE()` date part).
- Check-out is allowed only when the **server local** time is **17:00 or later** (align SQL Server timezone with your office if needed).
- Location must be within **100 m** of latitude **11.5564**, longitude **104.9282** (Haversine in procedures).
