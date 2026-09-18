(function () {
    "use strict";

    var dash = window.AdminDash;
    var region = dash.byId("dashToasts");

    var VISIBLE_MS = 4000;
    var LEAVE_MS = 200;
    var MAX_SHOWN = 3;

    // A short confirmation in the corner. tone "error" swaps the marker colour; the words carry the
    // meaning either way.
    dash.toast = function (message, tone) {
        var toast = dash.el("div", {
            className: "adm-toast" + (tone === "error" ? " adm-toast--error" : ""),
            text: message
        });

        region.appendChild(toast);

        while (region.children.length > MAX_SHOWN) {
            region.removeChild(region.firstChild);
        }

        setTimeout(function () {
            toast.classList.add("is-leaving");
            setTimeout(function () {
                if (toast.parentNode) {
                    toast.parentNode.removeChild(toast);
                }
            }, LEAVE_MS);
        }, VISIBLE_MS);
    };
})();
