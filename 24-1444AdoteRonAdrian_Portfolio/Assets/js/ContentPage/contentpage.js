(function () {
    "use strict";

    var navbar = document.getElementById("siteNavbar");
    var navToggle = document.getElementById("navToggle");
    var navLinksList = document.getElementById("navLinks");
    var navLinks = Array.prototype.slice.call(document.querySelectorAll(".nav-link"));
    var sections = navLinks
        .map(function (link) {
            var id = link.getAttribute("data-section");
            return document.getElementById(id);
        })
        .filter(Boolean);

    function setActiveLink(sectionId) {
        navLinks.forEach(function (link) {
            var isActive = link.getAttribute("data-section") === sectionId;
            link.classList.toggle("active", isActive);
        });
    }

    // Dynamic navbar: fully transparent at the top, a light blended wash once scrolled.
    if (navbar) {
        var topThreshold = 10;
        var tickingNavbar = false;

        var updateNavbarState = function () {
            var currentY = Math.max(window.pageYOffset || document.documentElement.scrollTop, 0);
            navbar.classList.toggle("navbar--top", currentY <= topThreshold);
            tickingNavbar = false;
        };

        window.addEventListener(
            "scroll",
            function () {
                if (!tickingNavbar) {
                    window.requestAnimationFrame(updateNavbarState);
                    tickingNavbar = true;
                }
            },
            { passive: true }
        );

        updateNavbarState();
    }

    // Smooth-scroll to a section. The navbar floats on top as an overlay (it doesn't
    // occupy layout space), so sections should land flush with the top of the viewport.
    navLinks.forEach(function (link) {
        link.addEventListener("click", function (event) {
            var targetId = link.getAttribute("data-section");
            var target = document.getElementById(targetId);
            if (!target) {
                return;
            }
            event.preventDefault();

            var targetTop = target.getBoundingClientRect().top + window.pageYOffset;

            window.scrollTo({ top: targetTop, behavior: "smooth" });
            setActiveLink(targetId);

            if (navLinksList && navLinksList.classList.contains("open")) {
                navLinksList.classList.remove("open");
                navToggle.setAttribute("aria-expanded", "false");
            }
        });
    });

    // Mobile nav collapse toggle.
    if (navToggle && navLinksList) {
        navToggle.addEventListener("click", function () {
            var isOpen = navLinksList.classList.toggle("open");
            navToggle.setAttribute("aria-expanded", isOpen ? "true" : "false");
        });
    }

    // Scrollspy: highlight the nav link for whichever section is crossing the top of the viewport.
    if ("IntersectionObserver" in window && sections.length) {
        var observer = new IntersectionObserver(
            function (entries) {
                entries.forEach(function (entry) {
                    if (entry.isIntersecting) {
                        setActiveLink(entry.target.id);
                    }
                });
            },
            {
                root: null,
                rootMargin: "0px 0px -70% 0px",
                threshold: 0,
            }
        );

        sections.forEach(function (section) {
            observer.observe(section);
        });
    }

    // TODO: functionality TBD for the circular navbar icon button (#navIconBtn).
})();
