<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="AnalyticsView.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Analytics.AnalyticsView" %>
<%@ Register TagPrefix="dash" TagName="Icon" Src="~/Components/Dashboard/Shared/Icon.ascx" %>
<%@ Register TagPrefix="dash" TagName="StatTile" Src="~/Components/Dashboard/Analytics/StatTile.ascx" %>
<%@ Register TagPrefix="dash" TagName="ChartCard" Src="~/Components/Dashboard/Analytics/ChartCard.ascx" %>
<%@ Register TagPrefix="dash" TagName="RecentSignups" Src="~/Components/Dashboard/Analytics/RecentSignups.ascx" %>
<%-- The view the dashboard opens on. Every figure comes from one request (analytics.js), so the
     tiles and charts always describe the same moment. --%>
<section class="adm-view" id="view-analytics" data-view="analytics" data-title="Analytics" aria-labelledby="dashTitle">
    <div class="adm-view-intro">
        <p class="adm-view-lead">How people sign up to and use the portfolio. Administrator accounts aren't counted.</p>
        <div class="adm-view-actions">
            <span class="adm-updated" id="analyticsUpdated"></span>
            <button type="button" class="adm-btn adm-btn--secondary" id="analyticsRefresh">
                <dash:Icon runat="server" Name="refresh" Size="18" />
                Refresh
            </button>
        </div>
    </div>

    <p class="adm-alert" id="analyticsError" role="alert"></p>

    <div class="adm-analytics" id="analyticsBody" aria-busy="true">
        <div class="adm-tiles">
            <dash:StatTile runat="server" Metric="total" Label="Registered users" IconName="users" />
            <dash:StatTile runat="server" Metric="active" Label="Active accounts" IconName="check-circle" />
            <dash:StatTile runat="server" Metric="inactive" Label="Inactive accounts" IconName="block" />
            <dash:StatTile runat="server" Metric="new" Label="New in the last 30 days" IconName="person-add" />
        </div>

        <div class="adm-chart-grid">
            <dash:ChartCard runat="server" Chart="signups" Heading="Sign-ups by month"
                Subheading="New accounts in each of the last 12 months (UTC)" IsWide="true" />
            <dash:ChartCard runat="server" Chart="status" Heading="Account status"
                Subheading="Active accounts can sign in; inactive ones are refused" />
            <dash:ChartCard runat="server" Chart="last-sign-in" Heading="Last sign-in"
                Subheading="How recently each account signed in" />
            <dash:ChartCard runat="server" Chart="profile" Heading="Profile completeness"
                Subheading="Accounts that filled in each optional field" />
            <dash:RecentSignups runat="server" />
        </div>
    </div>
</section>
