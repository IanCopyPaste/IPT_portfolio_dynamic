using System;
using System.Linq;
using System.Web.UI.WebControls;

namespace _24_1444AdoteRonAdrian_Portfolio.Accounts
{
    // The rules for a user_profile row, the counterpart to AccountRules: the slot counts and column
    // widths ProfilePage's form is built from, and the checks it runs before saving. Every field is
    // optional -- a portfolio fills up over time, and ContentPage shows a placeholder for whatever
    // is still missing -- so the checks only ever object to a value that is too long or impossible.
    public static class ProfileRules
    {
        // The page has room for exactly this many of each, and so does the table.
        public const int HobbyCount = 4;
        public const int SkillCount = 4;
        public const int ProjectCount = 5;

        // Column widths, so a value that passes here can always be written.
        public const int SexMaxLength = 20;
        public const int NationalityMaxLength = 50;
        public const int SchoolMaxLength = 120;
        public const int CourseMaxLength = 120;
        public const int HobbyMaxLength = 40;
        public const int SkillMaxLength = 40;
        public const int ProjectMaxLength = 120;

        // A fixed list keeps sex to values that belong in the column, the same way suffixes work.
        private static readonly string[] Sexes = { "Male", "Female", "Other" };

        // Nobody signing up for this is older than the oldest person on record, and a birthdate in
        // the future would give a negative age.
        public const int MaxAgeYears = 120;

        public static void FillSexes(DropDownList list)
        {
            list.Items.Add(new ListItem("None", ""));
            foreach (string sex in Sexes)
            {
                list.Items.Add(new ListItem(sex, sex));
            }
        }

        public static bool IsAllowedSex(string value)
        {
            return value.Length == 0 || Sexes.Contains(value);
        }

        // The browser sends an <input type="date"> as yyyy-MM-dd; anything else is a typed value
        // from a browser without a date picker, so it is parsed the same way and rejected if it
        // isn't a real date.
        public static string BirthdateError(string value, out DateTime? parsed)
        {
            parsed = null;

            if (value.Trim().Length == 0)
            {
                return null;
            }

            DateTime date;
            if (!DateTime.TryParse(value.Trim(), out date))
            {
                return "Enter a date as YYYY-MM-DD.";
            }

            if (date.Date > DateTime.Today)
            {
                return "That date hasn't happened yet.";
            }

            if (date.Date < DateTime.Today.AddYears(-MaxAgeYears))
            {
                return "That date is too far back.";
            }

            parsed = date.Date;
            return null;
        }

        public static string TextError(string value, int maxLength)
        {
            return value.Length > maxLength ? "Keep it under " + maxLength + " characters." : null;
        }
    }
}
