using _24_1444AdoteRonAdrian_Portfolio.Security;
using System;
using System.Collections.Generic;
using System.Linq;

namespace _24_1444AdoteRonAdrian_Portfolio.Accounts
{
    // One account's portfolio: the parts of the users row ContentPage puts on the page, and all of
    // its user_profile row. The repeated fields are arrays rather than a property each, so the page
    // and the form can loop over them; a slot the user left blank is "", never null, and the page
    // skips it.
    public class ProfileContent
    {
        public ProfileContent()
        {
            Hobbies = Slots(ProfileRules.HobbyCount);
            Skills = Slots(ProfileRules.SkillCount);
            Projects = Slots(ProfileRules.ProjectCount);
            FirstName = "";
            MiddleName = "";
            LastName = "";
            Suffix = "";
            Address = "";
            Sex = "";
            HomePhoto = "";
            AboutPhoto = "";
            Nationality = "";
            JhsSchool = "";
            ShsSchool = "";
            CollegeSchool = "";
            CollegeCourse = "";
        }

        // From the users row, so the page shows the name and address as they are now rather than as
        // the session recorded them at sign-in.
        public string FirstName { get; set; }
        public string MiddleName { get; set; }
        public string LastName { get; set; }
        public string Suffix { get; set; }
        public string Address { get; set; }

        public DateTime? Birthdate { get; set; }
        public string Sex { get; set; }
        public string Nationality { get; set; }

        public string JhsSchool { get; set; }
        public string ShsSchool { get; set; }
        public string CollegeSchool { get; set; }
        public string CollegeCourse { get; set; }

        public string[] Hobbies { get; private set; }
        public string[] Skills { get; private set; }
        public string[] Projects { get; private set; }

        // Paths under the uploads folder, "" until the user has uploaded one. ContentPage leaves
        // the home portrait out entirely when it is empty and shows a marked box in the About
        // section, so the two sections read differently on purpose.
        public string HomePhoto { get; set; }

        public string AboutPhoto { get; set; }

        public string HomePhotoUrl
        {
            get { return ProfilePhotos.Url(HomePhoto); }
        }

        public string AboutPhotoUrl
        {
            get { return ProfilePhotos.Url(AboutPhoto); }
        }

        public string FullName
        {
            get { return UserSession.FullName(FirstName, MiddleName, LastName, Suffix); }
        }

        // Null until a birthdate is saved, which is what an unfilled profile shows a placeholder
        // for. Counted off the calendar date rather than the day of the year, so a leap day between
        // the two doesn't shift the birthday by one.
        public int? Age
        {
            get
            {
                if (Birthdate == null)
                {
                    return null;
                }

                DateTime birth = Birthdate.Value.Date;
                DateTime today = DateTime.Today;
                int age = today.Year - birth.Year;

                if (birth.AddYears(age) > today)
                {
                    age--;
                }

                return age < 0 ? (int?)null : age;
            }
        }

        public IEnumerable<string> FilledHobbies
        {
            get { return Filled(Hobbies); }
        }

        public IEnumerable<string> FilledSkills
        {
            get { return Filled(Skills); }
        }

        public IEnumerable<string> FilledProjects
        {
            get { return Filled(Projects); }
        }

        // Blank slots are dropped rather than rendered empty, so four hobby inputs with two filled
        // in give two chips instead of two chips and two gaps.
        private static IEnumerable<string> Filled(string[] slots)
        {
            return slots.Where(value => !string.IsNullOrWhiteSpace(value)).Select(value => value.Trim());
        }

        private static string[] Slots(int count)
        {
            return Enumerable.Repeat("", count).ToArray();
        }
    }
}
