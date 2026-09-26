# Day 2 — Build the REST API, then Pivot to MCP

> *Part of **MCP Development for Web Applications** — AI-driven development with ColdFusion, Oracle
> and Node.js (Day 2 of 3).*

This morning the AI **builds yesterday's plan** one phase at a time, you **test every phase**, and by
lunch the student-records app has a second door: a **REST API** (Representational State Transfer
Application Programming Interface) protected by a key. This afternoon you learn what an **MCP
server** (Model Context Protocol) is, plan one with the same framework, and get its **first tool**
working end to end.

**Why an API first?** The web pages are a door for *people*. An AI — through the MCP server — needs a
door for *programs*: fixed URLs, JSON (JavaScript Object Notation) in and out, and a key. The MCP
server never touches the database; it only knocks on this door, so all the app's rules still apply.

**Stack:** Adobe ColdFusion 2021, Oracle XE, DBeaver, VS Code + Continue (Gemma 4 / Token Harbor),
**Postman** (API testing), **Node.js** (runs the MCP server), the **MCP Inspector** (tests MCP tools
without an AI app).

**What you build today**
- A **secret API key** in a file outside the web folder
- **Your REST API** over `murid` — list, get, create, update, delete — every call needs the key
- A **Postman collection** (written by the AI) that tests every acceptance check
- **`API.md`** — how the API works, the blueprint for the MCP server
- **Your MCP plan** — `REQUIREMENTS.md` + `PHASES.md` for a Node.js MCP server
- The **first MCP tool** (`list_murid`) working end to end in the MCP Inspector

**What is NOT in scope today:** writing code yourself, the other four MCP tools (Day 3 morning),
Claude Desktop (Day 3), authentication beyond one shared key, deploying anything off your laptop.

**How this day builds (prerequisites first, easy first):**
1. Ready the Day 2 tools → 2. REST fundamentals (concept) → 3. What an API looks like inside
(trainer demo) → 4. **Build the API** phase by phase with the AI → 5. **Test everything in Postman**
→ 6. Write down how it works (`API.md`) → 7. MCP architecture (concept) → 8. **Plan the MCP** with
the AI → 9. **First tool end to end.**

> **See it before the AI builds it:** Topic 3 shows a tiny API built by hand, so the one the AI builds
> in Topic 4 holds no surprises — you know what to look for in its code.

> **Carry-over:** you need Day 1's `workspace\rest-api\` with the approved `REQUIREMENTS.md` and
> `PHASES.md`. Missing them? Redo **Day 1 Topic 9** (about 20 minutes), or copy a neighbour's two files.

---

## Topic 1 — Ready your Day 2 tools

Three quick jobs.

### 1.1 — Create the API key file

The REST API only answers requests that carry this key. It lives **outside** the web folder, so it is
never in the code, in git, or in anything the AI reads.

```powershell
New-Item -ItemType Directory -Force C:\course-secrets | Out-Null
[guid]::NewGuid().ToString("N") | Set-Content -NoNewline C:\course-secrets\api-key.txt
Get-Content C:\course-secrets\api-key.txt
```

The last line prints your key. You paste it into **Postman** and (on Day 3) **Claude Desktop** only —
**never into the AI chat**.

### 1.2 — Install Postman (API testing)

1. Download from **`https://www.postman.com/downloads/`** (Windows 64-bit) and run it.
2. Sign in with a free account (recommended — it saves your work), or choose the lightweight client
   without an account.

### 1.3 — Install Node.js (runs the MCP server, this afternoon)

Install the **LTS** version from **`https://nodejs.org/`** (all defaults). In a **new** PowerShell:

```powershell
node -v      # v20 or newer
npm -v
```

**Checkpoint ✅ (Topic 1 complete)**
- `Get-Content C:\course-secrets\api-key.txt` prints a 32-character key.
- `http://localhost:8500/kpm-mcp-coldfusion/reference/api/murid.cfm` in the browser says
  `{"error":"Missing or wrong API key."}` — **correct!** The browser sends no key.
- Postman opens; `node -v` prints v20 or newer.

