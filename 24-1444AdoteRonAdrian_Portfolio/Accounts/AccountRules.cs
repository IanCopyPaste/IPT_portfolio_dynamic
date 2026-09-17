using System;
using System.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.UI.WebControls;

namespace _24_1444AdoteRonAdrian_Portfolio.Accounts
{
    // The rules for the fields of a users row, shared by RegisterPage (creating one) and ProfilePage
    // (editing one) so the two forms can't drift apart. registerpage.js checks the same rules in the
    // browser with the same messages. Each check returns a message, or null when the value passes.
    public static class AccountRules
    {
        // The name, address and email columns are varchar(max), so these caps are the form's own;
        // the username and sms caps are the column widths, and a longer value would fail the write.
        public const int NameMaxLength = 50;
        public const int AddressMaxLength = 200;
        public const int EmailMaxLength = 254;
        public const int SmsLength = 11;
        public const int UsernameMaxLength = 40;
        public const int PasswordMinLength = 8;
        public const int PasswordMaxLength = 64;
        public const int SuffixMaxLength = 15;
        public const int PasswordHashMaxLength = 200;

        public const string RequiredMessage = "This field is required.";
        public const string UsernameTakenMessage = "That username is already taken.";

        // users.suffix is varchar(15); a fixed list keeps it to values that belong there.
        private static readonly string[] Suffixes = { "Jr.", "Sr.", "II", "III", "IV", "V" };

        private static readonly Regex UsernamePattern = new Regex(@"^[A-Za-z0-9._]{3,40}$");
        private static readonly Regex EmailPattern = new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$");
        private static readonly Regex SmsPattern = new Regex(@"^09\d{9}$");

        // SQL Server's duplicate-key errors, for a unique index and a unique constraint.
        private const int DuplicateIndexError = 2601;
        private const int DuplicateKeyError = 2627;

        public static void ApplyLimits(TextBox first, TextBox middle, TextBox last, TextBox address,
            TextBox email, TextBox sms, TextBox username)
        {
            first.MaxLength = NameMaxLength;
            middle.MaxLength = NameMaxLength;
            last.MaxLength = NameMaxLength;
            address.MaxLength = AddressMaxLength;
            email.MaxLength = EmailMaxLength;
            // Room for the spaces or dashes people type in a number; they are stripped before the check.
            sms.MaxLength = SmsLength + 4;
            username.MaxLength = UsernameMaxLength;
        }

        public static void FillSuffixes(DropDownList list)
        {
            list.Items.Add(new ListItem("None", ""));
            foreach (string suffix in Suffixes)
            {
                list.Items.Add(new ListItem(suffix, suffix));
            }
        }

        public static bool IsAllowedSuffix(string value)
        {
            return value.Length == 0 || Suffixes.Contains(value);
        }

        public static string NameError(string value, bool required)
        {
            if (value.Length == 0)
            {
                return required ? RequiredMessage : null;
            }
            return value.Length > NameMaxLength ? TooLong(NameMaxLength) : null;
        }

        public static string AddressError(string value)
        {
            return value.Length == 0 ? RequiredMessage
                : value.Length > AddressMaxLength ? TooLong(AddressMaxLength)
                : null;
        }

        public static string EmailError(string value)
        {
            return value.Length > 0 && (value.Length > EmailMaxLength || !EmailPattern.IsMatch(value))
                ? "Enter a valid email address." : null;
        }

        public static string NormalizeSms(string raw)
        {
            return Regex.Replace(raw, @"[\s-]", "");
        }

        public static string SmsError(string normalized)
        {
            return normalized.Length > 0 && !SmsPattern.IsMatch(normalized)
                ? "Use 11 digits starting with 09." : null;
        }

        public static string UsernameError(string value)
        {
            return value.Length == 0 ? RequiredMessage
                : !UsernamePattern.IsMatch(value) ? "3 to 40 letters, digits, . or _"
                : null;
        }

        public static string PasswordError(string value)
        {
            return value.Length == 0 ? RequiredMessage
                : value.Length < PasswordMinLength ? "At least " + PasswordMinLength + " characters."
                : value.Length > PasswordMaxLength ? TooLong(PasswordMaxLength)
                : null;
        }

        public static string ConfirmError(string confirm, string password)
        {
            return confirm.Length == 0 ? RequiredMessage
                : confirm != password ? "The passwords don't match."
                : null;
        }

        public static bool IsDuplicateKey(SqlException ex)
        {
            return ex.Number == DuplicateIndexError || ex.Number == DuplicateKeyError;
        }

        // Writes the message (or clears it) into a field's error label and says whether the field passed.
        public static bool Report(Label error, string message)
        {
            error.Text = message ?? "";
            return message == null;
        }

        // Optional columns store NULL, not an empty string, for a field left blank.
        public static object OrNull(string value)
        {
            return value.Length == 0 ? (object)DBNull.Value : value;
        }

        private static string TooLong(int max)
        {
            return "Keep it under " + max + " characters.";
        }
    }
}
