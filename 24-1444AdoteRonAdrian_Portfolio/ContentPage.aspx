<%@ Page Language="C#" AutoEventWireup="true" CodeBehind="ContentPage.aspx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.ContentPage" %>

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
    <link href="/Assets/css/ContentPage/contentpage.css?v=20" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/home.css?v=3" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/about.css?v=7" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/skills.css?v=4" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/contact.css?v=4" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/reveal.css?v=3" rel="stylesheet" />
    <link href="/Assets/css/ContentPage/responsive.css?v=6" rel="stylesheet" />
    <link href="/DEV_PHOTO.png" rel="icon" type="image/png" />
</head>
<body>
    <form id="form1" runat="server">
    <div>

        <nav class="navbar navbar--top" id="siteNavbar">
            <div class="navbar-inner">
                <%-- The portfolio is branded with whoever it belongs to, not with the site: the
                     sign-in screens use SiteBrandName, this page uses its owner. --%>
                <a class="navbar-brand" href="#home"><%: BrandName %></a>

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
                        <div class="home-heading-wrap" data-text="<%: OwnerName %>">
                            <h1 class="home-heading"><%: OwnerName %></h1>
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
                        <%-- No portrait, nothing here: the hero is the name and the bio, and an empty
                             frame beside them would read as something that failed to load. --%>
                        <% if (HasHomePhoto) { %>
                        <div class="profile-photo profile-photo--home reveal" data-reveal-delay="320">
                            <img src="<%: Owner.HomePhotoUrl %>" alt="<%: OwnerName %>"
                                onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';" />
                            <%-- The silhouette is the fallback for a row that points at a file that is
                                 no longer on disk, not for a user who never uploaded one. --%>
                            <div class="profile-photo-placeholder" aria-hidden="true">
                                <span class="ph-head"></span>
                                <span class="ph-body"></span>
                            </div>
                        </div>
                        <% } %>
                    </div>
                </div>
            </section>

            <section id="about" class="section about-section">
                <div class="section-inner">
                    <%-- Hand-ordered so the heading slides in first and the column cascades behind it. --%>
                    <h2 class="section-heading reveal reveal--left" data-reveal-delay="60">Who am I?</h2>
                    <div class="about-content">
                        <div class="about-panels">
                            <%-- Every value below is the signed-in user's own, and every one of them
                                 can still be blank: a brand-new account has a name and an address and
                                 nothing else, so each field falls back to its placeholder. --%>
                            <article class="about-panel reveal" data-reveal-delay="120">
                                <h3><span class="about-panel-index" aria-hidden="true">01</span>Personal Information</h3>
                                <dl class="about-details">
                                    <div class="about-detail"><dt>Age</dt><dd class="<%= UnsetClass(Owner.Age == null) %>"><%: AgeText %></dd></div>
                                    <div class="about-detail"><dt>Sex</dt><dd class="<%= UnsetClass(Owner.Sex) %>"><%: Or(Owner.Sex) %></dd></div>
                                    <div class="about-detail"><dt>Birthdate</dt><dd class="<%= UnsetClass(Owner.Birthdate == null) %>"><%: BirthdateText %></dd></div>
                                    <div class="about-detail"><dt>Nationality</dt><dd class="<%= UnsetClass(Owner.Nationality) %>"><%: Or(Owner.Nationality) %></dd></div>
                                    <div class="about-detail about-detail--wide"><dt>From</dt><dd class="<%= UnsetClass(Owner.Address) %>"><%: Or(Owner.Address) %></dd></div>
                                </dl>
                            </article>
                            <%-- Three fixed stages rather than a list the user can add to: the rail is
                                 a path through school, and a missing stage still has to hold its place
                                 on it or the two either side would read as consecutive. --%>
                            <article class="about-panel reveal" data-reveal-delay="230">
                                <h3><span class="about-panel-index" aria-hidden="true">02</span>Educational Attainment</h3>
                                <ol class="about-timeline">
                                    <li class="about-timeline-item">
                                        <abbr class="about-timeline-level" title="Junior High School">JHS</abbr>
                                        <span class="about-timeline-school <%= UnsetClass(Owner.JhsSchool) %>"><%: Or(Owner.JhsSchool) %></span>
                                    </li>
                                    <li class="about-timeline-item">
                                        <abbr class="about-timeline-level" title="Senior High School">SHS</abbr>
                                        <span class="about-timeline-school <%= UnsetClass(Owner.ShsSchool) %>"><%: Or(Owner.ShsSchool) %></span>
                                    </li>
                                    <li class="about-timeline-item">
                                        <span class="about-timeline-level">College</span>
                                        <span class="about-timeline-school <%= UnsetClass(Owner.CollegeSchool) %>"><%: Or(Owner.CollegeSchool) %></span>
                                        <%-- The course is the one part with no placeholder: an empty
                                             second line under the school would read as a value that
                                             went missing rather than one that was never asked for. --%>
                                        <% if (Owner.CollegeCourse.Length > 0) { %>
                                        <span class="about-timeline-course"><%: Owner.CollegeCourse %></span>
                                        <% } %>
                                    </li>
                                </ol>
                            </article>
                            <article class="about-panel reveal" data-reveal-delay="340">
                                <h3><span class="about-panel-index" aria-hidden="true">03</span>Hobbies and Interest</h3>
                                <%-- Four slots on the form, however many of them were filled in here.
                                     No emoji any more: they were picked to suit one person's list, and
                                     there is no guessing one for a hobby somebody types in. --%>
                                <div class="hobbies">
                                    <% foreach (string hobby in Owner.FilledHobbies) { %>
                                    <span class="hobby-tag"><%: hobby %></span>
                                    <% } %>
                                    <% if (!HasHobbies) { %>
                                    <p class="cp-unset cp-unset--block">No hobbies added yet.</p>
                                    <% } %>
                                </div>
                            </article>
                        </div>
                        <%-- Same cutout portrait treatment as the home hero, parked on the right.
                             Its delay lands it after the three panels have cascaded in. --%>
                        <% if (HasAboutPhoto) { %>
                        <div class="profile-photo profile-photo--about reveal" data-reveal-delay="450">
                            <img src="<%: Owner.AboutPhotoUrl %>" alt="<%: OwnerName %>"
                                onerror="this.style.display='none'; this.nextElementSibling.style.display='flex';" />
                            <div class="profile-photo-placeholder" aria-hidden="true">
                                <span class="ph-head"></span>
                                <span class="ph-body"></span>
                            </div>
                        </div>
                        <% } else { %>
                        <%-- Unlike the hero, this column is half the layout: leaving it out would
                             strand the panels, so the empty frame says so instead. --%>
                        <div class="profile-photo profile-photo--about photo-unset reveal" data-reveal-delay="450">
                            <span class="photo-unset-mark" aria-hidden="true"></span>
                            <p class="photo-unset-text">Image isn&rsquo;t set yet</p>
                        </div>
                        <% } %>
                    </div>
                </div>
            </section>

            <section id="skills" class="section skills-section">
                <div class="section-inner">
                    <%-- Same hand-ordered cascade as the About section: heading, then the chips, then
                         the two panels. Each tag is observed on its own, so its delay is measured from
                         when that tag scrolls in; the offsets hold the chips back until the panel has
                         mostly landed. --%>
                    <h2 class="section-heading reveal reveal--left" data-reveal-delay="60">Skills</h2>
                    <div class="skill-tags">
                        <%-- Stepped by hand at the tech tags' cadence rather than left to the automatic
                             sibling stagger, so the chips carry on from the heading instead of
                             restarting at zero underneath it. --%>
                        <% int skillDelay = 120; %>
                        <% foreach (string skill in Owner.FilledSkills) { %>
                        <span class="skill-tag reveal" data-reveal-delay="<%= skillDelay %>"><%: skill %></span>
                        <% skillDelay += 40; %>
                        <% } %>
                        <% if (!HasSkills) { %>
                        <p class="cp-unset cp-unset--block reveal" data-reveal-delay="120">No skills added yet.</p>
                        <% } %>
                    </div>

                    <%-- The projects are the user's own five lines of text, so they are listed rather
                         than given the screenshot cards this section used to carry: there is no image
                         to show for a project somebody has only named. The panel is the tech stack's
                         terminal window, so the two read as one pair. --%>
                    <div class="project-panel reveal" data-reveal-delay="230">
                        <div class="terminal-bar" aria-hidden="true">
                            <span class="terminal-dot"></span>
                            <span class="terminal-dot"></span>
                            <span class="terminal-dot"></span>
                            <span class="terminal-path">~/portfolio/projects</span>
                        </div>
                        <div class="project-panel-body">
                            <h3>Top Projects</h3>
                            <p class="project-prompt" aria-hidden="true">$ cat ./projects --top <%= ProjectSlots %></p>
                            <% if (HasProjects) { %>
                            <ol class="project-list">
                                <% foreach (string project in Owner.FilledProjects) { %>
                                <li><%: project %></li>
                                <% } %>
                            </ol>
                            <% } else { %>
                            <p class="cp-unset cp-unset--block">No projects added yet.</p>
                            <% } %>
                        </div>
                    </div>

                    <div class="tech-stack-panel reveal" data-reveal-delay="340">
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
                                <%-- The same account address the About panel shows as "From": one
                                     value, so the two can't contradict each other. --%>
                                <div class="contact-fact">
                                    <dt>Based in</dt>
                                    <dd class="<%= UnsetClass(Owner.Address) %>"><%: Or(Owner.Address) %></dd>
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
                                <a class="footer-brand-name" href="#home" data-section="home"><%: BrandName %></a>
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
                        </div>

                        <div class="footer-bottom">
                            <p class="footer-copy">&copy; <%= DateTime.Today.Year %> <%: OwnerName %>. All rights reserved.</p>
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
