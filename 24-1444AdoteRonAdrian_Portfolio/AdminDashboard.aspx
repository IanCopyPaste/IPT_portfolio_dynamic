<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="AdminDashboard.aspx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.AdminDashboard" %>
<%@ Register TagPrefix="dash" TagName="Sidebar" Src="~/Components/Dashboard/Layout/Sidebar.ascx" %>
<%@ Register TagPrefix="dash" TagName="Header" Src="~/Components/Dashboard/Layout/Header.ascx" %>
<%@ Register TagPrefix="dash" TagName="AnalyticsView" Src="~/Components/Dashboard/Analytics/AnalyticsView.ascx" %>
<%@ Register TagPrefix="dash" TagName="UsersView" Src="~/Components/Dashboard/Users/UsersView.ascx" %>
<%@ Register TagPrefix="dash" TagName="ManageUserDialog" Src="~/Components/Dashboard/Users/ManageUserDialog.ascx" %>
<%@ Register TagPrefix="dash" TagName="SettingsView" Src="~/Components/Dashboard/Settings/SettingsView.ascx" %>
<%@ Register TagPrefix="dash" TagName="ToastRegion" Src="~/Components/Dashboard/Shared/ToastRegion.ascx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml" lang="en">
<head>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="robots" content="noindex, nofollow" />
    <%-- Read by api.js and sent back with every request that changes something. --%>
    <meta name="csrf-token" content="<%: CsrfToken %>" />
    <title data-suffix="<%: AdminConsoleName %>">Analytics - <%: AdminConsoleName %></title>
    <%-- Before first paint, so a remembered collapsed sidebar doesn't open and then snap shut. The
         js class gates the styles that only make sense once script is running. --%>
    <script>
        (function (root) {
            root.className += " js";
            try {
                if (window.localStorage.getItem("adm.sidebarCollapsed") === "1") {
                    root.className += " adm-sidebar-collapsed";
                }
            } catch (e) { }
        })(document.documentElement);
    </script>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet" />
    <%-- Shared with the sign-in page first, then one file per component group; responsive.css last. --%>
    <link href="/Assets/css/Admin/tokens.css?v=1" rel="stylesheet" />
    <link href="/Assets/css/Admin/forms.css?v=1" rel="stylesheet" />
    <link href="/Assets/css/Admin/Dashboard/controls.css?v=1" rel="stylesheet" />
    <link href="/Assets/css/Admin/Dashboard/layout.css?v=2" rel="stylesheet" />
    <link href="/Assets/css/Admin/Dashboard/sidebar.css?v=1" rel="stylesheet" />
    <link href="/Assets/css/Admin/Dashboard/header.css?v=1" rel="stylesheet" />
    <link href="/Assets/css/Admin/Dashboard/analytics.css?v=1" rel="stylesheet" />
    <link href="/Assets/css/Admin/Dashboard/users.css?v=2" rel="stylesheet" />
    <link href="/Assets/css/Admin/Dashboard/dialog.css?v=1" rel="stylesheet" />
    <link href="/Assets/css/Admin/Dashboard/settings.css?v=1" rel="stylesheet" />
    <link href="/Assets/css/Admin/Dashboard/toast.css?v=1" rel="stylesheet" />
    <link href="/Assets/css/Admin/Dashboard/responsive.css?v=1" rel="stylesheet" />
    <link href="/DEV_PHOTO.png" rel="icon" type="image/png" />
</head>
<body>
    <%-- No server <form>: every action is a fetch to /AdminApi, apart from log-out, which is its own
         small form. A page-wide form would make Enter in the search box post the page back. --%>
    <div class="adm-shell">
        <dash:Sidebar runat="server" />

        <div class="adm-workspace">
            <dash:Header runat="server" />

            <main class="adm-content" id="dashMain">
                <dash:AnalyticsView runat="server" />
                <dash:UsersView runat="server" />
                <dash:SettingsView runat="server" />
            </main>
        </div>
    </div>

    <dash:ManageUserDialog runat="server" />
    <dash:ToastRegion runat="server" />

    <%-- Order matters: core first (the AdminDash namespace and helpers), then the components, then
         main.js, which starts the router once every view has registered its listeners. --%>
    <script src="/Assets/js/Admin/Dashboard/core/dom.js?v=1"></script>
    <script src="/Assets/js/Admin/Dashboard/core/format.js?v=2"></script>
    <script src="/Assets/js/Admin/Dashboard/core/prefs.js?v=1"></script>
    <script src="/Assets/js/Admin/Dashboard/core/api.js?v=1"></script>
    <script src="/Assets/js/Admin/Dashboard/core/toast.js?v=1"></script>
    <script src="/Assets/js/Admin/Dashboard/layout/sidebar.js?v=1"></script>
    <script src="/Assets/js/Admin/Dashboard/layout/usermenu.js?v=1"></script>
    <script src="/Assets/js/Admin/Dashboard/layout/router.js?v=1"></script>
    <script src="/Assets/js/Admin/Dashboard/analytics/charts.js?v=2"></script>
    <script src="/Assets/js/Admin/Dashboard/analytics/analytics.js?v=1"></script>
    <script src="/Assets/js/Admin/Dashboard/users/userstable.js?v=1"></script>
    <script src="/Assets/js/Admin/Dashboard/users/managedialog.js?v=1"></script>
    <script src="/Assets/js/Admin/Dashboard/settings/password.js?v=1"></script>
    <script src="/Assets/js/Admin/Dashboard/settings/preferences.js?v=1"></script>
    <script src="/Assets/js/Admin/Dashboard/main.js?v=1"></script>
</body>
</html>
