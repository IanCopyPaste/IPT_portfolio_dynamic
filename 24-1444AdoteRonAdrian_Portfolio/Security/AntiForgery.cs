using System;
using System.Security.Cryptography;
using System.Text;
using System.Web.SessionState;

namespace _24_1444AdoteRonAdrian_Portfolio.Security
{
    // A per-session token the admin dashboard sends with every request that changes something. The
    // session cookie alone would ride along on a request forged by another site; this token can only
    // be read by a page this site served.
    public static class AntiForgery
    {
        public const string HeaderName = "X-CSRF-Token";
        public const string FormField = "csrf";

        private const string SessionKey = "csrf_token";
        private const int TokenBytes = 32;

        public static string Token(HttpSessionState session)
        {
            string token = session[SessionKey] as string;

            if (token == null)
            {
                byte[] bytes = new byte[TokenBytes];
                using (var rng = new RNGCryptoServiceProvider())
                    rng.GetBytes(bytes);

                token = Convert.ToBase64String(bytes);
                session[SessionKey] = token;
            }

            return token;
        }

        public static bool IsValid(HttpSessionState session, string candidate)
        {
            string expected = session[SessionKey] as string;

            if (expected == null || candidate == null)
            {
                return false;
            }

            // Compared in constant time, like the password hash, so timing doesn't leak the token.
            byte[] a = Encoding.ASCII.GetBytes(expected);
            byte[] b = Encoding.ASCII.GetBytes(candidate);
            int diff = a.Length ^ b.Length;
            for (int i = 0; i < a.Length && i < b.Length; i++)
                diff |= a[i] ^ b[i];
            return diff == 0;
        }
    }
}
