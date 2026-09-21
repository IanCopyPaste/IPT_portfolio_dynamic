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
    <%-- Built on the login screen: its stylesheet supplies the panel, fields and button, and
         registerpage.css lays the longer form out to fit one screen. reveal.css loads last so its hidden state wins. --%>
    <link href="/Assets/css/ContentPage/contentpage.css?v=21" rel="stylesheet" />
    <link href="/Assets/css/LoginPage/loginpage.css?v=4" rel="stylesheet" />
    <link href="/Assets/css/RegisterPage/registerpage.css?v=7" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/reveal.css?v=4" rel="stylesheet" />
    <link href="/DEV_PHOTO.png" rel="icon" type="image/png" />
</head>
<body>
    <form id="form1" runat="server">
    <div>

        <main>
            <section id="register" class="section login-section register-section">
                <div class="section-inner">
                    <%-- The form alone, laid out wide in three rows, so the whole of it fits on one desktop screen.
                         One field per writable column of the users table; id and role are left to the database.
                         Error spans are Labels so registerSubmit_Click can report on a field as well as the script. --%>
                    <div class="login-panel register-panel reveal" data-reveal-delay="0">
                        <div class="terminal-bar" aria-hidden="true">
                            <span class="terminal-dot"></span>
                            <span class="terminal-dot"></span>
                            <span class="terminal-dot"></span>
                            <span class="terminal-path">~/portfolio/auth --register</span>
                        </div>
                        <div class="login-form register-form" id="registerForm" data-account-form="" data-prefix="reg"
                            data-submit="registerSubmit" data-status="registerStatus"
                            data-invalid-status="sign-up failed. fix the highlighted fields and try again."
                            data-busy-label="Creating account..." data-busy-status="writing record for">
                            <div class="register-head">
                                <div>
                                    <p class="login-kicker">// new account</p>
                                    <h1 class="login-title">Create account</h1>
                                </div>
                                <p class="login-demo-note">Fields marked optional can be left blank.</p>
                            </div>

                            <div class="register-group" role="group" aria-labelledby="regGroupName">
                                <p class="register-group-label" id="regGroupName">// name</p>
                                <div class="register-fields register-fields--name">
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
                                    <div class="login-field">
                                        <label for="regLastName">Last name</label>
                                        <asp:TextBox ID="regLastName" runat="server" ClientIDMode="Static"
                                            autocomplete="family-name" placeholder="Dela Cruz" required="required" />
                                        <asp:Label ID="regLastNameError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                    </div>
                                    <%-- Options are filled from the code-behind, which also checks the posted value against them.
                                         No "optional" tag: the list starts at None, and the tag wouldn't fit the narrow column. --%>
                                    <div class="login-field register-select">
                                        <label for="regSuffix">Suffix</label>
                                        <asp:DropDownList ID="regSuffix" runat="server" ClientIDMode="Static" autocomplete="honorific-suffix" />
                                    </div>
                                </div>
                            </div>

                            <div class="register-group" role="group" aria-labelledby="regGroupContact">
                                <p class="register-group-label" id="regGroupContact">// contact</p>
                                <div class="register-fields register-fields--contact">
                                    <div class="login-field">
                                        <label for="regAddress">Address</label>
                                        <asp:TextBox ID="regAddress" runat="server" ClientIDMode="Static"
                                            autocomplete="street-address" placeholder="Street, barangay, city" required="required" />
                                        <asp:Label ID="regAddressError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                    </div>
                                    <div class="login-field">
                                        <label for="regEmail">Email <span class="register-optional">optional</span></label>
                                        <asp:TextBox ID="regEmail" runat="server" ClientIDMode="Static" TextMode="Email"
                                            autocomplete="email" placeholder="you@example.com" spellcheck="false" />
                                        <asp:Label ID="regEmailError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                    </div>
                                    <div class="login-field">
                                        <label for="regSms">Mobile <span class="register-optional">optional</span></label>
                                        <asp:TextBox ID="regSms" runat="server" ClientIDMode="Static" TextMode="Phone"
                                            autocomplete="tel-national" inputmode="numeric" placeholder="09171234567" />
                                        <asp:Label ID="regSmsError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                    </div>
                                </div>
                            </div>

                            <div class="register-group" role="group" aria-labelledby="regGroupAccount">
                                <p class="register-group-label" id="regGroupAccount">// account</p>
                                <div class="register-fields">
                                    <div class="login-field">
                                        <label for="regUser">Username</label>
                                        <asp:TextBox ID="regUser" runat="server" ClientIDMode="Static" autocomplete="username"
                                            placeholder="juan.delacruz" required="required" autocapitalize="none" spellcheck="false" />
                                        <asp:Label ID="regUserError" runat="server" ClientIDMode="Static" CssClass="login-error" aria-live="polite" />
                                    </div>
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
                            </div>

                            <div class="register-actions">
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
                </div>
            </section>
        </main>

    </div>
    </form>
    <%-- contentpage.js drives the navbar wash and the reveals; it skips the sections this page doesn't have. --%>
    <script src="/Assets/js/ContentPage/contentpage.js?v=6"></script>
    <script src="/Assets/js/RegisterPage/registerpage.js?v=11"></script>
</body>
</html>