**Common problems**
- *The reference URL says `Server key is not configured` / 500* → the key file is missing or in a
  different folder; redo 1.1.
- *`node` is not recognised* → open a **new** PowerShell after installing Node.js.

---

## Topic 2 — REST fundamentals (concept)

**Prerequisite:** none. **Why this comes first:** you check the AI's API against these ideas — you need
the vocabulary before Topic 4.

**A "resource"** is a thing the API exposes. Ours is **murid** (students). REST maps HTTP (Hypertext
Transfer Protocol) verbs to actions on that resource, each at a URL (Uniform Resource Locator):

| Verb | URL | Action | Success status |
|---|---|---|---|
| GET | `murid.cfm` | list all students | 200 OK |
| GET | `murid.cfm?id=3` | show one student | 200 OK |
| POST | `murid.cfm` | add a student | 201 Created |
| PUT | `murid.cfm?id=3` | change student 3 | 200 OK |
| DELETE | `murid.cfm?id=3` | delete student 3 | 200 OK |

**Status codes you should know**
- **2xx success:** 200 OK, 201 Created.
- **4xx the caller got it wrong:** 400 bad input, **401 missing or wrong key**, 404 not found.
- **5xx the server broke:** 500 — the details go to a log, never to the caller.

**The key is the doorway.** Every request carries a header `X-API-Key: <key>`. No key, wrong key →
**401**, and nothing else happens. The web pages don't need it (they are the human door); programs —
Postman today, the MCP server later — do.

**Rules of thumb**
- Responses are **JSON**, always with a sensible status code. Errors look like `{ "error": "text" }`.
- Bad input is **rejected, never silently fixed**: `tingkatan: 7` is a 400 error, not "changed to 5".

**Checkpoint ✅** You can say which verb and status you would expect for "add a student" (POST → 201)
and for "wrong key" (any verb → 401).

---

## Topic 3 — What an API looks like inside (trainer demo)

**Prerequisite:** Topic 2.

**Goal:** see a tiny API built by hand in 20 minutes, so you know what to look for when the AI builds
yours. **Trainer demo — you do not have to type this.** Open `api-demo/pelajar.cfm` in VS Code and
`http://localhost:8500/kpm-mcp-coldfusion/api-demo/` in the browser.

`pelajar.cfm` is a skeleton for the small `pelajar` table (`id`, `name`, `email`) with four `TODO`s.
It already has three helpers: `respond(body, status)` turns a struct into JSON and stops;
`readBody()` reads the JSON request body; `rows(query)` turns a query into a plain array.

**TODO 1 — GET (list all, or one by id)**

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

> **Why `AS "id"`?** Oracle returns column names in CAPITALS, so the JSON would say `"ID"`. The quoted
> alias keeps it lowercase.

**TODO 2 — POST (create)** — Oracle hands out ids from a **sequence**: take the next number, insert
with it, read the new row back.

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

**TODO 3 — PUT (update)**

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

**TODO 4 — DELETE**

```cfml
if (!hasId) respond({ "error": "id required" }, 400);
queryExecute(
    "DELETE FROM pelajar WHERE id = :id",
    { id: { value: url.id, cfsqltype: "cf_sql_integer" } },
    { datasource: ds }
);
respond({ "deleted": true, "id": val(url.id) });
```

**Three things to check in the AI's API later:** JSON in and out; **every value in a bind parameter**
(`:id`, `:name` — the script version of `<cfqueryparam>`); a **status code for every answer**. And one
thing this demo deliberately lacks: **no key and no validation** — yours has both.

**Checkpoint ✅** `http://localhost:8500/kpm-mcp-coldfusion/api-demo/pelajar.cfm` returns
`{"data":[…]}` after the trainer fills in TODO 1. (The finished file is `api-demo/pelajar.reference.cfm`.)

---

## Topic 4 — Build the REST API, one phase at a time

**Prerequisite:** Topics 1–3, and Day 1's approved plan.

**Goal:** let the AI build `PHASES.md` — and prove each phase works before the next one starts.

Open your workspace (`code workspace\rest-api`), Continue in **Agent** mode — the **same chat as
yesterday** if you still have it. If not, start a new chat and paste:

