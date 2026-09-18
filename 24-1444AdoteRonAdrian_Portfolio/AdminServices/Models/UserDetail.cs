namespace _24_1444AdoteRonAdrian_Portfolio.AdminServices.Models
{
    // Everything the Manage dialog shows. The password hash is deliberately not part of it.
    public class UserDetail : UserSummary
    {
        public string FirstName { get; set; }
        public string MiddleName { get; set; }
        public string LastName { get; set; }
        public string Suffix { get; set; }
        public string Address { get; set; }
        public string Sms { get; set; }
    }
}
