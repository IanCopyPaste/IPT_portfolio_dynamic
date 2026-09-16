(function () {
    "use strict";

    // Sample sign-in. Nothing is checked against a real account: any username and a long enough
    // password "authenticate", and the visitor is sent on to the portfolio.
    // TODO: replace with a real check in the code-behind once there are accounts to check against.
    var submit = document.getElementById("loginSubmit");

    if (!submit) {
        return;
    }

    var userInput = document.getElementById("loginUser");
    var passwordInput = document.getElementById("loginPassword");
    var passwordToggle = document.getElementById("loginPasswordToggle");
    var capsHint = document.getElementById("loginCapsHint");
    var remember = document.getElementById("loginRemember");
    var forgot = document.getElementById("loginForgot");
    var status = document.getElementById("loginStatus");
    var rememberKey = "portfolio.login.username";
    var isBusy = false;

    var fields = [
        { input: userInput, error: document.getElementById("loginUserError") },
        { input: passwordInput, error: document.getElementById("loginPasswordError") }
    ];

    var fieldError = function (input) {
        var value = input === passwordInput ? input.value : input.value.trim();

        if (!value) {
            return "This field is required.";
        }
        if (input === userInput && value.length < 3) {
            return "Usernames are at least 3 characters.";
        }
        if (input === passwordInput && value.length < 6) {
            return "Passwords are at least 6 characters.";
        }
        return "";
    };

    // The password input is wrapped for its toggle, so the field is found by class, not parentNode.
    var fieldOf = function (input) {
        var node = input.parentNode;

        while (node && !node.classList.contains("login-field")) {
            node = node.parentNode;
        }

        return node;
    };

    var showFieldError = function (field) {
        var message = fieldError(field.input);
        field.error.textContent = message;
        fieldOf(field.input).classList.toggle("is-invalid", !!message);
        field.input.setAttribute("aria-invalid", message ? "true" : "false");
        return !message;
    };

    var setStatus = function (text, isError) {
        status.textContent = text;
        status.classList.toggle("is-error", !!isError);
    };

    fields.forEach(function (field) {
        field.input.addEventListener("input", function () {
            if (fieldOf(field.input).classList.contains("is-invalid")) {
                showFieldError(field);
            }
        });

        // With no submit button in the server form, Enter would otherwise do nothing.
        field.input.addEventListener("keydown", function (event) {
            if (event.key === "Enter") {
                event.preventDefault();
                signIn();
            }
        });
    });

    passwordToggle.addEventListener("click", function () {
        var reveal = passwordInput.type === "password";
        passwordInput.type = reveal ? "text" : "password";
        passwordToggle.textContent = reveal ? "Hide" : "Show";
        passwordToggle.setAttribute("aria-pressed", reveal ? "true" : "false");
        passwordInput.focus();
    });

    var updateCapsHint = function (event) {
        if (event.getModifierState) {
            capsHint.textContent = event.getModifierState("CapsLock") ? "Caps Lock is on." : "";
        }
    };

    passwordInput.addEventListener("keyup", updateCapsHint);
    passwordInput.addEventListener("keydown", updateCapsHint);
    passwordInput.addEventListener("blur", function () {
        capsHint.textContent = "";
    });

    forgot.addEventListener("click", function () {
        setStatus("password recovery isn't part of this sample.", true);
    });

    // "Remember me" keeps the username only — never the password. Storage can be unavailable
    // (private windows, blocked site data), and the page has to work the same without it.
    try {
        var saved = window.localStorage.getItem(rememberKey);
        if (saved) {
            userInput.value = saved;
            remember.checked = true;
        }
    } catch (e) { }

    var storeUsername = function (username) {
        try {
            if (remember.checked) {
                window.localStorage.setItem(rememberKey, username);
            } else {
                window.localStorage.removeItem(rememberKey);
            }
        } catch (e) { }
    };

    // Prints each line of the fake handshake in turn, then hands over to the portfolio.
    var runSequence = function (lines, done) {
        var step = 0;

        var next = function () {
            if (step >= lines.length) {
                done();
                return;
            }
            setStatus(lines[step], false);
            step++;
            window.setTimeout(next, 650);
        };

        next();
    };

    var signIn = function () {
        if (isBusy) {
            return;
        }

        var firstInvalid = null;

        fields.forEach(function (field) {
            if (!showFieldError(field) && !firstInvalid) {
                firstInvalid = field.input;
            }
        });

        if (firstInvalid) {
            setStatus("access denied. fix the highlighted fields and try again.", true);
            firstInvalid.focus();
            return;
        }

        var username = userInput.value.trim();
        storeUsername(username);

        isBusy = true;
        submit.classList.add("is-busy");
        submit.setAttribute("aria-disabled", "true");
        submit.textContent = "Authenticating...";

        runSequence([
            "verifying " + username + "...",
            "handshake complete.",
            "access granted. redirecting..."
        ], function () {
            window.location.href = "ContentPage.aspx";
        });
    };

    submit.addEventListener("click", signIn);
})();
