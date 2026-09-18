using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using _24_1444AdoteRonAdrian_Portfolio.Security;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Web.UI.WebControls;

namespace _24_1444AdoteRonAdrian_Portfolio
{
    public partial class ProfilePage : System.Web.UI.Page
    {
        public const string SiteBrandName = ContentPage.SiteBrandName;

        private static readonly string PortfolioConn =
            ConfigurationManager.ConnectionStrings["portfolio_conn"].ConnectionString;

        // Read by LoginPage, which says so on the log-in screen.
        public const string SignedOutQuery = "signedout";

        protected void Page_Load(object sender, EventArgs e)
        {
            // Every read and write here is keyed on the session's user id, so a session without one
            // is treated as signed out. Redirect ends the request, so no click handler runs after it.
            if (UserSession.UserId(Session) == null)
            {
                Response.Redirect("~/ForbiddenPage.aspx");
                return;
            }

            AccountRules.ApplyLimits(prfFirstName, prfMiddleName, prfLastName, prfAddress, prfEmail, prfSms, prfUser);
            prfCurrentPassword.MaxLength = AccountRules.PasswordMaxLength;
            prfPassword.MaxLength = AccountRules.PasswordMaxLength;
            prfConfirm.MaxLength = AccountRules.PasswordMaxLength;

            if (!IsPostBack)
            {
                AccountRules.FillSuffixes(prfSuffix);
                FillForm(UserSession.UserId(Session).Value);
            }
        }

