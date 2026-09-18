(function () {
    "use strict";

    var dash = window.AdminDash;

    // Which view shows is kept in the URL hash (#users), so Back/Forward, a reload and a bookmark all
    // land on the same view. No hash, or one naming no view, means Analytics.
    var DEFAULT_VIEW = "analytics";

    var views = {};
    Array.prototype.slice.call(document.querySelectorAll(".adm-view[data-view]")).forEach(function (view) {
        views[view.getAttribute("data-view")] = view;
    });

    var links = Array.prototype.slice.call(document.querySelectorAll(".adm-nav-item[data-view]"));
    var title = dash.byId("dashTitle");
    var titleSuffix = document.querySelector("title").getAttribute("data-suffix");
    var current = null;

    var viewFromHash = function () {
        var name = window.location.hash.replace(/^#/, "");
        return views.hasOwnProperty(name) ? name : DEFAULT_VIEW;
    };

    var show = function (name, moveFocus) {
        if (name === current) {
            return;
        }
        current = name;

        Object.keys(views).forEach(function (key) {
            views[key].hidden = key !== name;
        });

        links.forEach(function (link) {
            var active = link.getAttribute("data-view") === name;
            link.classList.toggle("is-active", active);
            if (active) {
                link.setAttribute("aria-current", "page");
            } else {
                link.removeAttribute("aria-current");
            }
        });

        var label = views[name].getAttribute("data-title");
        title.textContent = label;
        document.title = label + " - " + titleSuffix;

        // After a click, a screen reader is moved to the new heading; on first load it isn't.
        if (moveFocus) {
            title.focus();
        }

        dash.emit("view:show", name);
    };

    window.addEventListener("hashchange", function () {
        show(viewFromHash(), true);
    });

    dash.router = {
        current: function () {
            return current;
        },

        // Called by main.js once every view has subscribed to view:show.
        start: function () {
            show(viewFromHash(), false);
        }
    };
})();
