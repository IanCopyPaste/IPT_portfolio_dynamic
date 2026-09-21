-- The users table itself, which no other script creates: it came from the original IPT_portfolio
-- database, and until now the only way to get one was to restore Database/IPT_portfolio.bak. This
-- makes a fresh server buildable from the scripts alone.
--
-- On a new database run this first, then 002 through 007 in order. It already includes everything
-- 001_admin_dashboard.sql adds (status, created_at, last_login_at), so 001 is skipped: 001 also
-- still names the retired IPT_portfolio database in its USE, and migrations are never edited.
--
-- The database name has to match Web.config's portfolio_conn. Safe to run more than once, and a
-- no-op against the existing database: the table and its index are created only when missing.

IF DB_ID('IPT_portfolio_dynamic') IS NULL
    CREATE DATABASE IPT_portfolio_dynamic;
GO

USE IPT_portfolio_dynamic;
GO

-- The username index below is filtered, and SQL Server refuses to create or write to a table with
-- one unless these are on. SSMS turns them on by default; sqlcmd needs -I.
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- The column types match the existing table exactly, since AccountRules' caps and the typed
-- parameters in RegisterPage and ProfilePage are written against them. role has no check: an
-- administrator is promoted by hand, and the code only ever compares it with 'admin'.
IF OBJECT_ID('dbo.users', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.users (
        id            int IDENTITY(1, 1) NOT NULL PRIMARY KEY,
        first_name    varchar(max) NOT NULL,
        middle_name   varchar(max) NULL,
        last_name     varchar(max) NOT NULL,
        suffix        varchar(15)  NULL,
        address       varchar(max) NOT NULL,
        email         varchar(max) NULL,
        sms           varchar(11)  NULL,
        role          varchar(10)  NOT NULL CONSTRAINT DF_users_role DEFAULT ('user'),
        username      varchar(40)  NULL,
        password_hash varchar(200) NULL,
        status        varchar(10)  NOT NULL CONSTRAINT DF_users_status DEFAULT ('active'),
        created_at    datetime2(0) NOT NULL CONSTRAINT DF_users_created_at DEFAULT (SYSUTCDATETIME()),
        -- NULL until the account's first sign-in.
        last_login_at datetime2(0) NULL,
        CONSTRAINT CK_users_status CHECK (status IN ('active', 'inactive'))
    );
END
GO

-- Unique so RegisterPage and ProfilePage can rely on the duplicate-key error rather than a
-- check-then-insert; filtered so rows without a username don't collide on NULL.
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_users_username' AND object_id = OBJECT_ID('dbo.users'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_users_username
        ON dbo.users (username)
        WHERE username IS NOT NULL;
GO

-- There is no screen that creates an administrator. Promote an existing account by hand:
--   UPDATE dbo.users SET role = 'admin' WHERE username = '<username>';
