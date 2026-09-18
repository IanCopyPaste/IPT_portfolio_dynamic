<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UserMenu.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Layout.UserMenu" %>
<%@ Register TagPrefix="dash" TagName="Icon" Src="~/Components/Dashboard/Shared/Icon.ascx" %>
<%-- Opens on hover and on click (usermenu.js); without script, the stylesheet opens it on hover and
     keyboard focus instead. Log out is a real form post, so it works either way. --%>
<div class="adm-usermenu" id="dashUserMenu">
    <button type="button" class="adm-usermenu-trigger" id="dashUserMenuTrigger"
        aria-expanded="false" aria-controls="dashUserMenuPanel">
        <span class="adm-avatar" aria-hidden="true"><%: CurrentAdmin.Initials %></span>
        <span class="adm-usermenu-name"><%: CurrentAdmin.Username %></span>
        <dash:Icon runat="server" Name="chevron-down" Size="18" />
    </button>

    <div class="adm-usermenu-panel" id="dashUserMenuPanel">
        <div class="adm-usermenu-card">
            <div class="adm-usermenu-who">
                <span class="adm-avatar adm-avatar--lg" aria-hidden="true"><%: CurrentAdmin.Initials %></span>
                <div class="adm-usermenu-names">
                    <p class="adm-usermenu-fullname"><%: CurrentAdmin.DisplayName %></p>
                    <p class="adm-usermenu-username">@<%: CurrentAdmin.Username %></p>
                </div>
            </div>
            <span class="adm-badge adm-badge--primary">
                <dash:Icon runat="server" Name="shield" Size="14" />
                Administrator
            </span>
            <form class="adm-usermenu-logout" method="post" action="<%: LogoutUrl %>">
                <input type="hidden" name="<%: CsrfField %>" value="<%: CsrfToken %>" />
                <button type="submit" class="adm-menu-item adm-menu-item--danger">
                    <dash:Icon runat="server" Name="logout" Size="18" />
                    Log out
                </button>
            </form>
        </div>
    </div>
</div>