```
REQUIREMENTS.md and PHASES.md in this folder are approved. Read them, then build Phase 1 only.
Stop after it and tell me exactly how to run its RUN TEST.
```

**The loop — repeat for every phase:**

| Step | You type (or do) |
|---|---|
| 1. Build | *(the AI edits files — read and approve each change it asks about)* |
| 2. Test | run the RUN TEST yourself — browser, Postman, or DBeaver (F5) |
| 3a. Passed | `RUN TEST passed: <what you saw>. Mark Phase 1 Verified in PHASES.md, then build Phase 2 only.` |
| 3b. Failed | `RUN TEST failed. Expected <x>. Got <paste the response or error>. Fix Phase 1 only.` |

**Rules that save you time**
- **One phase at a time.** If it builds two: `Stop. Only one phase at a time. Which phase is done?`
- **You run the test, not the AI.** "It should work" is not a test result.
- **Never paste the API key into the chat.** Paste responses and errors — not the key.
- **Check the code for the Topic 3 things:** binds (`:name`), status codes, and the key check first.
- `.cfm` changes work on the next refresh. A change to `Application.cfc` seems ignored? Ask the trainer
  to restart ColdFusion.

**Checkpoint ✅** Every phase in `PHASES.md` is marked **Verified**, and the CRUD web pages at
`…/workspace/rest-api/` still work (the API did not break the app).

**Common problems**
- *The AI says "done" but nothing changed* → ask: `Which files did you change? Show me the diff.`
- *Every request gets 401* → the API reads the key from the wrong place, or Postman sends it under a
  different header name — compare with `X-API-Key`.
- *The JSON has a block of HTML (a debug table) stuck on the end* → ColdFusion's debug output is on.
  Turn it off: Day 1, Topic 1.2, step 4.
- *`Datasource cf_test_crud could not be found`* → the AI created an `Application.cfc` without
  `this.datasource = "cf_test_crud"`; tell it.

---

## Topic 5 — Test everything in Postman

**Prerequisite:** Topic 4 (the API works phase by phase).

**Goal:** run every acceptance check in one go — and see that the wrong key and bad input are
rejected.

**Step 1 — ask the AI for a test collection:**

```
Write a Postman collection (v2.1 JSON) to postman_collection.json that runs every acceptance check
in REQUIREMENTS.md, in order. Use collection variables baseUrl and apiKey. Leave apiKey empty.
```

**Step 2 — import it.** Postman → **Import** → choose `workspace\rest-api\postman_collection.json`.

**Step 3 — add your key.** Open the collection → **Variables** → paste the key into the **Current
value** of `apiKey` (from `C:\course-secrets\api-key.txt`). Current values stay on your laptop — they
are never shared or exported. Check `baseUrl` points at **your** API.

**Step 4 — run it.** Collection → **Run** (the Runner). Every test should pass.

**Step 5 — compare with the reference collection.** Import
**`postman/Day2-murid-API.postman_collection.json`** too (set its `apiKey` the same way). It tests the
**reference API** (`reference/api/murid.cfm`):

| # | Request | Expect |
|---|---|---|
| 1 | List all | **200**, `data` is a list |
| 2 | List — Form 4 only (`?tingkatan=4`) | **200**, every row has `tingkatan` 4 |
| 3 | Get one (`?id=1`) | **200**, `id` 1 |
| 4 | Create | **201**, the new record (the IC number is made unique each run) |
| 5 | Update the new record | **200**, `kelas` changed |
| 6 | Delete the new record | **200**, `deleted: true` |
| 7 | Reject — wrong key | **401** |
| 8 | Reject — bad input (`tingkatan` 7, bad IC) | **400**, the error names `tingkatan` |
| 9 | Reject — not found (`?id=999999`) | **404** |

Did **your** AI's collection test the wrong-key and bad-input cases? If not:
`Add Postman tests for a wrong key (401) and for bad input (400).`

**Checkpoint ✅** Your collection runs all green, including a **401 for a wrong key** and a **400 for
bad input**.

