namespace _24_1444AdoteRonAdrian_Portfolio.AdminApi
{
    // The JSON body of the endpoints that act on one account.
    public class UserRequest
    {
        // One message for "gone" and "an admin's": either way there is nothing the dashboard may change.
        public const string NotFoundMessage = "That account no longer exists or can't be changed.";

        public int Id { get; set; }
        public string Status { get; set; }
    }
}
