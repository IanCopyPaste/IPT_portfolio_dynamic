(function () {
    "use strict";

    // Client-side checks for the sign-in form. The button is an <asp:Button>, so a click that passes
    // validation is left alone and posts back to loginSubmit_Click; only an invalid one is stopped.
    var submit = document.getElementById("loginSubmit");

    if (!submit) {
        return;
    }

    var userInput = document.getElementById("loginUser");
    var passwordInput = document.getElementById("loginPassword");
    var passwordToggle = document.getElementById("loginPasswordToggle");
    var capsHint = document.getElementById("loginCapsHint");
    // Optional: the markup may drop these, and the rest of the form has to keep working without them.
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

    // Enter needs no handler of its own: the browser treats it as a click on the form's submit button.
    fields.forEach(function (field) {
        field.input.addEventListener("input", function () {
            if (fieldOf(field.input).classList.contains("is-invalid")) {
                showFieldError(field);
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

    if (forgot) {
        forgot.addEventListener("click", function () {
            setStatus("password recovery isn't available yet.", true);
        });
    }

    // "Remember me" keeps the username only — never the password. Storage can be unavailable
    // (private windows, blocked site data), and the page has to work the same without it.
    if (remember) {
        try {
            var saved = window.localStorage.getItem(rememberKey);
            if (saved && !userInput.value) {
                userInput.value = saved;
                remember.checked = true;
            }
        } catch (e) { }
    }

    var storeUsername = function (username) {
        if (!remember) {
            return;
        }
        try {
            if (remember.checked) {
                window.localStorage.setItem(rememberKey, username);
            } else {
                window.localStorage.removeItem(rememberKey);
            }
        } catch (e) { }
    };

    submit.addEventListener("click", function (event) {
        // A second click while the first post is still in flight would submit twice.
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
            setStatus("access denied. fix the highlighted fields and try again.", true);
            firstInvalid.focus();
            return;
        }

        var username = userInput.value.trim();
        storeUsername(username);

        // Not `disabled`: a disabled button isn't sent with the form, and the server would never
        // know which button raised the post, so loginSubmit_Click wouldn't run.
        isBusy = true;
        submit.classList.add("is-busy");
        submit.setAttribute("aria-disabled", "true");
        submit.value = "Authenticating...";
        setStatus("verifying " + username + "...", false);
    });
})();