        private void FillForm(int userId)
        {
            using (var conn = new SqlConnection(PortfolioConn))
            using (var cmd = new SqlCommand(
                "SELECT first_name, middle_name, last_name, suffix, address, email, sms, username " +
                "FROM users WHERE id = @id AND status = @active", conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = userId;
                cmd.Parameters.Add("@active", SqlDbType.VarChar, 10).Value = AccountStatus.Active;
                conn.Open();

                using (SqlDataReader reader = cmd.ExecuteReader())
                {
                    if (!reader.Read())
                    {
                        // The account is gone, or an admin deactivated it, while the user was signed
                        // in, so the session is stale.
                        SignOutTo("LoginPage.aspx");
                        return;
                    }

                    prfFirstName.Text = Text(reader, 0);
                    prfMiddleName.Text = Text(reader, 1);
                    prfLastName.Text = Text(reader, 2);
                    // A suffix outside the list (only possible if it was written straight to the
                    // database) can't be selected, so the list falls back to None.
                    ListItem suffix = prfSuffix.Items.FindByValue(Text(reader, 3));
                    if (suffix != null)
                    {
                        prfSuffix.ClearSelection();
                        suffix.Selected = true;
                    }
                    prfAddress.Text = Text(reader, 4);
                    prfEmail.Text = Text(reader, 5);
                    prfSms.Text = Text(reader, 6);
                    prfUser.Text = Text(reader, 7);
                }
            }
        }

        protected void profileSave_Click(object sender, EventArgs e)
        {
            int userId = UserSession.UserId(Session).Value;

            string firstName = prfFirstName.Text.Trim();
            string middleName = prfMiddleName.Text.Trim();
            string lastName = prfLastName.Text.Trim();
            string suffix = prfSuffix.SelectedValue;
            string address = prfAddress.Text.Trim();
            string email = prfEmail.Text.Trim();
            string sms = AccountRules.NormalizeSms(prfSms.Text);
            string username = prfUser.Text.Trim();
            string currentPassword = prfCurrentPassword.Text;
            string newPassword = prfPassword.Text;
            string confirm = prfConfirm.Text;

            // Blank password fields keep the current password; typing a new one brings in all three.
            bool changingPassword = newPassword.Length > 0 || confirm.Length > 0;

            bool valid = true;
            valid &= AccountRules.Report(prfFirstNameError, AccountRules.NameError(firstName, true));
            valid &= AccountRules.Report(prfMiddleNameError, AccountRules.NameError(middleName, false));
            valid &= AccountRules.Report(prfLastNameError, AccountRules.NameError(lastName, true));
            valid &= AccountRules.Report(prfAddressError, AccountRules.AddressError(address));
            valid &= AccountRules.Report(prfEmailError, AccountRules.EmailError(email));
            valid &= AccountRules.Report(prfSmsError, AccountRules.SmsError(sms));
            valid &= AccountRules.Report(prfUserError, AccountRules.UsernameError(username));
            valid &= AccountRules.Report(prfCurrentPasswordError,
                changingPassword && currentPassword.Length == 0 ? AccountRules.RequiredMessage : null);
            valid &= AccountRules.Report(prfPasswordError,
                changingPassword ? AccountRules.PasswordError(newPassword) : null);
            valid &= AccountRules.Report(prfConfirmError,
                changingPassword ? AccountRules.ConfirmError(confirm, newPassword) : null);
            valid &= AccountRules.IsAllowedSuffix(suffix);

            if (!valid)
            {
                ShowStatus("save failed. fix the highlighted fields and try again.", true);
                return;
            }

            string newHash = null;

            if (changingPassword)
            {
                if (!PasswordHasher.Verify(currentPassword, StoredHash(userId) ?? ""))
                {
                    AccountRules.Report(prfCurrentPasswordError, "That isn't your current password.");
                    ShowStatus("save failed. check your current password.", true);
                    return;
                }
                newHash = PasswordHasher.Hash(newPassword);
            }

            int updated;

            try
            {
                using (var conn = new SqlConnection(PortfolioConn))
                using (var cmd = new SqlCommand(
                    "UPDATE users SET first_name = @first_name, middle_name = @middle_name, last_name = @last_name, " +
                    "suffix = @suffix, address = @address, email = @email, sms = @sms, username = @username, " +
                    // A null hash leaves the stored one alone, so one statement covers both cases.
                    "password_hash = COALESCE(@password_hash, password_hash) " +
                    "WHERE id = @id AND status = @active", conn))
                {
                    cmd.Parameters.Add("@active", SqlDbType.VarChar, 10).Value = AccountStatus.Active;
                    cmd.Parameters.Add("@first_name", SqlDbType.VarChar, -1).Value = firstName;
                    cmd.Parameters.Add("@middle_name", SqlDbType.VarChar, -1).Value = AccountRules.OrNull(middleName);
                    cmd.Parameters.Add("@last_name", SqlDbType.VarChar, -1).Value = lastName;
                    cmd.Parameters.Add("@suffix", SqlDbType.VarChar, AccountRules.SuffixMaxLength).Value = AccountRules.OrNull(suffix);
                    cmd.Parameters.Add("@address", SqlDbType.VarChar, -1).Value = address;
                    cmd.Parameters.Add("@email", SqlDbType.VarChar, -1).Value = AccountRules.OrNull(email);
                    cmd.Parameters.Add("@sms", SqlDbType.VarChar, AccountRules.SmsLength).Value = AccountRules.OrNull(sms);
                    cmd.Parameters.Add("@username", SqlDbType.VarChar, AccountRules.UsernameMaxLength).Value = username;
                    cmd.Parameters.Add("@password_hash", SqlDbType.VarChar, AccountRules.PasswordHashMaxLength).Value =
                        (object)newHash ?? DBNull.Value;
                    cmd.Parameters.Add("@id", SqlDbType.Int).Value = userId;

                    conn.Open();
                    updated = cmd.ExecuteNonQuery();
                }
            }
            catch (SqlException ex) when (AccountRules.IsDuplicateKey(ex))
            {
                AccountRules.Report(prfUserError, AccountRules.UsernameTakenMessage);
                ShowStatus("save failed. pick a different username.", true);
                return;
            }

            if (updated == 0)
            {
                SignOutTo("LoginPage.aspx");
                return;
            }

            // The navbar shows the name from the session, so it is refreshed along with the row.
            UserSession.SignIn(Session, userId, username, UserSession.FullName(firstName, middleName, lastName, suffix));

            // Show the values as they were saved.
            prfFirstName.Text = firstName;
            prfMiddleName.Text = middleName;
            prfLastName.Text = lastName;
            prfAddress.Text = address;
            prfEmail.Text = email;
            prfSms.Text = sms;
            prfUser.Text = username;
            ShowStatus(changingPassword ? "profile and password saved." : "profile saved.", false);
        }

        protected void profileLogout_Click(object sender, EventArgs e)
        {
            SignOutTo("LoginPage.aspx?" + SignedOutQuery + "=1");
        }

        private string StoredHash(int userId)
        {
            using (var conn = new SqlConnection(PortfolioConn))
            using (var cmd = new SqlCommand("SELECT password_hash FROM users WHERE id = @id", conn))
            {
                cmd.Parameters.Add("@id", SqlDbType.Int).Value = userId;
                conn.Open();
                return cmd.ExecuteScalar() as string;
            }
        }

        private void SignOutTo(string url)
        {
            UserSession.SignOut(Session);
            Response.Redirect(url, false);
            Context.ApplicationInstance.CompleteRequest();
        }

        private void ShowStatus(string message, bool isError)
        {
            profileStatus.Text = message;
            profileStatus.CssClass = isError ? "login-status is-error" : "login-status";
        }

        private static string Text(SqlDataReader reader, int column)
        {
            return reader.IsDBNull(column) ? "" : reader.GetString(column);
        }
    }
}
