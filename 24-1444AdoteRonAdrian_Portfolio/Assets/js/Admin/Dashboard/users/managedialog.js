(function () {
    "use strict";

    var dash = window.AdminDash;
    var dialog = dash.byId("manageDialog");
    var avatar = dash.byId("manageAvatar");
    var title = dash.byId("manageTitle");
    var subtitle = dash.byId("manageSubtitle");
    var closeButton = dash.byId("manageClose");
    var errorBox = dash.byId("manageError");
    var loadingText = dash.byId("manageLoading");
    var content = dash.byId("manageContent");
    var details = dash.byId("manageDetails");
    var portfolio = dash.byId("managePortfolio");
    var protectedNote = dash.byId("manageProtected");
    var statusSection = dash.byId("manageStatusSection");
    var statusLabel = dash.byId("manageStatusLabel");
    var statusHelp = dash.byId("manageStatusHelp");
    var statusSwitch = dash.byId("manageStatusSwitch");
    var deleteSection = dash.byId("manageDeleteSection");
    var deleteStart = dash.byId("manageDeleteStart");
    var confirmBox = dash.byId("manageConfirm");
    var confirmWord = dash.byId("manageConfirmWord");
    var confirmInput = dash.byId("manageConfirmInput");
    var deleteCancel = dash.byId("manageDeleteCancel");
    var deleteConfirm = dash.byId("manageDeleteConfirm");

    // An account without a username (the column allows it) is confirmed with this word instead.
    var FALLBACK_CONFIRM_WORD = "DELETE";

    var user = null;
    var busy = false;
    // Bumped on every open and close, so an answer for an account the dialog has since moved on
    // from is dropped instead of drawn.
    var session = 0;

    var showError = function (message) {
        errorBox.textContent = message;
        errorBox.classList.toggle("is-visible", !!message);
    };

    var detail = function (label, value, wide) {
        return dash.el("div", { className: wide ? "adm-details-wide" : null }, [
            dash.el("dt", { text: label }),
            value
                ? dash.el("dd", { text: value })
                : dash.el("dd", null, [dash.el("span", { className: "adm-empty-value", text: "Not given" })])
        ]);
    };

    var statusPill = function (status) {
        return dash.el("span", {
            className: "adm-status adm-status--" + status,
            text: status === "active" ? "Active" : "Inactive"
        });
    };

    var confirmText = function () {
        return user.username || FALLBACK_CONFIRM_WORD;
    };

    var renderHeader = function () {
        avatar.textContent = dash.format.initials(user.fullName, user.username);
        title.textContent = dash.format.displayName(user);
        dash.clear(subtitle);
        subtitle.appendChild(dash.el("span", { text: user.username ? "@" + user.username : "No username" }));
        subtitle.appendChild(statusPill(user.status));
    };

    var renderStatus = function () {
        var active = user.status === "active";
        statusSwitch.setAttribute("aria-checked", active ? "true" : "false");
        statusLabel.textContent = active ? "Active" : "Inactive";
        statusHelp.textContent = active
            ? "This account can sign in. Switch off to refuse its sign-ins."
            : "This account is refused at sign-in. Switch on to let it sign in again.";
    };

    // The birthdate is a plain calendar date, not an instant: parsing the whole timestamp would
    // shift it by a day for a viewer behind UTC, so only its yyyy-MM-dd part is read, as local.
    var plainDate = function (iso) {
        return iso ? dash.format.date(String(iso).slice(0, 10) + "T00:00:00") : "";
    };

    // The four-slot and five-slot lists come back with the blanks already dropped, so an account
    // that filled in two of four reads as those two rather than as two values and two gaps.
    var list = function (values) {
        return (values || []).join(", ");
    };

    var render = function () {
        renderHeader();

        dash.clear(details);
        [
            detail("First name", user.firstName),
            detail("Last name", user.lastName),
            detail("Middle name", user.middleName),
            detail("Suffix", user.suffix),
            detail("Email", user.email),
            detail("Mobile number", user.sms),
            detail("Address", user.address, true),
            detail("Role", user.isProtected ? "Administrator" : "User"),
            detail("Account ID", String(user.id)),
            detail("Joined", dash.format.dateTime(user.createdAt)),
            detail("Last sign-in", user.lastLoginAt ? dash.format.dateTime(user.lastLoginAt) : "Never")
        ].forEach(function (row) {
            details.appendChild(row);
        });

        var page = user.portfolio || {};

        dash.clear(portfolio);
        [
            detail("Age", page.age === null || page.age === undefined ? "" : String(page.age)),
            detail("Birthdate", plainDate(page.birthdate)),
            detail("Sex", page.sex),
            detail("Nationality", page.nationality),
            detail("Junior high", page.jhsSchool, true),
            detail("Senior high", page.shsSchool, true),
            detail("College", page.collegeSchool, true),
            detail("Course", page.collegeCourse, true),
            detail("Hobbies", list(page.filledHobbies), true),
            detail("Skills", list(page.filledSkills), true),
            detail("Top projects", list(page.filledProjects), true)
        ].forEach(function (row) {
            portfolio.appendChild(row);
        });

        protectedNote.hidden = !user.isProtected;
        statusSection.hidden = user.isProtected;
        deleteSection.hidden = user.isProtected;
        renderStatus();
        confirmWord.textContent = confirmText();

        loadingText.hidden = true;
        content.hidden = false;
    };

    var hideConfirm = function () {
        confirmBox.hidden = true;
        deleteStart.hidden = false;
        confirmInput.value = "";
        deleteConfirm.disabled = true;
    };

    var setBusy = function (isBusy, button) {
        busy = isBusy;
        button.classList.toggle("is-busy", isBusy);
        button.setAttribute("aria-busy", isBusy ? "true" : "false");
    };

    // A 404 means the account went away (another admin deleted it, say): the lists are told to
    // refresh so they stop showing it.
    var failed = function (error, id) {
        showError(error.message);
        if (error.status === 404) {
            dash.emit("user:deleted", { id: id });
        }
    };

    var open = function (id) {
        var mine = ++session;
        user = null;
        busy = false;
        showError("");
        hideConfirm();
        avatar.textContent = "";
        title.textContent = "Manage account";
        dash.clear(subtitle);
        content.hidden = true;
        loadingText.hidden = false;

        if (!dialog.open) {
            dialog.showModal();
        }

        dash.api.get("UserInfo.ashx", { id: id }).then(function (found) {
            if (mine !== session) {
                return;
            }
            user = found;
            render();
        }).catch(function (error) {
            if (mine !== session) {
                return;
            }
            loadingText.hidden = true;
            failed(error, id);
        });
    };

    statusSwitch.addEventListener("click", function () {
        if (!user || busy) {
            return;
        }

        var mine = session;
        var target = user;
        var next = target.status === "active" ? "inactive" : "active";
        showError("");
        setBusy(true, statusSwitch);

        dash.api.post("UserStatus.ashx", { id: target.id, status: next }).then(function () {
            target.status = next;
            dash.toast(dash.format.displayName(target) + (next === "active" ? " can sign in again." : " is now inactive."));
            dash.emit("user:changed", { id: target.id, status: next });
            if (mine === session) {
                renderHeader();
                renderStatus();
            }
        }).catch(function (error) {
            if (mine === session) {
                failed(error, target.id);
            }
        }).then(function () {
            setBusy(false, statusSwitch);
        });
    });

    deleteStart.addEventListener("click", function () {
        deleteStart.hidden = true;
        confirmBox.hidden = false;
        confirmInput.focus();
    });

    deleteCancel.addEventListener("click", function () {
        hideConfirm();
        deleteStart.focus();
    });

    // Exact match, capitals included: the point is to make the admin read the name they're deleting.
    confirmInput.addEventListener("input", function () {
        deleteConfirm.disabled = confirmInput.value.trim() !== confirmText();
    });

    confirmInput.addEventListener("keydown", function (event) {
        if (event.key === "Enter") {
            event.preventDefault();
            if (!deleteConfirm.disabled) {
                deleteConfirm.click();
            }
        }
    });

    deleteConfirm.addEventListener("click", function () {
        if (!user || busy || deleteConfirm.disabled) {
            return;
        }

        var mine = session;
        var target = user;
        showError("");
        setBusy(true, deleteConfirm);

        dash.api.post("UserDelete.ashx", { id: target.id }).then(function () {
            dash.toast(dash.format.displayName(target) + "'s account was deleted.");
            dash.emit("user:deleted", { id: target.id });
            if (mine === session) {
                dialog.close();
            }
        }).catch(function (error) {
            if (mine === session) {
                failed(error, target.id);
            }
        }).then(function () {
            setBusy(false, deleteConfirm);
        });
    });

    closeButton.addEventListener("click", function () {
        dialog.close();
    });

    // A click on the backdrop lands on the <dialog> itself; its content covers every other pixel.
    dialog.addEventListener("click", function (event) {
        if (event.target === dialog) {
            dialog.close();
        }
    });

    dialog.addEventListener("close", function () {
        session++;
        user = null;
        busy = false;
        hideConfirm();
    });

    dash.on("user:manage", function (detail) {
        open(detail.id);
    });
})();
