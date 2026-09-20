<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ManageUserDialog.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Dashboard.Users.ManageUserDialog" %>
<%@ Register TagPrefix="dash" TagName="Icon" Src="~/Components/Dashboard/Shared/Icon.ascx" %>
<%-- Opened from a Manage button or a recent sign-up (managedialog.js). A native <dialog>: showModal
     gives it the backdrop, the focus trap and Escape to close without any code of ours. --%>
<dialog class="adm-dialog" id="manageDialog" aria-labelledby="manageTitle">
    <div class="adm-dialog-head">
        <span class="adm-avatar adm-avatar--lg" id="manageAvatar" aria-hidden="true"></span>
        <div class="adm-dialog-titles">
            <h2 class="adm-dialog-title" id="manageTitle">Manage account</h2>
            <p class="adm-dialog-subtitle" id="manageSubtitle"></p>
        </div>
        <button type="button" class="adm-icon-btn" id="manageClose" aria-label="Close">
            <dash:Icon runat="server" Name="close" />
        </button>
    </div>

    <div class="adm-dialog-body">
        <p class="adm-alert" id="manageError" role="alert"></p>
        <p class="adm-dialog-loading" id="manageLoading">Loading account&hellip;</p>

        <div id="manageContent" hidden>
            <section class="adm-dialog-section" aria-labelledby="manageInfoTitle">
                <h3 class="adm-section-title" id="manageInfoTitle">Account information</h3>
                <dl class="adm-details" id="manageDetails"></dl>
            </section>

            <%-- What the account filled in on its own portfolio page, kept apart from the
                 sign-up details above so it is clear which of the two the admin is reading. --%>
            <section class="adm-dialog-section" aria-labelledby="managePortfolioTitle">
                <h3 class="adm-section-title" id="managePortfolioTitle">Portfolio content</h3>
                <dl class="adm-details" id="managePortfolio"></dl>
            </section>

            <p class="adm-protected-note" id="manageProtected" hidden>
                <dash:Icon runat="server" Name="shield" Size="18" />
                Administrator accounts can't be deactivated or deleted from the dashboard.
            </p>

            <section class="adm-dialog-section" id="manageStatusSection" aria-labelledby="manageStatusTitle">
                <h3 class="adm-section-title" id="manageStatusTitle">Account status</h3>
                <div class="adm-status-row">
                    <div>
                        <p class="adm-status-label" id="manageStatusLabel">Active</p>
                        <p class="adm-status-help" id="manageStatusHelp"></p>
                    </div>
                    <button type="button" class="adm-switch" id="manageStatusSwitch" role="switch"
                        aria-checked="true" aria-labelledby="manageStatusTitle" aria-describedby="manageStatusHelp">
                        <span class="adm-switch-thumb" aria-hidden="true"></span>
                    </button>
                </div>
            </section>

            <section class="adm-dialog-section adm-danger-zone" id="manageDeleteSection" aria-labelledby="manageDeleteTitle">
                <h3 class="adm-section-title" id="manageDeleteTitle">Delete account</h3>
                <p class="adm-status-help">Permanently removes the account and everything stored with it. This can't be undone.</p>
                <button type="button" class="adm-btn adm-btn--danger-outline" id="manageDeleteStart">
                    <dash:Icon runat="server" Name="trash" Size="18" />
                    Delete account
                </button>

                <%-- Typing the username is the confirmation, so a stray click or Enter can't delete. --%>
                <div class="adm-confirm" id="manageConfirm" hidden>
                    <label class="adm-label" for="manageConfirmInput">
                        Type <strong id="manageConfirmWord"></strong> to confirm
                    </label>
                    <input type="text" class="adm-input" id="manageConfirmInput" autocomplete="off" spellcheck="false" />
                    <div class="adm-confirm-actions">
                        <button type="button" class="adm-btn adm-btn--secondary" id="manageDeleteCancel">Cancel</button>
                        <button type="button" class="adm-btn adm-btn--danger" id="manageDeleteConfirm" disabled="disabled">
                            Delete permanently
                        </button>
                    </div>
                </div>
            </section>
        </div>
    </div>
</dialog>
