-- SmartAttendance: schema + stored procedures
-- Run against SQL Server (create database first or change USE statement)

IF DB_ID(N'SmartAttendance') IS NULL
BEGIN
    CREATE DATABASE SmartAttendance;
END
GO

USE SmartAttendance;
GO

IF OBJECT_ID(N'dbo.Attendance', N'U') IS NOT NULL
    DROP TABLE dbo.Attendance;
GO

IF OBJECT_ID(N'dbo.Users', N'U') IS NOT NULL
    DROP TABLE dbo.Users;
GO

CREATE TABLE dbo.Users
(
    Id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    Username NVARCHAR(256) NOT NULL,
    PasswordHash NVARCHAR(500) NOT NULL,
    Role NVARCHAR(50) NOT NULL,
    CreatedAt DATETIME2 NOT NULL DEFAULT GETDATE(),
    CONSTRAINT UQ_Users_Username UNIQUE (Username),
    CONSTRAINT CK_Users_Role CHECK (Role IN (N'Admin', N'User'))
);
GO

CREATE TABLE dbo.Attendance
(
    Id INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
    UserId INT NOT NULL,
    CheckInTime DATETIME2 NULL,
    CheckOutTime DATETIME2 NULL,
    [Date] DATE NOT NULL,
    Latitude FLOAT NOT NULL,
    Longitude FLOAT NOT NULL,
    CONSTRAINT FK_Attendance_Users FOREIGN KEY (UserId) REFERENCES dbo.Users (Id),
    CONSTRAINT UQ_Attendance_User_PerDay UNIQUE (UserId, [Date])
);
GO

CREATE INDEX IX_Attendance_UserId_Date ON dbo.Attendance (UserId, [Date]);
GO

-- Office: 11.5564, 104.9282 — radius 100m (Haversine in procedures)

