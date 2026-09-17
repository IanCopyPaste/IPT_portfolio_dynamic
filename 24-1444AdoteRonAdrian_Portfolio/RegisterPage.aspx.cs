using _24_1444AdoteRonAdrian_Portfolio.Security;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.UI.WebControls;

namespace _24_1444AdoteRonAdrian_Portfolio
{
    public partial class RegisterPage : System.Web.UI.Page
    {
        public const string SiteBrandName = ContentPage.SiteBrandName;

        private static readonly string PortfolioConn =
            ConfigurationManager.ConnectionStrings["portfolio_conn"].ConnectionString;

        // The name, address and email columns are varchar(max), so these caps are the form's own;
        // the username and sms caps are the column widths, and a longer value would fail the insert.
        private const int NameMaxLength = 50;
        private const int AddressMaxLength = 200;
        private const int EmailMaxLength = 254;
        private const int SmsLength = 11;
        private const int UsernameMaxLength = 40;
        private const int PasswordMinLength = 8;
        private const int PasswordMaxLength = 64;

        // users.suffix is varchar(15); a fixed list keeps it to values that belong there.
        private static readonly string[] Suffixes = { "Jr.", "Sr.", "II", "III", "IV", "V" };

        // registerpage.js checks the same patterns, so both sides give the same answer.
        private static readonly Regex UsernamePattern = new Regex(@"^[A-Za-z0-9._]{3,40}$");
        private static readonly Regex EmailPattern = new Regex(@"^[^@\s]+@[^@\s]+\.[^@\s]+$");
        private static readonly Regex SmsPattern = new Regex(@"^09\d{9}$");

        // SQL Server's duplicate-key errors, for a unique index and a unique constraint.
        private const int DuplicateIndexError = 2601;
        private const int DuplicateKeyError = 2627;

        private const string RequiredMessage = "This field is required.";

        protected void Page_Load(object sender, EventArgs e)
        {
            regFirstName.MaxLength = NameMaxLength;
            regMiddleName.MaxLength = NameMaxLength;
            regLastName.MaxLength = NameMaxLength;
            regAddress.MaxLength = AddressMaxLength;
            regEmail.MaxLength = EmailMaxLength;
            // Room for the spaces or dashes people type in a number; they are stripped before the check.
            regSms.MaxLength = SmsLength + 4;
            regUser.MaxLength = UsernameMaxLength;
            regPassword.MaxLength = PasswordMaxLength;
            regConfirm.MaxLength = PasswordMaxLength;

            if (!IsPostBack)
            {
                regSuffix.Items.Add(new ListItem("None", ""));
                foreach (string suffix in Suffixes)
                {
                    regSuffix.Items.Add(new ListItem(suffix, suffix));
                }
            }
        }

