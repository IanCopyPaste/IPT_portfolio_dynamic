<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UsersView.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Users.UsersView" %>
<%@ Register TagPrefix="dash" TagName="UsersToolbar" Src="~/Components/Dashboard/Users/UsersToolbar.ascx" %>
<%@ Register TagPrefix="dash" TagName="UsersTable" Src="~/Components/Dashboard/Users/UsersTable.ascx" %>
<%@ Register TagPrefix="dash" TagName="UsersPagination" Src="~/Components/Dashboard/Users/UsersPagination.ascx" %>
<section class="adm-view" id="view-users" data-view="users" data-title="Users" aria-labelledby="dashTitle" hidden>
    <div class="adm-view-intro">
        <p class="adm-view-lead">Every account on the portfolio. Open Manage to see an account's details, switch it between active and inactive, or delete it.</p>
    </div>

    <div class="adm-panel adm-users">
        <dash:UsersToolbar runat="server" />
        <dash:UsersTable runat="server" />
        <dash:UsersPagination runat="server" />
    </div>
</section>
