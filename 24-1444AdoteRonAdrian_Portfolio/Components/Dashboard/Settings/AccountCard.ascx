<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AccountCard.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Settings.AccountCard" %>
<%@ Register TagPrefix="dash" TagName="Icon" Src="~/Components/Dashboard/Shared/Icon.ascx" %>
<article class="adm-panel adm-settings-card">
    <header class="adm-panel-header adm-panel-header--icon">
        <span class="adm-panel-icon"><dash:Icon runat="server" Name="person" /></span>
        <div>
            <h2 class="adm-panel-title">Account</h2>
            <p class="adm-panel-subtitle">The administrator you're signed in as.</p>
        </div>
    </header>

    <div class="adm-account">
        <span class="adm-avatar adm-avatar--xl" aria-hidden="true"><%: CurrentAdmin.Initials %></span>
        <div>
            <p class="adm-account-name"><%: CurrentAdmin.DisplayName %></p>
            <p class="adm-account-username">@<%: CurrentAdmin.Username %></p>
        </div>
    </div>

    <dl class="adm-details adm-details--stacked">
        <div>
            <dt>Role</dt>
            <dd><span class="adm-badge adm-badge--primary">Administrator</span></dd>
        </div>
        <div>
            <dt>Portfolio</dt>
            <dd>
                <a class="adm-inline-link" href="<%: PortfolioUrl %>" target="_blank" rel="noopener">
                    Open the portfolio <dash:Icon runat="server" Name="open" Size="16" />
                </a>
            </dd>
        </div>
    </dl>
</article>
