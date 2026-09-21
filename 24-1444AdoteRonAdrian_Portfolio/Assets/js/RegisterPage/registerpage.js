(function () {
    "use strict";

    // Client-side checks for an account form: the sign-up form, and the profile page's edit form,
    // which loads this same script. Each rule mirrors AccountRules on the server, message for message.
    // As on the login page, a click that passes is left alone to post back; only an invalid one is
    // stopped. The server checks everything again regardless.
    //
    // The form element says which page it is on:
    //   data-prefix              id prefix of its fields ("reg" gives regFirstName, regFirstNameError, ...)
    //   data-submit, data-status ids of the submit button and the status line
    //   data-invalid-status      status text when a field fails
    //   data-busy-label          button text while the post is in flight
    //   data-busy-status         status text while it is, followed by the username
    //   data-password-optional   blank password fields mean "keep the current password" (profile page)
    var form = document.querySelector("[data-account-form]");

    if (!form) {
        return;
    }

    var prefix = form.getAttribute("data-prefix");
    var byName = function (name) {
        return document.getElementById(prefix + name);
    };

    var submit = document.getElementById(form.getAttribute("data-submit"));
    var status = document.getElementById(form.getAttribute("data-status"));
    var passwordOptional = form.hasAttribute("data-password-optional");
    var passwordInput = byName("Password");
    var confirmInput = byName("Confirm");
    // Only the profile form asks for the current password, and only to change it.
    var currentInput = byName("CurrentPassword");
    var passwordToggle = byName("PasswordToggle");
    var capsHint = byName("CapsHint");
    var passwordInputs = [currentInput, passwordInput, confirmInput].filter(Boolean);
    var isBusy = false;

    var requiredMessage = "This field is required.";

    // With optional passwords, the password fields only count once a new one has been typed.
    var changingPassword = function () {
        return !passwordOptional || !!(passwordInput.value || confirmInput.value);
    };

    var nameRule = function (required) {
        return function (value, input) {
            if (!value) {
                return required ? requiredMessage : "";
            }
            return input.maxLength > 0 && value.length > input.maxLength
                ? "Keep it under " + input.maxLength + " characters." : "";
        };
    };

    // Each rule gets the trimmed value (passwords stay untrimmed) and returns a message, or "".
    var rules = {
        FirstName: nameRule(true),
        MiddleName: nameRule(false),
        LastName: nameRule(true),
        Address: nameRule(true),
        Email: function (value) {
            return value && !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(value)
                ? "Enter a valid email address." : "";
        },
        Sms: function (value) {
            return value && !/^09\d{9}$/.test(value.replace(/[\s-]/g, ""))
                ? "Use 11 digits starting with 09." : "";
        },
        User: function (value) {
            if (!value) {
                return requiredMessage;
            }
            return /^[A-Za-z0-9._]{3,40}$/.test(value)
                ? "" : "3 to 40 letters, digits, . or _";
        },
        CurrentPassword: function (value) {
            return changingPassword() && !value ? requiredMessage : "";
        },
        Password: function (value) {
            if (!changingPassword()) {
                return "";
            }
            if (!value) {
                return requiredMessage;
            }
            return value.length < 8 ? "At least 8 characters." : "";
        },
        Confirm: function (value) {
            if (!changingPassword()) {
                return "";
            }
            if (!value) {
                return requiredMessage;
            }
            return value !== passwordInput.value ? "The passwords don't match." : "";
        },
        // Only the profile form asks for a birthdate. The bounds mirror ProfileRules.MaxAgeYears.
        Birthdate: function (value) {
            if (!value) {
                return "";
            }
            // A date input hands back yyyy-MM-dd, or "" for anything it couldn't parse; a browser
            // with no date picker hands back whatever was typed, so it is parsed here either way.
            var parsed = Date.parse(value);
            if (isNaN(parsed)) {
                return "Enter a date as YYYY-MM-DD.";
            }
            var date = new Date(parsed);
            var oldest = new Date();
            oldest.setFullYear(oldest.getFullYear() - 120);
            if (date > new Date()) {
                return "That date hasn't happened yet.";
            }
            return date < oldest ? "That date is too far back." : "";
        }
    };

    // The profile form's school fields and its project slots are all optional text capped by the
    // input's own maxlength, so one rule covers them. They are named here rather than left out so
    // that a value the server rejects gets its field highlighted like any other. The hobby and skill
    // lists aren't: their rows come and go, so profilepage.js looks after them, and only the
    // markup check below reaches them.
    var optionalText = nameRule(false);

    ["Nationality", "Jhs", "Shs", "College", "Course",
        "Project1", "Project2", "Project3", "Project4", "Project5", "Tagline"].forEach(function (name) {
            rules[name] = optionalText;
        });

    // The portrait picker, which only the profile form has. The accept attribute narrows the file
    // explorer, but every browser lets the user widen it back to "All files", so the pick is
    // checked here too and a bad one never reaches the server. The limits and both messages are
    // read off the input, where ProfilePhotos.Apply put them, so there is no second copy of them
    // to drift. The server still checks the bytes: a name and a type are only claims.
    rules.HomePhoto = function (value, input) {
        var file = input.files && input.files[0];

        if (!file) {
            // No pick at all means "keep the portrait I already have", not a mistake.
            return "";
        }

        // The reported type is taken as a claim to be matched when the browser makes one, and
        // skipped when it doesn't -- an OS with no mapping for .png would otherwise send back a
        // real portrait as a rejection.
        if (!/\.(jpe?g|png)$/i.test(file.name) || (file.type && !/^image\/(jpeg|png)$/i.test(file.type))) {
            return input.getAttribute("data-type-message");
        }

        return file.size > parseInt(input.getAttribute("data-max-bytes"), 10)
            ? input.getAttribute("data-size-message") : "";
    };

    var fields = Object.keys(rules).map(function (name) {
        return {
            input: byName(name),
            error: byName(name + "Error"),
            rule: rules[name]
        };
    }).filter(function (field) {
        return field.input && field.error;
    });

    var isPasswordField = function (field) {
        return passwordInputs.indexOf(field.input) !== -1;
    };

    // The password input is wrapped for its toggle, so the field is found by class, not parentNode.
    var fieldOf = function (input) {
        var node = input.parentNode;

        while (node && !node.classList.contains("login-field")) {
            node = node.parentNode;
        }

        return node;
    };

    var markField = function (field, message) {
        field.error.textContent = message;
        fieldOf(field.input).classList.toggle("is-invalid", !!message);
        field.input.setAttribute("aria-invalid", message ? "true" : "false");
    };

    // ASP.NET's request validation refuses the whole post when any field holds "<" right before a
    // letter, "!", "/" or "?", or holds "&#", and the user would lose everything they typed to an
    // error page. It is checked here first, on every field including the passwords, so the one
    // field at fault is named instead.
    var markupMessage = "Can't contain \"<\" right before a letter or symbol, or \"&#\".";

    var looksLikeMarkup = function (value) {
        return /<[a-z!\/?]|&#/i.test(value);
    };

    var showFieldError = function (field) {
        var value = isPasswordField(field) ? field.input.value : field.input.value.trim();
        var message = field.rule(value, field.input) ||
            (field.input.type !== "file" && looksLikeMarkup(field.input.value) ? markupMessage : "");
        markField(field, message);
        return !message;
    };

    // The profile's hobby and skill rows come and go, so they are found when the form is sent
    // rather than listed up front. profilepage.js clears a row's message once it is edited.
    var firstBadListRow = function () {
        var firstBad = null;

        Array.prototype.slice.call(form.querySelectorAll(".profile-list-row input")).forEach(function (input) {
            var row = fieldOf(input);
            var bad = looksLikeMarkup(input.value);

            if (bad) {
                row.classList.add("is-invalid");
                row.querySelector(".login-error").textContent = markupMessage;
                firstBad = firstBad || input;
            }
        });

        return firstBad;
    };

    var setStatus = function (text, isError) {
        status.textContent = text;
        status.classList.toggle("is-error", !!isError);
    };

    // A rejected post comes back with the server's messages already in the error labels; the
    // highlight is a class the server doesn't set, so it is restored from them here.
    fields.forEach(function (field) {
        if (field.error.textContent) {
            markField(field, field.error.textContent);
        }
    });

    fields.forEach(function (field) {
        field.input.addEventListener("input", function () {
            if (fieldOf(field.input).classList.contains("is-invalid")) {
                showFieldError(field);
            }
            // The password fields depend on each other: the new password decides whether the
            // confirmation matches, and on the profile form whether the others are needed at all.
            if (isPasswordField(field)) {
                fields.forEach(function (other) {
                    if (other !== field && isPasswordField(other) &&
                        (fieldOf(other.input).classList.contains("is-invalid") || other.input.value)) {
                        showFieldError(other);
                    }
                });
            }
        });
    });

    // A file input reports a pick as `change`, and the text fields' `input` handler above only
    // rechecks a field that is already marked, so the first bad pick would otherwise go unanswered
    // until Save. This says so the moment the dialog closes.
    fields.forEach(function (field) {
        if (field.input.type === "file") {
            field.input.addEventListener("change", function () {
                showFieldError(field);
            });
        }
    });

    // One toggle reveals every password input, so they can be compared by eye.
    passwordToggle.addEventListener("click", function () {
        var reveal = passwordInput.type === "password";
        passwordInputs.forEach(function (input) {
            input.type = reveal ? "text" : "password";
        });
        passwordToggle.textContent = reveal ? "Hide" : "Show";
        passwordToggle.setAttribute("aria-pressed", reveal ? "true" : "false");
        passwordInput.focus();
    });

    var updateCapsHint = function (event) {
        if (event.getModifierState) {
            capsHint.textContent = event.getModifierState("CapsLock") ? "Caps Lock is on." : "";
        }
    };

    passwordInputs.forEach(function (input) {
        input.addEventListener("keyup", updateCapsHint);
        input.addEventListener("keydown", updateCapsHint);
        input.addEventListener("blur", function () {
            capsHint.textContent = "";
        });
    });

    submit.addEventListener("click", function (event) {
        // A second click while the first post is still in flight would send the form twice.
        if (isBusy) {
            event.preventDefault();
            return;
        }

        var firstInvalid = null;

        fields.forEach(function (field) {
            if (!showFieldError(field) && !firstInvalid) {
                firstInvalid = field.input;
            }
        });

        firstInvalid = firstInvalid || firstBadListRow();

        if (firstInvalid) {
            event.preventDefault();
            setStatus(form.getAttribute("data-invalid-status"), true);
            // The profile page splits this form into steps and hides all but one, and focus does
            // nothing on a hidden input, so it is given the chance to bring the field forward
            // first. Nothing registers this on the sign-up page, where the whole form is on screen.
            if (window.AccountFormReveal) {
                window.AccountFormReveal(firstInvalid);
            }
            firstInvalid.focus();
            return;
        }

        // Not `disabled`: a disabled button isn't sent with the form, and the server would never
        // know which button raised the post, so its click handler wouldn't run.
        isBusy = true;
        submit.classList.add("is-busy");
        submit.setAttribute("aria-disabled", "true");
        submit.value = form.getAttribute("data-busy-label");
        setStatus(form.getAttribute("data-busy-status") + " " + byName("User").value.trim() + "...", false);
    });
})();
