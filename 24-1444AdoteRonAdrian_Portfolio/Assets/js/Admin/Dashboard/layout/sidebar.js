(function () {
    "use strict";

    var dash = window.AdminDash;
    var root = document.documentElement;
    var toggle = dash.byId("dashSidebarToggle");
    var COLLAPSED_CLASS = "adm-sidebar-collapsed";

    // The class itself was put on <html> by the inline script in <head>; this keeps the toggle's
    // state and label in step with it. Settings > Collapsed sidebar goes through the same pref.
    var apply = function (collapsed) {
        root.classList.toggle(COLLAPSED_CLASS, collapsed);
        toggle.setAttribute("aria-expanded", collapsed ? "false" : "true");
        toggle.setAttribute("aria-label", collapsed ? "Expand sidebar" : "Collapse sidebar");
    };

    toggle.addEventListener("click", function () {
        dash.prefs.set("sidebarCollapsed", !root.classList.contains(COLLAPSED_CLASS));
    });

    dash.on("prefs:changed", function (change) {
        if (change.key === "sidebarCollapsed") {
            apply(change.value);
        }
    });

    apply(dash.prefs.get("sidebarCollapsed"));
})();
