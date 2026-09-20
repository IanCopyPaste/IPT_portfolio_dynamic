-- The About section's "Personal Information" panel now carries the account's email and mobile
-- number, and the About portrait is gone from the page altogether, so usp_UserProfile_Get returns
-- the two contact columns and no longer returns about_photo, and usp_UserProfile_Save no longer
-- writes it.
--
-- The about_photo column itself is deliberately left on the table and untouched: dropping it would
-- throw away the paths of portraits accounts have already uploaded, and nothing reads it any more.
-- The same goes for the files under ~/uploads named "<id>-about-<stamp>" -- they are now orphaned,
-- and clearing them out is a separate housekeeping step.
--
-- The database name has to match Web.config's portfolio_conn. Safe to run more than once: both
-- procedures are dropped and recreated.

USE IPT_portfolio_dynamic;
GO

SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
GO

-- email and sms join the rest of the users row at the front of the SELECT rather than being
-- appended, so every column the page reads from users stays together; ProfileStore reads the whole
-- row by position and was renumbered to match.
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
           p.hobby_1, p.hobby_2, p.hobby_3, p.hobby_4,
           p.skill_1, p.skill_2, p.skill_3, p.skill_4,
           p.project_1, p.project_2, p.project_3, p.project_4, p.project_5,
           p.home_photo
    FROM dbo.users AS u
    LEFT JOIN dbo.user_profile AS p ON p.user_id = u.id
    WHERE u.id = @user_id;
END
GO

-- about_photo is left out of both the UPDATE and the INSERT, so an existing row keeps whatever
-- path it already has instead of having it quietly nulled by the next save.
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
    @home_photo     varchar(260) = NULL
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
            home_photo = @home_photo,
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
            home_photo)
        VALUES (
            @user_id, @birthdate, @sex, @nationality,
            @jhs_school, @shs_school, @college_school, @college_course,
            @hobby_1, @hobby_2, @hobby_3, @hobby_4,
            @skill_1, @skill_2, @skill_3, @skill_4,
            @project_1, @project_2, @project_3, @project_4, @project_5,
            @home_photo);
    END

    COMMIT TRANSACTION;
    RETURN 1;
END
GO
