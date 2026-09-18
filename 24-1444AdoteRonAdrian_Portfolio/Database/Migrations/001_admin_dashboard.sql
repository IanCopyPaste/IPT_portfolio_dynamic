-- Adds what the admin dashboard needs from the users table: an account status the admin can switch,
-- and the two dates the analytics are built from. Safe to run more than once: each change is skipped
-- when it is already there.
--
-- Rows that exist when this runs get the run time as their created_at, since the real sign-up date
-- was never recorded; the sign-ups chart counts them in the month the script was run.

USE IPT_portfolio;
GO

-- The unique username index is filtered, and SQL Server won't alter a table that has one unless
-- these are on. SSMS turns them on by default; sqlcmd does not.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

IF COL_LENGTH('dbo.users', 'status') IS NULL
    ALTER TABLE dbo.users ADD status varchar(10) NOT NULL
        CONSTRAINT DF_users_status DEFAULT ('active') WITH VALUES;
GO

IF OBJECT_ID('dbo.CK_users_status', 'C') IS NULL
    ALTER TABLE dbo.users ADD CONSTRAINT CK_users_status CHECK (status IN ('active', 'inactive'));
GO

IF COL_LENGTH('dbo.users', 'created_at') IS NULL
    ALTER TABLE dbo.users ADD created_at datetime2(0) NOT NULL
        CONSTRAINT DF_users_created_at DEFAULT (SYSUTCDATETIME()) WITH VALUES;
GO

-- NULL until the account's first sign-in.
IF COL_LENGTH('dbo.users', 'last_login_at') IS NULL
    ALTER TABLE dbo.users ADD last_login_at datetime2(0) NULL;
GO

-- There is no screen that creates an administrator. Promote an existing account by hand:
--   UPDATE dbo.users SET role = 'admin' WHERE username = '<username>';
