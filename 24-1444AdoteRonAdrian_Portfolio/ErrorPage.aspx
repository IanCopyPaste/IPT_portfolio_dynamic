<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ErrorPage.aspx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.ErrorPage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <%-- Same pre-paint flag as ContentPage: the reveal styles only hide what script can bring back. --%>
    <script>document.documentElement.className += " js";</script>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="robots" content="noindex" />
    <title><%= Code %> <%: Heading %> - <%= SiteBrandName %></title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Anton&family=Share+Tech+Mono&display=swap" rel="stylesheet" />
    <%-- The 403 screen's layout, which SharePage's 404 borrows too, so every error the site shows
         reads as one family. reveal.css loads last so its hidden state wins. --%>
    <link href="/Assets/css/ContentPage/contentpage.css?v=22" rel="stylesheet" />
    <link href="/Assets/css/ForbiddenPage/forbiddenpage.css?v=1" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/reveal.css?v=4" rel="stylesheet" />
    <link href="/DEV_PHOTO.png" rel="icon" type="image/png" />
</head>
<body>
    <%-- No server <form>: nothing on this page posts back, and a page that failed mid-post must not
         be able to post again from here. --%>
    <nav class="navbar navbar--top" id="siteNavbar">
        <div class="navbar-inner">
            <a class="navbar-brand" href="/LoginPage.aspx"><%= SiteBrandName %></a>
        </div>
    </nav>

    <main>
        <section id="error" class="section forbidden-section">
            <div class="section-inner">
                <div class="forbidden-layout">
                    <div class="forbidden-intro">
                        <p class="forbidden-kicker reveal" data-reveal-delay="0">// error <%= Code %> &middot; <%: Kicker %></p>
                        <%-- The glitch layers read data-text, so it has to match the visible code. --%>
                        <div class="forbidden-code reveal" data-text="<%= Code %>" data-reveal-delay="100" aria-hidden="true"><%= Code %></div>
                        <h1 class="forbidden-heading reveal" data-reveal-delay="200"><%: Heading %></h1>
                        <p class="forbidden-copy reveal" data-reveal-delay="280"><%: Copy %></p>
                        <%-- Root-relative: the page is drawn at whatever address failed, which may
                             sit in a folder such as /AdminApi/. --%>
                        <div class="forbidden-actions reveal" data-reveal-delay="360">
                            <a class="forbidden-btn" href="/LoginPage.aspx">Back to start</a>
                        </div>
                    </div>

                    <div class="forbidden-panel reveal" data-reveal-delay="260" aria-hidden="true">
                        <div class="terminal-bar">
                            <span class="terminal-dot"></span>
                            <span class="terminal-dot"></span>
                            <span class="terminal-dot"></span>
                            <span class="terminal-path">~/portfolio/request --status</span>
                        </div>
                        <ul class="forbidden-log">
                            <li class="reveal" data-reveal-delay="420"><%: Request.HttpMethod %> <%: RequestedPath %></li>
                            <li class="reveal" data-reveal-delay="520">handling request <span class="forbidden-log-bad"><%: LogResult %></span></li>
                            <li class="reveal" data-reveal-delay="620">connection closed with status <%= Code %></li>
                            <li class="reveal" data-reveal-delay="720">awaiting a new request<span class="forbidden-cursor"></span></li>
                        </ul>
                    </div>
                </div>

                <p class="forbidden-footnote reveal" data-reveal-delay="820">
                    &copy; <%= DateTime.Today.Year %> <%= SiteBrandName %> &middot; HTTP <%= Code %> <%: StatusName %>
                </p>
            </div>
        </section>
    </main>

    <%-- contentpage.js drives the navbar wash and the reveals; it skips the sections this page doesn't have. --%>
    <script src="/Assets/js/ContentPage/contentpage.js?v=6"></script>
</body>
</html>
