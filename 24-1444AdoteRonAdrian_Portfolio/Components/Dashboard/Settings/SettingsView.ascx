<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="SettingsView.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Settings.SettingsView" %>
<%@ Register TagPrefix="dash" TagName="AccountCard" Src="~/Components/Dashboard/Settings/AccountCard.ascx" %>
<%@ Register TagPrefix="dash" TagName="PasswordCard" Src="~/Components/Dashboard/Settings/PasswordCard.ascx" %>
<%@ Register TagPrefix="dash" TagName="PreferencesCard" Src="~/Components/Dashboard/Settings/PreferencesCard.ascx" %>
<section class="adm-view" id="view-settings" data-view="settings" data-title="Settings" aria-labelledby="dashTitle" hidden>
    <div class="adm-view-intro">
        <p class="adm-view-lead">Your administrator account, and how the dashboard behaves in this browser.</p>
    </div>

    <div class="adm-settings-grid">
        <dash:AccountCard runat="server" />
        <dash:PasswordCard runat="server" />
        <dash:PreferencesCard runat="server" />
    </div>
</section>
