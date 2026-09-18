<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PasswordCard.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Settings.PasswordCard" %>
<%@ Register TagPrefix="dash" TagName="Icon" Src="~/Components/Dashboard/Shared/Icon.ascx" %>
<%-- A plain <form>, sent by password.js as JSON rather than posted. The page has no server form, so
     Enter in any of these fields submits this form and nothing else. --%>
<article class="adm-panel adm-settings-card">
    <header class="adm-panel-header adm-panel-header--icon">
        <span class="adm-panel-icon"><dash:Icon runat="server" Name="lock" /></span>
        <div>
            <h2 class="adm-panel-title">Change password</h2>
            <p class="adm-panel-subtitle">At least <%= MinLength %> characters. You stay signed in afterwards.</p>
        </div>
    </header>

    <form class="adm-settings-form" id="passwordForm" novalidate="novalidate">
        <p class="adm-alert" id="passwordStatus" role="alert"></p>

        <%-- Lets a password manager tell which account the new password belongs to. --%>
        <input type="text" class="adm-sr-only" name="username" autocomplete="username" value="<%: Username %>"
            tabindex="-1" aria-hidden="true" readonly="readonly" />

        <div class="adm-field">
            <label class="adm-label" for="passwordCurrent">Current password</label>
            <input type="password" class="adm-input" id="passwordCurrent" data-field="currentPassword"
                autocomplete="current-password" maxlength="<%= MaxLength %>" />
            <span class="adm-error" id="passwordCurrentError" aria-live="polite"></span>
        </div>

        <div class="adm-field">
            <label class="adm-label" for="passwordNew">New password</label>
            <input type="password" class="adm-input" id="passwordNew" data-field="newPassword"
                autocomplete="new-password" maxlength="<%= MaxLength %>" data-min="<%= MinLength %>" />
            <span class="adm-error" id="passwordNewError" aria-live="polite"></span>
        </div>

        <div class="adm-field">
            <label class="adm-label" for="passwordConfirm">Confirm new password</label>
            <input type="password" class="adm-input" id="passwordConfirm" data-field="confirmPassword"
                autocomplete="new-password" maxlength="<%= MaxLength %>" />
            <span class="adm-error" id="passwordConfirmError" aria-live="polite"></span>
        </div>

        <div class="adm-form-actions">
            <label class="adm-checkbox">
                <input type="checkbox" id="passwordShow" />
                <span>Show passwords</span>
            </label>
            <button type="submit" class="adm-btn adm-btn--primary" id="passwordSubmit">Update password</button>
        </div>
    </form>
</article>
