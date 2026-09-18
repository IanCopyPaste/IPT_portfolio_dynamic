namespace _24_1444AdoteRonAdrian_Portfolio.Accounts
{
    // The values of users.status. The column's check constraint allows exactly these two, so anything
    // else coming in from a request is refused here before it reaches the database.
    public static class AccountStatus
    {
        public const string Active = "active";
        public const string Inactive = "inactive";

        public const string DeactivatedMessage = "this account has been deactivated.";

        public static bool IsValid(string value)
        {
            return value == Active || value == Inactive;
        }
    }
}
