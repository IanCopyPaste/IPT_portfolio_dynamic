<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContentPage.aspx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.ContentPage" %>
<%@ Register TagPrefix="cp" TagName="PortfolioView" Src="~/Components/Portfolio/PortfolioView.ascx" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <%-- Marks the document as scripted before the first paint, so the reveal styles
         only ever hide elements on browsers that can slide them back in. --%>
    <script>document.documentElement.className += " js";</script>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><%: OwnerName %> - Portfolio</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Anton&family=Share+Tech+Mono&display=swap" rel="stylesheet" />
    <%-- Order matters: tokens and base first, sections in page order, then the reveal
         and responsive overrides, which have to win over the section rules. --%>
    <link href="/Assets/css/ContentPage/contentpage.css?v=22" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/home.css?v=4" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/about.css?v=9" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/skills.css?v=5" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/contact.css?v=6" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/reveal.css?v=4" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/responsive.css?v=9" rel="stylesheet" />
    <link href="/DEV_PHOTO.png" rel="icon" type="image/png" />
</head>
<body>
    <form id="form1" runat="server">
    <div>

        <%-- Everything on the page, shared with SharePage; this page is its owner's view of it. --%>
        <cp:PortfolioView ID="portfolio" runat="server" />

    </div>
    </form>
    <script src="/Assets/js/ContentPage/contentpage.js?v=6"></script>
</body>
</html>
