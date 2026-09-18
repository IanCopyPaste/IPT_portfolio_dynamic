<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UsersPagination.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Users.UsersPagination" %>
<%-- The page buttons are built by userstable.js from the total the server reports. --%>
<div class="adm-pagination">
    <p class="adm-pagination-range" id="usersRange"></p>
    <div class="adm-pagination-controls">
        <label class="adm-pagesize">
            <span>Rows per page</span>
            <select class="adm-select adm-select--sm" id="usersPageSize">
                <% foreach (int size in PageSizes) { %>
                <option value="<%= size %>"<%= size == DefaultPageSize ? " selected=\"selected\"" : "" %>><%= size %></option>
                <% } %>
            </select>
        </label>
        <nav class="adm-pager" id="usersPager" aria-label="Users pages"></nav>
    </div>
</div>