**Common problems**
- *A test fails* → that is the build-and-check rhythm working. Paste the failing request and response to
  the AI: `This Postman test failed: ... Fix the API, not the test.`
- *Everything is 401* → the `apiKey` **Current value** is empty (the Initial value alone is not used).

---

## Topic 6 — Write down how the API works (`API.md`)

**Prerequisite:** Topic 5.

**Goal:** produce the document the MCP server is built from this afternoon. If it is wrong, the MCP
will be wrong.

```
Write API.md for a developer who will call this API from another program: base URL, the key header,
every method and URL, body fields with their rules, example responses, and every error code.
Do not include the key itself.
```

Compare it with **`reference/api/API.md`**. Check it has: the base URL, `X-API-Key`, the five
operations, every field with its rule, and the error table (400/401/404).

**Milestone — end of the application block (1.5 days)**
- [ ] every phase in `PHASES.md` is **Verified**
- [ ] the Postman run is all green, including **401** and **400**
- [ ] `API.md` describes the API correctly, with **no key in it**
- [ ] the CRUD web pages still work

> **Not finished by lunch?** No problem — the afternoon uses the **reference API** instead:
> `http://localhost:8500/kpm-mcp-coldfusion/reference/api/murid.cfm` with `reference/api/API.md`.
> Everyone starts the MCP on equal footing.

**Checkpoint ✅** `workspace\rest-api\API.md` exists and matches what your API really does.

---

## Topic 7 — MCP architecture (concept)

**Prerequisite:** a working API (yours or the reference).

**Goal:** know the parts of an MCP before planning one.

