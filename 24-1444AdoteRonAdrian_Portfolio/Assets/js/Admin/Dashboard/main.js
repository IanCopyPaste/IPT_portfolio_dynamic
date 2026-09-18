(function () {
    "use strict";

    // Loaded last: every component has subscribed to view:show by now, so the first view shown
    // (Analytics, unless the URL names another) finds its listener waiting.
    window.AdminDash.router.start();
})();
