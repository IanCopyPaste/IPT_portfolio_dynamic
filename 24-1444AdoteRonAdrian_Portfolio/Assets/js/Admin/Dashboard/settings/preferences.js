(function () {
    "use strict";

    var dash = window.AdminDash;
    var pageSize = dash.byId("prefPageSize");
    var relativeDates = dash.byId("prefRelativeDates");
    var sidebarCollapsed = dash.byId("prefSidebarCollapsed");
    var reset = dash.byId("prefReset");

    // The controls only write the preference; they are redrawn from the prefs:changed event, so the
    // Users table's own page-size list and the sidebar's toggle stay in agreement with this card.
    var switches = {
        relativeDates: relativeDates,
        sidebarCollapsed: sidebarCollapsed
    };

    var setSwitch = function (control, on) {
        control.setAttribute("aria-checked", on ? "true" : "false");
    };

    pageSize.value = String(dash.prefs.get("pageSize"));
    Object.keys(switches).forEach(function (key) {
        setSwitch(switches[key], dash.prefs.get(key));

        switches[key].addEventListener("click", function () {
            dash.prefs.set(key, switches[key].getAttribute("aria-checked") !== "true");
        });
    });

    pageSize.addEventListener("change", function () {
        dash.prefs.set("pageSize", parseInt(pageSize.value, 10));
    });

    reset.addEventListener("click", function () {
        dash.prefs.reset();
        dash.toast("Preferences restored to their defaults.");
    });

    dash.on("prefs:changed", function (change) {
        if (change.key === "pageSize") {
            pageSize.value = String(change.value);
        } else if (switches[change.key]) {
            setSwitch(switches[change.key], change.value);
        }
    });
})();