        protected void registerSubmit_Click(object sender, EventArgs e)
        {
            string firstName = regFirstName.Text.Trim();
            string middleName = regMiddleName.Text.Trim();
            string lastName = regLastName.Text.Trim();
            string suffix = regSuffix.SelectedValue;
            string address = regAddress.Text.Trim();
            string email = regEmail.Text.Trim();
            string sms = Regex.Replace(regSms.Text, @"[\s-]", "");
            string username = regUser.Text.Trim();
            string password = regPassword.Text;

            // Every field is checked, not just up to the first failure, so all the problems show at once.
            bool valid = true;
            valid &= Report(regFirstNameError, NameError(firstName, true));
            valid &= Report(regMiddleNameError, NameError(middleName, false));
            valid &= Report(regLastNameError, NameError(lastName, true));
            valid &= Report(regAddressError,
                address.Length == 0 ? RequiredMessage
                : address.Length > AddressMaxLength ? "Keep it under " + AddressMaxLength + " characters."
                : null);
            valid &= Report(regEmailError,
                email.Length > 0 && (email.Length > EmailMaxLength || !EmailPattern.IsMatch(email))
                    ? "Enter an email like you@example.com." : null);
            valid &= Report(regSmsError,
                sms.Length > 0 && !SmsPattern.IsMatch(sms)
                    ? "Use an 11-digit mobile number starting with 09." : null);
            valid &= Report(regUserError,
                username.Length == 0 ? RequiredMessage
                : !UsernamePattern.IsMatch(username) ? "Use 3 to 40 letters, numbers, dots or underscores."
                : null);
            valid &= Report(regPasswordError,
                password.Length == 0 ? RequiredMessage
                : password.Length < PasswordMinLength ? "Passwords are at least " + PasswordMinLength + " characters."
                : password.Length > PasswordMaxLength ? "Keep it under " + PasswordMaxLength + " characters."
                : null);
            valid &= Report(regConfirmError,
                regConfirm.Text.Length == 0 ? RequiredMessage
                : regConfirm.Text != password ? "The passwords don't match."
                : null);

            if (suffix.Length > 0 && !Suffixes.Contains(suffix))
            {
                valid = false;
            }

            if (!valid)
            {
                ShowStatus("sign-up failed. fix the highlighted fields and try again.");
                return;
            }

            int userId;

            try
            {
                using (var conn = new SqlConnection(PortfolioConn))
                using (var cmd = new SqlCommand(
                    "INSERT INTO users (first_name, middle_name, last_name, suffix, address, email, sms, username, password_hash) " +
                    "OUTPUT INSERTED.id " +
                    "VALUES (@first_name, @middle_name, @last_name, @suffix, @address, @email, @sms, @username, @password_hash)", conn))
                {
                    // Typed as varchar to match the columns; AddWithValue would send nvarchar and make
                    // SQL Server convert every value on the way in.
                    cmd.Parameters.Add("@first_name", SqlDbType.VarChar, -1).Value = firstName;
                    cmd.Parameters.Add("@middle_name", SqlDbType.VarChar, -1).Value = OrNull(middleName);
                    cmd.Parameters.Add("@last_name", SqlDbType.VarChar, -1).Value = lastName;
                    cmd.Parameters.Add("@suffix", SqlDbType.VarChar, 15).Value = OrNull(suffix);
                    cmd.Parameters.Add("@address", SqlDbType.VarChar, -1).Value = address;
                    cmd.Parameters.Add("@email", SqlDbType.VarChar, -1).Value = OrNull(email);
                    cmd.Parameters.Add("@sms", SqlDbType.VarChar, SmsLength).Value = OrNull(sms);
                    cmd.Parameters.Add("@username", SqlDbType.VarChar, UsernameMaxLength).Value = username;
                    cmd.Parameters.Add("@password_hash", SqlDbType.VarChar, 200).Value = PasswordHasher.Hash(password);

                    conn.Open();
                    userId = (int)cmd.ExecuteScalar();
                }
            }
            // Relying on the unique index rather than checking first: a check-then-insert would let two
            // sign-ups with the same name slip through together.
            catch (SqlException ex) when (ex.Number == DuplicateIndexError || ex.Number == DuplicateKeyError)
            {
                Report(regUserError, "That username is already taken.");
                ShowStatus("sign-up failed. pick a different username.");
                return;
            }

            // Signed straight in, with the same two keys LoginPage sets and ContentPage checks.
            Session["user_id"] = userId;
            Session["username"] = username;
            Response.Redirect("ContentPage.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private static string NameError(string value, bool required)
        {
            if (value.Length == 0)
            {
                return required ? RequiredMessage : null;
            }
            return value.Length > NameMaxLength ? "Keep it under " + NameMaxLength + " characters." : null;
        }

        // Writes the message (or clears it) and says whether the field passed.
        private static bool Report(Label error, string message)
        {
            error.Text = message ?? "";
            return message == null;
        }

        private void ShowStatus(string message)
        {
            registerStatus.Text = message;
            registerStatus.CssClass = "login-status is-error";
        }

        private static object OrNull(string value)
        {
            return value.Length == 0 ? (object)DBNull.Value : value;
        }
    }
}
