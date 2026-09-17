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
    <%-- Order matters: tokens and base first, sections in page order, then the reveal
         and responsive overrides, which have to win over the section rules. --%>
    <link href="/Assets/css/ContentPage/contentpage.css?v=19" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/home.css?v=3" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/about.css?v=5" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/skills.css?v=3" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/contact.css?v=3" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/reveal.css?v=3" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/responsive.css?v=5" rel="stylesheet" />
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

                <%-- The account button opens the profile page. Hovering or focusing it names the
                     signed-in user. The name is user-entered, so it goes out HTML-encoded. --%>
                <a class="icon-btn" id="navIconBtn" href="ProfilePage.aspx" aria-label="Your profile: <%: AccountName %>">
                    <span class="icon-btn-glyph"></span>
                    <span class="icon-btn-tooltip" aria-hidden="true">
                        <span class="icon-btn-tooltip-label">signed in as</span>
                        <span class="icon-btn-tooltip-name"><%: AccountName %></span>
                    </span>
                </a>
            </div>
        </nav>

        <main>
            <section id="home" class="section home-section">
                <div class="section-inner">
                    <%-- The home block is in view on load, so its reveals fire immediately;
                         the delays stage them into a name → bio → portrait sequence. --%>
                    <div class="home-heading-row reveal" data-reveal-delay="0">
                        <%-- The glitch layers read data-text, so it has to match the heading. --%>
                        <div class="home-heading-wrap" data-text="<%= HomeHeadingName %>">
                            <h1 class="home-heading"><%= HomeHeadingName %></h1>
                        </div>
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
                    <h2 class="section-heading reveal reveal--left" data-reveal-delay="60">Who am I?</h2>
                    <div class="about-content">
                        <div class="about-panels">
                            <article class="about-panel reveal" data-reveal-delay="120">
                                <h3><span class="about-panel-index" aria-hidden="true">01</span>Personal Information</h3>
                                <dl class="about-details">
                                    <div class="about-detail"><dt>Age</dt><dd><%= Age %> yrs Old</dd></div>
                                    <div class="about-detail"><dt>Sex</dt><dd>Male</dd></div>
                                    <div class="about-detail"><dt>Birthdate</dt><dd>April 16, 2006</dd></div>
                                    <div class="about-detail"><dt>Nationality</dt><dd>Filipino</dd></div>
                                    <div class="about-detail about-detail--wide"><dt>From</dt><dd>Baesa, Quezon City</dd></div>
                                </dl>
                            </article>
                            <article class="about-panel reveal" data-reveal-delay="230">
                                <h3><span class="about-panel-index" aria-hidden="true">02</span>Educational Attainment</h3>
                                <ol class="about-timeline">
                                    <li class="about-timeline-item">
                                        <abbr class="about-timeline-level" title="Junior High School">JHS</abbr>
                                        <span class="about-timeline-school">Dr. Carlos S. Lanting College</span>
                                    </li>
                                    <li class="about-timeline-item">
                                        <abbr class="about-timeline-level" title="Senior High School">SHS</abbr>
                                        <span class="about-timeline-school">Ismael Mathay Sr. High School</span>
                                    </li>
                                    <li class="about-timeline-item">
                                        <span class="about-timeline-level">College</span>
                                        <span class="about-timeline-school">Quezon City University</span>
                                        <abbr class="about-timeline-course" title="Bachelor of Science in Information Technology">BSIT</abbr>
                                    </li>
                                </ol>
                            </article>
                            <article class="about-panel reveal" data-reveal-delay="340">
                                <h3><span class="about-panel-index" aria-hidden="true">03</span>Hobbies and Interest</h3>
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
                            <img src="/Assets/ContentPage/dev_photo2.png" alt="<%= HomeHeadingName %>"
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
                    <%-- Same hand-ordered cascade as the About section: heading, then the cards, then the
                         panel. Each tag is observed on its own, so its delay is measured from when that
                         tag scrolls in; the offsets hold the chips back until the panel has mostly landed. --%>
                    <h2 class="section-heading reveal reveal--left" data-reveal-delay="60">Projects</h2>
                    <div class="project-cards">
                        <a class="project-card reveal" data-reveal-delay="120" href="https://github.com/IanCopyPaste/LibraryManagementSystem" target="_blank" rel="noopener noreferrer">
                            <img class="project-card-image" src="/Assets/ContentPage/Library_Management_System.png" alt=""
                                onerror="this.parentNode.classList.add('project-card--no-image'); this.style.display='none';" />
                            <div class="project-card-overlay">
                                <h3>Library Management System</h3>
                                <p>Placeholder description of the Library Management System project goes here.</p>
                            </div>
                        </a>
                        <a class="project-card reveal" data-reveal-delay="230" href="https://mj-player.vercel.app/" target="_blank" rel="noopener noreferrer">
                            <img class="project-card-image" src="/Assets/ContentPage/Michael_Jackson_Player.png" alt=""
                                onerror="this.parentNode.classList.add('project-card--no-image'); this.style.display='none';" />
                            <div class="project-card-overlay">
                                <h3>Michael Jackson Player</h3>
                                <p>Placeholder description of the Michael Jackson Player project goes here.</p>
                            </div>
                        </a>
                        <a class="project-card reveal" data-reveal-delay="340" href="https://github.com/IanCopyPaste/Event_Management_System" target="_blank" rel="noopener noreferrer">
                            <img class="project-card-image" src="/Assets/ContentPage/Event_Management_System.png" alt=""
                                onerror="this.parentNode.classList.add('project-card--no-image'); this.style.display='none';" />
                            <div class="project-card-overlay">
                                <h3>Event Management System</h3>
                                <p>Placeholder description of the Event Management System project goes here.</p>
                            </div>
                        </a>
                    </div>

                    <div class="tech-stack-panel reveal" data-reveal-delay="450">
                        <div class="terminal-bar" aria-hidden="true">
                            <span class="terminal-dot"></span>
                            <span class="terminal-dot"></span>
                            <span class="terminal-dot"></span>
                            <span class="terminal-path">~/portfolio/tech-stack</span>
                        </div>
                        <div class="tech-stack-body">
                            <h3>Tech Stack</h3>
                            <p class="tech-stack-prompt" aria-hidden="true">$ ls ./stack --all</p>
                            <div class="tech-tags">
                                <span class="tech-tag reveal" data-reveal-delay="550"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-html5.svg" alt="" />HTML</span>
                                <span class="tech-tag reveal" data-reveal-delay="590"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-css3.svg" alt="" />CSS</span>
                                <span class="tech-tag reveal" data-reveal-delay="630"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-javascript.svg" alt="" />JS</span>
                                <span class="tech-tag reveal" data-reveal-delay="670"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-react.svg" alt="" />React.js</span>
                                <span class="tech-tag reveal" data-reveal-delay="710"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-php.svg" alt="" />PHP</span>
                                <span class="tech-tag reveal" data-reveal-delay="750"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-dotnetcore.svg" alt="" />ASP.NET</span>
                                <span class="tech-tag reveal" data-reveal-delay="790"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-mssql.svg" alt="" />MSSQL</span>
                                <span class="tech-tag reveal" data-reveal-delay="830"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-mysql.svg" alt="" />MySQL</span>
                                <span class="tech-tag reveal" data-reveal-delay="870"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-git.svg" alt="" />Git</span>
                                <span class="tech-tag reveal" data-reveal-delay="910"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-github.svg" alt="" />GitHub</span>
                                <span class="tech-tag reveal" data-reveal-delay="950"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-csharp.svg" alt="" />C#</span>
                                <span class="tech-tag reveal" data-reveal-delay="990"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-java.svg" alt="" />Java</span>
                                <span class="tech-tag reveal" data-reveal-delay="1030"><img class="tech-tag-icon" src="/Assets/ContentPage/logo-vbnet.svg" alt="" />VB.NET</span>
                            </div>
                        </div>
                    </div>
                </div>
            </section>

            <%-- The footer lives inside the last section rather than after <main>: it closes out the
                 contact screen instead of hanging below it as a separate strip. --%>
            <section id="contact" class="section contact-section">
                <div class="section-inner">
                    <h2 class="section-heading reveal reveal--left" data-reveal-delay="60">Contact Me!</h2>
                    <div class="contact-layout">
                        <div class="contact-info reveal" data-reveal-delay="120">
                            <p class="contact-lead">Let's build something.</p>
                            <p class="contact-intro">
                                Have a project in mind, an opening on your team, or just want to talk code?
                                Drop a message and I'll get back to you as soon as I can.
                            </p>
                            <dl class="contact-facts">
                                <div class="contact-fact">
                                    <dt>Status</dt>
                                    <dd><span class="status-dot" aria-hidden="true"></span>Open to internships &amp; freelance work</dd>
                                </div>
                                <div class="contact-fact">
                                    <dt>Based in</dt>
                                    <dd>Quezon City, Philippines</dd>
                                </div>
                                <div class="contact-fact">
                                    <dt>Replies</dt>
                                    <dd>Usually within 24&ndash;48 hours</dd>
                                </div>
                            </dl>
                        </div>

                        <%-- Plain inputs, not server controls, and a type="button" send: the whole page already
                             sits inside the server <form>, so a real submit would post the page back. Sending
                             isn't wired up yet — contentpage.js validates and reports that honestly. --%>
                        <div class="contact-form-panel reveal" data-reveal-delay="230">
                            <div class="terminal-bar" aria-hidden="true">
                                <span class="terminal-dot"></span>
                                <span class="terminal-dot"></span>
                                <span class="terminal-dot"></span>
                                <span class="terminal-path">~/portfolio/contact --new-message</span>
                            </div>
                            <div class="contact-form" id="contactForm">
                                <div class="contact-form-row">
                                    <div class="contact-field">
                                        <label for="contactName">Name</label>
                                        <input type="text" id="contactName" name="contactName" autocomplete="name"
                                            placeholder="Juan Dela Cruz" maxlength="80" required="required" />
                                        <span class="contact-error" id="contactNameError" aria-live="polite"></span>
                                    </div>
                                    <div class="contact-field">
                                        <label for="contactEmail">Email</label>
                                        <input type="email" id="contactEmail" name="contactEmail" autocomplete="email"
                                            placeholder="you@example.com" maxlength="120" required="required" />
                                        <span class="contact-error" id="contactEmailError" aria-live="polite"></span>
                                    </div>
                                </div>
                                <div class="contact-field contact-field--select">
                                    <label for="contactTopic">What's it about?</label>
                                    <select id="contactTopic" name="contactTopic">
                                        <option value="project">A project or freelance work</option>
                                        <option value="job">A job or internship opportunity</option>
                                        <option value="collab">A collaboration</option>
                                        <option value="hello">Just saying hi</option>
                                    </select>
                                </div>
                                <div class="contact-field">
                                    <label for="contactMessage">Message</label>
                                    <textarea id="contactMessage" name="contactMessage" rows="5" maxlength="1000"
                                        placeholder="Tell me a bit about what you have in mind..." required="required"></textarea>
                                    <span class="contact-error" id="contactMessageError" aria-live="polite"></span>
                                    <span class="contact-counter" id="contactCounter" aria-hidden="true">0 / 1000</span>
                                </div>
                                <div class="contact-actions">
                                    <button type="button" class="contact-send" id="contactSend">Send message</button>
                                    <p class="contact-status" id="contactStatus" role="status" aria-live="polite"></p>
                                </div>
                            </div>
                        </div>
                    </div>

                    <footer class="site-footer reveal" data-reveal-delay="340">
                        <div class="footer-grid">
                            <div class="footer-brand">
                                <a class="footer-brand-name" href="#home" data-section="home"><%= SiteBrandName %></a>
                                <p class="footer-tagline">
                                    A student developer from Quezon City building web apps, systems and the
                                    occasional music player &mdash; one commit at a time.
                                </p>
                            </div>

                            <nav class="footer-nav" aria-label="Footer">
                                <h3 class="footer-heading">Navigate</h3>
                                <ul>
                                    <li><a class="footer-link" href="#home" data-section="home">Home</a></li>
                                    <li><a class="footer-link" href="#about" data-section="about">About</a></li>
                                    <li><a class="footer-link" href="#skills" data-section="skills">Skills</a></li>
                                    <li><a class="footer-link" href="#contact" data-section="contact">Contact</a></li>
                                </ul>
                            </nav>

                            <div class="footer-socials">
                                <h3 class="footer-heading">Find me on</h3>
                                <%-- Placeholder hrefs: each points at the site's home page until the real profile
                                     URL goes in. --%>
                                <ul class="social-list">
                                    <li>
                                        <a class="social-link" href="https://www.instagram.com/" target="_blank" rel="noopener noreferrer">
                                            <span class="social-icon social-icon--instagram" aria-hidden="true"></span>
                                            <span class="social-text">
                                                <span class="social-name">Instagram</span>
                                                <span class="social-note">Snapshots &amp; behind the scenes</span>
                                            </span>
                                        </a>
                                    </li>
                                    <li>
                                        <a class="social-link" href="https://www.facebook.com/" target="_blank" rel="noopener noreferrer">
                                            <span class="social-icon social-icon--facebook" aria-hidden="true"></span>
                                            <span class="social-text">
                                                <span class="social-name">Facebook</span>
                                                <span class="social-note">Say hello anytime</span>
                                            </span>
                                        </a>
                                    </li>
                                    <li>
                                        <a class="social-link" href="https://github.com/" target="_blank" rel="noopener noreferrer">
                                            <span class="social-icon social-icon--github" aria-hidden="true"></span>
                                            <span class="social-text">
                                                <span class="social-name">GitHub</span>
                                                <span class="social-note">Code, projects &amp; commits</span>
                                            </span>
                                        </a>
                                    </li>
                                    <li>
                                        <a class="social-link" href="https://www.linkedin.com/" target="_blank" rel="noopener noreferrer">
                                            <span class="social-icon social-icon--linkedin" aria-hidden="true"></span>
                                            <span class="social-text">
                                                <span class="social-name">LinkedIn</span>
                                                <span class="social-note">Work &amp; experience</span>
                                            </span>
                                        </a>
                                    </li>
                                </ul>
                            </div>
                        </div>

                        <div class="footer-bottom">
                            <p class="footer-copy">&copy; <%= DateTime.Today.Year %> <%= HomeHeadingName %>. All rights reserved.</p>
                            <p class="footer-built">Hand-built with ASP.NET, HTML, CSS &amp; JavaScript.</p>
                            <a class="footer-top-link" href="#home" data-section="home">Back to top <span aria-hidden="true">&uarr;</span></a>
                        </div>
                    </footer>
                </div>
            </section>
        </main>

    </div>
    </form>
    <script src="/Assets/js/ContentPage/contentpage.js?v=6"></script>
</body>
</html>
