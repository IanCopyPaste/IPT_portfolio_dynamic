<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContentPage.aspx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.ContentPage" %>

<!DOCTYPE html>

<html xmlns="http://www.w3.org/1999/xhtml">
<head runat="server">
    <%-- Marks the document as scripted before the first paint, so the reveal styles
         only ever hide elements on browsers that can slide them back in. --%>
    <script>document.documentElement.className += " js";</script>
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
    <title><%= SiteBrandName %> - Portfolio</title>
    <link rel="preconnect" href="https://fonts.googleapis.com" />
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin="anonymous" />
    <link href="https://fonts.googleapis.com/css2?family=Anton&family=Share+Tech+Mono&display=swap" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/contentpage.css?v=11" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
    <div>

        <nav class="navbar navbar--top" id="siteNavbar">
            <div class="navbar-inner">
                <a class="navbar-brand" href="#home"><%= SiteBrandName %></a>

                <button type="button" class="nav-toggle" id="navToggle" aria-label="Toggle navigation" aria-expanded="false" aria-controls="navLinks">
                    <span></span>
                    <span></span>
                    <span></span>
                </button>

                <ul class="nav-links" id="navLinks">
                    <li><a href="#home" class="nav-link active" data-section="home">Home</a></li>
                    <li><a href="#about" class="nav-link" data-section="about">About</a></li>
                    <li><a href="#skills" class="nav-link" data-section="skills">Skills</a></li>
                    <li><a href="#contact" class="nav-link" data-section="contact">Contact</a></li>
                </ul>

                <button type="button" class="icon-btn" id="navIconBtn" aria-label="Menu options">
                    <%-- TODO: functionality TBD --%>
                    <span class="icon-btn-glyph"></span>
                </button>
            </div>
        </nav>

        <main>
            <section id="home" class="section home-section">
                <div class="section-inner">
                    <%-- The home block is in view on load, so its reveals fire immediately;
                         the delays stage them into a name → bio → portrait sequence. --%>
                    <div class="home-heading-row reveal" data-reveal-delay="0">
                        <h1 class="home-heading"><%= HomeHeadingName %></h1>
                    </div>
                    <div class="home-stack">
                        <%-- data-text drives the CSS glitch layers; contentpage.js keeps it in sync with the text below. --%>
                        <p class="home-bio glitch-text reveal" data-reveal-delay="160">
                            Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor
                            incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud
                            exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute
                            irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla
                            pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
                            deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error
                            sit voluptatem accusantium doloremque laudantium, totam rem aperiam eaque ipsa quae
                            ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo.
                        </p>
                        <div class="profile-photo profile-photo--home reveal" data-reveal-delay="320">
                            <img src="/Assets/ContentPage/dev_photo.png" alt="<%= HomeHeadingName %>"
                                onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';" />
                            <div class="profile-photo-placeholder" aria-hidden="true">
                                <span class="ph-head"></span>
                                <span class="ph-body"></span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section id="about" class="section about-section">
                <div class="section-inner">
                    <%-- Hand-ordered so the heading slides in first and the column cascades behind it. --%>
                    <h2 class="section-heading reveal reveal--left" data-reveal-delay="0">Who am I?</h2>
                    <div class="about-content">
                        <div class="about-panels">
                            <article class="about-panel card-pastel-1 reveal" data-reveal-delay="120">
                                <h3>Personal Information</h3>
                                <p>Age: <%= Age %> yrs Old</p>
                                <p>Sex: Male</p>
                                <p>Birthdate: April 16, 2006</p>
                                <p>Nationality: Filipino</p>
                                <p>From: Baesa, Quezon City</p>

                            </article>
                            <article class="about-panel card-pastel-2 reveal" data-reveal-delay="230">
                                <h3>Educational Attainment</h3>
                                <p>- JHS: Dr. Carlos S. Lanting College</p>
                                <p>- SHS: Ismael Mathay Sr. High School</p>
                                <p>- College: Quezon City University - BSIT</p>
                            </article>
                            <article class="about-panel card-pastel-3 reveal" data-reveal-delay="340">
                                <h3>Hobbies and Interest</h3>
                                <%-- Emoji go in as character references, not literal characters: this file
                                     carries no BOM and Web.config sets no fileEncoding, so ASP.NET reads it
                                     as the system codepage and raw UTF-8 emoji bytes would come out mangled. --%>
                                <div class="hobbies">
                                    <span class="hobby-tag"><span class="hobby-tag-emoji" aria-hidden="true">&#x2708;&#xFE0F;</span>Travelling</span>
                                    <span class="hobby-tag"><span class="hobby-tag-emoji" aria-hidden="true">&#x1F697;</span>Driving</span>
                                    <span class="hobby-tag"><span class="hobby-tag-emoji" aria-hidden="true">&#x1F3AE;</span>Gaming</span>
                                    <span class="hobby-tag"><span class="hobby-tag-emoji" aria-hidden="true">&#x1F4BC;</span>Workaholism</span>
                                </div>
                            </article>
                        </div>
                        <%-- Same cutout portrait treatment as the home hero, parked on the right.
                             Its delay lands it after the three panels have cascaded in. --%>
                        <div class="profile-photo profile-photo--about reveal" data-reveal-delay="450">
                            <img src="/Assets/ContentPage/dev_photo.png" alt="<%= HomeHeadingName %>"
                                onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';" />
                            <div class="profile-photo-placeholder" aria-hidden="true">
                                <span class="ph-head"></span>
                                <span class="ph-body"></span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <section id="skills" class="section skills-section">
                <div class="section-inner">
                    <h2 class="section-heading">Projects</h2>
                    <div class="project-cards">
                        <article class="project-card card-pastel-1">
                            <h3>Library Management System</h3>
                            <p>Placeholder description of the Library Management System project goes here.</p>
                        </article>
                        <article class="project-card card-pastel-2">
                            <h3>Michael Jackson Player</h3>
                            <p>Placeholder description of the Michael Jackson Player project goes here.</p>
                        </article>
                        <article class="project-card card-pastel-3">
                            <h3>Event Management System</h3>
                            <p>Placeholder description of the Event Management System project goes here.</p>
                        </article>
                    </div>

                    <div class="tech-stack-panel">
                        <h3>Tech Stack</h3>
                        <div class="tech-tags">
                            <span class="tech-tag"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-html5.svg" alt="" />HTML</span>
                            <span class="tech-tag"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-css3.svg" alt="" />CSS</span>
                            <span class="tech-tag"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-javascript.svg" alt="" />JS</span>
                            <span class="tech-tag"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-react.svg" alt="" />React.js</span>
                            <span class="tech-tag"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-php.svg" alt="" />PHP</span>
                            <span class="tech-tag"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-dotnetcore.svg" alt="" />ASP.NET</span>
                            <span class="tech-tag"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-mssql.svg" alt="" />MSSQL</span>
                            <span class="tech-tag"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-mysql.svg" alt="" />MySQL</span>
                            <span class="tech-tag"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-git.svg" alt="" />Git</span>
                            <span class="tech-tag"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-github.svg" alt="" />GitHub</span>
                            <span class="tech-tag"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-csharp.svg" alt="" />C#</span>
                            <span class="tech-tag"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-java.svg" alt="" />Java</span>
                            <span class="tech-tag"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-vbnet.svg" alt="" />VB.NET</span>
                        </div>
                    </div>
                </div>
            </section>

            <section id="contact" class="section contact-section">
                <div class="section-inner">
                    <h2 class="section-heading">Contact Me!</h2>
                    <div class="contact-form-placeholder" aria-hidden="true"></div>
                </div>
            </section>
        </main>

    </div>
    </form>
    <script src="/Assets/js/ContentPage/contentpage.js?v=4"></script>
</body>
</html>
