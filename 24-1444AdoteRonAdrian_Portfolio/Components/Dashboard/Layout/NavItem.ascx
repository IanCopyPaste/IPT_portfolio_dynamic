<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="NavItem.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Layout.NavItem" %>
<%-- A link to #<view>, which router.js turns into a view switch; being a link, it also works with
     the browser's back button and can be opened from a bookmark. data-label feeds the tooltip the
     collapsed rail shows in place of the hidden text. --%>
<a class="adm-nav-item<%= IsDefault ? " is-active" : "" %>" href="#<%: View %>" data-view="<%: View %>"
    data-label="<%: Label %>"<%= IsDefault ? " aria-current=\"page\"" : "" %>>
    <%= IconMarkup %>
    <span class="adm-sidebar-label"><%: Label %></span>
</a>
