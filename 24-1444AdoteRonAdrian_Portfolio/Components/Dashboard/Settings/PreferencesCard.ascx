<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="PreferencesCard.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Settings.PreferencesCard" %>
<%@ Register TagPrefix="dash" TagName="Icon" Src="~/Components/Dashboard/Shared/Icon.ascx" %>
<%-- Conveniences for this browser only (preferences.js keeps them in localStorage), so nothing here
     touches the server. Each change applies at once; there is no Save button to forget. --%>
<article class="adm-panel adm-settings-card">
    <header class="adm-panel-header adm-panel-header--icon">
        <span class="adm-panel-icon"><dash:Icon runat="server" Name="tune" /></span>
        <div>
            <h2 class="adm-panel-title">Preferences</h2>
            <p class="adm-panel-subtitle">Saved in this browser only. Changes apply straight away.</p>
        </div>
    </header>

    <div class="adm-pref-list">
        <div class="adm-pref">
            <div>
                <label class="adm-pref-label" for="prefPageSize">Rows per page</label>
                <p class="adm-pref-help" id="prefPageSizeHelp">How many accounts the Users table shows at once.</p>
            </div>
            <select class="adm-select adm-select--sm" id="prefPageSize" aria-describedby="prefPageSizeHelp">
                <% foreach (int size in PageSizes) { %>
                <option value="<%= size %>"><%= size %></option>
                <% } %>
            </select>
        </div>

        <div class="adm-pref">
            <div>
                <p class="adm-pref-label" id="prefRelativeLabel">Relative dates</p>
                <p class="adm-pref-help" id="prefRelativeHelp">Show &ldquo;3 days ago&rdquo; instead of the calendar date.</p>
            </div>
            <button type="button" class="adm-switch" id="prefRelativeDates" role="switch" aria-checked="true"
                aria-labelledby="prefRelativeLabel" aria-describedby="prefRelativeHelp">
                <span class="adm-switch-thumb" aria-hidden="true"></span>
            </button>
        </div>

        <div class="adm-pref">
            <div>
                <p class="adm-pref-label" id="prefCollapsedLabel">Collapsed sidebar</p>
                <p class="adm-pref-help" id="prefCollapsedHelp">Show the sidebar as icons only.</p>
            </div>
            <button type="button" class="adm-switch" id="prefSidebarCollapsed" role="switch" aria-checked="false"
                aria-labelledby="prefCollapsedLabel" aria-describedby="prefCollapsedHelp">
                <span class="adm-switch-thumb" aria-hidden="true"></span>
            </button>
        </div>
    </div>

    <div class="adm-form-actions adm-form-actions--end">
        <button type="button" class="adm-btn adm-btn--secondary" id="prefReset">Restore defaults</button>
    </div>
</article>
