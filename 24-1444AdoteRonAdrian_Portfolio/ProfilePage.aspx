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
    <link href="/Assets/css/ContentPage/contentpage.css?v=19" rel="stylesheet" />
    <link href="/Assets/css/LoginPage/loginpage.css?v=4" rel="stylesheet" />
    <link href="/Assets/css/RegisterPage/registerpage.css?v=7" rel="stylesheet" />
    <link href="/Assets/css/ProfilePage/profilepage.css?v=1" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/reveal.css?v=3" rel="stylesheet" />
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
    <script src="/Assets/js/RegisterPage/registerpage.js?v=5"></script>
</body>
</html>
