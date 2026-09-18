using _24_1444AdoteRonAdrian_Portfolio.Accounts;
using _24_1444AdoteRonAdrian_Portfolio.Security;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminServices
{
    // The signed-in admin changing their own password from Settings. The rules are AccountRules', the
    // same ones the portfolio's profile page applies.
    public static class AdminPassword
    {
        // Field name -> message for each field that failed; empty when the password was changed. The
        // keys are the JSON names the settings form uses.
        public static Dictionary<string, string> Change(int adminId, string current, string next, string confirm)
        {
            var errors = new Dictionary<string, string>();
            current = current ?? "";
            next = next ?? "";
            confirm = confirm ?? "";

            AddIf(errors, "currentPassword", current.Length == 0 ? AccountRules.RequiredMessage : null);
            AddIf(errors, "newPassword", AccountRules.PasswordError(next));
            AddIf(errors, "confirmPassword", AccountRules.ConfirmError(confirm, next));

            if (errors.Count > 0)
            {
                return errors;
            }

            if (next == current)
            {
                errors["newPassword"] = "Choose a password different from the current one.";
                return errors;
            }

            using (SqlConnection conn = Db.Open())
            {
                string storedHash;

                using (var read = new SqlCommand("SELECT password_hash FROM users WHERE id = @id AND role = @admin", conn))
                {
                    read.Parameters.Add("@id", SqlDbType.Int).Value = adminId;
                    Db.AddAdminRole(read);
                    storedHash = read.ExecuteScalar() as string;
                }

                if (storedHash == null || !PasswordHasher.Verify(current, storedHash))
                {
                    errors["currentPassword"] = "That isn't your current password.";
                    return errors;
                }

                using (var write = new SqlCommand("UPDATE users SET password_hash = @hash WHERE id = @id AND role = @admin", conn))
                {
                    write.Parameters.Add("@hash", SqlDbType.VarChar, AccountRules.PasswordHashMaxLength).Value = PasswordHasher.Hash(next);
                    write.Parameters.Add("@id", SqlDbType.Int).Value = adminId;
                    Db.AddAdminRole(write);
                    write.ExecuteNonQuery();
                }
            }

            return errors;
        }

        private static void AddIf(Dictionary<string, string> errors, string field, string message)
        {
            if (message != null)
            {
                errors[field] = message;
            }
        }
    }
}
