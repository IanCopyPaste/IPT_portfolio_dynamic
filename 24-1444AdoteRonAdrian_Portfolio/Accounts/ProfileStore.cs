using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace _24_1444AdoteRonAdrian_Portfolio.Accounts
{
    // Reads and writes a user_profile row through the two stored procedures in
    // Database/Migrations/002_profile_content.sql. ContentPage reads the signed-in user's row,
    // ProfilePage writes it, and the admin dashboard reads anyone's.
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
        private const int BirthdateColumn = 5;
        private const int SexColumn = 6;
        private const int NationalityColumn = 7;
        private const int JhsColumn = 8;
        private const int ShsColumn = 9;
        private const int CollegeColumn = 10;
        private const int CourseColumn = 11;
        private const int FirstHobbyColumn = 12;

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
                    content.Birthdate = reader.IsDBNull(BirthdateColumn)
                        ? (DateTime?)null : reader.GetDateTime(BirthdateColumn);
                    content.Sex = Text(reader, SexColumn);
                    content.Nationality = Text(reader, NationalityColumn);
                    content.JhsSchool = Text(reader, JhsColumn);
                    content.ShsSchool = Text(reader, ShsColumn);
                    content.CollegeSchool = Text(reader, CollegeColumn);
                    content.CollegeCourse = Text(reader, CourseColumn);

                    // The three runs of slots are stored, and returned, back to back in the same
                    // order the arrays are in, so one walk fills all three.
                    int column = FirstHobbyColumn;
                    column = ReadSlots(reader, column, content.Hobbies);
                    column = ReadSlots(reader, column, content.Skills);
                    ReadSlots(reader, column, content.Projects);
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
                AddSlots(cmd, "@hobby_", ProfileRules.HobbyMaxLength, content.Hobbies);
                AddSlots(cmd, "@skill_", ProfileRules.SkillMaxLength, content.Skills);
                AddSlots(cmd, "@project_", ProfileRules.ProjectMaxLength, content.Projects);

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
