-- A public, read-only copy of an account's portfolio at SharePage.aspx?t=<token>. The token is
-- what makes the link private to whoever it is given to, so it is random rather than the user id
-- (which anyone could count through) and the user can replace or withdraw it from ProfilePage.
--
-- It lives on users rather than user_profile: it belongs to the account, exists before the
-- portfolio has ever been saved, and is read and written with the account's inline SQL
-- (Accounts/ShareLinks.cs), not the portfolio procedures.
--
-- The database name has to match Web.config's portfolio_conn. Safe to run more than once: the
-- column and the index are created only when missing.

USE IPT_portfolio_dynamic;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Null until the user makes a link, and again once they turn it off. The width matches
-- ShareLinks.TokenLength: 16 random bytes written as hex.
IF COL_LENGTH('dbo.users', 'share_token') IS NULL
    ALTER TABLE dbo.users ADD share_token char(32) NULL;
GO

-- Filtered, so the many accounts with no link don't collide on NULL, and it is also the index the
-- share page looks a token up by.
IF NOT EXISTS (SELECT 1 FROM sys.indexes
               WHERE name = 'UX_users_share_token' AND object_id = OBJECT_ID('dbo.users'))
    CREATE UNIQUE NONCLUSTERED INDEX UX_users_share_token
        ON dbo.users (share_token)
        WHERE share_token IS NOT NULL;
GO
