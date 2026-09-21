using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace _24_1444AdoteRonAdrian_Portfolio.Accounts
{
    // How many hobbies and how many skills one account may list: the single site_settings row that
    // Database/Migrations/005_profile_lists.sql creates. The admin sets both from the dashboard's
    // Settings view; ProfilePage caps its "+" buttons at them and refuses a save over them, and
    // ContentPage draws no more than them.
    public class ProfileLimits
    {
        // The range the admin may pick from, matched by the table's CHECK constraints. The ceiling is
        // what the Interests step can hold and still fit the screen, four to a row.
        public const int Min = 1;
        public const int Max = 12;

        // What the form had room for before the limits were adjustable, and what a database without
        // the settings row falls back to.
        public const int Default = 4;

        private static readonly string PortfolioConn =
            ConfigurationManager.ConnectionStrings["portfolio_conn"].ConnectionString;

        public ProfileLimits(int hobbies, int skills)
        {
            Hobbies = hobbies;
            Skills = skills;
        }

        public int Hobbies { get; private set; }
        public int Skills { get; private set; }

        public static ProfileLimits Get()
        {
            using (var conn = new SqlConnection(PortfolioConn))
            using (var cmd = new SqlCommand("SELECT max_hobbies, max_skills FROM site_settings WHERE id = 1", conn))
            {
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    // The migration inserts the row, so this only happens if someone deleted it by
                    // hand; the form keeps working at the old four rather than failing.
                    return reader.Read()
                        ? new ProfileLimits(reader.GetInt32(0), reader.GetInt32(1))
                        : new ProfileLimits(Default, Default);
                }
            }
        }

        public static void Save(ProfileLimits limits)
        {
            using (var conn = new SqlConnection(PortfolioConn))
            using (var cmd = new SqlCommand(
                "UPDATE site_settings SET max_hobbies = @hobbies, max_skills = @skills, " +
                "updated_at = SYSUTCDATETIME() WHERE id = 1", conn))
            {
                cmd.Parameters.Add("@hobbies", SqlDbType.Int).Value = limits.Hobbies;
                cmd.Parameters.Add("@skills", SqlDbType.Int).Value = limits.Skills;
                conn.Open();
                cmd.ExecuteNonQuery();
            }
        }

        // Null when the value is one the admin may pick; the message otherwise. A missing value
        // (the JSON field left out) is reported the same way as one out of range.
        public static string Error(int? value)
        {
            return value == null || value < Min || value > Max
                ? "Pick a number from " + Min + " to " + Max + "."
                : null;
        }
    }
}
