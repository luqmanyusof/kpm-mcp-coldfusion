# 02 - The CRUD app (run it, understand it)

> **Day 1, after lunch** - you run the app and read how it works. This is the "existing app" that the
> rest of the course connects an AI to.

This module is **already written**. You don't write CRUD code here - you run it and read this guide,
which explains each part. It's a Create / Read / Update / Delete app for the `murid` table, with a
Bootstrap UI.

- **Pages:** [`crud/`](crud/)
- **Table:** `murid` (full student record - see [DATABASE.md](../00-setup/DATABASE.md))
- **Run this project:** <http://localhost:8500/kpm-mcp-coldfusion/02-crud-app/crud/> (the home page redirects to the list).

---

## Setup (what makes it run)

1. **The datasource** - the connection named `cf_test_crud` is defined once in the ColdFusion
   Administrator, and `Application.cfc` makes it this app's default. Every CRUD page just says `datasource="cf_test_crud"`; no connection details are
   repeated.
2. **The shared layout** - `includes/_header.cfm` and `_footer.cfm` hold the page top (with the
   Bootstrap CDN link + nav) and bottom. Each page pulls them in with
   `<cfinclude template="includes/_header.cfm">`, so the look is consistent.
3. **The database** - created by `00-setup/db/schema.sql` ([setup](../00-setup/SETUP.md) step 5). Nothing else to configure.

Try it: add a student, click a name to view, edit it, delete it. Then read how each page works.

---

## The five pages

### `list.cfm` - Read all

- Runs one `SELECT` and loops the rows with `<cfoutput query="murid">` into a table.
- Reads a flash message from the URL (`<cfparam name="url.msg" default="">`) and shows a green banner
  after a create/update/delete.
- Each row links to `view`, `edit` and `delete` with `?id=#murid.id#`.

### `view.cfm` - Read one

- `<cfparam name="url.id" default="0">` gives `id` a default so the page never errors.
- The `SELECT` guards the id with `<cfqueryparam ... cfsqltype="cf_sql_integer">`.
- If `murid.recordCount` is 0 it shows a "not found" message and `<cfabort>`s (stops the page).

### `create.cfm` - Create

- The top of the file `<cfparam>`s every form field, so the form works on first load and after an
  error.
- It only acts when the form was posted: `<cfif cgi.request_method EQ "POST">`.
- It validates into an `errors` array, and if empty runs an `INSERT` (every value wrapped in
  `<cfqueryparam>`).
- On success it uses **Post/Redirect/Get**: `<cflocation url="list.cfm?msg=created">`. This
  redirect runs *before* any HTML, so refreshing the list won't re-submit the form.
- The form fields themselves come from a shared include (below).

### `_form_fields.cfm` - the shared form

- Used by **both** `create.cfm` and `edit.cfm`, so the form is written once.
- The caller sets `form.*` (the current values), `formAction` (where it posts) and `submitLabel`
  (the button text) before including it.
- Every value is printed with `encodeForHTMLAttribute(...)` so user input can't break the HTML.

### `edit.cfm` - Update

- On first load (a GET) it `SELECT`s the row and copies each column into `form.*` to pre-fill the form.
- On POST it validates and runs an `UPDATE ... WHERE id = <cfqueryparam ...>`, then redirects with
  `?msg=updated`.

### `delete.cfm` - Delete

- A GET shows *what* will be deleted (a small summary) with a confirm button.
- The delete itself is a **POST** (a `<form>` button), not a link - so it can't be triggered by a
  stray click or a crawler. On POST it runs `DELETE ... WHERE id = <cfqueryparam ...>` and redirects
  with `?msg=deleted`.

---

## The ideas worth remembering

- **`cgi.request_method`** tells you GET vs POST - that's how one page both shows a form and handles it.
- **`<cfparam>`** avoids "variable doesn't exist" errors by giving defaults.
- **`<cfqueryparam>`** on every user value stops SQL injection - non-negotiable.
- **Post/Redirect/Get** (`<cflocation>` after a write) stops double submits.
- **`encodeForHTML()` / `encodeForHTMLAttribute()`** when printing user data stops broken pages and XSS.

When you've read all five, move on to **[03 - The AI framework](../03-ai-framework/NOTES.md)**. From here on
you stop reading code and start *directing* the AI that writes it.
