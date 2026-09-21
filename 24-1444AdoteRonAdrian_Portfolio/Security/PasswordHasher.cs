using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Security.Cryptography;

namespace _24_1444AdoteRonAdrian_Portfolio.Security
{
    public static class PasswordHasher
    {
        private const int SaltSize = 16;
        private const int HashSize = 32;
        private const int Iterations = 100000;

        public static string Hash(string password)
        {
            byte[] salt = new byte[SaltSize];
            using (var rng = new RNGCryptoServiceProvider())
                rng.GetBytes(salt);

            byte[] hash;
            using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, Iterations, HashAlgorithmName.SHA256))
                hash = pbkdf2.GetBytes(HashSize);

            return Iterations + "." + Convert.ToBase64String(salt) + "." + Convert.ToBase64String(hash);
        }

        // A stored value that isn't in Hash's format (hand-edited, truncated, or blank) is a failed
        // check rather than an exception, so a damaged row can't take a sign-in page down with it.
        public static bool Verify(string password, string stored)
        {
            if (password == null || string.IsNullOrEmpty(stored)) return false;

            var parts = stored.Split('.');
            if (parts.Length != 3) return false;

            int iterations;
            byte[] salt;
            byte[] expected;

            if (!int.TryParse(parts[0], out iterations) || iterations <= 0) return false;

            try
            {
                salt = Convert.FromBase64String(parts[1]);
                expected = Convert.FromBase64String(parts[2]);
            }
            catch (FormatException)
            {
                return false;
            }

            // Rfc2898DeriveBytes refuses a salt under 8 bytes.
            if (salt.Length < 8 || expected.Length == 0) return false;

            byte[] actual;
            using (var pbkdf2 = new Rfc2898DeriveBytes(password, salt, iterations, HashAlgorithmName.SHA256))
                actual = pbkdf2.GetBytes(expected.Length);

            int diff = 0;
            for (int i = 0; i < expected.Length; i++)
                diff |= actual[i] ^ expected[i];
            return diff == 0;
        }
    }
}