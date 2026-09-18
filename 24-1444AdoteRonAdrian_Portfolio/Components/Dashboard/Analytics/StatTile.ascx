<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="StatTile.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Analytics.StatTile" %>
<%-- A headline number. analytics.js finds the tile by data-metric and fills the value and hint. --%>
<article class="adm-tile" data-metric="<%: Metric %>">
    <div class="adm-tile-head">
        <h2 class="adm-tile-label"><%: Label %></h2>
        <span class="adm-tile-icon"><%= IconMarkup %></span>
    </div>
    <p class="adm-tile-value" data-role="value">&ndash;</p>
    <p class="adm-tile-hint" data-role="hint">Loading&hellip;</p>
</article>
