<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ProfilePage.aspx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.ProfilePage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <%-- Same pre-paint flag as ContentPage: the reveal styles only hide what script can bring back. --%>
    <script>document.documentElement.className += " js";</script>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="robots" content="noindex" />
    <title>Profile - <%= SiteBrandName %></title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Anton&family=Share+Tech+Mono&display=swap" rel="stylesheet" />
    <%-- The same account form as the sign-up page, filled in, so it borrows that page's stylesheet
         (and, through it, the login page's); profilepage.css only adds the profile's own parts.
         reveal.css loads last so its hidden state wins. --%>
    <link href="/Assets/css/ContentPage/contentpage.css?v=20" rel="stylesheet" />
    <link href="/Assets/css/LoginPage/loginpage.css?v=4" rel="stylesheet" />
    <link href="/Assets/css/RegisterPage/registerpage.css?v=7" rel="stylesheet" />
    <link href="/Assets/css/ProfilePage/profilepage.css?v=4" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/reveal.css?v=3" rel="stylesheet" />
    <link href="/DEV_PHOTO.png" rel="icon" type="image/png" />
</head>
<body>
    <form id="form1" runat="server">
    <div>

        <nav class="navbar navbar--top" id="siteNavbar">
            <div class="navbar-inner">
                <a class="navbar-brand" href="ContentPage.aspx"><%= SiteBrandName %></a>
            </div>
        </nav>

        <main>
            <section id="profile" class="section login-section register-section">
                <div class="section-inner">
                    <%-- Error spans are Labels so profileSave_Click can report on a field as well as the script. --%>
                    <div class="login-panel register-panel reveal" data-reveal-delay="0">
                        <div class="terminal-bar" aria-hidden="true">
                            <span class="terminal-dot"></span>
                            <span class="terminal-dot"></span>
                            <span class="terminal-dot"></span>
                            <span class="terminal-path">~/portfolio/account --edit</span>
                        </div>
                        <div class="login-form register-form" id="profileForm" data-account-form="" data-prefix="prf"
                            data-submit="profileSave" data-status="profileStatus" data-password-optional=""
                            data-invalid-status="save failed. fix the highlighted fields and try again."
                            data-busy-label="Saving..." data-busy-status="saving changes for">
                            <div class="register-head">
                                <div>
                                    <p class="login-kicker">// account</p>
                                    <h1 class="login-title">Your profile</h1>
                                </div>
                                <p class="login-demo-note">Leave the password fields blank to keep your current password.</p>
                            </div>

                            <%-- The rail is built by profilepage.js from each step's data-step-label, so it
                                 only exists where the steps do. --%>
                            <div class="profile-steps" id="profileSteps" role="tablist" aria-label="Profile sections"></div>
                            <%-- Carries the open step through the post-back, so saving leaves the user
                                 where they were instead of back at the first step. A HiddenField
                                 rather than sessionStorage because it rides along with the form. --%>
                            <asp:HiddenField ID="profileStep" runat="server" ClientIDMode="Static" />

                            <section class="profile-step" data-step-label="You">
                                <div class="register-group" role="group" aria-labelledby="prfGroupName">
                                    <p class="register-group-label" id="prfGroupName">// name</p>
                                    <div class="register-fields register-fields--name">
                                        <div class="login-field">
                                            <label for="prfFirstName">First name</label>
                                            <asp:TextBox ID="prfFirstName" runat="server" ClientIDMode="Static"
                                                autocomplete="given-name" required="required" />
                                            <asp:Label ID="prfFirstNameError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfMiddleName">Middle name <span class="register-optional">optional</span></label>
                                            <asp:TextBox ID="prfMiddleName" runat="server" ClientIDMode="Static" autocomplete="additional-name" />
                                            <asp:Label ID="prfMiddleNameError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfLastName">Last name</label>
                                            <asp:TextBox ID="prfLastName" runat="server" ClientIDMode="Static"
                                                autocomplete="family-name" required="required" />
                                            <asp:Label ID="prfLastNameError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field register-select">
                                            <label for="prfSuffix">Suffix</label>
                                            <asp:DropDownList ID="prfSuffix" runat="server" ClientIDMode="Static" autocomplete="honorific-suffix" />
                                        </div>
                                    </div>
                                </div>

                                <div class="register-group" role="group" aria-labelledby="prfGroupContact">
                                    <p class="register-group-label" id="prfGroupContact">// contact</p>
                                    <div class="register-fields register-fields--contact">
                                        <div class="login-field">
                                            <label for="prfAddress">Address</label>
                                            <asp:TextBox ID="prfAddress" runat="server" ClientIDMode="Static"
                                                autocomplete="street-address" required="required" />
                                            <asp:Label ID="prfAddressError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfEmail">Email <span class="register-optional">optional</span></label>
                                            <asp:TextBox ID="prfEmail" runat="server" ClientIDMode="Static" TextMode="Email"
                                                autocomplete="email" placeholder="you@example.com" spellcheck="false" />
                                            <asp:Label ID="prfEmailError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfSms">Mobile <span class="register-optional">optional</span></label>
                                            <asp:TextBox ID="prfSms" runat="server" ClientIDMode="Static" TextMode="Phone"
                                                autocomplete="tel-national" inputmode="numeric" placeholder="09171234567" />
                                            <asp:Label ID="prfSmsError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                    </div>
                                </div>
                            </section>

                            <section class="profile-step" data-step-label="Background">
                                <%-- Everything from here to the account group is what ContentPage draws
                                     the portfolio from. All of it is optional: the page shows a
                                     placeholder for whatever is still blank, so a new account can fill
                                     it in over as many visits as it likes. --%>
                                <div class="register-group" role="group" aria-labelledby="prfGroupPersonal">
                                    <p class="register-group-label" id="prfGroupPersonal">// about</p>
                                    <div class="register-fields">
                                        <div class="login-field">
                                            <label for="prfBirthdate">Birthdate <span class="register-optional">optional</span></label>
                                            <%-- The age in the About panel is worked out from this, so it is not asked for twice. --%>
                                            <asp:TextBox ID="prfBirthdate" runat="server" ClientIDMode="Static" TextMode="Date" autocomplete="bday" />
                                            <asp:Label ID="prfBirthdateError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field register-select">
                                            <label for="prfSex">Sex</label>
                                            <asp:DropDownList ID="prfSex" runat="server" ClientIDMode="Static" autocomplete="sex" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfNationality">Nationality <span class="register-optional">optional</span></label>
                                            <asp:TextBox ID="prfNationality" runat="server" ClientIDMode="Static" placeholder="Filipino" />
                                            <asp:Label ID="prfNationalityError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                    </div>
                                </div>

                                <%-- Three stages, matching the rail ContentPage draws them on. --%>
                                <div class="register-group" role="group" aria-labelledby="prfGroupSchool">
                                    <p class="register-group-label" id="prfGroupSchool">// school</p>
                                    <div class="register-fields profile-fields--education">
                                        <div class="login-field">
                                            <label for="prfJhs">Junior high <span class="register-optional">optional</span></label>
                                            <asp:TextBox ID="prfJhs" runat="server" ClientIDMode="Static" placeholder="School name" />
                                            <asp:Label ID="prfJhsError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfShs">Senior high <span class="register-optional">optional</span></label>
                                            <asp:TextBox ID="prfShs" runat="server" ClientIDMode="Static" placeholder="School name" />
                                            <asp:Label ID="prfShsError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfCollege">College <span class="register-optional">optional</span></label>
                                            <asp:TextBox ID="prfCollege" runat="server" ClientIDMode="Static" placeholder="School name" />
                                            <asp:Label ID="prfCollegeError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfCourse">Course <span class="register-optional">optional</span></label>
                                            <asp:TextBox ID="prfCourse" runat="server" ClientIDMode="Static" placeholder="BSIT" />
                                            <asp:Label ID="prfCourseError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                    </div>
                                </div>
                            </section>

                            <section class="profile-step" data-step-label="Interests">
                                <%-- Four slots each, however many of them get used: ContentPage skips the
                                     blanks rather than leaving gaps in the row of chips. --%>
                                <div class="register-group" role="group" aria-labelledby="prfGroupHobbies">
                                    <p class="register-group-label" id="prfGroupHobbies">// hobbies</p>
                                    <div class="register-fields profile-fields--slots">
                                        <div class="login-field">
                                            <label for="prfHobby1">Hobby 1</label>
                                            <asp:TextBox ID="prfHobby1" runat="server" ClientIDMode="Static" placeholder="Travelling" />
                                            <asp:Label ID="prfHobby1Error" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfHobby2">Hobby 2</label>
                                            <asp:TextBox ID="prfHobby2" runat="server" ClientIDMode="Static" placeholder="Driving" />
                                            <asp:Label ID="prfHobby2Error" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfHobby3">Hobby 3</label>
                                            <asp:TextBox ID="prfHobby3" runat="server" ClientIDMode="Static" placeholder="Gaming" />
                                            <asp:Label ID="prfHobby3Error" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfHobby4">Hobby 4</label>
                                            <asp:TextBox ID="prfHobby4" runat="server" ClientIDMode="Static" placeholder="Reading" />
                                            <asp:Label ID="prfHobby4Error" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                    </div>
                                </div>

                                <div class="register-group" role="group" aria-labelledby="prfGroupSkills">
                                    <p class="register-group-label" id="prfGroupSkills">// skills</p>
                                    <div class="register-fields profile-fields--slots">
                                        <div class="login-field">
                                            <label for="prfSkill1">Skill 1</label>
                                            <asp:TextBox ID="prfSkill1" runat="server" ClientIDMode="Static" placeholder="Web design" />
                                            <asp:Label ID="prfSkill1Error" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfSkill2">Skill 2</label>
                                            <asp:TextBox ID="prfSkill2" runat="server" ClientIDMode="Static" placeholder="Databases" />
                                            <asp:Label ID="prfSkill2Error" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfSkill3">Skill 3</label>
                                            <asp:TextBox ID="prfSkill3" runat="server" ClientIDMode="Static" placeholder="Problem solving" />
                                            <asp:Label ID="prfSkill3Error" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfSkill4">Skill 4</label>
                                            <asp:TextBox ID="prfSkill4" runat="server" ClientIDMode="Static" placeholder="Teamwork" />
                                            <asp:Label ID="prfSkill4Error" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                    </div>
                                </div>
                            </section>

                            <section class="profile-step" data-step-label="Projects">
                                <%-- Listed best first: ContentPage numbers them in the order they are typed. --%>
                                <div class="register-group" role="group" aria-labelledby="prfGroupProjects">
                                    <p class="register-group-label" id="prfGroupProjects">// projects</p>
                                    <div class="register-fields profile-fields--projects">
                                        <div class="login-field">
                                            <label for="prfProject1">Project 1</label>
                                            <asp:TextBox ID="prfProject1" runat="server" ClientIDMode="Static" placeholder="Your best one" />
                                            <asp:Label ID="prfProject1Error" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfProject2">Project 2</label>
                                            <asp:TextBox ID="prfProject2" runat="server" ClientIDMode="Static" />
                                            <asp:Label ID="prfProject2Error" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfProject3">Project 3</label>
                                            <asp:TextBox ID="prfProject3" runat="server" ClientIDMode="Static" />
                                            <asp:Label ID="prfProject3Error" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfProject4">Project 4</label>
                                            <asp:TextBox ID="prfProject4" runat="server" ClientIDMode="Static" />
                                            <asp:Label ID="prfProject4Error" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfProject5">Project 5</label>
                                            <asp:TextBox ID="prfProject5" runat="server" ClientIDMode="Static" />
                                            <asp:Label ID="prfProject5Error" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                    </div>
                                </div>
                            </section>

                            <%-- The two portraits ContentPage draws. A step of their own: an upload
                                 is a different kind of answer from a text box, and the current
                                 image has to be shown beside the picker to be worth anything. --%>
                            <section class="profile-step" data-step-label="Photos">
                                <div class="register-group" role="group" aria-labelledby="prfGroupPhotos">
                                    <p class="register-group-label" id="prfGroupPhotos">// photos</p>
                                    <div class="register-fields profile-fields--photos">
                                        <div class="login-field">
                                            <label for="prfHomePhoto">Home portrait <span class="register-optional">optional</span></label>
                                            <p class="profile-photo-note">Left out of the home screen entirely until you set one.</p>
                                            <asp:Image ID="prfHomePreview" runat="server" ClientIDMode="Static" CssClass="profile-photo-preview" AlternateText="Your home portrait" />
                                            <asp:FileUpload ID="prfHomePhoto" runat="server" ClientIDMode="Static" CssClass="profile-file" />
                                            <asp:Label ID="prfHomePhotoError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfAboutPhoto">About portrait <span class="register-optional">optional</span></label>
                                            <p class="profile-photo-note">Shows a marked empty frame until you set one.</p>
                                            <asp:Image ID="prfAboutPreview" runat="server" ClientIDMode="Static" CssClass="profile-photo-preview" AlternateText="Your about portrait" />
                                            <asp:FileUpload ID="prfAboutPhoto" runat="server" ClientIDMode="Static" CssClass="profile-file" />
                                            <asp:Label ID="prfAboutPhotoError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                    </div>
                                </div>
                            </section>

                            <section class="profile-step" data-step-label="Account">
                                <%-- The current password is only asked for, and only checked, when a new one is typed. --%>
                                <div class="register-group" role="group" aria-labelledby="prfGroupAccount">
                                    <p class="register-group-label" id="prfGroupAccount">// account</p>
                                    <div class="register-fields profile-fields--account">
                                        <div class="login-field">
                                            <label for="prfUser">Username</label>
                                            <asp:TextBox ID="prfUser" runat="server" ClientIDMode="Static" autocomplete="username"
                                                required="required" autocapitalize="none" spellcheck="false" />
                                            <asp:Label ID="prfUserError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfCurrentPassword">Current password</label>
                                            <asp:TextBox ID="prfCurrentPassword" runat="server" ClientIDMode="Static" TextMode="Password"
                                                autocomplete="current-password" placeholder="Only to change it" />
                                            <asp:Label ID="prfCurrentPasswordError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfPassword">New password</label>
                                            <div class="login-password">
                                                <asp:TextBox ID="prfPassword" runat="server" ClientIDMode="Static" TextMode="Password"
                                                    autocomplete="new-password" placeholder="8+ characters" />
                                                <button type="button" class="login-reveal-btn" id="prfPasswordToggle"
                                                    aria-controls="prfCurrentPassword prfPassword prfConfirm" aria-pressed="false">Show</button>
                                            </div>
                                            <span class="login-hint" id="prfCapsHint" aria-live="polite"></span>
                                            <asp:Label ID="prfPasswordError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="prfConfirm">Confirm new</label>
                                            <asp:TextBox ID="prfConfirm" runat="server" ClientIDMode="Static" TextMode="Password"
                                                autocomplete="new-password" placeholder="Type it again" />
                                            <asp:Label ID="prfConfirmError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                    </div>
                                </div>
                            </section>

                            <%-- Hidden without script, where there are no steps to move between. --%>
                            <div class="profile-stepnav">
                                <button type="button" class="profile-stepbtn" id="profileBack">Back</button>
                                <span class="profile-stepcount" id="profileStepCount" role="status" aria-live="polite"></span>
                                <button type="button" class="profile-stepbtn profile-stepbtn--next" id="profileNext">Next</button>
                            </div>

                            <%-- Save comes first in the markup: pressing Enter in a field clicks the form's first
                                 submit button, and that must never be Log out. Log out skips the browser's
                                 required-field checks, since signing out shouldn't depend on the form. --%>
                            <div class="register-actions">
                                <asp:Button ID="profileSave" runat="server" ClientIDMode="Static" CssClass="login-submit"
                                    Text="Save changes" OnClick="profileSave_Click" />
                                <%-- Always rendered, even when empty: registerpage.js writes its validation messages here too. --%>
                                <asp:Label ID="profileStatus" runat="server" ClientIDMode="Static" CssClass="login-status"
                                    role="status" aria-live="polite" />
                                <div class="profile-links">
                                    <a class="profile-back" href="ContentPage.aspx">Back to portfolio</a>
                                    <asp:Button ID="profileLogout" runat="server" ClientIDMode="Static" CssClass="profile-logout"
                                        Text="Log out" OnClick="profileLogout_Click" formnovalidate="formnovalidate" />
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </section>
        </main>

    </div>
    </form>
    <%-- contentpage.js drives the navbar wash and the reveals; it skips the sections this page doesn't have. --%>
    <script src="/Assets/js/ContentPage/contentpage.js?v=6"></script>
    <script src="/Assets/js/RegisterPage/registerpage.js?v=7"></script>
    <%-- Loads after registerpage.js: it wraps that form in steps and hands it a way to bring
         a failed field back on screen. --%>
    <script src="/Assets/js/ProfilePage/profilepage.js?v=2"></script>
</body>
</html>
