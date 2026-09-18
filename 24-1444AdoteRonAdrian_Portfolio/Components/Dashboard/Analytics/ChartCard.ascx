<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ChartCard.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Analytics.ChartCard" %>
<%-- The frame around one chart. analytics.js draws into the data-chart element; charts.js puts a
     screen-reader table beside each drawing, so no value is only available as a picture. --%>
<article class="adm-panel adm-chart-card<%= IsWide ? " adm-chart-card--wide" : "" %>">
    <header class="adm-panel-header">
        <h2 class="adm-panel-title"><%: Heading %></h2>
        <p class="adm-panel-subtitle"><%: Subheading %></p>
    </header>
    <div class="adm-chart" data-chart="<%: Chart %>"></div>
</article>
