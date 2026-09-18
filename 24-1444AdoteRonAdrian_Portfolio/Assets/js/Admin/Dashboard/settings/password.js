(function () {
    "use strict";

    var dash = window.AdminDash;
    var form = dash.byId("passwordForm");
    var status = dash.byId("passwordStatus");
    var submit = dash.byId("passwordSubmit");
    var showToggle = dash.byId("passwordShow");
    var current = dash.byId("passwordCurrent");
    var next = dash.byId("passwordNew");
    var confirm = dash.byId("passwordConfirm");

    var inputs = [current, next, confirm];
    var errors = {
        currentPassword: dash.byId("passwordCurrentError"),
        newPassword: dash.byId("passwordNewError"),
        confirmPassword: dash.byId("passwordConfirmError")
    };

    // The server's rules (AccountRules), checked here first so a slip is caught without a round
    // trip. The server checks again and has the last word; its messages land in the same places.
    var MIN_LENGTH = parseInt(next.getAttribute("data-min"), 10);
    var REQUIRED = "This field is required.";

    var check = function () {
        var found = {};

        if (!current.value) {
            found.currentPassword = REQUIRED;
        }

        if (!next.value) {
            found.newPassword = REQUIRED;
        } else if (next.value.length < MIN_LENGTH) {
            found.newPassword = "At least " + MIN_LENGTH + " characters.";
        } else if (next.value === current.value) {
            found.newPassword = "Choose a password different from the current one.";
        }

        if (!confirm.value) {
            found.confirmPassword = REQUIRED;
        } else if (confirm.value !== next.value) {
            found.confirmPassword = "The passwords don't match.";
        }

        return found;
    };

    var showStatus = function (message, tone) {
        status.textContent = message;
        status.className = "adm-alert" + (tone === "success" ? " adm-alert--success" : "") + (message ? " is-visible" : "");
    };

    var showErrors = function (found) {
        var firstInvalid = null;

        inputs.forEach(function (input) {
            var key = input.getAttribute("data-field");
            var message = found[key] || "";
            errors[key].textContent = message;
            input.parentNode.classList.toggle("is-invalid", !!message);
            input.setAttribute("aria-invalid", message ? "true" : "false");
            if (message && !firstInvalid) {
                firstInvalid = input;
            }
        });

        return firstInvalid;
    };

    // Once a field has been flagged, it is rechecked as the admin types, so the message clears the
    // moment it is fixed rather than on the next submit.
    inputs.forEach(function (input) {
        input.addEventListener("input", function () {
            showStatus("");
            if (input.parentNode.classList.contains("is-invalid")) {
                var key = input.getAttribute("data-field");
                var message = check()[key] || "";
                errors[key].textContent = message;
                input.parentNode.classList.toggle("is-invalid", !!message);
                input.setAttribute("aria-invalid", message ? "true" : "false");
            }
        });
    });

    showToggle.addEventListener("change", function () {
        inputs.forEach(function (input) {
            input.type = showToggle.checked ? "text" : "password";
        });
    });

    form.addEventListener("submit", function (event) {
        event.preventDefault();

        if (submit.classList.contains("is-busy")) {
            return;
        }

        var firstInvalid = showErrors(check());
        if (firstInvalid) {
            showStatus("");
            firstInvalid.focus();
            return;
        }

        submit.classList.add("is-busy");
        submit.setAttribute("aria-disabled", "true");
        submit.textContent = "Updating…";

        dash.api.post("Password.ashx", {
            currentPassword: current.value,
            newPassword: next.value,
            confirmPassword: confirm.value
        }).then(function () {
            form.reset();
            showToggle.checked = false;
            inputs.forEach(function (input) {
                input.type = "password";
            });
            showErrors({});
            showStatus("Password updated. Use the new one next time you sign in.", "success");
        }).catch(function (error) {
            var firstInvalid = error.fields ? showErrors(error.fields) : null;
            showStatus(error.message);
            if (firstInvalid) {
                firstInvalid.focus();
            }
        }).then(function () {
            submit.classList.remove("is-busy");
            submit.removeAttribute("aria-disabled");
            submit.textContent = "Update password";
        });
    });
})();
