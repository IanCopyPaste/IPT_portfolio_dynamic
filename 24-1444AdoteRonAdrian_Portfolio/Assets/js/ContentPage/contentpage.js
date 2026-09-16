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
    // The footer's in-page links share the handler, so they glide instead of jumping.
    var scrollLinks = navLinks.concat(
        Array.prototype.slice.call(document.querySelectorAll(".site-footer a[data-section]"))
    );

    scrollLinks.forEach(function (link) {
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

    // Home bio "corruption": each tick rebuilds the line from the pristine text with a
    // handful of characters swapped for symbols, so the copy reads as unstable without
    // ever drifting from the original. The monospace face keeps swaps from reflowing.
    var bio = document.querySelector(".home-bio");

    if (bio) {
        var bioText = bio.textContent.replace(/\s+/g, " ").trim();
        var glitchChars = "#%$&@!?/\\|<>*+=~^01";
        // Swap counts scale with the copy, so a long bio stays as visibly unstable as a short one.
        var steadySwaps = Math.max(5, Math.round(bioText.length * 0.03));
        var burstSwaps = Math.max(16, Math.round(bioText.length * 0.1));

        var corruptBio = function () {
            var chars = bioText.split("");
            var swaps = Math.random() < 0.25 ? burstSwaps : steadySwaps;

            for (var i = 0; i < swaps; i++) {
                var index = Math.floor(Math.random() * chars.length);
                if (chars[index] !== " ") {
                    chars[index] = glitchChars.charAt(Math.floor(Math.random() * glitchChars.length));
                }
            }

            var corrupted = chars.join("");
            bio.textContent = corrupted;
            bio.setAttribute("data-text", corrupted);
        };

        corruptBio();
        setInterval(corruptBio, 90);
    }

    // Slide each marked block in as it scrolls into view, once. Siblings stagger so a
    // row of cards cascades instead of landing as one slab. The classes come off on
    // animationend, leaving the element free of any lingering animation or opacity.
    var revealEls = Array.prototype.slice.call(document.querySelectorAll(".reveal"));

    var staggerIndex = function (el) {
        var index = 0;
        var sibling = el.previousElementSibling;

        while (sibling) {
            if (sibling.classList.contains("reveal")) {
                index++;
            }
            sibling = sibling.previousElementSibling;
        }

        return index;
    };

    // data-reveal-delay wins over the sibling stagger, so a hand-authored sequence
    // (the home block) can order elements that aren't siblings of one another.
    var revealDelay = function (el) {
        var authored = parseInt(el.getAttribute("data-reveal-delay"), 10);

        if (!isNaN(authored)) {
            return authored;
        }

        return Math.min(staggerIndex(el), 6) * 110;
    };

    var clearReveal = function (el) {
        el.classList.remove("reveal");
        el.classList.remove("is-visible");
        el.style.animationDelay = "";
    };

    if (revealEls.length && "IntersectionObserver" in window) {
        var revealObserver = new IntersectionObserver(function (entries) {
            entries.forEach(function (entry) {
                if (!entry.isIntersecting) {
                    return;
                }

                var el = entry.target;
                el.style.animationDelay = revealDelay(el) + "ms";
                el.classList.add("is-visible");
                revealObserver.unobserve(el);
            });
        }, { threshold: 0.12, rootMargin: "0px 0px -8% 0px" });

        revealEls.forEach(function (el) {
            // The bio and portrait run their own looping flicker animations; those bubble
            // up here, so only the element's own reveal animation should clear it.
            el.addEventListener("animationend", function (event) {
                if (event.target === el) {
                    clearReveal(el);
                }
            });

            revealObserver.observe(el);
        });
    } else {
        revealEls.forEach(clearReveal);
    }

    // Contact form. The fields sit inside the page-wide server <form>, so the send button is
    // type="button" and everything is checked here instead of by a postback.
    // TODO: nothing is delivered yet — hook the send up to a backend (SMTP from the code-behind,
    // or a form service) and replace the "not connected" status below.
    var contactSend = document.getElementById("contactSend");

    if (contactSend) {
        var contactStatus = document.getElementById("contactStatus");
        var contactMessage = document.getElementById("contactMessage");
        var contactCounter = document.getElementById("contactCounter");
        var contactFields = [
            { input: document.getElementById("contactName"), error: document.getElementById("contactNameError") },
            { input: document.getElementById("contactEmail"), error: document.getElementById("contactEmailError") },
            { input: contactMessage, error: document.getElementById("contactMessageError") }
        ];

        var fieldError = function (input) {
            var value = input.value.trim();

            if (!value) {
                return "This field is required.";
            }
            if (input.type === "email" && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)) {
                return "That doesn't look like an email address.";
            }
            if (input === contactMessage && value.length < 10) {
                return "A little more detail, please (10 characters minimum).";
            }
            return "";
        };

        var showFieldError = function (field) {
            var message = fieldError(field.input);
            field.error.textContent = message;
            field.input.parentNode.classList.toggle("is-invalid", !!message);
            field.input.setAttribute("aria-invalid", message ? "true" : "false");
            return !message;
        };

        var setStatus = function (text, isError) {
            contactStatus.textContent = text;
            contactStatus.classList.toggle("is-error", !!isError);
        };

        // Once a field has been flagged, re-check it as the visitor types so the error clears
        // the moment it is fixed rather than on the next click.
        contactFields.forEach(function (field) {
            field.input.addEventListener("input", function () {
                if (field.input.parentNode.classList.contains("is-invalid")) {
                    showFieldError(field);
                }
            });
        });

        var updateCounter = function () {
            contactCounter.textContent = contactMessage.value.length + " / " + contactMessage.maxLength;
        };

        contactMessage.addEventListener("input", updateCounter);
        updateCounter();

        contactSend.addEventListener("click", function () {
            var firstInvalid = null;

            contactFields.forEach(function (field) {
                if (!showFieldError(field) && !firstInvalid) {
                    firstInvalid = field.input;
                }
            });

            if (firstInvalid) {
                setStatus("fix the highlighted fields and try again.", true);
                firstInvalid.focus();
                return;
            }

            setStatus("message looks good, but sending isn't connected yet. please reach out through the socials below for now.", false);
        });
    }

    // TODO: functionality TBD for the circular navbar icon button (#navIconBtn).
})();
