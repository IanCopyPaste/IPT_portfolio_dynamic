<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="RegisterPage.aspx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.RegisterPage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <%-- Same pre-paint flag as ContentPage: the reveal styles only hide what script can bring back. --%>
    <script>document.documentElement.className += " js";</script>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Sign up - <%= SiteBrandName %></title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Anton&family=Share+Tech+Mono&display=swap" rel="stylesheet" />
    <%-- Built on the login screen: its stylesheet supplies the layout, panel, fields and button, and
         registerpage.css only adds what the longer form needs. reveal.css loads last so its hidden state wins. --%>
    <link href="/Assets/css/ContentPage/contentpage.css?v=17" rel="stylesheet" />
    <link href="/Assets/css/LoginPage/loginpage.css?v=4" rel="stylesheet" />
    <link href="/Assets/css/RegisterPage/registerpage.css?v=2" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/reveal.css?v=2" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
    <div>

        <nav class="navbar navbar--top" id="siteNavbar">
            <div class="navbar-inner">
                <a class="navbar-brand" href="LoginPage.aspx"><%= SiteBrandName %></a>
            </div>
        </nav>

        <main>
            <section id="register" class="section login-section">
                <div class="section-inner">
                    <div class="login-layout register-layout">
                        <div class="login-intro">
                            <p class="login-kicker reveal" data-reveal-delay="0">// new account</p>
                            <div class="login-heading-wrap reveal" data-text="Create account" data-reveal-delay="100">
                                <h1 class="login-heading">Create account</h1>
                            </div>
                            <p class="login-intro-copy reveal" data-reveal-delay="200">
                                Set up an account to open the portfolio. You'll be signed in as soon as it's created.
                            </p>
                            <ul class="login-log" aria-hidden="true">
                                <li class="reveal" data-reveal-delay="320">allocating user record <span class="login-log-ok">[ ok ]</span></li>
                                <li class="reveal" data-reveal-delay="420">default role: user <span class="login-log-ok">[ ok ]</span></li>
                                <li class="reveal" data-reveal-delay="520">awaiting details<span class="login-cursor"></span></li>
                            </ul>
                        </div>

                        <%-- One field per writable column of the users table; id and role are left to the database.
                             Error spans are Labels so registerSubmit_Click can report on a field as well as the script. --%>
                        <div class="login-panel reveal" data-reveal-delay="260">
                            <div class="terminal-bar" aria-hidden="true">
                                <span class="terminal-dot"></span>
                                <span class="terminal-dot"></span>
                                <span class="terminal-dot"></span>
                                <span class="terminal-path">~/portfolio/auth --register</span>
                            </div>
                            <div class="login-form" id="registerForm">
                                <div class="login-form-head">
                                    <h2 class="login-title">Sign up</h2>
                                    <p class="login-demo-note">Fields marked optional can be left blank.</p>
                                </div>

                                <fieldset class="register-group">
                                    <legend class="register-group-label">// personal</legend>
                                    <div class="register-row">
                                        <div class="login-field">
                                            <label for="regFirstName">First name</label>
                                            <asp:TextBox ID="regFirstName" runat="server" ClientIDMode="Static"
                                                autocomplete="given-name" placeholder="Juan" required="required" />
                                            <asp:Label ID="regFirstNameError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="regMiddleName">Middle name <span class="register-optional">optional</span></label>
                                            <asp:TextBox ID="regMiddleName" runat="server" ClientIDMode="Static"
                                                autocomplete="additional-name" placeholder="Santos" />
                                            <asp:Label ID="regMiddleNameError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                    </div>
                                    <div class="register-row register-row--suffix">
                                        <div class="login-field">
                                            <label for="regLastName">Last name</label>
                                            <asp:TextBox ID="regLastName" runat="server" ClientIDMode="Static"
                                                autocomplete="family-name" placeholder="Dela Cruz" required="required" />
                                            <asp:Label ID="regLastNameError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <%-- Options are filled from the code-behind, which also checks the posted value against them. --%>
                                        <div class="login-field register-select">
                                            <label for="regSuffix">Suffix <span class="register-optional">optional</span></label>
                                            <asp:DropDownList ID="regSuffix" runat="server" ClientIDMode="Static" autocomplete="honorific-suffix" />
                                        </div>
                                    </div>
                                    <div class="login-field">
                                        <label for="regAddress">Address</label>
                                        <asp:TextBox ID="regAddress" runat="server" ClientIDMode="Static" TextMode="MultiLine" Rows="2"
                                            autocomplete="street-address" placeholder="Street, barangay, city" required="required" />
                                        <asp:Label ID="regAddressError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                    </div>
                                </fieldset>

                                <fieldset class="register-group">
                                    <legend class="register-group-label">// contact</legend>
                                    <div class="register-row">
                                        <div class="login-field">
                                            <label for="regEmail">Email <span class="register-optional">optional</span></label>
                                            <asp:TextBox ID="regEmail" runat="server" ClientIDMode="Static" TextMode="Email"
                                                autocomplete="email" placeholder="you@example.com" spellcheck="false" />
                                            <asp:Label ID="regEmailError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="regSms">Mobile number <span class="register-optional">optional</span></label>
                                            <asp:TextBox ID="regSms" runat="server" ClientIDMode="Static" TextMode="Phone"
                                                autocomplete="tel-national" inputmode="numeric" placeholder="09171234567" />
                                            <asp:Label ID="regSmsError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                    </div>
                                </fieldset>

                                <fieldset class="register-group">
                                    <legend class="register-group-label">// account</legend>
                                    <div class="login-field">
                                        <label for="regUser">Username</label>
                                        <asp:TextBox ID="regUser" runat="server" ClientIDMode="Static" autocomplete="username"
                                            placeholder="juan.delacruz" required="required" autocapitalize="none" spellcheck="false" />
                                        <asp:Label ID="regUserError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                    </div>
                                    <div class="register-row">
                                        <div class="login-field">
                                            <label for="regPassword">Password</label>
                                            <div class="login-password">
                                                <asp:TextBox ID="regPassword" runat="server" ClientIDMode="Static" TextMode="Password"
                                                    autocomplete="new-password" placeholder="8+ characters" required="required" />
                                                <button type="button" class="login-reveal-btn" id="regPasswordToggle"
                                                    aria-controls="regPassword regConfirm" aria-pressed="false">Show</button>
                                            </div>
                                            <span class="login-hint" id="regCapsHint" aria-live="polite"></span>
                                            <asp:Label ID="regPasswordError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                        <div class="login-field">
                                            <label for="regConfirm">Confirm password</label>
                                            <asp:TextBox ID="regConfirm" runat="server" ClientIDMode="Static" TextMode="Password"
                                                autocomplete="new-password" placeholder="Type it again" required="required" />
                                            <asp:Label ID="regConfirmError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                        </div>
                                    </div>
                                </fieldset>

                                <asp:Button ID="registerSubmit" runat="server" ClientIDMode="Static" CssClass="login-submit"
                                    Text="Create account" OnClick="registerSubmit_Click" />
                                <%-- Always rendered, even when empty: registerpage.js writes its validation messages here too. --%>
                                <asp:Label ID="registerStatus" runat="server" ClientIDMode="Static" CssClass="login-status"
                                    role="status" aria-live="polite" />
                                <p class="login-signup">
                                    Already have an account? <a href="LoginPage.aspx">Log in</a>
                                </p>
                            </div>
                        </div>
                    </div>

                    <p class="login-footnote reveal" data-reveal-delay="620">
                        &copy; <%= DateTime.Today.Year %> <%= SiteBrandName %> &middot;
                        <a href="LoginPage.aspx">Back to log in</a>
                    </p>
                </div>
            </section>
        </main>

    </div>
    </form>
    <%-- contentpage.js drives the navbar wash and the reveals; it skips the sections this page doesn't have. --%>
    <script src="/Assets/js/ContentPage/contentpage.js?v=5"></script>
    <script src="/Assets/js/RegisterPage/registerpage.js?v=1"></script>
</body>
</html>
