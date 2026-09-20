-- The two portraits ContentPage draws, one per user. The file itself lives under the site's
-- uploads folder; only its path is stored here, so the row stays small and the image is served
-- as an ordinary static file.
--
-- The database name has to match Web.config's portfolio_conn. Safe to run more than once: the
-- columns are added only when missing, and both procedures are dropped and recreated. The two new
-- columns are appended to usp_UserProfile_Get's SELECT so the existing ones keep their positions,
-- which is what ProfileStore reads them by.

USE IPT_portfolio_dynamic;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- 260 is the longest path Windows will hand back; the names are generated, never the user's own.
IF COL_LENGTH('dbo.user_profile', 'home_photo') IS NULL
    ALTER TABLE dbo.user_profile ADD home_photo varchar(260) NULL;
GO

IF COL_LENGTH('dbo.user_profile', 'about_photo') IS NULL
    ALTER TABLE dbo.user_profile ADD about_photo varchar(260) NULL;
GO

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
           p.project_1, p.project_2, p.project_3, p.project_4, p.project_5,
           p.home_photo, p.about_photo
    FROM dbo.users AS u
    LEFT JOIN dbo.user_profile AS p ON p.user_id = u.id
    WHERE u.id = @user_id;
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
    @project_5      varchar(120) = NULL,
    @home_photo     varchar(260) = NULL,
    @about_photo    varchar(260) = NULL
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
            hobby_1 = @hobby_1, hobby_2 = @hobby_2, hobby_3 = @hobby_3, hobby_4 = @hobby_4,
            skill_1 = @skill_1, skill_2 = @skill_2, skill_3 = @skill_3, skill_4 = @skill_4,
            project_1 = @project_1, project_2 = @project_2, project_3 = @project_3,
            project_4 = @project_4, project_5 = @project_5,
            home_photo = @home_photo, about_photo = @about_photo,
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
            project_1, project_2, project_3, project_4, project_5,
            home_photo, about_photo)
        VALUES (
            @user_id, @birthdate, @sex, @nationality,
            @jhs_school, @shs_school, @college_school, @college_course,
            @hobby_1, @hobby_2, @hobby_3, @hobby_4,
            @skill_1, @skill_2, @skill_3, @skill_4,
            @project_1, @project_2, @project_3, @project_4, @project_5,
            @home_photo, @about_photo);
    END

    COMMIT TRANSACTION;
    RETURN 1;
END
GO
