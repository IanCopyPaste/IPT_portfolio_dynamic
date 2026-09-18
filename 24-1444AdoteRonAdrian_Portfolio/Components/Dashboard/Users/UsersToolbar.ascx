<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UsersToolbar.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Users.UsersToolbar" %>
<%@ Register TagPrefix="dash" TagName="Icon" Src="~/Components/Dashboard/Shared/Icon.ascx" %>
<%-- The search waits for a pause in typing before it asks the server (userstable.js), so a name
     typed at speed costs one request, not one per key. --%>
<div class="adm-toolbar">
    <label class="adm-search">
        <span class="adm-sr-only">Search users by name or username</span>
        <dash:Icon runat="server" Name="search" Size="18" />
        <input type="search" class="adm-search-input" id="usersSearch" placeholder="Search by name or username"
            autocomplete="off" spellcheck="false" maxlength="<%= MaxQueryLength %>" />
    </label>

    <label class="adm-select-wrap">
        <span class="adm-sr-only">Filter by status</span>
        <select class="adm-select" id="usersStatus">
            <option value="">All statuses</option>
            <option value="<%: ActiveStatus %>">Active</option>
            <option value="<%: InactiveStatus %>">Inactive</option>
        </select>
    </label>

    <p class="adm-toolbar-status" id="usersSummary" aria-live="polite"></p>
</div>
