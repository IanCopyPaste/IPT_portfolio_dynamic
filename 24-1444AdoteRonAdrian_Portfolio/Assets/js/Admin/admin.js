(function () {
    "use strict";

    // Client-side checks for the admin sign-in. The button is an <asp:Button>, so a click that passes
    // validation is left alone and posts back to adminSubmit_Click; only an invalid one is stopped.
    var submit = document.getElementById("adminSubmit");

    if (!submit) {
        return;
    }

    var userInput = document.getElementById("adminUser");
    var passwordInput = document.getElementById("adminPassword");
    var passwordToggle = document.getElementById("adminPasswordToggle");
    var capsHint = document.getElementById("adminCapsHint");
    var status = document.getElementById("adminStatus");
    var isBusy = false;

    var fields = [
        { input: userInput, error: document.getElementById("adminUserError") },
        { input: passwordInput, error: document.getElementById("adminPasswordError") }
    ];

    var fieldError = function (input) {
        var value = input === passwordInput ? input.value : input.value.trim();

        if (!value) {
            return input === userInput ? "Enter your username." : "Enter your password.";
        }
        // ASP.NET's request validation would refuse the whole post over this and show an error
        // page instead of the form, so it is caught here.
        if (/<[a-z!\/?]|&#/i.test(value)) {
            return "Can't contain \"<\" before a letter or symbol, or \"&#\".";
        }
        return "";
    };

    // The password input is wrapped for its toggle, so the field is found by class, not parentNode.
    var fieldOf = function (input) {
        var node = input.parentNode;

        while (node && !node.classList.contains("adm-field")) {
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

    var clearStatus = function () {
        status.textContent = "";
        status.classList.remove("is-visible");
    };

    fields.forEach(function (field) {
        field.input.addEventListener("input", function () {
            clearStatus();
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

    if (!userInput.value) {
        userInput.focus();
    }

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
            // The field messages replace the server's alert rather than stacking under it, which
            // would push the page past the viewport.
            clearStatus();
            firstInvalid.focus();
            return;
        }

        // Not `disabled`: a disabled button isn't sent with the form, and the server would never
        // know which button raised the post, so adminSubmit_Click wouldn't run.
        isBusy = true;
        submit.classList.add("is-busy");
        submit.setAttribute("aria-disabled", "true");
        submit.value = "Signing in...";
    });
})();
