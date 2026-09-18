<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="Admin.aspx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Admin" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="robots" content="noindex, nofollow" />
    <title>Admin sign in - <%= AdminConsoleName %></title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <%-- Deliberately shares nothing with the portfolio's stylesheets: the admin side is a separate,
         plain business interface, not part of the terminal look. --%>
    <link href="/Assets/css/Admin/tokens.css?v=1" rel="stylesheet" />
    <link href="/Assets/css/Admin/forms.css?v=1" rel="stylesheet" />
    <link href="/Assets/css/Admin/admin.css?v=6" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
    <%-- The grid lives on this wrapper, not the form: ASP.NET injects hidden-field divs into the
         form, and they would each claim a grid row. --%>
    <div class="adm-page">

        <header class="adm-topbar">
            <div class="adm-brand">
                <span class="adm-logo" aria-hidden="true"><%= BrandInitials %></span>
                <span class="adm-brand-name"><%= AdminConsoleName %></span>
            </div>
        </header>

        <main class="adm-main">
            <div class="adm-card">
                <div class="adm-card-head">
                    <span class="adm-badge">
                        <svg viewBox="0 0 24 24" width="14" height="14" aria-hidden="true" focusable="false">
                            <path fill="currentColor" d="M12 1 3 5v6c0 5.55 3.84 10.74 9 12 5.16-1.26 9-6.45 9-12V5l-9-4Zm0 10.99h7c-.53 4.12-3.28 7.79-7 8.94V12H5V6.3l7-3.11v8.8Z" />
                        </svg>
                        Administrator access
                    </span>
                    <h1 class="adm-title">Sign in to the console</h1>
                    <p class="adm-subtitle">Enter your administrator credentials to continue.</p>
                </div>

                <%-- Written by the server on a failed sign-in and by admin.js on a failed client check,
                     so it is always rendered and simply hidden while empty. --%>
                <asp:Label ID="adminStatus" runat="server" ClientIDMode="Static" CssClass="adm-alert"
                    role="alert" aria-live="assertive" />

                <%-- ClientIDMode="Static" keeps the ids admin.js looks for. --%>
                <div class="adm-field">
                    <label class="adm-label" for="adminUser">Username</label>
                    <asp:TextBox ID="adminUser" runat="server" ClientIDMode="Static" CssClass="adm-input"
                        autocomplete="username" MaxLength="40" required="required"
                        autocapitalize="none" spellcheck="false" />
                    <span class="adm-error" id="adminUserError" aria-live="polite"></span>
                </div>

                <div class="adm-field">
                    <label class="adm-label" for="adminPassword">Password</label>
                    <div class="adm-password">
                        <asp:TextBox ID="adminPassword" runat="server" ClientIDMode="Static" CssClass="adm-input"
                            TextMode="Password" autocomplete="current-password" MaxLength="64" required="required" />
                        <button type="button" class="adm-toggle" id="adminPasswordToggle"
                            aria-controls="adminPassword" aria-pressed="false">Show</button>
                    </div>
                    <span class="adm-hint" id="adminCapsHint" aria-live="polite"></span>
                    <span class="adm-error" id="adminPasswordError" aria-live="polite"></span>
                </div>

                <asp:Button ID="adminSubmit" runat="server" ClientIDMode="Static" CssClass="adm-submit"
                    Text="Sign in" OnClick="adminSubmit_Click" />

                <p class="adm-notice">
                    This area is restricted to authorised administrators. Visitors should use the
                    <a href="LoginPage.aspx">regular sign-in</a>.
                </p>
            </div>
        </main>

        <footer class="adm-footer">
            <a href="LoginPage.aspx">&larr; Back to the portfolio</a>
            <span>&copy; <%= DateTime.Today.Year %> <%= SiteBrandName %></span>
        </footer>

    </div>
    </form>
    <script src="/Assets/js/Admin/admin.js?v=2"></script>
</body>
</html>
