<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="UsersTable.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Users.UsersTable" %>
<%-- userstable.js fills the body. The wrapper scrolls sideways on a narrow screen, so the table
     never forces the whole page wider than the viewport. --%>
<div class="adm-table-wrap">
    <table class="adm-table" id="usersTable">
        <caption class="adm-sr-only">User accounts</caption>
        <thead>
            <tr>
                <th scope="col">User</th>
                <th scope="col">Email</th>
                <th scope="col">Status</th>
                <th scope="col">Joined</th>
                <th scope="col">Last sign-in</th>
                <th scope="col" class="adm-table-actions"><span class="adm-sr-only">Actions</span></th>
            </tr>
        </thead>
        <tbody id="usersBody">
            <tr class="adm-table-message">
                <td colspan="6">Loading users&hellip;</td>
            </tr>
        </tbody>
    </table>
</div>
