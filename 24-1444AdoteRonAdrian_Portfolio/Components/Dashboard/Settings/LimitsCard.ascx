<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="LimitsCard.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Settings.LimitsCard" %>
<%@ Register TagPrefix="dash" TagName="Icon" Src="~/Components/Dashboard/Shared/Icon.ascx" %>
<%-- Site-wide, unlike the Preferences card: the numbers are saved on the server (limits.js posts
     them to Limits.ashx) and every user's profile form is held to them from its next page load. --%>
<article class="adm-panel adm-settings-card adm-settings-card--wide">
    <header class="adm-panel-header adm-panel-header--icon">
        <span class="adm-panel-icon"><dash:Icon runat="server" Name="person" /></span>
        <div>
            <h2 class="adm-panel-title">Profile limits</h2>
            <p class="adm-panel-subtitle">How many hobbies and skills each user can add, from <%= Min %> to <%= Max %>.</p>
        </div>
    </header>

    <form class="adm-settings-form" id="limitsForm" novalidate="novalidate">
        <p class="adm-alert" id="limitsStatus" role="alert"></p>

        <div class="adm-settings-pair">
            <div class="adm-field">
                <label class="adm-label" for="limitsHobbies">Hobbies</label>
                <input type="number" class="adm-input" id="limitsHobbies" data-field="maxHobbies" inputmode="numeric"
                    min="<%= Min %>" max="<%= Max %>" step="1" value="<%= Current.Hobbies %>" />
                <span class="adm-error" id="limitsHobbiesError" aria-live="polite"></span>
            </div>

            <div class="adm-field">
                <label class="adm-label" for="limitsSkills">Skills</label>
                <input type="number" class="adm-input" id="limitsSkills" data-field="maxSkills" inputmode="numeric"
                    min="<%= Min %>" max="<%= Max %>" step="1" value="<%= Current.Skills %>" />
                <span class="adm-error" id="limitsSkillsError" aria-live="polite"></span>
            </div>
        </div>

        <p class="adm-pref-help">Lowering a limit deletes nothing. Portfolios show only that many, and a user who is over it is asked to remove the extras the next time they save.</p>

        <div class="adm-form-actions adm-form-actions--end">
            <button type="submit" class="adm-btn adm-btn--primary" id="limitsSubmit">Save limits</button>
        </div>
    </form>
</article>
