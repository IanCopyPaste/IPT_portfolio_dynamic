<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ForbiddenPage.aspx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.ForbiddenPage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head>
    <%-- Same pre-paint flag as ContentPage: the reveal styles only hide what script can bring back. --%>
    <script>document.documentElement.className += " js";</script>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <meta name="robots" content="noindex" />
    <title>403 Access denied - <%= SiteBrandName %></title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Anton&family=Share+Tech+Mono&display=swap" rel="stylesheet" />
    <%-- Shared tokens, navbar and terminal bar come from the portfolio, as on the login page.
         reveal.css loads last so its hidden state wins. --%>
    <link href="/Assets/css/ContentPage/contentpage.css?v=19" rel="stylesheet" />
    <link href="/Assets/css/ForbiddenPage/forbiddenpage.css?v=1" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/reveal.css?v=3" rel="stylesheet" />
</head>
<body>
    <%-- No server <form>: nothing on this page posts back. --%>
    <nav class="navbar navbar--top" id="siteNavbar">
        <div class="navbar-inner">
            <a class="navbar-brand" href="LoginPage.aspx"><%= SiteBrandName %></a>
        </div>
    </nav>

    <main>
        <section id="forbidden" class="section forbidden-section">
            <div class="section-inner">
                <div class="forbidden-layout">
                    <div class="forbidden-intro">
                        <p class="forbidden-kicker reveal" data-reveal-delay="0">// error 403 &middot; forbidden</p>
                        <%-- The glitch layers read data-text, so it has to match the visible code. --%>
                        <div class="forbidden-code reveal" data-text="403" data-reveal-delay="100" aria-hidden="true">403</div>
                        <h1 class="forbidden-heading reveal" data-reveal-delay="200">Access denied</h1>
                        <p class="forbidden-copy reveal" data-reveal-delay="280">
                            You don't have permission to open this page. Log in with an account that has access,
                            then try again.
                        </p>
                        <div class="forbidden-actions reveal" data-reveal-delay="360">
                            <a class="forbidden-btn" href="LoginPage.aspx">Log in</a>
                        </div>
                    </div>

                    <div class="forbidden-panel reveal" data-reveal-delay="260" aria-hidden="true">
                        <div class="terminal-bar">
                            <span class="terminal-dot"></span>
                            <span class="terminal-dot"></span>
                            <span class="terminal-dot"></span>
                            <span class="terminal-path">~/portfolio/auth --check</span>
                        </div>
                        <ul class="forbidden-log">
                            <li class="reveal" data-reveal-delay="420">GET <%: RequestedPath %></li>
                            <li class="reveal" data-reveal-delay="520">reading session <span class="forbidden-log-bad">[ none ]</span></li>
                            <li class="reveal" data-reveal-delay="620">checking permissions <span class="forbidden-log-bad">[ denied ]</span></li>
                            <li class="reveal" data-reveal-delay="720">connection closed with status 403</li>
                            <li class="reveal" data-reveal-delay="820">awaiting credentials<span class="forbidden-cursor"></span></li>
                        </ul>
                    </div>
                </div>

                <p class="forbidden-footnote reveal" data-reveal-delay="900">
                    &copy; <%= DateTime.Today.Year %> <%= SiteBrandName %> &middot; HTTP 403 Forbidden
                </p>
            </div>
        </section>
    </main>

    <%-- contentpage.js drives the navbar wash and the reveals; it skips the sections this page doesn't have. --%>
    <script src="/Assets/js/ContentPage/contentpage.js?v=6"></script>
</body>
</html>
