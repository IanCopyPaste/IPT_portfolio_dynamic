using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using _24_1444AdoteRonAdrian_Portfolio.Security;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;

namespace _24_1444AdoteRonAdrian_Portfolio
{
    public partial class RegisterPage : System.Web.UI.Page
    {
        public const string SiteBrandName = ContentPage.SiteBrandName;

        private static readonly string PortfolioConn =
            ConfigurationManager.ConnectionStrings["portfolio_conn"].ConnectionString;

        protected void Page_Load(object sender, EventArgs e)
        {
            AccountRules.ApplyLimits(regFirstName, regMiddleName, regLastName, regAddress, regEmail, regSms, regUser);
            regPassword.MaxLength = AccountRules.PasswordMaxLength;
            regConfirm.MaxLength = AccountRules.PasswordMaxLength;

            if (!IsPostBack)
            {
                AccountRules.FillSuffixes(regSuffix);
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
            string sms = AccountRules.NormalizeSms(regSms.Text);
            string username = regUser.Text.Trim();
            string password = regPassword.Text;

            // Every field is checked, not just up to the first failure, so all the problems show at once.
            bool valid = true;
            valid &= AccountRules.Report(regFirstNameError, AccountRules.NameError(firstName, true));
            valid &= AccountRules.Report(regMiddleNameError, AccountRules.NameError(middleName, false));
            valid &= AccountRules.Report(regLastNameError, AccountRules.NameError(lastName, true));
            valid &= AccountRules.Report(regAddressError, AccountRules.AddressError(address));
            valid &= AccountRules.Report(regEmailError, AccountRules.EmailError(email));
            valid &= AccountRules.Report(regSmsError, AccountRules.SmsError(sms));
            valid &= AccountRules.Report(regUserError, AccountRules.UsernameError(username));
            valid &= AccountRules.Report(regPasswordError, AccountRules.PasswordError(password));
            valid &= AccountRules.Report(regConfirmError, AccountRules.ConfirmError(regConfirm.Text, password));
            valid &= AccountRules.IsAllowedSuffix(suffix);

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
                    // status and created_at take their column defaults. last_login_at is set here
                    // because a new account is signed straight in below.
                    "INSERT INTO users (first_name, middle_name, last_name, suffix, address, email, sms, username, password_hash, last_login_at) " +
                    "OUTPUT INSERTED.id " +
                    "VALUES (@first_name, @middle_name, @last_name, @suffix, @address, @email, @sms, @username, @password_hash, SYSUTCDATETIME())", conn))
                {
                    // Typed as varchar to match the columns; AddWithValue would send nvarchar and make
                    // SQL Server convert every value on the way in.
                    cmd.Parameters.Add("@first_name", SqlDbType.VarChar, -1).Value = firstName;
                    cmd.Parameters.Add("@middle_name", SqlDbType.VarChar, -1).Value = AccountRules.OrNull(middleName);
                    cmd.Parameters.Add("@last_name", SqlDbType.VarChar, -1).Value = lastName;
                    cmd.Parameters.Add("@suffix", SqlDbType.VarChar, AccountRules.SuffixMaxLength).Value = AccountRules.OrNull(suffix);
                    cmd.Parameters.Add("@address", SqlDbType.VarChar, -1).Value = address;
                    cmd.Parameters.Add("@email", SqlDbType.VarChar, -1).Value = AccountRules.OrNull(email);
                    cmd.Parameters.Add("@sms", SqlDbType.VarChar, AccountRules.SmsLength).Value = AccountRules.OrNull(sms);
                    cmd.Parameters.Add("@username", SqlDbType.VarChar, AccountRules.UsernameMaxLength).Value = username;
                    cmd.Parameters.Add("@password_hash", SqlDbType.VarChar, AccountRules.PasswordHashMaxLength).Value =
                        PasswordHasher.Hash(password);

                    conn.Open();
                    userId = (int)cmd.ExecuteScalar();
                }
            }
            // Relying on the unique index rather than checking first: a check-then-insert would let two
            // sign-ups with the same name slip through together.
            catch (SqlException ex) when (AccountRules.IsDuplicateKey(ex))
            {
                AccountRules.Report(regUserError, AccountRules.UsernameTakenMessage);
                ShowStatus("sign-up failed. pick a different username.");
                return;
            }

            // Signed straight in, the same way LoginPage does it.
            UserSession.SignIn(Session, userId, username,
                UserSession.FullName(firstName, middleName, lastName, suffix));
            Response.Redirect("ContentPage.aspx", false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowStatus(string message)
        {
            registerStatus.Text = message;
            registerStatus.CssClass = "login-status is-error";
        }
    }
}
