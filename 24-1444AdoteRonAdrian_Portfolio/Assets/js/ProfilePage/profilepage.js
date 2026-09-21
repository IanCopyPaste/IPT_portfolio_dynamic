(function () {
    "use strict";

    // The profile form asks for everything at once -- the name, the contact details, the whole
    // portfolio and the account -- which is a wall of about thirty inputs. This splits it into one
    // screen at a time: a rail of steps at the top, Back and Next at the bottom, and every field
    // still inside the one server form, so Save still posts the lot however far through the user is.
    //
    // It runs on top of registerpage.js, which does the validating; this file decides what is on
    // screen, and runs the hobby and skill lists. With scripting off, profilepage.css leaves every
    // step visible and the form works exactly as it did before.
    var form = document.getElementById("profileForm");

    if (!form) {
        return;
    }

    // ---------- Growable lists ----------

    // The hobbies and skills are lists the user grows with "+", up to the limit the admin set. The
    // server draws whatever rows there are (ListField.ascx); this adds, removes and renumbers them.
    // Every row posts under the same name, so the numbering is only for the labels and the ids.

    // Set further down to the steps' error refresh, once the rail exists; a removed row can take
    // the only message on its step with it.
    var onListChange = function () { };

    var setUpList = function (list) {
        var rows = list.querySelector(".profile-list-rows");
        var template = list.querySelector(".profile-list-template");
        var add = list.querySelector(".profile-list-add");
        var count = list.querySelector(".profile-list-count");
        var countError = list.querySelector(".profile-list-error");
        var noun = list.getAttribute("data-noun");
        var plural = list.getAttribute("data-plural");
        var max = parseInt(list.getAttribute("data-max"), 10);

        if (!rows || !template || !template.content || !add || !count || !countError || isNaN(max)) {
            return;
        }

        var rowsOf = function () {
            return Array.prototype.slice.call(rows.querySelectorAll(".profile-list-row"));
        };

        // Numbers follow position, so removing hobby 2 makes hobby 3 the new hobby 2.
        var refresh = function () {
            var all = rowsOf();

            all.forEach(function (row, index) {
                var number = index + 1;
                var input = row.querySelector("input");
                var label = row.querySelector("label");

                input.id = input.name + number;
                label.setAttribute("for", input.id);
                label.textContent = noun + " " + number;
                row.querySelector(".profile-list-remove").setAttribute("aria-label",
                    "Remove " + noun.toLowerCase() + " " + number);
            });

            // Worded as ProfileRules.ListCountError words it, so the message doesn't change
            // between what the server said and what this says once a row is removed.
            var over = all.length - max;
            countError.textContent = over > 0
                ? "You can list up to " + max + " " + plural + ". Remove " + over + " to save."
                : "";
            count.textContent = all.length + " of " + max;
            add.disabled = all.length >= max;
        };

        // Null at the limit, which the disabled "+" normally makes unreachable; Enter in a row
        // still gets here.
        var addRow = function (after) {
            if (rowsOf().length >= max) {
                return null;
            }

            var row = template.content.firstElementChild.cloneNode(true);
            rows.insertBefore(row, after ? after.nextSibling : null);
            refresh();
            row.querySelector("input").focus();
            return row;
        };

        add.addEventListener("click", function () {
            addRow(null);
        });

        rows.addEventListener("click", function (event) {
            var button = event.target.closest(".profile-list-remove");

            if (!button) {
                return;
            }

            var row = button.closest(".profile-list-row");
            var index = rowsOf().indexOf(row);
            rows.removeChild(row);
            refresh();

            // Focus lands on the row that moved into the gap, or the one above it, or "+" once the
            // list is empty, so a keyboard user isn't thrown back to the top of the page.
            var left = rowsOf();
            var next = left[Math.min(index, left.length - 1)];
            (next ? next.querySelector("input") : add).focus();
            onListChange();
        });

        // Enter in a text box presses the form's first submit button, which is Save. In a list the
        // user means "and another one", so it adds a row under this one instead.
        rows.addEventListener("keydown", function (event) {
            if (event.key !== "Enter" || event.target.tagName !== "INPUT") {
                return;
            }

            event.preventDefault();
            addRow(event.target.closest(".profile-list-row"));
        });

        // A row the server objected to clears as soon as it is edited, the way registerpage.js
        // clears the fixed fields. Runs before the form's own input handler refreshes the rail.
        rows.addEventListener("input", function (event) {
            var row = event.target.closest(".profile-list-row");

            if (row && row.classList.contains("is-invalid")) {
                row.classList.remove("is-invalid");
                row.querySelector(".login-error").textContent = "";
            }
        });

        refresh();
    };

    Array.prototype.slice.call(form.querySelectorAll("[data-profile-list]")).forEach(setUpList);

    // ---------- Steps ----------

    var rail = document.getElementById("profileSteps");

    if (!rail) {
        return;
    }

    var steps = Array.prototype.slice.call(form.querySelectorAll(".profile-step"));
    var back = document.getElementById("profileBack");
    var next = document.getElementById("profileNext");
    var counter = document.getElementById("profileStepCount");
    // Rides along with the form so the step survives a post-back; absent is simply step one.
    var keep = document.getElementById("profileStep");

    // One step is not worth a wizard, and the rest of this assumes both buttons are there.
    if (steps.length < 2 || !back || !next || !counter) {
        return;
    }

    var tabs = [];
    var current = -1;

    var hasError = function (step) {
        return Array.prototype.slice.call(step.querySelectorAll(".login-error")).some(function (label) {
            return label.textContent.trim() !== "";
        });
    };

    // A failed save leaves its messages on whichever steps they belong to, and all but one of those
    // is off screen, so the rail carries the bad news instead.
    var refreshErrors = function () {
        steps.forEach(function (step, index) {
            tabs[index].classList.toggle("has-error", hasError(step));
        });
    };

    var show = function (index) {
        if (index < 0 || index >= steps.length) {
            return;
        }

        current = index;

        steps.forEach(function (step, i) {
            var on = i === index;
            step.classList.toggle("is-active", on);
            tabs[i].classList.toggle("is-current", on);
            tabs[i].setAttribute("aria-selected", on ? "true" : "false");
            // Only the current tab is in the tab order; the arrow keys move between them.
            tabs[i].tabIndex = on ? 0 : -1;
        });

        back.disabled = index === 0;
        next.disabled = index === steps.length - 1;
        counter.textContent = "Step " + (index + 1) + " of " + steps.length;

        if (keep) {
            keep.value = String(index);
        }
    };

    var move = function (delta, focusTab) {
        var index = Math.min(Math.max(current + delta, 0), steps.length - 1);
        show(index);

        if (focusTab) {
            tabs[index].focus();
        }
    };

    steps.forEach(function (step, index) {
        var id = "profileStep" + (index + 1);
        var label = step.getAttribute("data-step-label") || "Step " + (index + 1);
        // Padded so the rail reads as a numbered list, matching the section numbers on the portfolio.
        var number = index < 9 ? "0" + (index + 1) : String(index + 1);

        step.id = id;
        step.setAttribute("role", "tabpanel");
        step.setAttribute("aria-labelledby", id + "Tab");

        var tab = document.createElement("button");
        tab.type = "button";
        tab.id = id + "Tab";
        tab.className = "profile-step-tab";
        tab.setAttribute("role", "tab");
        tab.setAttribute("aria-controls", id);

        var count = document.createElement("span");
        count.className = "profile-step-index";
        count.setAttribute("aria-hidden", "true");
        count.textContent = number;
        tab.appendChild(count);
        tab.appendChild(document.createTextNode(label));

        tab.addEventListener("click", function () {
            show(index);
        });

        rail.appendChild(tab);
        tabs.push(tab);
    });

    back.addEventListener("click", function () {
        move(-1, false);
    });

    next.addEventListener("click", function () {
        move(1, false);
    });

    // Arrow keys walk the rail, as a tablist is expected to.
    rail.addEventListener("keydown", function (event) {
        if (event.key === "ArrowRight" || event.key === "ArrowDown") {
            event.preventDefault();
            move(1, true);
        } else if (event.key === "ArrowLeft" || event.key === "ArrowUp") {
            event.preventDefault();
            move(-1, true);
        }
    });

    // registerpage.js calls this with the first field that failed, before focusing it: focus does
    // nothing on a hidden input, so the step holding it has to come forward first.
    window.AccountFormReveal = function (input) {
        for (var i = 0; i < steps.length; i++) {
            if (steps[i].contains(input)) {
                show(i);
                break;
            }
        }
        refreshErrors();
    };

    // The messages registerpage.js writes as the user types change which steps are at fault.
    // Delegated, so it sees the labels after the per-input handlers have already updated them.
    form.addEventListener("input", refreshErrors);
    onListChange = refreshErrors;

    // A rejected save comes back with the server's messages in place, so the form opens on the
    // first step that has one rather than making the user hunt for it. A save that went through
    // has no messages, and opens on the step the user was on when they pressed it.
    var stored = keep ? parseInt(keep.value, 10) : 0;
    var opening = isNaN(stored) ? 0 : Math.min(Math.max(stored, 0), steps.length - 1);

    for (var i = 0; i < steps.length; i++) {
        if (hasError(steps[i])) {
            opening = i;
            break;
        }
    }

    show(opening);
    refreshErrors();
})();
