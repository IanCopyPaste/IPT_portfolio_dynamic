<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="Sidebar.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Layout.Sidebar" %>
<%@ Register TagPrefix="dash" TagName="Icon" Src="~/Components/Dashboard/Shared/Icon.ascx" %>
<%@ Register TagPrefix="dash" TagName="NavItem" Src="~/Components/Dashboard/Layout/NavItem.ascx" %>
<%-- Collapses to an icon rail. The collapsed state is a class on <html>, set by the inline script in
     the page's <head> before first paint, so a collapsed sidebar doesn't flash open on load. --%>
<aside class="adm-sidebar" id="dashSidebar">
    <div class="adm-sidebar-brand">
        <span class="adm-sidebar-logo"><dash:Icon runat="server" Name="shield" Size="20" /></span>
        <span class="adm-sidebar-name adm-sidebar-label"><%: ConsoleName %></span>
    </div>

    <nav class="adm-nav" aria-label="Dashboard sections">
        <p class="adm-nav-heading adm-sidebar-label">Menu</p>
        <ul class="adm-nav-list">
            <li><dash:NavItem runat="server" View="analytics" Label="Analytics" IconName="analytics" IsDefault="true" /></li>
            <li><dash:NavItem runat="server" View="users" Label="Users" IconName="users" /></li>
            <li><dash:NavItem runat="server" View="settings" Label="Settings" IconName="settings" /></li>
        </ul>
    </nav>

    <button type="button" class="adm-sidebar-toggle" id="dashSidebarToggle" aria-controls="dashSidebar"
        aria-expanded="true" aria-label="Collapse sidebar" data-label="Expand">
        <dash:Icon runat="server" Name="collapse" />
        <span class="adm-sidebar-label">Collapse</span>
    </button>
</aside>
