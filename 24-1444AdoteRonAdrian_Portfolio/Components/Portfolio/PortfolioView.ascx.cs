using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using _24_1444AdoteRonAdrian_Portfolio.Security;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;

namespace _24_1444AdoteRonAdrian_Portfolio.Components.Portfolio
{
    public partial class PortfolioView : System.Web.UI.UserControl
    {
        // Set by the page in its Page_Load, which runs before the control renders: whose portfolio
        // this is, and the admin's list limits to draw it under.
        public ProfileContent Owner { get; set; }
        public ProfileLimits Limits { get; set; }

        // True on SharePage, where the visitor is anonymous. See the markup for what it leaves out.
        public bool Shared { get; set; }

        // Shown when the account button is hovered. A session signed in before the full name was
        // stored has only the username, so that stands in until the user signs in again.
        protected string AccountName =>
            Session[UserSession.FullNameKey] as string ?? Session[UserSession.UsernameKey] as string ?? "";

        // The page is branded with its owner: their first name in the navbar and the footer, their
        // full name in the hero and the copyright line.
        protected string BrandName => Owner.FirstName;

        protected string OwnerName => Owner.FullName;

        // No more than the admin's current limit. An account filled in before the admin lowered it
        // keeps its extra rows until it next saves, but the page already shows the new number.
        protected IEnumerable<string> Hobbies => Owner.FilledHobbies.Take(Limits.Hobbies);

        protected IEnumerable<string> Skills => Owner.FilledSkills.Take(Limits.Skills);

        // The markup asks these rather than calling Any() itself, so the "nothing here yet" line
        // and the loop above it can never disagree.
        protected bool HasHobbies => Hobbies.Any();

        protected bool HasSkills => Skills.Any();

        protected bool HasProjects => Owner.FilledProjects.Any();

        protected bool HasHomePhoto => Owner.HomePhotoUrl.Length > 0;

        // The projects and skills prompts name how many the form has room for, so the two can't drift.
        protected static int ProjectSlots => ProfileRules.ProjectCount;

        protected int SkillSlots => Limits.Skills;

        protected string AgeText => Owner.Age == null
            ? ContentPage.UnsetText
            : Owner.Age.Value + (Owner.Age.Value == 1 ? " yr Old" : " yrs Old");

        // Written out in full ("April 16, 2006") rather than as the form's yyyy-MM-dd, and in a
        // fixed culture so the month name doesn't follow the server's locale.
        protected string BirthdateText => Owner.Birthdate == null
            ? ContentPage.UnsetText
            : Owner.Birthdate.Value.ToString("MMMM d, yyyy", CultureInfo.InvariantCulture);

        // The placeholder and the class that greys it go together: a field is shown as unset in
        // both or in neither.
        protected static string Or(string value)
        {
            return string.IsNullOrWhiteSpace(value) ? ContentPage.UnsetText : value.Trim();
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
