(function () {
    "use strict";

    var dash = window.AdminDash;
    var table = dash.byId("usersTable");
    var tbody = dash.byId("usersBody");
    var searchInput = dash.byId("usersSearch");
    var statusSelect = dash.byId("usersStatus");
    var summary = dash.byId("usersSummary");
    var range = dash.byId("usersRange");
    var pager = dash.byId("usersPager");
    var pageSizeSelect = dash.byId("usersPageSize");

    // How long typing has to pause before the search is sent. One request per pause, not per key.
    var SEARCH_DELAY_MS = 600;
    var COLUMNS = 6;
    // Page buttons shown before the list collapses to 1 ... 4 5 6 ... 12.
    var MAX_PLAIN_PAGES = 7;

    var pageSizes = Array.prototype.slice.call(pageSizeSelect.options).map(function (option) {
        return parseInt(option.value, 10);
    });

    var validPageSize = function (size) {
        return pageSizes.indexOf(size) >= 0 ? size : pageSizes[0];
    };

    var state = {
        query: "",
        status: "",
        page: 1,
        pageSize: validPageSize(dash.prefs.get("pageSize"))
    };

    var loadedOnce = false;
    var lastResult = null;
    // The request in flight. A newer one aborts it, and an answer is only used if it belongs to the
    // newest request, so a slow reply to an old search can never overwrite a newer one.
    var controller = null;

    pageSizeSelect.value = String(state.pageSize);

    var messageRow = function (children) {
        return dash.el("tr", { className: "adm-table-message" }, [
            dash.el("td", { colspan: COLUMNS }, children)
        ]);
    };

    var showMessage = function (children) {
        dash.clear(tbody);
        tbody.appendChild(messageRow(children));
    };

    var cell = function (className, children, title) {
        return dash.el("td", { className: className, title: title }, children);
    };

    var userRow = function (user) {
        var name = dash.format.displayName(user);
        var manage = dash.el("button", {
            type: "button",
            className: "adm-btn adm-btn--secondary adm-btn--sm",
            "aria-label": "Manage " + name,
            text: "Manage"
        });

        manage.addEventListener("click", function () {
            dash.emit("user:manage", { id: user.id });
        });

        return dash.el("tr", null, [
            cell(null, [dash.el("div", { className: "adm-user-cell" }, [
                dash.el("span", {
                    className: "adm-avatar" + (user.isProtected ? "" : " adm-avatar--muted"),
                    "aria-hidden": "true",
                    text: dash.format.initials(user.fullName, user.username)
                }),
                dash.el("div", { className: "adm-user-names" }, [
                    dash.el("p", { className: "adm-user-name" }, [
                        name,
                        user.isProtected ? dash.el("span", { className: "adm-badge adm-badge--primary", text: "Admin" }) : null
                    ]),
                    dash.el("p", { className: "adm-user-username", text: user.username ? "@" + user.username : "No username" })
                ])
            ])]),
            user.email
                ? cell("adm-table-email", [user.email], user.email)
                : cell("adm-table-muted", [dash.el("span", { className: "adm-empty-value", text: "Not given" })]),
            cell(null, [dash.el("span", {
                className: "adm-status adm-status--" + user.status,
                text: user.status === "active" ? "Active" : "Inactive"
            })]),
            cell("adm-table-muted", [dash.format.when(user.createdAt)], dash.format.dateTime(user.createdAt)),
            cell("adm-table-muted", [dash.format.when(user.lastLoginAt, "Never")],
                user.lastLoginAt ? dash.format.dateTime(user.lastLoginAt) : null),
            cell("adm-table-actions", [manage])
        ]);
    };

    var clearFiltersButton = function () {
        var button = dash.el("button", { type: "button", className: "adm-btn adm-btn--secondary", text: "Clear search and filter" });
        button.addEventListener("click", function () {
            search.cancel();
            searchInput.value = "";
            statusSelect.value = "";
            state.query = "";
            state.status = "";
            state.page = 1;
            load();
            searchInput.focus();
        });
        return button;
    };

    var renderRows = function (result) {
        if (result.items.length) {
            dash.clear(tbody);
            result.items.forEach(function (user) {
                tbody.appendChild(userRow(user));
            });
            return;
        }

        if (state.query || state.status) {
            showMessage([
                dash.el("p", { text: state.query ? "No accounts match “" + state.query + "”." : "No accounts with that status." }),
                clearFiltersButton()
            ]);
        } else {
            showMessage([dash.el("p", { text: "No accounts yet." })]);
        }
    };

    var renderSummary = function (result) {
        var count = dash.format.plural(result.total, "account");
        summary.textContent = state.query || state.status ? count + " found" : count;

        if (!result.total) {
            range.textContent = "";
            return;
        }
        var first = (result.page - 1) * result.pageSize + 1;
        var last = first + result.items.length - 1;
        range.textContent = "Showing " + dash.format.number(first) + "–" + dash.format.number(last) +
            " of " + dash.format.number(result.total);
    };

    // 1 ... 4 [5] 6 ... 12: the first and last page, the current one and its neighbours.
    var pageList = function (current, last) {
        var pages = [];
        var i;

        if (last <= MAX_PLAIN_PAGES) {
            for (i = 1; i <= last; i++) {
                pages.push(i);
            }
            return pages;
        }

        var start = Math.max(2, Math.min(current - 1, last - 4));
        var end = Math.min(last - 1, Math.max(current + 1, 5));

        pages.push(1);
        if (start > 2) {
            pages.push(null);
        }
        for (i = start; i <= end; i++) {
            pages.push(i);
        }
        if (end < last - 1) {
            pages.push(null);
        }
        pages.push(last);
        return pages;
    };

    var pageButton = function (label, page, action, ariaLabel, disabled, current) {
        var button = dash.el("button", {
            type: "button",
            className: "adm-page-btn",
            "data-page-action": action,
            "aria-label": ariaLabel,
            "aria-current": current ? "page" : null,
            disabled: disabled,
            text: label
        });

        if (!disabled && !current) {
            button.addEventListener("click", function () {
                state.page = page;
                load();
            });
        }
        return button;
    };

    var renderPager = function (result) {
        var last = Math.max(1, Math.ceil(result.total / result.pageSize));
        var page = result.page;
        // The pager is rebuilt on every answer, so keyboard focus is carried over to its counterpart.
        var focused = pager.contains(document.activeElement) ? document.activeElement.getAttribute("data-page-action") : null;

        dash.clear(pager);
        pager.hidden = result.total === 0;
        pager.appendChild(pageButton("‹ Prev", page - 1, "prev", "Previous page", page <= 1, false));

        pageList(page, last).forEach(function (number) {
            pager.appendChild(number === null
                ? dash.el("span", { className: "adm-page-gap", "aria-hidden": "true", text: "…" })
                : pageButton(String(number), number, "page-" + number, "Page " + number, false, number === page));
        });

        pager.appendChild(pageButton("Next ›", page + 1, "next", "Next page", page >= last, false));

        if (focused) {
            var target = pager.querySelector('[data-page-action="' + focused + '"]:not(:disabled)') ||
                pager.querySelector('[aria-current="page"]');
            if (target) {
                target.focus();
            }
        }
    };

    var setLoading = function (isLoading) {
        table.classList.toggle("is-loading", isLoading && loadedOnce);
        table.setAttribute("aria-busy", isLoading ? "true" : "false");
    };

    var load = function () {
        if (controller) {
            controller.abort();
        }
        var mine = controller = new AbortController();
        setLoading(true);

        dash.api.get("Users.ashx", {
            q: state.query,
            status: state.status,
            page: state.page,
            pageSize: state.pageSize
        }, mine.signal).then(function (result) {
            if (mine !== controller) {
                return;
            }
            loadedOnce = true;
            lastResult = result;
            // The server clamps a page past the end (after a delete, say) to the last one.
            state.page = result.page;
            renderRows(result);
            renderSummary(result);
            renderPager(result);
        }).catch(function (error) {
            if (dash.isAbort(error) || mine !== controller) {
                return;
            }
            var retry = dash.el("button", { type: "button", className: "adm-btn adm-btn--secondary", text: "Try again" });
            retry.addEventListener("click", load);
            showMessage([dash.el("p", { text: error.message }), retry]);
            summary.textContent = "";
            range.textContent = "";
            pager.hidden = true;
        }).then(function () {
            if (mine === controller) {
                controller = null;
                setLoading(false);
            }
        });
    };

    var search = dash.debounce(function () {
        var query = searchInput.value.trim();

        // Typing a letter and deleting it again comes back to the same search: nothing to fetch.
        if (query === state.query) {
            if (lastResult) {
                renderSummary(lastResult);
            }
            return;
        }
        state.query = query;
        state.page = 1;
        load();
    }, SEARCH_DELAY_MS);

    searchInput.addEventListener("input", function () {
        if (searchInput.value.trim() !== state.query) {
            summary.textContent = "Searching…";
        }
        search();
    });

    // Enter searches straight away instead of waiting out the pause.
    searchInput.addEventListener("keydown", function (event) {
        if (event.key === "Enter") {
            event.preventDefault();
            search();
            search.flush();
        }
    });

    statusSelect.addEventListener("change", function () {
        // Whatever is in the search box counts too, even if its pause hasn't run out yet.
        search.cancel();
        state.query = searchInput.value.trim();
        state.status = statusSelect.value;
        state.page = 1;
        load();
    });

    // Goes through the preference, so Settings > Rows per page shows the same number.
    pageSizeSelect.addEventListener("change", function () {
        dash.prefs.set("pageSize", validPageSize(parseInt(pageSizeSelect.value, 10)));
    });

    dash.on("prefs:changed", function (change) {
        if (change.key === "pageSize") {
            var size = validPageSize(change.value);
            pageSizeSelect.value = String(size);
            if (size !== state.pageSize) {
                state.pageSize = size;
                state.page = 1;
                if (loadedOnce) {
                    load();
                }
            }
        } else if (change.key === "relativeDates" && lastResult) {
            renderRows(lastResult);
        }
    });

    dash.on("view:show", function (name) {
        if (name === "users" && !loadedOnce && !controller) {
            load();
        }
    });

    // The row's status, or the row itself, has changed: the current page is asked for again, since
    // under a status filter the account may no longer belong on it.
    var reload = function () {
        if (loadedOnce) {
            load();
        }
    };

    dash.on("user:changed", reload);
    dash.on("user:deleted", reload);
})();
