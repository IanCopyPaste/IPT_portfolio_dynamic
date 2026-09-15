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

    // Which section is "current": the last one whose top has crossed a line
    // near the top of the viewport, falling back to the last section once
    // the page is scrolled to (or near) the bottom.
    function getActiveSectionId() {
        var scrollY = Math.max(window.pageYOffset || document.documentElement.scrollTop, 0);
        var docHeight = document.documentElement.scrollHeight;
        var atBottom = scrollY + window.innerHeight >= docHeight - 2;

        if (atBottom) {
            return sections[sections.length - 1].id;
        }

        var triggerLine = scrollY + window.innerHeight * 0.3;
        var activeId = sections[0].id;

        for (var i = 0; i < sections.length; i++) {
            var sectionTop = sections[i].getBoundingClientRect().top + scrollY;
            if (sectionTop <= triggerLine) {
                activeId = sections[i].id;
            } else {
                break;
            }
        }

        return activeId;
    }

    // Dynamic navbar (transparent at top, blended wash once scrolled) and the
    // scrollspy both need to read layout on scroll, so they share a single
    // rAF-throttled tick instead of running two separate scroll listeners.
    var topThreshold = 10;
    var ticking = false;

    var updateOnScroll = function () {
        var currentY = Math.max(window.pageYOffset || document.documentElement.scrollTop, 0);

        if (navbar) {
            navbar.classList.toggle("navbar--top", currentY <= topThreshold);
        }

        if (sections.length) {
            setActiveLink(getActiveSectionId());
        }

        ticking = false;
    };

    var requestScrollUpdate = function () {
        if (!ticking) {
            window.requestAnimationFrame(updateOnScroll);
            ticking = true;
        }
    };

    window.addEventListener("scroll", requestScrollUpdate, { passive: true });
    window.addEventListener("resize", requestScrollUpdate, { passive: true });

    updateOnScroll();

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

    // TODO: functionality TBD for the circular navbar icon button (#navIconBtn).
})();
