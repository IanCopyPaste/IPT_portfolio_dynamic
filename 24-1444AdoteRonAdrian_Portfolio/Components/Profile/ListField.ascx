<%@ Control Language="C#" AutoEventWireup="true" CodeBehind="ListField.ascx.cs" Inherits="_24_1444AdoteRonAdrian_Portfolio.Components.Profile.ListField" %>
<%-- One of the profile's growable lists: a row per value the user has, and a "+" that adds another
     up to the admin's limit. Every row's input shares one name, so the whole list posts back as a
     single repeated field in the order it is on screen, however many rows there are.
     profilepage.js adds, removes and renumbers the rows; the server only ever draws them. --%>
<div class="profile-list" data-profile-list="" data-noun="<%: Noun %>" data-plural="<%: Plural %>" data-max="<%= Max %>">
    <div class="register-fields profile-fields--slots profile-list-rows">
        <% for (int i = 0; i < Values.Count; i++) { %>
        <div class="login-field profile-list-row<%= Errors[i] == null ? "" : " is-invalid" %>">
            <label for="<%= FieldName %><%= i + 1 %>"><%: Noun %> <%= i + 1 %></label>
            <div class="profile-list-input">
                <input type="text" id="<%= FieldName %><%= i + 1 %>" name="<%= FieldName %>" value="<%: Values[i] %>"
                    maxlength="<%= MaxLength %>" placeholder="<%: Placeholder %>" />
                <button type="button" class="profile-list-remove" aria-label="Remove <%: Noun.ToLowerInvariant() %> <%= i + 1 %>">&times;</button>
            </div>
            <span class="login-error" aria-live="polite"><%: Errors[i] %></span>
        </div>
        <% } %>
        <%-- Without script there is no "+", so one empty row is drawn instead; a list then grows by
             one per save. A blank row is dropped on the way in, so leaving it empty costs nothing. --%>
        <% if (Values.Count < Max) { %>
        <noscript>
            <div class="login-field profile-list-row">
                <label for="<%= FieldName %><%= Values.Count + 1 %>"><%: Noun %> <%= Values.Count + 1 %></label>
                <input type="text" id="<%= FieldName %><%= Values.Count + 1 %>" name="<%= FieldName %>"
                    maxlength="<%= MaxLength %>" placeholder="<%: Placeholder %>" />
            </div>
        </noscript>
        <% } %>
    </div>

    <%-- What "+" clones. Inside a template its input is inert, so it is never posted with the form;
         the label, the id and the remove button's name are filled in as the row is numbered. --%>
    <template class="profile-list-template">
        <div class="login-field profile-list-row">
            <label></label>
            <div class="profile-list-input">
                <input type="text" name="<%= FieldName %>" maxlength="<%= MaxLength %>" placeholder="<%: Placeholder %>" />
                <button type="button" class="profile-list-remove">&times;</button>
            </div>
            <span class="login-error" aria-live="polite"></span>
        </div>
    </template>

    <div class="profile-list-foot">
        <button type="button" class="profile-list-add">+ Add <%: Noun.ToLowerInvariant() %></button>
        <span class="profile-list-count"><%= Values.Count %> of <%= Max %></span>
    </div>
    <%-- Only ever says something when the admin has lowered the limit below what is already here. --%>
    <span class="login-error profile-list-error" aria-live="polite"><%: CountError %></span>
</div>
