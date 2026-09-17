(function () {
    "use strict";

    // Client-side checks for the sign-up form, mirroring registerSubmit_Click so both give the same
    // answer. As on the login page, a click that passes is left alone to post back; only an invalid
    // one is stopped. The server checks everything again regardless.
    var submit = document.getElementById("registerSubmit");

    if (!submit) {
        return;
    }

    var passwordInput = document.getElementById("regPassword");
    var confirmInput = document.getElementById("regConfirm");
    var passwordToggle = document.getElementById("regPasswordToggle");
    var capsHint = document.getElementById("regCapsHint");
    var status = document.getElementById("registerStatus");
    var isBusy = false;

    var requiredMessage = "This field is required.";

    var nameRule = function (required) {
        return function (value, input) {
            if (!value) {
                return required ? requiredMessage : "";
            }
            return value.length > input.maxLength && input.maxLength > 0
                ? "Keep it under " + input.maxLength + " characters." : "";
        };
    };

    // Each rule gets the trimmed value (passwords stay untrimmed) and returns a message, or "".
    var rules = {
        regFirstName: nameRule(true),
        regMiddleName: nameRule(false),
        regLastName: nameRule(true),
        regAddress: nameRule(true),
        regEmail: function (value) {
            return value && !/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(value)
                ? "Enter an email like you@example.com." : "";
        },
        regSms: function (value) {
            return value && !/^09\d{9}$/.test(value.replace(/[\s-]/g, ""))
                ? "Use an 11-digit mobile number starting with 09." : "";
        },
        regUser: function (value) {
            if (!value) {
                return requiredMessage;
            }
            return /^[A-Za-z0-9._]{3,40}$/.test(value)
                ? "" : "Use 3 to 40 letters, numbers, dots or underscores.";
        },
        regPassword: function (value) {
            if (!value) {
                return requiredMessage;
            }
            return value.length < 8 ? "Passwords are at least 8 characters." : "";
        },
        regConfirm: function (value) {
            if (!value) {
                return requiredMessage;
            }
            return value !== passwordInput.value ? "The passwords don't match." : "";
        }
    };

    var fields = Object.keys(rules).map(function (id) {
        return {
            input: document.getElementById(id),
            error: document.getElementById(id + "Error"),
            rule: rules[id]
        };
    });

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

    var showFieldError = function (field) {
        var isPassword = field.input === passwordInput || field.input === confirmInput;
        var value = isPassword ? field.input.value : field.input.value.trim();
        var message = field.rule(value, field.input);
        markField(field, message);
        return !message;
    };

    var fieldById = function (id) {
        return fields.filter(function (field) {
            return field.input.id === id;
        })[0];
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
            // Changing the password can make an already-checked confirmation right or wrong.
            if (field.input === passwordInput) {
                var confirmField = fieldById("regConfirm");
                if (fieldOf(confirmInput).classList.contains("is-invalid") || confirmInput.value) {
                    showFieldError(confirmField);
                }
            }
        });
    });

    // One toggle reveals both password inputs, so the two can be compared by eye.
    passwordToggle.addEventListener("click", function () {
        var reveal = passwordInput.type === "password";
        passwordInput.type = reveal ? "text" : "password";
        confirmInput.type = passwordInput.type;
        passwordToggle.textContent = reveal ? "Hide" : "Show";
        passwordToggle.setAttribute("aria-pressed", reveal ? "true" : "false");
        passwordInput.focus();
    });

    var updateCapsHint = function (event) {
        if (event.getModifierState) {
            capsHint.textContent = event.getModifierState("CapsLock") ? "Caps Lock is on." : "";
        }
    };

    [passwordInput, confirmInput].forEach(function (input) {
        input.addEventListener("keyup", updateCapsHint);
        input.addEventListener("keydown", updateCapsHint);
        input.addEventListener("blur", function () {
            capsHint.textContent = "";
        });
    });

    submit.addEventListener("click", function (event) {
        // A second click while the first post is still in flight would create the account twice.
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

        if (firstInvalid) {
            event.preventDefault();
            setStatus("sign-up failed. fix the highlighted fields and try again.", true);
            firstInvalid.focus();
            return;
        }

        // Not `disabled`: a disabled button isn't sent with the form, and the server would never
        // know which button raised the post, so registerSubmit_Click wouldn't run.
        isBusy = true;
        submit.classList.add("is-busy");
        submit.setAttribute("aria-disabled", "true");
        submit.value = "Creating account...";
        setStatus("writing record for " + document.getElementById("regUser").value.trim() + "...", false);
    });
})();
