(function () {
    "use strict";

    // The dashboard's one global. Every other script adds its piece to it and talks to the others
    // through the small event bus below, never by reaching into another component's elements.
    var dash = window.AdminDash = window.AdminDash || {};
    var listeners = {};

    dash.byId = function (id) {
        return document.getElementById(id);
    };

    // Builds an element. Text always goes in as a text node, never through innerHTML: names, emails
    // and addresses come from whatever people typed when they signed up.
    dash.el = function (tag, props, children) {
        var node = document.createElement(tag);

        Object.keys(props || {}).forEach(function (key) {
            var value = props[key];

            if (value === null || value === undefined || value === false) {
                return;
            }

            if (key === "text") {
                node.textContent = value;
            } else if (key === "className") {
                node.className = value;
            } else {
                node.setAttribute(key, value === true ? "" : String(value));
            }
        });

        (children || []).forEach(function (child) {
            if (child === null || child === undefined || child === false) {
                return;
            }
            node.appendChild(typeof child === "string" ? document.createTextNode(child) : child);
        });

        return node;
    };

    dash.clear = function (node) {
        while (node.firstChild) {
            node.removeChild(node.firstChild);
        }
    };

    dash.on = function (name, handler) {
        (listeners[name] = listeners[name] || []).push(handler);
    };

    dash.emit = function (name, detail) {
        (listeners[name] || []).forEach(function (handler) {
            handler(detail);
        });
    };

    // Runs fn once the calls stop for `wait` ms. flush() runs a pending call now; cancel() drops it.
    dash.debounce = function (fn, wait) {
        var timer = null;
        var pendingArgs = null;

        var run = function () {
            var args = pendingArgs;
            timer = null;
            pendingArgs = null;
            fn.apply(null, args);
        };

        var debounced = function () {
            pendingArgs = Array.prototype.slice.call(arguments);
            clearTimeout(timer);
            timer = setTimeout(run, wait);
        };

        debounced.flush = function () {
            if (timer !== null) {
                clearTimeout(timer);
                run();
            }
        };

        debounced.cancel = function () {
            clearTimeout(timer);
            timer = null;
            pendingArgs = null;
        };

        return debounced;
    };
})();
