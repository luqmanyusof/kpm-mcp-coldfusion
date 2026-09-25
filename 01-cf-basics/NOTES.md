# 01 - ColdFusion basics

> **Day 1, morning** - trainer demo, you follow along in the browser and in VS Code.

Learn just enough ColdFusion (CFML) to read data from a database. **No CSS** here - plain HTML so
the language stays in focus. Open the pages in your browser and read the code alongside this guide.

- **Pages:** [`basics/`](basics/) (`index`, `01-syntax`, `02-logic`, `03-database`)
- **Table used:** `pelajar` (`id`, `name`, `email`)
- **Run this project:** <http://localhost:8500/cf-mcp-course/01-cf-basics/basics/> (Oracle container running -
  [00-setup](../00-setup/SETUP.md)).

---

## How CFML works

A `.cfm` file is an HTML file with a `.cfm` extension. The server runs any tag starting with `cf`
and sends plain HTML to the browser. You freely mix CFML and HTML in the same file.

## 1. Variables and output (`01-syntax.cfm`)

- `<cfset x = ...>` creates a variable (shows nothing).
- `<cfoutput> ... </cfoutput>` prints, and text between `#hashes#` inside it is read as a variable.
- Outside `<cfoutput>`, a `#` is just a normal character.

```cfml
<cfset name = "Ahmad Danish">
<cfoutput>Name: #name#, uppercase: #ucase(name)#</cfoutput>
```

The most common beginner mistake is forgetting `<cfoutput>` - then `#name#` prints literally.

## 2. Logic, loops and data (`02-logic.cfm`)

- `<cfif> / <cfelseif> / <cfelse>` with word operators: `EQ NEQ GT LT GTE LTE`.
- `<cfloop index="i" from="1" to="5">` repeats.
- Arrays `["a","b"]` (they **start at index 1**) and structs `{ key = "value" }`.

A struct is a set of key/value pairs - the same shape as one database row, which leads into the next
page.

## 3. Reading the database (`03-database.cfm`)

- A **datasource** is a named database connection. Ours, `cf_test_crud`, is defined once in the
  ColdFusion Administrator (setup step 6), so every page can use it without knowing the password.
- `<cfquery name="pelajar" datasource="cf_test_crud"> SELECT ... </cfquery>` runs SQL and stores the
  result in `pelajar`.
- `<cfoutput query="pelajar"> ... </cfoutput>` repeats its body once per row; `pelajar.recordCount`
  is the row count.

```cfml
<cfquery name="pelajar" datasource="cf_test_crud">
    SELECT id, name, email FROM pelajar ORDER BY name
</cfquery>

<cfoutput query="pelajar">#pelajar.name# - #pelajar.email#<br></cfoutput>
```

**Safety rule:** when a query uses a value from the user (like `url.id`), never paste it into the SQL.
Wrap it in `<cfqueryparam>` so it can't be abused (SQL injection):

```cfml
WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
```

---

## What's next

- **[02 - The CRUD app](../02-crud-app/NOTES.md)** takes the same query idea and adds create / update /
  delete, with a Bootstrap UI. You run it and read how it works.
- Later, **[04 - REST API](../04-rest-api/NOTES.md)** opens a second door into the same data - for programs
  instead of people.
