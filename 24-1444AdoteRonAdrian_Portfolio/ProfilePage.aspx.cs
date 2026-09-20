using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using _24_1444AdoteRonAdrian_Portfolio.Security;
using System;
using System.Configuration;
using System.Data;
using System.Data.SqlClient;
using System.Globalization;
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
            ApplyPortfolioLimits();
            prfCurrentPassword.MaxLength = AccountRules.PasswordMaxLength;
            prfPassword.MaxLength = AccountRules.PasswordMaxLength;
            prfConfirm.MaxLength = AccountRules.PasswordMaxLength;

            if (!IsPostBack)
            {
                AccountRules.FillSuffixes(prfSuffix);
                ProfileRules.FillSexes(prfSex);
                FillForm(UserSession.UserId(Session).Value);
                FillPortfolio(UserSession.UserId(Session).Value);
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

            // Read and checked alongside the account fields so one failed save highlights every
            // field at fault, not just the first half of the form.
            bool portfolioValid;
            ProfileContent portfolio = ReadPortfolio(out portfolioValid);
            valid &= portfolioValid;

            // Only the picker is checked here. Nothing is written to disk until every other
            // field has passed too, so a save that fails on a typo somewhere else does not leave
            // an orphaned image behind.
            valid &= AccountRules.Report(prfHomePhotoError, ProfilePhotos.Check(prfHomePhoto));

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

            // A second write rather than part of the first: the portfolio lives in its own table,
            // behind the stored procedure that upserts it. The row above has just been updated, so
            // the account is there; a false here would mean it went in between the two.
            // Everything has passed and the account is still there, so the upload can be written.
            // The path of the portrait it replaces comes from the stored row, not the form: a
            // picker posts nothing when no file was chosen, so the row is the only record of it.
            ApplyPhoto(portfolio, userId, ProfileStore.Get(userId) ?? new ProfileContent());

            if (!ProfileStore.Save(userId, portfolio))
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
            ShowPortfolio(portfolio);
            ShowStatus(changingPassword ? "profile and password saved." : "profile saved.", false);
        }

        protected void profileLogout_Click(object sender, EventArgs e)
        {
            SignOutTo("LoginPage.aspx?" + SignedOutQuery + "=1");
        }


        // The portfolio's three runs of slots, each paired with the error labels under them, so the
        // fill and the save can walk them rather than naming twenty-odd controls twice over. The
        // order matches ProfileContent's arrays, and through them the numbered columns.
        private TextBox[] HobbyBoxes => new[] { prfHobby1, prfHobby2, prfHobby3, prfHobby4 };

        private Label[] HobbyErrors => new[] { prfHobby1Error, prfHobby2Error, prfHobby3Error, prfHobby4Error };

        private TextBox[] SkillBoxes => new[] { prfSkill1, prfSkill2, prfSkill3, prfSkill4 };

        private Label[] SkillErrors => new[] { prfSkill1Error, prfSkill2Error, prfSkill3Error, prfSkill4Error };

        private TextBox[] ProjectBoxes => new[] { prfProject1, prfProject2, prfProject3, prfProject4, prfProject5 };

        private Label[] ProjectErrors => new[] { prfProject1Error, prfProject2Error, prfProject3Error,
            prfProject4Error, prfProject5Error };

        private void ApplyPortfolioLimits()
        {
            prfNationality.MaxLength = ProfileRules.NationalityMaxLength;
            prfJhs.MaxLength = ProfileRules.SchoolMaxLength;
            prfShs.MaxLength = ProfileRules.SchoolMaxLength;
            prfCollege.MaxLength = ProfileRules.SchoolMaxLength;
            prfCourse.MaxLength = ProfileRules.CourseMaxLength;
            SetMaxLength(HobbyBoxes, ProfileRules.HobbyMaxLength);
            SetMaxLength(SkillBoxes, ProfileRules.SkillMaxLength);
            SetMaxLength(ProjectBoxes, ProfileRules.ProjectMaxLength);
        }

        // FillForm has already signed a stale session out by the time this runs, so a missing row
        // here needs no second redirect; the form is simply left with its placeholders.
        private void FillPortfolio(int userId)
        {
            ProfileContent content = ProfileStore.Get(userId);

            if (content != null)
            {
                ShowPortfolio(content);
            }
        }

        private void ShowPortfolio(ProfileContent content)
        {
            // An <input type="date"> only accepts yyyy-MM-dd, whatever the browser then shows.
            prfBirthdate.Text = content.Birthdate == null
                ? ""
                : content.Birthdate.Value.ToString("yyyy-MM-dd", CultureInfo.InvariantCulture);
            Select(prfSex, content.Sex);
            prfNationality.Text = content.Nationality;
            prfJhs.Text = content.JhsSchool;
            prfShs.Text = content.ShsSchool;
            prfCollege.Text = content.CollegeSchool;
            prfCourse.Text = content.CollegeCourse;
            ShowSlots(HobbyBoxes, content.Hobbies);
            ShowSlots(SkillBoxes, content.Skills);
            ShowSlots(ProjectBoxes, content.Projects);
            ShowPhoto(content);
        }

        // The picker can't be pre-filled -- a browser never hands a file input a value back -- so
        // the current portrait is shown beside it instead, and "no file chosen" means keep it.
        private void ShowPhoto(ProfileContent content)
        {
            prfHomePreview.Visible = content.HomePhotoUrl.Length > 0;
            prfHomePreview.ImageUrl = content.HomePhotoUrl;
        }

        // Writes the file if one was chosen and puts its path on the content about to be saved, so
        // every path in the database already has a file behind it. A picker left empty keeps the
        // portrait that is there; one that was replaced is deleted by Save.
        private void ApplyPhoto(ProfileContent content, int userId, ProfileContent saved)
        {
            content.HomePhoto = ProfilePhotos.Save(prfHomePhoto, userId, ProfilePhotos.HomeSlot, saved.HomePhoto);
        }

        // Reads the portfolio half of the form and reports on each field, the same way the account
        // half is checked above it. Every field is optional, so the only thing that can fail is a
        // value that couldn't have been typed into the form as it stands: a birthdate that isn't a
        // date, or a value past the length the input caps at.
        private ProfileContent ReadPortfolio(out bool valid)
        {
            var content = new ProfileContent();
            valid = true;

            DateTime? birthdate;
            valid &= AccountRules.Report(prfBirthdateError,
                ProfileRules.BirthdateError(prfBirthdate.Text, out birthdate));
            content.Birthdate = birthdate;

            // No error label: the sex list is a fixed set, so a value outside it can only come from
            // a forged post, and the suffix list above is handled the same way.
            content.Sex = prfSex.SelectedValue;
            valid &= ProfileRules.IsAllowedSex(content.Sex);

            content.Nationality = prfNationality.Text.Trim();
            valid &= AccountRules.Report(prfNationalityError,
                ProfileRules.TextError(content.Nationality, ProfileRules.NationalityMaxLength));

            content.JhsSchool = prfJhs.Text.Trim();
            valid &= AccountRules.Report(prfJhsError,
                ProfileRules.TextError(content.JhsSchool, ProfileRules.SchoolMaxLength));

            content.ShsSchool = prfShs.Text.Trim();
            valid &= AccountRules.Report(prfShsError,
                ProfileRules.TextError(content.ShsSchool, ProfileRules.SchoolMaxLength));

            content.CollegeSchool = prfCollege.Text.Trim();
            valid &= AccountRules.Report(prfCollegeError,
                ProfileRules.TextError(content.CollegeSchool, ProfileRules.SchoolMaxLength));

            content.CollegeCourse = prfCourse.Text.Trim();
            valid &= AccountRules.Report(prfCourseError,
                ProfileRules.TextError(content.CollegeCourse, ProfileRules.CourseMaxLength));

            valid &= ReadSlots(HobbyBoxes, HobbyErrors, content.Hobbies, ProfileRules.HobbyMaxLength);
            valid &= ReadSlots(SkillBoxes, SkillErrors, content.Skills, ProfileRules.SkillMaxLength);
            valid &= ReadSlots(ProjectBoxes, ProjectErrors, content.Projects, ProfileRules.ProjectMaxLength);

            return content;
        }

        private static bool ReadSlots(TextBox[] boxes, Label[] errors, string[] slots, int maxLength)
        {
            bool valid = true;

            for (int i = 0; i < slots.Length; i++)
            {
                slots[i] = boxes[i].Text.Trim();
                valid &= AccountRules.Report(errors[i], ProfileRules.TextError(slots[i], maxLength));
            }

            return valid;
        }

        private static void ShowSlots(TextBox[] boxes, string[] slots)
        {
            for (int i = 0; i < slots.Length; i++)
            {
                boxes[i].Text = slots[i];
            }
        }

        private static void SetMaxLength(TextBox[] boxes, int maxLength)
        {
            foreach (TextBox box in boxes)
            {
                box.MaxLength = maxLength;
            }
        }

        // A stored value outside the list (only possible if it was written straight to the database)
        // can't be selected, so the list falls back to its first entry, as the suffix list does.
        private static void Select(DropDownList list, string value)
        {
            ListItem item = list.Items.FindByValue(value ?? "");

            if (item != null)
            {
                list.ClearSelection();
                item.Selected = true;
            }
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
