using System.Linq;
using System.Web.SessionState;

namespace _24_1444AdoteRonAdrian_Portfolio.Security
{
    // The signed-in user's session values. LoginPage and RegisterPage both sign people in through
    // here, so they can't store the values differently, and ContentPage reads the keys they write.
    public static class UserSession
    {
        public const string UserIdKey = "user_id";
        public const string UsernameKey = "username";
        public const string FullNameKey = "full_name";
        public const string RoleKey = "role";

        // The value of users.role that the admin sign-in accepts. New accounts default to 'user'.
        public const string AdminRole = "admin";

        // The full name is built once at sign-in, so pages that show it don't each query the database.
        public static void SignIn(HttpSessionState session, int userId, string username, string fullName,
            string role = null)
        {
            session[UserIdKey] = userId;
            session[UsernameKey] = username;
            session[FullNameKey] = fullName;
            session[RoleKey] = role;
        }

        // Only the admin sign-in records a role, so an admin who came in through LoginPage is treated
        // as an ordinary user until they sign in through Admin.aspx.
        public static bool IsAdmin(HttpSessionState session)
        {
            return string.Equals(session[RoleKey] as string, AdminRole, System.StringComparison.OrdinalIgnoreCase);
        }

        public static bool IsSignedIn(HttpSessionState session)
        {
            return session[UserIdKey] != null || session[UsernameKey] != null;
        }

        // Null when the session doesn't hold an id, which a page that reads or writes the user's
        // own row has to treat as signed out.
        public static int? UserId(HttpSessionState session)
        {
            return session[UserIdKey] as int?;
        }

        // Abandon alone only takes effect at the end of the request, so the values are cleared too
        // and nothing later in this request still sees the user as signed in.
        public static void SignOut(HttpSessionState session)
        {
            session.Clear();
            session.Abandon();
        }

        // "Juan Santos Dela Cruz Jr." Missing parts (no middle name, no suffix) are skipped, so they
        // don't leave doubled spaces behind.
        public static string FullName(string first, string middle, string last, string suffix)
        {
            return string.Join(" ", new[] { first, middle, last, suffix }
                .Where(part => !string.IsNullOrWhiteSpace(part))
                .Select(part => part.Trim()));
        }
    }
}
