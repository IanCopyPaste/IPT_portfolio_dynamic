<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="RecentSignups.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Analytics.RecentSignups" %>
<%-- The newest accounts. Each row opens the same Manage dialog as the Users table. --%>
<article class="adm-panel adm-recent">
    <header class="adm-panel-header adm-panel-header--split">
        <div>
            <h2 class="adm-panel-title">Recent sign-ups</h2>
            <p class="adm-panel-subtitle">The newest accounts</p>
        </div>
        <a class="adm-link-btn" href="#users">View all</a>
    </header>
    <ul class="adm-recent-list" id="analyticsRecent"></ul>
</article>