> **Theory:** read [mcp-theory.md](mcp-theory.md), parts 4–7 —
> [how a conversation works](mcp-theory.md#4--how-a-conversation-works-step-by-step),
> [what a tool is made of](mcp-theory.md#5--what-a-tool-is-made-of),
> [how the host and server connect](mcp-theory.md#6--how-the-host-and-the-server-connect) and
> [where MCP sits next to your API](mcp-theory.md#7--where-mcp-sits-next-to-your-api). This topic is the short version.

An **MCP server** is a small program that tells an AI app: *"here are the actions you may take, and
exactly what each one needs."* The AI decides **when** to use an action; your code decides **what it
is allowed to do**.

```
 You (plain English)
      |
      v
 Claude Desktop  (the AI app = MCP host/client)
      |   starts your server and talks to it over stdin/stdout ("stdio")
      v
 Your MCP server (Node.js)   list_murid  get_murid  create_murid  update_murid  delete_murid
      |   HTTP + X-API-Key
      v
 Your REST API (ColdFusion)  --->  Oracle
```

| Word | Meaning here |
|---|---|
| **Tool** | one action the AI may call, e.g. `create_murid` |
| **Description** | the sentence the AI reads to decide *when* to use the tool — written for the AI |
| **Input schema** | the exact fields and rules a tool accepts; a call that breaks them is rejected before it reaches your app |
| **stdio** | the AI app starts your server as a program and talks through its input/output — no port, no URL |
| **Environment variables** | how the server gets the API URL and key — from the AI app's config, never from the code |
| **SDK** | Software Development Kit — here `@modelcontextprotocol/sdk`, the official MCP library for Node.js |

**Three safety ideas to carry through the build**
- The AI's tool call is an **untrusted request** — check it against the rules, reject bad values, never
  "fix" them.
- **Delete is special:** the tool demands `confirm: true`, and its description tells the AI to ask you
  first.
- The **key never appears** in code, in a tool result, in an error message, or in the chat.

**Checkpoint ✅** You can name the five tools and say which one needs a confirmation, and why.

---

## Topic 8 — Plan the MCP server with the AI

**Prerequisite:** Topics 6 and 7.

**Goal:** the same interview as Day 1 — this time choosing **MCP** at Question 1.

**Step 1 — make the workspace:**

```powershell
cd C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion
New-Item -ItemType Directory workspace\mcp-server | Out-Null
Copy-Item framework\START_PROMPT.md, framework\project_starter.json workspace\mcp-server
Copy-Item workspace\rest-api\API.md workspace\mcp-server        # yours - or reference\api\API.md
code workspace\mcp-server
```

**Step 2 — run the interview.** New Continue chat, Agent mode, paste `START_PROMPT.md`.

| # | Suggested answer for the MCP |
|---|---|
| 1 | **2** — Node.js MCP server |
| 2 | "Let an AI assistant list, find, add, change and delete students in plain English, through the murid API." |
| 3 | the endpoints in `API.md` |
| 4 | **1** — All CRUD |
| 5 | **1** — Yes (the server sends the key on every call) |
| 6 | "Reject values that break the rules in API.md before calling the API. Delete only after the user confirms. Show the API's error message in plain words. Never show the key." |

**Step 3 — check the scope summary before you type *approved*:**
- [ ] Node.js, the official MCP SDK (`@modelcontextprotocol/sdk`), **stdio** transport
- [ ] base URL and key come from environment variables **`API_BASE_URL`** and **`API_KEY`**
- [ ] 5 tools, each with a clear description and an input schema matching `API.md`
- [ ] `delete_murid` requires `confirm: true`
- [ ] nothing is written with `console.log` (it would break stdio) — `console.error` only
- [ ] errors come back as a readable tool error — never a crash, never the key

**Checkpoint ✅** `workspace\mcp-server` contains the approved `REQUIREMENTS.md` and `PHASES.md`.

---

## Topic 9 — First tool, end to end (MCP Inspector)

**Prerequisite:** Topic 8.

**Goal:** the Day 2 finish line — one AI-ready action reading real data from Oracle.

Build the phases up to the first tool (usually: project skeleton + `list_murid`), with the same loop
as Topic 4. To test a tool **without any AI app**, use the **MCP Inspector** — a web page that calls
your tools directly:

```powershell
cd C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion\workspace\mcp-server
npm install
npx @modelcontextprotocol/inspector -e "API_BASE_URL=<your API URL>" -e "API_KEY=$(Get-Content C:\course-secrets\api-key.txt)" node index.js
```

- `<your API URL>` is your API from Topic 4, or the reference:
  `http://localhost:8500/kpm-mcp-coldfusion/reference/api/murid.cfm`
- `index.js` is the server's main file — if the AI named it differently, use that name.

In the Inspector page: **Connect** → **Tools** → **List Tools** → `list_murid` → **Run Tool**. You see
the students from Oracle.

**Checkpoint ✅** `list_murid` returns the 6 students in the Inspector — **an AI-ready action, working
end to end.**

**Common problems**
- *Inspector says the server disconnected* → the server crashed on start. Run `node index.js` alone and
  paste the error to the AI.
- *`Cannot reach the app`* → `API_BASE_URL` is wrong, or ColdFusion is stopped.
- *`401`* → the key was not passed; check the `-e "API_KEY=…"` part.

---

## End-of-Day 2 — final working state

You should now have:
- `C:\course-secrets\api-key.txt` — your API key, outside the web folder.
- `workspace\rest-api\` — the app **plus your REST API**, every phase **Verified**, with
  `postman_collection.json` and **`API.md`**.
- Postman — your collection (all green) and the reference collection.
- `workspace\mcp-server\` — the approved MCP `REQUIREMENTS.md` + `PHASES.md`, and a Node.js project
  whose **`list_murid`** works in the MCP Inspector.

**Security recap**
- The key is **checked first** on every API request; missing or wrong → **401**, nothing else runs.
- Every SQL value is a **bind parameter**; bad input gets a **400** with a readable reason.
- Errors are short and safe — no SQL, no stack trace, no key.
- The MCP server gets its URL and key from **environment variables**, never from its code.

**Stretch goals (if time remains)**
- Ask the AI to add a filter to the list endpoint (for example `?kelas=Bestari`) as a new phase — with
  its own RUN TEST and a new Postman test.
- Build `get_murid` ahead of tomorrow and test it in the Inspector.
- Read `reference/mcp/index.js` — compare its tool descriptions with your AI's.

**Tomorrow (Day 3):** build the other four MCP tools, connect Claude Desktop, run the app in plain
English — then try to break it on purpose, and present a final project.
