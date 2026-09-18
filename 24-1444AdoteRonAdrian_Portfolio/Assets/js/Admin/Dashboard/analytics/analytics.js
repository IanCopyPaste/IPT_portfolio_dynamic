(function () {
    "use strict";

    var dash = window.AdminDash;
    var body = dash.byId("analyticsBody");
    var errorBox = dash.byId("analyticsError");
    var updated = dash.byId("analyticsUpdated");
    var refreshButton = dash.byId("analyticsRefresh");
    var recentList = dash.byId("analyticsRecent");

    var loaded = false;
    var loading = false;
    // Set when a user is changed or deleted elsewhere, so the figures are fetched again the next
    // time this view is opened rather than showing counts that are no longer true.
    var stale = false;
    var lastData = null;

    var chartArea = function (name) {
        return body.querySelector('[data-chart="' + name + '"]');
    };

    var setTile = function (metric, value, hint) {
        var tile = body.querySelector('[data-metric="' + metric + '"]');
        tile.querySelector('[data-role="value"]').textContent = dash.format.number(value);
        tile.querySelector('[data-role="hint"]').textContent = hint;
    };

    var renderTiles = function (data) {
        var total = data.totalUsers;
        setTile("total", total, "Excluding administrators");
        setTile("active", data.activeUsers, dash.format.percent(data.activeUsers, total) + "% of users");
        setTile("inactive", data.inactiveUsers, dash.format.percent(data.inactiveUsers, total) + "% of users");
        setTile("new", data.newLast30Days, dash.format.plural(data.signedInLast30Days, "user") + " signed in over the same period");
    };

    var renderCharts = function (data) {
        dash.charts.columns(chartArea("signups"), data.signupsByMonth, {
            unit: "sign-up",
            unitHeading: "Sign-ups",
            caption: "Sign-ups by month",
            emptyText: "No sign-ups in the last 12 months."
        });

        dash.charts.split(chartArea("status"), [
            { label: "Active", count: data.activeUsers, className: "adm-split-segment--active" },
            { label: "Inactive", count: data.inactiveUsers, className: "adm-split-segment--inactive" }
        ], { emptyText: "No accounts yet." });

        dash.charts.barList(chartArea("last-sign-in"), data.lastSignIn, data.totalUsers, {
            emptyText: "No accounts yet."
        });

        dash.charts.barList(chartArea("profile"), data.profileFields, data.totalUsers, {
            emptyText: "No accounts yet."
        });
    };

    var renderRecent = function (users) {
        dash.clear(recentList);

        if (!users.length) {
            recentList.appendChild(dash.el("li", { className: "adm-chart-empty", text: "No accounts yet." }));
            return;
        }

        users.forEach(function (user) {
            var name = dash.format.displayName(user);
            var button = dash.el("button", {
                type: "button",
                className: "adm-recent-item",
                "aria-label": "Manage " + name
            }, [
                dash.el("span", { className: "adm-avatar", "aria-hidden": "true", text: dash.format.initials(user.fullName, user.username) }),
                dash.el("span", { className: "adm-recent-text" }, [
                    dash.el("span", { className: "adm-recent-name", text: name }),
                    dash.el("span", { className: "adm-recent-meta", text: user.username ? "@" + user.username : "No username" })
                ]),
                dash.el("span", { className: "adm-recent-when", text: dash.format.when(user.createdAt) })
            ]);

            button.addEventListener("click", function () {
                dash.emit("user:manage", { id: user.id });
            });

            recentList.appendChild(dash.el("li", null, [button]));
        });
    };

    var showError = function (message) {
        errorBox.textContent = message;
        errorBox.classList.toggle("is-visible", !!message);
    };

    var load = function () {
        // The request already in flight may have been answered before the latest change; flagging
        // it has another one sent when this finishes.
        if (loading) {
            stale = true;
            return;
        }
        loading = true;
        stale = false;
        showError("");
        body.setAttribute("aria-busy", "true");
        refreshButton.classList.add("is-busy");
        refreshButton.setAttribute("aria-disabled", "true");
        if (loaded) {
            body.classList.add("is-refreshing");
        }

        dash.api.get("Analytics.ashx").then(function (data) {
            loaded = true;
            lastData = data;
            renderTiles(data);
            renderCharts(data);
            renderRecent(data.recentSignups);
            updated.textContent = "Updated " + dash.format.time(new Date());
        }).catch(function (error) {
            showError(error.message);
        }).then(function () {
            loading = false;
            body.classList.remove("is-refreshing");
            body.setAttribute("aria-busy", "false");
            refreshButton.classList.remove("is-busy");
            refreshButton.removeAttribute("aria-disabled");

            if (stale && dash.router.current() === "analytics") {
                load();
            }
        });
    };

    refreshButton.addEventListener("click", function () {
        if (!loading) {
            load();
        }
    });

    dash.on("view:show", function (name) {
        if (name === "analytics" && (!loaded || stale)) {
            load();
        }
    });

    // A change made from this view (through Recent sign-ups) is reflected at once; one made from
    // another view waits until this one is opened again.
    var markStale = function () {
        if (dash.router.current() === "analytics") {
            load();
        } else {
            stale = true;
        }
    };

    dash.on("user:changed", markStale);
    dash.on("user:deleted", markStale);

    dash.on("prefs:changed", function (change) {
        if (change.key === "relativeDates" && lastData) {
            renderRecent(lastData.recentSignups);
        }
    });
})();
