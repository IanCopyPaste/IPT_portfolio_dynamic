using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace _24_1444AdoteRonAdrian_Portfolio.Accounts
{
    // Reads and writes a user_profile row, and the account's hobbies and skills, through the two
    // stored procedures, as last recreated by Database/Migrations/006_profile_tagline.sql. ContentPage reads the signed-in user's row,
    // ProfilePage writes it, and the admin dashboard reads anyone's. The users columns the read
    // brings back with it are read-only here: ProfilePage saves those with its own UPDATE.
    public static class ProfileStore
    {
        private static readonly string PortfolioConn =
            ConfigurationManager.ConnectionStrings["portfolio_conn"].ConnectionString;

        // The order the columns come back in from usp_UserProfile_Get: the users row first, then
        // the profile.
        private const int FirstNameColumn = 0;
        private const int MiddleNameColumn = 1;
        private const int LastNameColumn = 2;
        private const int SuffixColumn = 3;
        private const int AddressColumn = 4;
        private const int EmailColumn = 5;
        private const int SmsColumn = 6;
        private const int BirthdateColumn = 7;
        private const int SexColumn = 8;
        private const int NationalityColumn = 9;
        private const int JhsColumn = 10;
        private const int ShsColumn = 11;
        private const int CollegeColumn = 12;
        private const int CourseColumn = 13;
        private const int FirstProjectColumn = 14;
        // Last, after the run of project slots.
        private const int HomePhotoColumn = 19;
        // Added by 006 after everything 005 returned, so nothing above it moved.
        private const int TaglineColumn = 20;

        // The width of the home_photo column.
        private const int PhotoPathMaxLength = 260;

        // user_profile_item.kind, which says which list a row belongs to.
        private const string HobbyKind = "hobby";
        private const string SkillKind = "skill";

        // Null only when there is no such account, which tells the caller its session is stale. An
        // account that has simply never saved its portfolio comes back with the name and address
        // filled in and every portfolio field empty, and ContentPage draws the placeholders.
        public static ProfileContent Get(int userId)
        {
            var content = new ProfileContent();

            using (var conn = new SqlConnection(PortfolioConn))
            using (var cmd = new SqlCommand("dbo.usp_UserProfile_Get", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;
                cmd.Parameters.Add("@user_id", SqlDbType.Int).Value = userId;
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        return null;
                    }

                    content.FirstName = Text(reader, FirstNameColumn);
                    content.MiddleName = Text(reader, MiddleNameColumn);
                    content.LastName = Text(reader, LastNameColumn);
                    content.Suffix = Text(reader, SuffixColumn);
                    content.Address = Text(reader, AddressColumn);
                    content.Email = Text(reader, EmailColumn);
                    content.Sms = Text(reader, SmsColumn);
                    content.Birthdate = reader.IsDBNull(BirthdateColumn)
                        ? (DateTime?)null : reader.GetDateTime(BirthdateColumn);
                    content.Sex = Text(reader, SexColumn);
                    content.Nationality = Text(reader, NationalityColumn);
                    content.JhsSchool = Text(reader, JhsColumn);
                    content.ShsSchool = Text(reader, ShsColumn);
                    content.CollegeSchool = Text(reader, CollegeColumn);
                    content.CollegeCourse = Text(reader, CourseColumn);

                    ReadSlots(reader, FirstProjectColumn, content.Projects);

                    content.HomePhoto = Text(reader, HomePhotoColumn);
                    content.Tagline = Text(reader, TaglineColumn);

                    // The second result set is the two lists, already in the order they are shown.
                    reader.NextResult();

                    while (reader.Read())
                    {
                        List<string> list = reader.GetString(0) == SkillKind ? content.Skills : content.Hobbies;
                        list.Add(reader.GetString(1));
                    }
                }
            }

            return content;
        }

        // False when the account is gone or was deactivated while the form was open, which is the
        // same signal ProfilePage's own UPDATE gives it.
        public static bool Save(int userId, ProfileContent content)
        {
            using (var conn = new SqlConnection(PortfolioConn))
            using (var cmd = new SqlCommand("dbo.usp_UserProfile_Save", conn))
            {
                cmd.CommandType = CommandType.StoredProcedure;

                SqlParameter saved = cmd.Parameters.Add("@saved", SqlDbType.Int);
                saved.Direction = ParameterDirection.ReturnValue;

                cmd.Parameters.Add("@user_id", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@birthdate", SqlDbType.Date).Value =
                    (object)content.Birthdate ?? DBNull.Value;
                Add(cmd, "@sex", ProfileRules.SexMaxLength, content.Sex);
                Add(cmd, "@nationality", ProfileRules.NationalityMaxLength, content.Nationality);
                Add(cmd, "@jhs_school", ProfileRules.SchoolMaxLength, content.JhsSchool);
                Add(cmd, "@shs_school", ProfileRules.SchoolMaxLength, content.ShsSchool);
                Add(cmd, "@college_school", ProfileRules.SchoolMaxLength, content.CollegeSchool);
                Add(cmd, "@college_course", ProfileRules.CourseMaxLength, content.CollegeCourse);
                AddSlots(cmd, "@project_", ProfileRules.ProjectMaxLength, content.Projects);
                Add(cmd, "@home_photo", PhotoPathMaxLength, content.HomePhoto);
                Add(cmd, "@tagline", ProfileRules.TaglineMaxLength, content.Tagline);

                SqlParameter items = cmd.Parameters.Add("@items", SqlDbType.Structured);
                items.TypeName = "dbo.ProfileItemList";
                items.Value = Items(content);

                conn.Open();
                cmd.ExecuteNonQuery();

                // SET NOCOUNT ON inside the procedure makes ExecuteNonQuery return -1 whatever
                // happened, so the procedure reports through its return code instead.
                return (int)saved.Value == 1;
            }
        }

        private static int ReadSlots(SqlDataReader reader, int column, string[] slots)
        {
            for (int i = 0; i < slots.Length; i++)
            {
                slots[i] = Text(reader, column + i);
            }

            return column + slots.Length;
        }

        // Both lists as one table for the procedure's dbo.ProfileItemList parameter. Blanks are
        // dropped and the rest numbered from one, so the stored positions never have gaps.
        private static DataTable Items(ProfileContent content)
        {
            var table = new DataTable();
            table.Columns.Add("kind", typeof(string));
            table.Columns.Add("position", typeof(int));
            table.Columns.Add("value", typeof(string));

            AddItems(table, HobbyKind, content.Hobbies);
            AddItems(table, SkillKind, content.Skills);
            return table;
        }

        private static void AddItems(DataTable table, string kind, IEnumerable<string> values)
        {
            int position = 1;

            foreach (string value in values)
            {
                string trimmed = (value ?? "").Trim();

                if (trimmed.Length > 0)
                {
                    table.Rows.Add(kind, position++, trimmed);
                }
            }
        }

        private static void AddSlots(SqlCommand cmd, string prefix, int maxLength, string[] slots)
        {
            for (int i = 0; i < slots.Length; i++)
            {
                // The parameters are numbered from one, matching the column names.
                Add(cmd, prefix + (i + 1), maxLength, slots[i]);
            }
        }

        private static void Add(SqlCommand cmd, string name, int maxLength, string value)
        {
            cmd.Parameters.Add(name, SqlDbType.VarChar, maxLength).Value =
                AccountRules.OrNull((value ?? "").Trim());
        }

        private static string Text(SqlDataReader reader, int column)
        {
            return reader.IsDBNull(column) ? "" : reader.GetString(column);
        }
    }
}