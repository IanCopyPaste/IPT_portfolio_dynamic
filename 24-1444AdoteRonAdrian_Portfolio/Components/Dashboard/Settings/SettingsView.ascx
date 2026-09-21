<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SettingsView.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Settings.SettingsView" %>
<%@ Register TagPrefix="dash" TagName="AccountCard" Src="~/Components/Dashboard/Settings/AccountCard.ascx" %>
<%@ Register TagPrefix="dash" TagName="PasswordCard" Src="~/Components/Dashboard/Settings/PasswordCard.ascx" %>
<%@ Register TagPrefix="dash" TagName="PreferencesCard" Src="~/Components/Dashboard/Settings/PreferencesCard.ascx" %>
<%@ Register TagPrefix="dash" TagName="LimitsCard" Src="~/Components/Dashboard/Settings/LimitsCard.ascx" %>
<section class="adm-view" id="view-settings" data-view="settings" data-title="Settings" aria-labelledby="dashTitle" hidden>
    <div class="adm-view-intro">
        <p class="adm-view-lead">Your administrator account, how the dashboard behaves in this browser, and the limits on every user's profile.</p>
    </div>

    <%-- Limits goes last: settings.css spans the second card (Password) down two rows, and gives
         this one the full width underneath. --%>
    <div class="adm-settings-grid">
        <dash:AccountCard runat="server" />
        <dash:PasswordCard runat="server" />
        <dash:PreferencesCard runat="server" />
        <dash:LimitsCard runat="server" />
    </div>
</section>
