using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using _24_1444AdoteRonAdrian_Portfolio.Security;
using System;
using System.Globalization;
using System.Linq;

namespace _24_1444AdoteRonAdrian_Portfolio
{
    public partial class ContentPage : System.Web.UI.Page
    {
        // The site's own name, on the sign-in, sign-up and 403 screens and in the dashboard footer,
        // where there is no user to name. The portfolio itself is branded with its owner instead.
        public const string SiteBrandName = "IAN";

        // Stands in for any portfolio field the user hasn't filled in yet. ContentPage is one
        // account's page, so a brand-new account sees this in most of it until they visit
        // ProfilePage; UnsetClass greys each one out so a filled page is obvious at a glance.
        public const string UnsetText = "Not set yet";

        // Filled in Page_Load, which runs before the markup is rendered.
        protected ProfileContent Owner;

        // Shown when the account button is hovered. A session signed in before the full name was
        // stored has only the username, so that stands in until the user signs in again.
        protected string AccountName =>
            Session[UserSession.FullNameKey] as string ?? Session[UserSession.UsernameKey] as string ?? "";

        protected void Page_Load(object sender, EventArgs e)
        {
            if (!UserSession.IsSignedIn(Session))
            {
                Response.StatusCode = 401;
                Response.Redirect("~/ForbiddenPage.aspx");
                Response.End();
                return;
            }

            int? userId = UserSession.UserId(Session);
            Owner = userId == null ? null : ProfileStore.Get(userId.Value);

            // No row means the account was deleted while this session was open, so the session is
            // stale and there is no portfolio to draw.
            if (Owner == null)
            {
                UserSession.SignOut(Session);
                Response.Redirect("~/LoginPage.aspx");
                Response.End();
            }
        }

        // The page is branded with its owner: their first name in the navbar and the footer, their
        // full name in the hero and the copyright line.
        protected string BrandName => Owner.FirstName;

        protected string OwnerName => Owner.FullName;

        // The markup asks these rather than calling Any() itself, so the "nothing here yet" line
        // and the loop above it can never disagree.
        protected bool HasHobbies => Owner.FilledHobbies.Any();

        protected bool HasSkills => Owner.FilledSkills.Any();

        protected bool HasProjects => Owner.FilledProjects.Any();

        protected bool HasHomePhoto => Owner.HomePhotoUrl.Length > 0;

        protected bool HasAboutPhoto => Owner.AboutPhotoUrl.Length > 0;

        // The projects prompt names how many the form has room for, so the two can't drift.
        protected static int ProjectSlots => ProfileRules.ProjectCount;

        protected string AgeText => Owner.Age == null
            ? UnsetText
            : Owner.Age.Value + (Owner.Age.Value == 1 ? " yr Old" : " yrs Old");

        // Written out in full ("April 16, 2006") rather than as the form's yyyy-MM-dd, and in a
        // fixed culture so the month name doesn't follow the server's locale.
        protected string BirthdateText => Owner.Birthdate == null
            ? UnsetText
            : Owner.Birthdate.Value.ToString("MMMM d, yyyy", CultureInfo.InvariantCulture);

        // The placeholder and the class that greys it go together: a field is shown as unset in
        // both or in neither.
        protected static string Or(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? UnsetText : value.Trim();
        }

        protected static string UnsetClass(string value)
        {
            return UnsetClass(string.IsNullOrWhiteSpace(value));
        }

        // For the two values that aren't plain strings: the age and the birthdate are unset when no
        // birthdate has been saved.
        protected static string UnsetClass(bool isUnset)
        {
            return isUnset ? " cp-unset" : "";
        }
    }
}