IF OBJECT_ID(N'dbo.sp_LoginUser', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_LoginUser;
GO
CREATE PROCEDURE dbo.sp_LoginUser
    @Username NVARCHAR(256),
    @Password NVARCHAR(256) -- Plain password not verified in SQL; API verifies hash (BCrypt)
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id,
           Username,
           PasswordHash,
           Role,
           CreatedAt
    FROM dbo.Users
    WHERE Username = @Username;
END
GO

IF OBJECT_ID(N'dbo.sp_CreateUser', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_CreateUser;
GO
CREATE PROCEDURE dbo.sp_CreateUser
    @Username NVARCHAR(256),
    @PasswordHash NVARCHAR(500),
    @Role NVARCHAR(50)
AS
BEGIN
    SET NOCOUNT ON;

    IF EXISTS (SELECT 1 FROM dbo.Users WHERE Username = @Username)
    BEGIN
        RAISERROR(N'Username already exists.', 16, 1);
        RETURN;
    END;

    IF @Role NOT IN (N'Admin', N'User')
    BEGIN
        RAISERROR(N'Invalid role. Use Admin or User.', 16, 1);
        RETURN;
    END;

    INSERT INTO dbo.Users (Username, PasswordHash, Role, CreatedAt)
    VALUES (@Username, @PasswordHash, @Role, GETDATE());

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS NewUserId;
END
GO

IF OBJECT_ID(N'dbo.sp_GetAllUsers', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetAllUsers;
GO
CREATE PROCEDURE dbo.sp_GetAllUsers
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id,
           Username,
           Role,
           CreatedAt
    FROM dbo.Users
    ORDER BY CreatedAt DESC;
END
GO

IF OBJECT_ID(N'dbo.sp_CheckIn', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_CheckIn;
GO
CREATE PROCEDURE dbo.sp_CheckIn
    @UserId INT,
    @Latitude FLOAT,
    @Longitude FLOAT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OfficeLat FLOAT = 11.5564;
    DECLARE @OfficeLon FLOAT = 104.9282;
    DECLARE @EarthRadiusMeters FLOAT = 6371000.0;

    DECLARE @dLat FLOAT = RADIANS(@Latitude - @OfficeLat);
    DECLARE @dLon FLOAT = RADIANS(@Longitude - @OfficeLon);
    DECLARE @lat1 FLOAT = RADIANS(@OfficeLat);
    DECLARE @lat2 FLOAT = RADIANS(@Latitude);

    DECLARE @a FLOAT = SIN(@dLat / 2.0) * SIN(@dLat / 2.0)
        + COS(@lat1) * COS(@lat2) * SIN(@dLon / 2.0) * SIN(@dLon / 2.0);
    DECLARE @c FLOAT = 2.0 * ATN2(SQRT(@a), SQRT(1.0 - @a));
    DECLARE @distanceMeters FLOAT = @EarthRadiusMeters * @c;

    IF @distanceMeters > 100.0
    BEGIN
        RAISERROR(N'Location is outside the allowed office radius (100 meters).', 16, 1);
        RETURN;
    END;

    DECLARE @Today DATE = CAST(GETDATE() AS DATE);

    IF EXISTS (
        SELECT 1
        FROM dbo.Attendance
        WHERE UserId = @UserId
          AND [Date] = @Today
          AND CheckInTime IS NOT NULL
    )
    BEGIN
        RAISERROR(N'Check-in is allowed only once per day.', 16, 1);
        RETURN;
    END;

    IF EXISTS (SELECT 1 FROM dbo.Attendance WHERE UserId = @UserId AND [Date] = @Today)
    BEGIN
        RAISERROR(N'Duplicate attendance record for today.', 16, 1);
        RETURN;
    END;

    INSERT INTO dbo.Attendance (UserId, CheckInTime, CheckOutTime, [Date], Latitude, Longitude)
    VALUES (@UserId, GETDATE(), NULL, @Today, @Latitude, @Longitude);

    SELECT CAST(SCOPE_IDENTITY() AS INT) AS AttendanceId;
END
GO

IF OBJECT_ID(N'dbo.sp_CheckOut', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_CheckOut;
GO
CREATE PROCEDURE dbo.sp_CheckOut
    @UserId INT,
    @Latitude FLOAT,
    @Longitude FLOAT
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @OfficeLat FLOAT = 11.5564;
    DECLARE @OfficeLon FLOAT = 104.9282;
    DECLARE @EarthRadiusMeters FLOAT = 6371000.0;

    DECLARE @dLat FLOAT = RADIANS(@Latitude - @OfficeLat);
    DECLARE @dLon FLOAT = RADIANS(@Longitude - @OfficeLon);
    DECLARE @lat1 FLOAT = RADIANS(@OfficeLat);
    DECLARE @lat2 FLOAT = RADIANS(@Latitude);

    DECLARE @a FLOAT = SIN(@dLat / 2.0) * SIN(@dLat / 2.0)
        + COS(@lat1) * COS(@lat2) * SIN(@dLon / 2.0) * SIN(@dLon / 2.0);
    DECLARE @c FLOAT = 2.0 * ATN2(SQRT(@a), SQRT(1.0 - @a));
    DECLARE @distanceMeters FLOAT = @EarthRadiusMeters * @c;

    IF @distanceMeters > 100.0
    BEGIN
        RAISERROR(N'Location is outside the allowed office radius (100 meters).', 16, 1);
        RETURN;
    END;

    DECLARE @Today DATE = CAST(GETDATE() AS DATE);
    DECLARE @Now TIME = CAST(GETDATE() AS TIME);

    IF @Now < CAST(N'17:00:00' AS TIME)
    BEGIN
        RAISERROR(N'Check-out is allowed only after 5:00 PM.', 16, 1);
        RETURN;
    END;

    IF NOT EXISTS (
        SELECT 1
        FROM dbo.Attendance
        WHERE UserId = @UserId
          AND [Date] = @Today
          AND CheckInTime IS NOT NULL
    )
    BEGIN
        RAISERROR(N'You must check in before check-out.', 16, 1);
        RETURN;
    END;

    IF EXISTS (
        SELECT 1
        FROM dbo.Attendance
        WHERE UserId = @UserId
          AND [Date] = @Today
          AND CheckOutTime IS NOT NULL
    )
    BEGIN
        RAISERROR(N'Check-out is allowed only once per day.', 16, 1);
        RETURN;
    END;

    UPDATE dbo.Attendance
    SET CheckOutTime = GETDATE(),
        Latitude = @Latitude,
        Longitude = @Longitude
    WHERE UserId = @UserId
      AND [Date] = @Today;

    SELECT @@ROWCOUNT AS RowsUpdated;
END
GO

IF OBJECT_ID(N'dbo.sp_GetUserAttendance', N'P') IS NOT NULL DROP PROCEDURE dbo.sp_GetUserAttendance;
GO
CREATE PROCEDURE dbo.sp_GetUserAttendance
    @UserId INT
AS
BEGIN
    SET NOCOUNT ON;

    SELECT Id,
           UserId,
           CheckInTime,
           CheckOutTime,
           [Date],
           Latitude,
           Longitude
    FROM dbo.Attendance
    WHERE UserId = @UserId
    ORDER BY [Date] DESC, Id DESC;
END
GO
