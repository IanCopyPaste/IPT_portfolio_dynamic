-- The portfolio's content, one row per account, plus the two stored procedures that read and write
-- it. ContentPage used to be one person hard-coded into the markup; every value it shows now comes
-- from here, filled in by the signed-in user on ProfilePage.
--
-- The database name has to match Web.config's portfolio_conn. Safe to run more than once: the table
-- is created only when it is missing, and both procedures are dropped and recreated.

USE IPT_portfolio_dynamic;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- Fixed slots rather than child tables: the page has room for exactly four hobbies, four skills,
-- five projects and three schools, so a row here is the whole of one portfolio and one SELECT
-- fills the page. Every column is NULL until the user fills it; ContentPage shows a placeholder
-- in place of a NULL, which is what an account that has just signed up looks like.
IF OBJECT_ID('dbo.user_profile', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.user_profile (
        user_id         int          NOT NULL,
        birthdate       date         NULL,
        sex             varchar(20)  NULL,
        nationality     varchar(50)  NULL,
        jhs_school      varchar(120) NULL,
        shs_school      varchar(120) NULL,
        college_school  varchar(120) NULL,
        college_course  varchar(120) NULL,
        hobby_1         varchar(40)  NULL,
        hobby_2         varchar(40)  NULL,
        hobby_3         varchar(40)  NULL,
        hobby_4         varchar(40)  NULL,
        skill_1         varchar(40)  NULL,
        skill_2         varchar(40)  NULL,
        skill_3         varchar(40)  NULL,
        skill_4         varchar(40)  NULL,
        project_1       varchar(120) NULL,
        project_2       varchar(120) NULL,
        project_3       varchar(120) NULL,
        project_4       varchar(120) NULL,
        project_5       varchar(120) NULL,
        updated_at      datetime2(0) NOT NULL CONSTRAINT DF_user_profile_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT PK_user_profile PRIMARY KEY CLUSTERED (user_id),
        -- Cascade because the dashboard deletes an account with a plain DELETE on users; without it
        -- that delete would fail on this row instead.
        CONSTRAINT FK_user_profile_users FOREIGN KEY (user_id)
            REFERENCES dbo.users (id) ON DELETE CASCADE
    );
END
GO

-- Everything one portfolio is drawn from, in one round trip. The name and address come from users,
-- so ContentPage shows them as they are now rather than as the session recorded them at sign-in.
-- LEFT JOIN because the profile row only appears at the first save: an account that has just signed
-- up still has a name to show and a page to draw placeholders on. No rows at all means no such
-- account, which is the caller's signal that the session is stale.
IF OBJECT_ID('dbo.usp_UserProfile_Get', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_UserProfile_Get;
GO

CREATE PROCEDURE dbo.usp_UserProfile_Get
    @user_id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT u.first_name, u.middle_name, u.last_name, u.suffix, u.address,
           p.birthdate, p.sex, p.nationality,
           p.jhs_school, p.shs_school, p.college_school, p.college_course,
           p.hobby_1, p.hobby_2, p.hobby_3, p.hobby_4,
           p.skill_1, p.skill_2, p.skill_3, p.skill_4,
           p.project_1, p.project_2, p.project_3, p.project_4, p.project_5
    FROM dbo.users AS u
    LEFT JOIN dbo.user_profile AS p ON p.user_id = u.id
    WHERE u.id = @user_id;
END
GO

-- One save writes the whole portfolio, so this is an upsert: the first save of an account inserts
-- its row, every later one replaces it. The existence check and the write share a transaction so
-- two saves of the same account can't both decide to insert. Returns 1 when the row was written and
-- 0 when it wasn't; SET NOCOUNT ON makes ExecuteNonQuery return -1, so the return code carries it.
IF OBJECT_ID('dbo.usp_UserProfile_Save', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_UserProfile_Save;
GO

CREATE PROCEDURE dbo.usp_UserProfile_Save
    @user_id        int,
    @birthdate      date         = NULL,
    @sex            varchar(20)  = NULL,
    @nationality    varchar(50)  = NULL,
    @jhs_school     varchar(120) = NULL,
    @shs_school     varchar(120) = NULL,
    @college_school varchar(120) = NULL,
    @college_course varchar(120) = NULL,
    @hobby_1        varchar(40)  = NULL,
    @hobby_2        varchar(40)  = NULL,
    @hobby_3        varchar(40)  = NULL,
    @hobby_4        varchar(40)  = NULL,
    @skill_1        varchar(40)  = NULL,
    @skill_2        varchar(40)  = NULL,
    @skill_3        varchar(40)  = NULL,
    @skill_4        varchar(40)  = NULL,
    @project_1      varchar(120) = NULL,
    @project_2      varchar(120) = NULL,
    @project_3      varchar(120) = NULL,
    @project_4      varchar(120) = NULL,
    @project_5      varchar(120) = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

    -- Nothing is written for an account that is gone or deactivated, so a session left open while
    -- an admin removed the account can't write a row back.
    IF NOT EXISTS (SELECT 1 FROM dbo.users WITH (UPDLOCK, HOLDLOCK)
                   WHERE id = @user_id AND status = 'active')
    BEGIN
        COMMIT TRANSACTION;
        RETURN 0;
    END

    IF EXISTS (SELECT 1 FROM dbo.user_profile WITH (UPDLOCK, HOLDLOCK) WHERE user_id = @user_id)
    BEGIN
        UPDATE dbo.user_profile
        SET birthdate = @birthdate, sex = @sex, nationality = @nationality,
            jhs_school = @jhs_school, shs_school = @shs_school,
            college_school = @college_school, college_course = @college_course,
            hobby_1 = @hobby_1, hobby_2 = @hobby_2, hobby_3 = @hobby_3, hobby_4 = @hobby_4,
            skill_1 = @skill_1, skill_2 = @skill_2, skill_3 = @skill_3, skill_4 = @skill_4,
            project_1 = @project_1, project_2 = @project_2, project_3 = @project_3,
            project_4 = @project_4, project_5 = @project_5,
            updated_at = SYSUTCDATETIME()
        WHERE user_id = @user_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.user_profile (
            user_id, birthdate, sex, nationality,
            jhs_school, shs_school, college_school, college_course,
            hobby_1, hobby_2, hobby_3, hobby_4,
            skill_1, skill_2, skill_3, skill_4,
            project_1, project_2, project_3, project_4, project_5)
        VALUES (
            @user_id, @birthdate, @sex, @nationality,
            @jhs_school, @shs_school, @college_school, @college_course,
            @hobby_1, @hobby_2, @hobby_3, @hobby_4,
            @skill_1, @skill_2, @skill_3, @skill_4,
            @project_1, @project_2, @project_3, @project_4, @project_5);
    END

    COMMIT TRANSACTION;
    RETURN 1;
END
GO
