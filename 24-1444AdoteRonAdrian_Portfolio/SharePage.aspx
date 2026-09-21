<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="SharePage.aspx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.SharePage" %>
<%@ Register TagPrefix="cp" TagName="PortfolioView" Src="~/Components/Portfolio/PortfolioView.ascx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <%-- Same pre-paint flag as ContentPage: the reveal styles only hide what script can bring back. --%>
    <script>document.documentElement.className += " js";</script>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <%-- The link is meant for whoever it is handed to, not for search results. --%>
    <meta name="robots" content="noindex" />
    <% if (Found) { %>
    <title><%: OwnerName %> - Portfolio</title>
    <% } else { %>
    <title>404 Link not found - <%= SiteBrandName %></title>
    <% } %>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Anton&family=Share+Tech+Mono&display=swap" rel="stylesheet" />
    <%-- The portfolio's own stylesheets, in ContentPage's order; a dead link borrows the 403
         screen's instead. reveal.css loads after the section files either way. --%>
    <link href="/Assets/css/ContentPage/contentpage.css?v=21" rel="stylesheet" />
    <% if (Found) { %>
    <link href="/Assets/css/ContentPage/home.css?v=4" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/about.css?v=9" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/skills.css?v=5" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/contact.css?v=6" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/reveal.css?v=4" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/responsive.css?v=8" rel="stylesheet" />
    <% } else { %>
    <link href="/Assets/css/ForbiddenPage/forbiddenpage.css?v=1" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/reveal.css?v=4" rel="stylesheet" />
    <% } %>
    <link href="/DEV_PHOTO.png" rel="icon" type="image/png" />
</head>
<body>
    <%-- No server <form>: a visitor only reads this page, nothing on it posts back. --%>

    <%-- The same portfolio ContentPage draws, minus the owner-only parts. --%>
    <cp:PortfolioView ID="portfolio" runat="server" Shared="true" />

    <% if (!Found) { %>
    <%-- One answer for a token that never existed, one that was replaced or turned off, and an
         account that was deactivated, so the page gives nothing away about which it was. --%>
    <nav class="navbar navbar--top" id="siteNavbar">
        <div class="navbar-inner">
            <a class="navbar-brand" href="LoginPage.aspx"><%= SiteBrandName %></a>
        </div>
    </nav>

    <main>
        <section id="notfound" class="section forbidden-section">
            <div class="section-inner">
                <div class="forbidden-layout">
                    <div class="forbidden-intro">
                        <p class="forbidden-kicker reveal" data-reveal-delay="0">// error 404 &middot; not found</p>
                        <%-- The glitch layers read data-text, so it has to match the visible code. --%>
                        <div class="forbidden-code reveal" data-text="404" data-reveal-delay="100" aria-hidden="true">404</div>
                        <h1 class="forbidden-heading reveal" data-reveal-delay="200">Link not found</h1>
                        <p class="forbidden-copy reveal" data-reveal-delay="280">
                            This portfolio link doesn't work any more. Its owner may have replaced it with a
                            new one or turned sharing off &mdash; ask them for the current link.
                        </p>
                    </div>

                    <div class="forbidden-panel reveal" data-reveal-delay="260" aria-hidden="true">
                        <div class="terminal-bar">
                            <span class="terminal-dot"></span>
                            <span class="terminal-dot"></span>
                            <span class="terminal-dot"></span>
                            <span class="terminal-path">~/portfolio/share --open</span>
                        </div>
                        <ul class="forbidden-log">
                            <li class="reveal" data-reveal-delay="420">GET /SharePage.aspx</li>
                            <li class="reveal" data-reveal-delay="520">resolving link <span class="forbidden-log-bad">[ unknown ]</span></li>
                            <li class="reveal" data-reveal-delay="620">connection closed with status 404</li>
                            <li class="reveal" data-reveal-delay="720">awaiting a valid link<span class="forbidden-cursor"></span></li>
                        </ul>
                    </div>
                </div>

                <p class="forbidden-footnote reveal" data-reveal-delay="820">
                    &copy; <%= DateTime.Today.Year %> <%= SiteBrandName %> &middot; HTTP 404 Not Found
                </p>
            </div>
        </section>
    </main>
    <% } %>

    <%-- contentpage.js drives the navbar, the reveals and the smooth scroll; it skips what isn't here. --%>
    <script src="/Assets/js/ContentPage/contentpage.js?v=6"></script>
</body>
</html>
