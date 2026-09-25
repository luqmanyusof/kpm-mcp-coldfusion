# 04 demo - What an API looks like inside (20 minutes)

> **Day 2, first thing** - the trainer fills in `pelajar.cfm` live, one TODO at a time, so you have seen
> what an API is *before* the AI builds one for you. You do not have to type this.

The file `pelajar.cfm` is a skeleton with four `TODO`s. This guide has the exact code for each one.

- **Table:** `pelajar` (`id`, `name`, `email`).
- **File you edit:** [`pelajar.cfm`](pelajar.cfm)
- **Stuck?** Compare with [`pelajar.reference.cfm`](pelajar.reference.cfm) (the finished version).
- **Run this project:** open <http://localhost:8500/cf-mcp-course/04-rest-api/api-demo/>.

---

## What the API does

| Method | URL | Body (JSON) | Returns |
|--------|-----|-------------|---------|
| GET    | `/pelajar.cfm`      | -                         | `{ "data": [ ...rows ] }` |
| GET    | `/pelajar.cfm?id=1` | -                         | one row, or 404 |
| POST   | `/pelajar.cfm`      | `{"name":..,"email":..}`  | the created row (201) |
| PUT    | `/pelajar.cfm?id=1` | `{"name":..,"email":..}`  | `{ "updated": true, "id": 1 }` |
| DELETE | `/pelajar.cfm?id=1` | -                         | `{ "deleted": true, "id": 1 }` |

## The helpers (already written for you)

The skeleton already has three small helpers, so you can focus on the SQL:

- `respond(body, status)` - turns a struct/array into JSON and stops the page.
- `readBody()` - reads the JSON request body into a struct.
- `rows(query)` - turns a query result into a plain array (clean JSON).

It also sets three variables you will use: `ds` (the datasource name), `method` (GET/POST/...),
and `hasId` (`true` when `?id=` is in the URL).

Every query below uses **`<cfqueryparam>`-style binds** (`:id`, `:name`, ...) so user input can never
break the SQL. The third argument, `{ datasource: ds }`, tells CFML which database to use.

---

## TODO 1 - GET (list all, or one by id)

In the `case "GET":` block, replace the `respond({ "todo": ... }, 501);` line with:

```cfml
if (hasId) {
    one = queryExecute(
        'SELECT id AS "id", name AS "name", email AS "email" FROM pelajar WHERE id = :id',
        { id: { value: url.id, cfsqltype: "cf_sql_integer" } },
        { datasource: ds }
    );
    if (!one.recordCount) respond({ "error": "Not found" }, 404);
    respond(rows(one)[1]);
}
all = queryExecute('SELECT id AS "id", name AS "name", email AS "email" FROM pelajar ORDER BY name', {}, { datasource: ds });
respond({ "data": rows(all) });
```

**Test it:**

```bash
curl http://localhost:8500/cf-mcp-course/04-rest-api/api-demo/pelajar.cfm
curl http://localhost:8500/cf-mcp-course/04-rest-api/api-demo/pelajar.cfm?id=1
```

---

## TODO 2 - POST (create)

In the `case "POST":` block, replace the placeholder line with:

```cfml
b = readBody();
newId = queryExecute("SELECT pelajar_seq.NEXTVAL AS id FROM dual", {}, { datasource: ds }).id;
queryExecute(
    "INSERT INTO pelajar (id, name, email) VALUES (:id, :name, :email)",
    { id:    { value: newId,   cfsqltype: "cf_sql_integer" },
      name:  { value: b.name,  cfsqltype: "cf_sql_varchar" },
      email: { value: b.email, cfsqltype: "cf_sql_varchar" } },
    { datasource: ds }
);
created = queryExecute(
    'SELECT id AS "id", name AS "name", email AS "email" FROM pelajar WHERE id = :id',
    { id: { value: newId, cfsqltype: "cf_sql_integer" } },
    { datasource: ds }
);
respond(rows(created)[1], 201);
```

Oracle hands out ids from a **sequence** (`pelajar_seq`). We take the next number first, insert
with it, then read the new row back to return it.

**Why `AS "id"` in the SELECT?** Oracle returns column names in CAPITALS, so the JSON would say
`"ID"`. Quoting the alias keeps it lowercase: `"id"`. (The SQL is in single quotes so the double
quotes inside don't end the string.)

**Test it:**

```bash
curl -X POST http://localhost:8500/cf-mcp-course/04-rest-api/api-demo/pelajar.cfm \
     -H "Content-Type: application/json" \
     -d '{"name":"Chong Ke Xin","email":"kexin@example.com"}'
```

---

## TODO 3 - PUT (update)

In the `case "PUT":` block, replace the placeholder line with:

```cfml
if (!hasId) respond({ "error": "id required" }, 400);
b = readBody();
queryExecute(
    "UPDATE pelajar SET name = :name, email = :email WHERE id = :id",
    { name:  { value: b.name,  cfsqltype: "cf_sql_varchar" },
      email: { value: b.email, cfsqltype: "cf_sql_varchar" },
      id:    { value: url.id,  cfsqltype: "cf_sql_integer" } },
    { datasource: ds }
);
respond({ "updated": true, "id": val(url.id) });
```

**Test it:**

```bash
curl -X PUT "http://localhost:8500/cf-mcp-course/04-rest-api/api-demo/pelajar.cfm?id=1" \
     -H "Content-Type: application/json" \
     -d '{"name":"Ahmad Danish","email":"ahmad.new@example.com"}'
```

---

## TODO 4 - DELETE

In the `case "DELETE":` block, replace the placeholder line with:

```cfml
if (!hasId) respond({ "error": "id required" }, 400);
queryExecute(
    "DELETE FROM pelajar WHERE id = :id",
    { id: { value: url.id, cfsqltype: "cf_sql_integer" } },
    { datasource: ds }
);
respond({ "deleted": true, "id": val(url.id) });
```

**Test it:**

```bash
curl -X DELETE "http://localhost:8500/cf-mcp-course/04-rest-api/api-demo/pelajar.cfm?id=6"
```

---

## Done

That is a working API - with no access key, which is why the real one in this module has one. Notes:

- A `.cfm` edit is picked up on the next request - **no server restart needed** for this file.
- If your JSON looks like `{"COLUMNS":[...],"DATA":[...]}`, you forgot to wrap the query in `rows(...)`.
- Keep every user value inside a `:bind` - never build SQL by joining strings.

Compare with `pelajar.reference.cfm` if anything misbehaves. Next: back to [NOTES.md](../NOTES.md), part B.
