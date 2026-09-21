(function () {
    "use strict";

    var dash = window.AdminDash;
    var form = dash.byId("limitsForm");
    var status = dash.byId("limitsStatus");
    var submit = dash.byId("limitsSubmit");
    var hobbies = dash.byId("limitsHobbies");
    var skills = dash.byId("limitsSkills");

    var inputs = [hobbies, skills];
    var errors = {
        maxHobbies: dash.byId("limitsHobbiesError"),
        maxSkills: dash.byId("limitsSkillsError")
    };

    // The range is read off the inputs, where LimitsCard put ProfileLimits' bounds, so there is no
    // second copy of it here. The server checks again and has the last word.
    var MIN = parseInt(hobbies.getAttribute("min"), 10);
    var MAX = parseInt(hobbies.getAttribute("max"), 10);

    // A number input hands back "" for anything it can't parse, so "abc" and "" both land here as
    // not a whole number in range.
    var valueOf = function (input) {
        return /^\d+$/.test(input.value.trim()) ? parseInt(input.value, 10) : NaN;
    };

    var check = function () {
        var found = {};

        inputs.forEach(function (input) {
            var value = valueOf(input);
            if (isNaN(value) || value < MIN || value > MAX) {
                found[input.getAttribute("data-field")] = "Pick a number from " + MIN + " to " + MAX + ".";
            }
        });

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

    // Same as the password card: a flagged field is rechecked as the admin types.
    inputs.forEach(function (input) {
        input.addEventListener("input", function () {
            showStatus("");
            if (input.parentNode.classList.contains("is-invalid")) {
                showErrors(check());
            }
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
        submit.textContent = "Saving…";

        dash.api.post("Limits.ashx", {
            maxHobbies: valueOf(hobbies),
            maxSkills: valueOf(skills)
        }).then(function (saved) {
            // Shown as the server stored them, e.g. "04" comes back as 4.
            hobbies.value = saved.maxHobbies;
            skills.value = saved.maxSkills;
            showErrors({});
            showStatus("Limits saved. Users get the new limits the next time they open their profile.", "success");
        }).catch(function (error) {
            var firstInvalid = error.fields ? showErrors(error.fields) : null;
            showStatus(error.message);
            if (firstInvalid) {
                firstInvalid.focus();
            }
        }).then(function () {
            submit.classList.remove("is-busy");
            submit.removeAttribute("aria-disabled");
            submit.textContent = "Save limits";
        });
    });
})();
