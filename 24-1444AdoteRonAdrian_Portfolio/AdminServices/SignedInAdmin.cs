using _24_1444AdoteRonAdrian_Portfolio.Security;
using System.Linq;
using System.Text.RegularExpressions;
using System.Web.SessionState;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminServices
{
    // The signed-in admin as the dashboard's components show them, read from the session that
    // Admin.aspx filled in, so rendering the page costs no database query.
    public class SignedInAdmin
    {
        public string Username { get; private set; }
        public string FullName { get; private set; }

        // The full name, or the username for an account that has no name parts.
        public string DisplayName
        {
            get { return string.IsNullOrWhiteSpace(FullName) ? Username : FullName; }
        }

        // A name suffix isn't a surname, so it never gives an initial. format.js skips the same words.
        private static readonly Regex Suffix = new Regex(@"^(jr\.?|sr\.?|ii|iii|iv|v)$", RegexOptions.IgnoreCase);

        // "JD" from "Juan Dela Cruz Jr.": the first letters of the first and last words.
        public string Initials
        {
            get
            {
                string[] words = (DisplayName ?? "").Split(new[] { ' ' }, System.StringSplitOptions.RemoveEmptyEntries)
                    .Where(word => !Suffix.IsMatch(word)).ToArray();

                if (words.Length == 0)
                {
                    return "?";
                }

                string first = words[0].Substring(0, 1);
                return (words.Length == 1 ? first : first + words.Last().Substring(0, 1)).ToUpperInvariant();
            }
        }

        public static SignedInAdmin From(HttpSessionState session)
        {
            return new SignedInAdmin
            {
                Username = session[UserSession.UsernameKey] as string ?? "",
                FullName = session[UserSession.FullNameKey] as string
            };
        }
    }
}
