<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Header.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Layout.Header" %>
<%@ Register TagPrefix="dash" TagName="UserMenu" Src="~/Components/Dashboard/Layout/UserMenu.ascx" %>
<%-- Sticks to the top of the content column, so the section title and the account menu stay in reach
     while a long table scrolls under them. router.js rewrites the title on each view switch; it is
     focusable (tabindex -1) so the switch can move a screen reader to it. --%>
<header class="adm-header">
    <div class="adm-header-titles">
        <p class="adm-header-eyebrow"><%: ConsoleName %></p>
        <h1 class="adm-header-title" id="dashTitle" tabindex="-1">Analytics</h1>
    </div>
    <dash:UserMenu runat="server" />
</header>
