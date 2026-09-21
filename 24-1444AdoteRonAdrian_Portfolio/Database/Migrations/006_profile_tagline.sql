-- The footer's one-line tagline becomes the user's own, typed on ProfilePage's Interests step. It
-- is one value per account, so it is a column on user_profile rather than a user_profile_item row.
--
-- Both procedures are recreated from 005 with the column added. usp_UserProfile_Get returns it
-- last, after home_photo, so ProfileStore's existing column numbers stay where they are.
--
-- The database name has to match Web.config's portfolio_conn. Safe to run more than once: the
-- column is added only when missing, and both procedures are dropped and recreated.

USE IPT_portfolio_dynamic;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- The width matches ProfileRules.TaglineMaxLength.
IF COL_LENGTH('dbo.user_profile', 'tagline') IS NULL
    ALTER TABLE dbo.user_profile ADD tagline varchar(200) NULL;
GO

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
           p.home_photo,
           p.tagline
    FROM dbo.users AS u
    LEFT JOIN dbo.user_profile AS p ON p.user_id = u.id
    WHERE u.id = @user_id;

    SELECT kind, value
    FROM dbo.user_profile_item
    WHERE user_id = @user_id
    ORDER BY kind, position;
END
GO

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
    @tagline        varchar(200) = NULL,
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
            tagline = @tagline,
            updated_at = SYSUTCDATETIME()
        WHERE user_id = @user_id;
    END
    ELSE
    BEGIN
        INSERT INTO dbo.user_profile (
            user_id, birthdate, sex, nationality,
            jhs_school, shs_school, college_school, college_course,
            project_1, project_2, project_3, project_4, project_5,
            home_photo, tagline)
        VALUES (
            @user_id, @birthdate, @sex, @nationality,
            @jhs_school, @shs_school, @college_school, @college_course,
            @project_1, @project_2, @project_3, @project_4, @project_5,
            @home_photo, @tagline);
    END

    DELETE FROM dbo.user_profile_item WHERE user_id = @user_id;

    INSERT INTO dbo.user_profile_item (user_id, kind, position, value)
    SELECT @user_id, kind, position, value
    FROM @items;

    COMMIT TRANSACTION;
    RETURN 1;
END
GO
