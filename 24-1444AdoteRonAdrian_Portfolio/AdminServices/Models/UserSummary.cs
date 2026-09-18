using System;

namespace _24_1444AdoteRonAdrian_Portfolio.AdminServices.Models
{
    // One row of the users table on the dashboard.
    public class UserSummary
    {
        public int Id { get; set; }
        public string FullName { get; set; }
        public string Username { get; set; }
        public string Email { get; set; }
        public string Role { get; set; }
        public string Status { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLoginAt { get; set; }

        // Administrator rows are listed but can't be deactivated or deleted from the dashboard, so
        // an admin can't lock themselves or another admin out. The client greys the actions out on
        // this flag; the server enforces it regardless.
        public bool IsProtected { get; set; }
    }
}
