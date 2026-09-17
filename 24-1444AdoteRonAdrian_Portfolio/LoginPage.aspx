<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="LoginPage.aspx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.LoginPage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <%-- Same pre-paint flag as ContentPage: the reveal styles only hide what script can bring back. --%>
    <script>document.documentElement.className += " js";</script>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title>Sign in - <%= SiteBrandName %></title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Anton&family=Share+Tech+Mono&display=swap" rel="stylesheet" />
    <%-- The portfolio's tokens, base, navbar and terminal bar are reused rather than copied, so the
         two pages can't drift apart. reveal.css loads after the login rules so its hidden state wins. --%>
    <link href="/Assets/css/ContentPage/contentpage.css?v=16" rel="stylesheet" />
    <link href="/Assets/css/LoginPage/loginpage.css?v=3" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/reveal.css?v=2" rel="stylesheet" />
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
            <section id="login" class="section login-section">
                <div class="section-inner">
                    <div class="login-layout">
                        <%-- Everything is in view on load, so the delays stage a heading → log → panel sequence. --%>
                        <div class="login-intro">
                            <p class="login-kicker reveal" data-reveal-delay="0">// restricted area</p>
                            <%-- The glitch layers sit on the wrapper, not the heading: the heading's gradient is a
                                 background-clip fill, which would swallow pseudo-element text drawn inside it. --%>
                            <div class="login-heading-wrap reveal" data-text="Welcome back" data-reveal-delay="100">
                                <h1 class="login-heading">Welcome back</h1>
                            </div>
                            <p class="login-intro-copy reveal" data-reveal-delay="200">
                                Log in to pick up where you left off. The portfolio is only open to signed-in
                                accounts.
                            </p>
                            <ul class="login-log" aria-hidden="true">
                                <li class="reveal" data-reveal-delay="320">establishing secure channel <span class="login-log-ok">[ ok ]</span></li>
                                <li class="reveal" data-reveal-delay="420">loading profile: <%= SiteBrandName %> <span class="login-log-ok">[ ok ]</span></li>
                                <li class="reveal" data-reveal-delay="520">awaiting credentials<span class="login-cursor"></span></li>
                            </ul>
                        </div>

                        <%-- Server controls so loginSubmit_Click can read them; ClientIDMode="Static" keeps the ids
                             the CSS and loginpage.js look for. The script validates and only then lets the post back through. --%>
                        <div class="login-panel reveal" data-reveal-delay="260">
                            <div class="terminal-bar" aria-hidden="true">
                                <span class="terminal-dot"></span>
                                <span class="terminal-dot"></span>
                                <span class="terminal-dot"></span>
                                <span class="terminal-path">~/portfolio/auth --login</span>
                            </div>
                            <div class="login-form" id="loginForm" runat="server">
                                <div class="login-form-head">
                                    <h2 class="login-title">Log in</h2>
                                    <p class="login-demo-note">&nbsp;</p>
                                </div>

                                <div class="login-field">
                                    <label for="loginUser">Username</label>
                                    <asp:TextBox ID="loginUser" runat="server" ClientIDMode="Static" autocomplete="username"
                                        placeholder="juan.delacruz" MaxLength="40" required="required"
                                        autocapitalize="none" spellcheck="false" />
                                    <span class="login-error" id="loginUserError" aria-live="polite"></span>
                                </div>

                                <div class="login-field">
                                    <label for="loginPassword">Password</label>
                                    <div class="login-password">
                                        <asp:TextBox ID="loginPassword" runat="server" ClientIDMode="Static" TextMode="Password"
                                            autocomplete="current-password" placeholder="&bull;&bull;&bull;&bull;&bull;&bull;&bull;&bull;"
                                            MaxLength="64" required="required" />
                                        <button type="button" class="login-reveal-btn" id="loginPasswordToggle"
                                            aria-controls="loginPassword" aria-pressed="false">Show</button>
                                    </div>
                                    <span class="login-hint" id="loginCapsHint" aria-live="polite"></span>
                                    <span class="login-error" id="loginPasswordError" aria-live="polite"></span>
                                </div>

                                <div class="login-options">
                                    <label class="login-check" for="loginRemember">
                                    </label>
                                </div>

                                <asp:Button ID="loginSubmit" runat="server" ClientIDMode="Static" CssClass="login-submit"
                                    Text="Log in" OnClick="loginSubmit_Click" />
                                <%-- Always rendered, even when empty: loginpage.js writes its validation messages here too. --%>
                                <asp:Label ID="loginStatus" runat="server" ClientIDMode="Static" CssClass="login-status"
                                    role="status" aria-live="polite" />
                                <p class="login-signup">
                                    Don't have an account? <a href="RegisterPage.aspx">Sign up</a>
                                </p>
                            </div>
                        </div>
                    </div>

                    <p class="login-footnote reveal" data-reveal-delay="620">
                        &copy; <%= DateTime.Today.Year %> <%= SiteBrandName %> &middot;
                        <a href="ContentPage.aspx">Just browsing? View the portfolio</a>
                    </p>
                </div>
            </section>
        </main>

    </div>
    </form>
    <%-- contentpage.js drives the navbar wash and the reveals; it skips the sections this page doesn't have. --%>
    <script src="/Assets/js/ContentPage/contentpage.js?v=5"></script>
    <script src="/Assets/js/LoginPage/loginpage.js?v=2"></script>
</body>
</html>
