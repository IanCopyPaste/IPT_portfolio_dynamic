-- Hobbies and skills stop being four fixed slots each. The user adds as many as they like on
-- ProfilePage, up to a maximum the admin sets from the dashboard's Settings view, so both lists
-- move out of user_profile's numbered columns into rows of their own, and the two maximums get a
-- table to live in.
--
-- The old hobby_1..hobby_4 and skill_1..skill_4 columns are copied across once, when the new table
-- is created, and are then left on user_profile untouched, the same way 004 left about_photo:
-- dropping them would lose the only copy if this script were ever rolled back, and nothing reads
-- them any more.
--
-- The database name has to match Web.config's portfolio_conn. Safe to run more than once: each
-- table and the list type are created only when missing, and both procedures are dropped and
-- recreated.

USE IPT_portfolio_dynamic;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- One table for both lists rather than one each: they are the same shape, and a single
-- table-valued parameter can then carry the whole of both in one save. position is the order the
-- user typed them in, from 1, and is what the page draws them in.
IF OBJECT_ID('dbo.user_profile_item', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.user_profile_item (
        user_id  int         NOT NULL,
        kind     varchar(10) NOT NULL,
        position int         NOT NULL,
        value    varchar(40) NOT NULL,
        CONSTRAINT PK_user_profile_item PRIMARY KEY CLUSTERED (user_id, kind, position),
        CONSTRAINT CK_user_profile_item_kind CHECK (kind IN ('hobby', 'skill')),
        -- Cascade for the same reason as user_profile: the dashboard deletes an account with a
        -- plain DELETE on users.
        CONSTRAINT FK_user_profile_item_users FOREIGN KEY (user_id)
            REFERENCES dbo.users (id) ON DELETE CASCADE
    );

    -- In the same block as the CREATE, so it runs exactly once: a rerun must not bring back a
    -- hobby the user has since removed. Blank slots are dropped and the rest renumbered, so
    -- "Gaming" in slot 3 with 1 and 2 empty becomes the first hobby rather than the third.
    INSERT INTO dbo.user_profile_item (user_id, kind, position, value)
    SELECT p.user_id, slot.kind,
           ROW_NUMBER() OVER (PARTITION BY p.user_id, slot.kind ORDER BY slot.number),
           LTRIM(RTRIM(slot.value))
    FROM dbo.user_profile AS p
    CROSS APPLY (VALUES
        ('hobby', 1, p.hobby_1), ('hobby', 2, p.hobby_2), ('hobby', 3, p.hobby_3), ('hobby', 4, p.hobby_4),
        ('skill', 1, p.skill_1), ('skill', 2, p.skill_2), ('skill', 3, p.skill_3), ('skill', 4, p.skill_4)
    ) AS slot (kind, number, value)
    WHERE LTRIM(RTRIM(ISNULL(slot.value, ''))) <> '';
END
GO

-- Site-wide settings the admin changes from the dashboard. Exactly one row, pinned by the CHECK on
-- id, so reading it never has to choose between rows. The bounds match ProfileLimits in
-- Accounts/ProfileLimits.cs; the default of 4 is what the form had room for before this script.
IF OBJECT_ID('dbo.site_settings', 'U') IS NULL
BEGIN
    CREATE TABLE dbo.site_settings (
        id          tinyint      NOT NULL CONSTRAINT PK_site_settings PRIMARY KEY CLUSTERED,
        max_hobbies int          NOT NULL CONSTRAINT DF_site_settings_max_hobbies DEFAULT (4),
        max_skills  int          NOT NULL CONSTRAINT DF_site_settings_max_skills DEFAULT (4),
        updated_at  datetime2(0) NOT NULL CONSTRAINT DF_site_settings_updated_at DEFAULT (SYSUTCDATETIME()),
        CONSTRAINT CK_site_settings_single CHECK (id = 1),
        CONSTRAINT CK_site_settings_max_hobbies CHECK (max_hobbies BETWEEN 1 AND 12),
        CONSTRAINT CK_site_settings_max_skills CHECK (max_skills BETWEEN 1 AND 12)
    );
END
GO

IF NOT EXISTS (SELECT 1 FROM dbo.site_settings WHERE id = 1)
    INSERT INTO dbo.site_settings (id) VALUES (1);
GO

-- The shape usp_UserProfile_Save takes both lists in. A type can't be dropped while a procedure
-- uses it, so it is only ever created, never recreated; a change to it needs a new name.
IF TYPE_ID('dbo.ProfileItemList') IS NULL
    CREATE TYPE dbo.ProfileItemList AS TABLE (
        kind     varchar(10) NOT NULL,
        position int         NOT NULL,
        value    varchar(40) NOT NULL,
        PRIMARY KEY (kind, position)
    );
GO

-- Two result sets now. The first is the row it always was, less the eight hobby and skill columns,
-- so the projects and home_photo move up; ProfileStore was renumbered to match. The second is the
-- account's hobbies and skills, one per row, in the order they are shown.
IF OBJECT_ID('dbo.usp_UserProfile_Get', 'P') IS NOT NULL
    DROP PROCEDURE dbo.usp_UserProfile_Get;
GO

CREATE PROCEDURE dbo.usp_UserProfile_Get
    @user_id int
AS
BEGIN
    SET NOCOUNT ON;

    SELECT u.first_name, u.middle_name, u.last_name, u.suffix, u.address, u.email, u.sms,
           p.birthdate, p.sex, p.nationality,
           p.jhs_school, p.shs_school, p.college_school, p.college_course,
           p.project_1, p.project_2, p.project_3, p.project_4, p.project_5,
           p.home_photo
    FROM dbo.users AS u
    LEFT JOIN dbo.user_profile AS p ON p.user_id = u.id
    WHERE u.id = @user_id;

    SELECT kind, value
    FROM dbo.user_profile_item
    WHERE user_id = @user_id
    ORDER BY kind, position;
END
GO

-- The lists are replaced wholesale on every save, inside the same transaction as the row, so a
-- removed hobby can't outlive the save that removed it and a half-written list is never seen.
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
    @project_1      varchar(120) = NULL,
    @project_2      varchar(120) = NULL,
    @project_3      varchar(120) = NULL,
    @project_4      varchar(120) = NULL,
    @project_5      varchar(120) = NULL,
    @home_photo     varchar(260) = NULL,
    @items          dbo.ProfileItemList READONLY
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    BEGIN TRANSACTION;

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
            project_1 = @project_1, project_2 = @project_2, project_3 = @project_3,
            project_4 = @project_4, project_5 = @project_5,
            home_photo = @home_photo,
            updated_at = SYSUTCDATETIME()
        WHERE user_id = @user_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.user_profile (
            user_id, birthdate, sex, nationality,
            jhs_school, shs_school, college_school, college_course,
            project_1, project_2, project_3, project_4, project_5,
            home_photo)
        VALUES (
            @user_id, @birthdate, @sex, @nationality,
            @jhs_school, @shs_school, @college_school, @college_course,
            @project_1, @project_2, @project_3, @project_4, @project_5,
            @home_photo);
    END

    DELETE FROM dbo.user_profile_item WHERE user_id = @user_id;

    INSERT INTO dbo.user_profile_item (user_id, kind, position, value)
    SELECT @user_id, kind, position, value
    FROM @items;

    COMMIT TRANSACTION;
    RETURN 1;
END
GO
