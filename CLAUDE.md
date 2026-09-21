# Design rules — 24-1444 Adote Ron Adrian Portfolio

ASP.NET Web Forms (.NET Framework, C#). The portfolio proper is hand-written HTML/CSS/JS;
there is no front-end framework and no build step. Read this before touching any markup or styling.

## Two kinds of pages — don't mix them

- **Portfolio pages** (`ContentPage.aspx`, `LoginPage.aspx`) are standalone full documents.
  They declare their own `<!DOCTYPE html>`, `<head>` and `<body>`, use **no** master page, and
  pull in only their own stylesheet. `ContentPage.aspx` is the real, finished work.
- **Scaffold pages** (`Default.aspx`, `Site.Master`, `ViewSwitcher.ascx`, `Content/bootstrap.css`,
  `Scripts/`) are leftover Visual Studio template. They use Bootstrap and jQuery.

Never introduce Bootstrap, jQuery, or a master page into a portfolio page, and don't treat the
scaffold's conventions as this project's conventions.

## Visual language

Dark "terminal / glitched CRT" aesthetic: near-black background, a single neon-green accent,
generous glow, and deliberate instability (flicker, RGB split, character corruption). Cards (the
About panels, the projects and tech-stack panels) deliberately carry no coloured stripe or
coloured border — keep their edges neutral (`--cp-border`). Keep new work inside that language —
it is the point of the design, not decoration to be sanded off.

## Design tokens

Every colour, radius, and font lives as a `--cp-*` custom property on `:root` at the top of
`Assets/css/ContentPage/contentpage.css`. Use the token, never a duplicated literal:

| Purpose | Token |
| --- | --- |
| Page background / surfaces | `--cp-bg`, `--cp-surface`, `--cp-surface-alt` |
| Text | `--cp-text`, `--cp-muted` |
| Accent | `--cp-accent` (`#39ff88`), `--cp-accent-soft` |
| Borders | `--cp-border` |
| Terminal title-bar dots | `--cp-pastel-1` (red), `--cp-pastel-2` (cyan), `--cp-pastel-3` (green) |
| Form errors | `--cp-pastel-1` |
| Radii | `--cp-radius-lg` (20px), `--cp-radius-md` (12px) |
| Fonts | `--cp-font-display` (Anton), `--cp-font-mono` (Share Tech Mono) |
| Navbar | `--cp-navbar-height` |

**The one exception:** glows and translucent washes are written as literal `rgba(57, 255, 136, …)`
rather than the token, because a hex custom property can't be given an alpha channel inside
`rgba()`. Match the existing literals exactly when adding a glow; if the accent ever changes,
these have to be updated with it.

## Typography

- Headings, brand, card titles, tech-panel titles: `var(--cp-font-display)`, `font-weight: 400`
  (Anton ships a single weight — never ask for bold), `text-transform: uppercase`, positive
  `letter-spacing`.
- The home bio and anything meant to read as terminal output: `var(--cp-font-mono)`. Monospace is
  load-bearing there — the JS swaps characters in place and a proportional face would reflow.
- Body copy: the `body` sans-serif stack (`Segoe UI`, Roboto, …). Muted copy uses `--cp-muted`
  with `line-height: 1.8`.
- Hero sizing uses `clamp()` rather than breakpoint overrides.

## Class naming

- Lowercase, hyphen-separated, descriptive of the block: `.home-heading-row`, `.tech-stack-panel`,
  `.project-list`.
- Variants use a double-hyphen suffix on the base class, and the element carries both:
  `.profile-photo.profile-photo--home`, `.navbar.navbar--top`, `.reveal.reveal--left`.
- State is a plain adjective class toggled from JS: `.active`, `.open`, `.is-visible`.
- Every `@keyframes` name is prefixed `cp-`: `cp-reveal-up`, `cp-text-flicker`, `cp-grid-scroll`.
  Keep the prefix — it is what keeps page animations from colliding with scaffold CSS.

## Stylesheet organisation

The stylesheet is split into files under `Assets/css/ContentPage/`, linked from `ContentPage.aspx`
in this order — the order is load-bearing, since later files override earlier ones:

| File | Holds |
| --- | --- |
| `contentpage.css` | tokens → base → navbar → layout helpers, incl. the shared `.terminal-bar` |
| `home.css`, `about.css`, `skills.css`, `contact.css` | one section each, in page order (the footer lives in the contact section and in `contact.css`) |
| `reveal.css` | the scroll-reveal system and its reduced-motion override |
| `responsive.css` | the responsive block; always last |

Each file keeps its banner comment:

```css
/* ---------- Home section ---------- */
```

Add new rules to the matching section file rather than to whichever file is open, and give a new
section its own file linked in page order. All breakpoint media queries live in `responsive.css`,
at exactly two breakpoints — **900px** and **720px**. Don't invent a third without a reason.

## Layout

- `.section` is `min-height: 100vh`, flex, vertically centred, `overflow: hidden`.
  That clipping is real: anything that animates sideways will shear against the section edge, so
  entrance motion travels vertically.
- `.section-inner` caps content at `max-width: 1200px` with `padding: 96px 24px`, tightening to
  `64px 20px` below 720px.
- The navbar is `position: fixed` and does **not** occupy layout space — sections land flush with
  the top of the viewport, and the smooth-scroll code in `contentpage.js` assumes exactly that.

## Motion

Animation is central here, but it follows one system — extend it, don't write a parallel one.

- **Ambient motion** loops forever (`cp-grid-scroll`, `cp-text-flicker`, `cp-photo-flicker`, the
  glitch shifts). It belongs on the element itself.
- **Entrance motion** goes through the shared reveal system in `contentpage.js`:
  add `class="reveal"` to the block; an `IntersectionObserver` adds `is-visible`, and the classes
  are stripped on `animationend` so the element is left with no leftover animation or opacity.
  - Reveals are **animations, not transitions**, so they never fight an element's own hover transition.
  - Siblings auto-stagger. For a hand-ordered sequence across non-siblings, set
    `data-reveal-delay="<ms>"`, which overrides the stagger.
  - An element that also has ambient motion is held at `animation: none` until its reveal starts —
    otherwise its keyframed `opacity` paints straight over the hidden state and it flashes into
    view. That rule is `.js .reveal:not(.is-visible)`; keep it in mind when adding a reveal to
    anything that already flickers.
- **Hover** uses short transitions (200–320ms) on `transform`, `box-shadow`, `border-color`, `color`.
- Honour `prefers-reduced-motion: reduce` for anything new that travels: content should still
  appear, it just shouldn't move.

## Progressive enhancement

- The `js` class is added to `<html>` by an inline script in `<head>`, before first paint.
  Everything that hides content pre-animation is gated on `.js`, so with scripting off the page
  still renders fully. Any new "hidden until revealed" rule must be gated the same way.
- Photos carry an inline `onerror` that hides the `<img>` and shows the
  `.profile-photo-placeholder` silhouette. Keep that fallback on new portraits.
- Decorative elements get `aria-hidden="true"`; nav toggles carry `aria-expanded` / `aria-controls`.

## JavaScript style

`contentpage.js` is a single IIFE with `"use strict"`, written in ES5 (`var`, function expressions,
`Array.prototype.slice.call`) — match it rather than introducing `let`/arrow functions mid-file.
Scroll work is rAF-throttled through **one** shared listener; if you need another scroll-driven
effect, add it to `updateOnScroll` instead of registering a second listener.

## Files and assets

```
Assets/<PageName>/          images and logos for that page
Assets/css/<PageName>/<pagename>.css   tokens, base, navbar, layout
Assets/css/<PageName>/<section>.css    one per section, plus reveal.css and responsive.css
Assets/js/<PageName>/<pagename>.js
```

Logo files are lowercase `logo-<tech>.svg`. Each stylesheet and the script is linked with its
own `?v=N` cache-busting query — **bump that file's number whenever you edit it**, or the change
won't show up for anyone with the old copy cached.

## Server-side

User-facing text that repeats lives as a `public const string` in the code-behind
(`ContentPage.aspx.cs`) and is emitted with `<%= %>`, so it has one source of truth.
Server-side comments in markup use `<%-- --%>`, not `<!-- -->`.

Anything a user typed is emitted with `<%: %>`, which HTML-encodes; `<%= %>` is only for
values the code itself produced (a year, a CSS class name).

### The portfolio is per-user

The portfolio is one account's page, not one person's: `ContentPage.aspx` reads the signed-in
user and draws everything from their row. The account fields (name, address) live on `users`;
birthdate, sex, nationality, the footer tagline, the three schools and five projects live one-to-one in
`user_profile`; hobbies and skills are rows in `user_profile_item`. The user fills all of it in
on `ProfilePage`.

Every portfolio field is optional. A field that is still blank renders `ContentPage.UnsetText`
with the `cp-unset` class, and a list that is entirely blank renders a short line in its place,
so a brand-new account gets a complete page of placeholders rather than gaps. The project and
school counts (5 / 3) are fixed in `ProfileRules` and matched by the table's numbered columns;
blanks are dropped on the way out.

Hobbies and skills are growable lists (`Components/Profile/ListField.ascx`, driven by
`profilepage.js`): a "+" adds a row, up to a maximum the admin sets in the dashboard's Settings
view. The two maximums live in the single `site_settings` row, read through
`Accounts/ProfileLimits.cs` (range 1–12). `ProfilePage` refuses a save over the limit, and
`ContentPage` draws no more than it.

The tech-stack panel in the Skills section is deliberately **not** per-user — it is the site's
own list, with logos, and stays hard-coded.

### SQL

Sign-in, sign-up, the account half of `ProfilePage`, and the admin dashboard use inline
parameterised SQL. The portfolio content is the exception: it goes through the two stored
procedures last recreated in `Database/Migrations/006_profile_tagline.sql`, wrapped by
`Accounts/ProfileStore.cs`.
New work on the portfolio content belongs in a procedure; don't convert the rest.

Migrations are numbered, idempotent, and name the database in a `USE` that has to match
`Web.config`'s `portfolio_conn`. They are never edited after being run — add the next number.

## Comments

The codebase comments explain **why**, not what — the clipping constraint, why the bio is
monospace, why reveals are animations. Match that density and that habit; a comment restating the
line below it doesn't belong.

## Verifying visual work

There is no test suite. To actually check a change, serve the rendered page over `http://localhost`
(a file:// URL won't load and the browser tool refuses it) with the server tags substituted, then
inspect computed styles — screenshots alone will not catch an animation that never fires or an
element that flashes before it animates.
