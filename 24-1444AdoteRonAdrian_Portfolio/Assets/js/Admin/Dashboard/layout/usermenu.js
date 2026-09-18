(function () {
    "use strict";

    var dash = window.AdminDash;
    var menu = dash.byId("dashUserMenu");
    var trigger = dash.byId("dashUserMenuTrigger");

    // Long enough to cross the gap between the trigger and the panel without it closing.
    var CLOSE_DELAY_MS = 180;
    var closeTimer = null;

    // A click pins the menu open, so it stays after the pointer leaves; hover alone doesn't.
    var pinned = false;

    var setOpen = function (open) {
        clearTimeout(closeTimer);
        menu.classList.toggle("is-open", open);
        trigger.setAttribute("aria-expanded", open ? "true" : "false");
        if (!open) {
            pinned = false;
        }
    };

    var isOpen = function () {
        return menu.classList.contains("is-open");
    };

    // Hover is for a mouse; a touch "hover" would open the menu and the same tap would close it.
    menu.addEventListener("pointerenter", function (event) {
        if (event.pointerType === "mouse") {
            setOpen(true);
        }
    });

    menu.addEventListener("pointerleave", function (event) {
        if (event.pointerType === "mouse" && !pinned) {
            closeTimer = setTimeout(function () {
                setOpen(false);
            }, CLOSE_DELAY_MS);
        }
    });

    trigger.addEventListener("click", function () {
        if (isOpen() && pinned) {
            setOpen(false);
            return;
        }
        setOpen(true);
        pinned = true;
    });

    document.addEventListener("click", function (event) {
        if (isOpen() && !menu.contains(event.target)) {
            setOpen(false);
        }
    });

    document.addEventListener("keydown", function (event) {
        if (event.key === "Escape" && isOpen()) {
            setOpen(false);
            trigger.focus();
        }
    });

    // Tabbing out of the panel closes it, so it isn't left open behind the next control.
    menu.addEventListener("focusout", function (event) {
        if (isOpen() && event.relatedTarget && !menu.contains(event.relatedTarget)) {
            setOpen(false);
        }
    });
})();
