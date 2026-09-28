# Day 2 — Build the REST API, then Pivot to MCP

> *Part of **MCP Development for Web Applications** — AI-driven development with ColdFusion, Oracle
> and Node.js (Day 2 of 3).*

**Morning:** the AI builds yesterday's plan, one phase at a time, and you test every phase. By lunch
the app has a **REST API** — a door for *programs*, protected by a key.

**Afternoon:** you learn what an **MCP server** is, plan one with the same framework, and get its
**first tool** working.

**Why an API first?** The web pages are a door for people. An AI needs a door for programs: fixed
URLs, JSON in and out, and a key. The MCP server only knocks on this door — it never touches the
database — so all the app's rules still apply.

**Today you will**
- make a secret API key
- let the AI build **your REST API** (list, get, add, change, delete students)
- test it in **Postman**
- write **`API.md`** — how the API works
- plan the **MCP server** with the AI
- get the first MCP tool, **`list_murid`**, working

**Not today:** writing code yourself, the other four MCP tools (Day 3), Claude Desktop (Day 3),
putting anything on a real server.

> **Need from Day 1:** `workspace\rest-api\` with the approved `REQUIREMENTS.md` and `PHASES.md`.
> Missing? Redo **Day 1 Topic 9** (about 20 minutes), or copy a neighbour's two files.

---

## Topic 1 — Get today's tools ready

### 1.1 — Make the API key

The API only answers requests that carry this key. It is kept **outside** the course folder, so it
is never in the code, in git, or seen by the AI.

**PowerShell** — paste all three lines:

```powershell
New-Item -ItemType Directory -Force C:\course-secrets | Out-Null
[guid]::NewGuid().ToString("N") | Set-Content -NoNewline C:\course-secrets\api-key.txt
Get-Content C:\course-secrets\api-key.txt
```

The last line prints your key (32 letters and numbers). You paste it into **Postman** today and
**Claude Desktop** on Day 3 — **never into the AI chat**.

### 1.2 — Install Postman (to test the API)

1. **Browser:** download from `https://www.postman.com/downloads/` (Windows 64-bit) and install.
2. Sign in with a free account (it saves your work), or use it without an account.

### 1.3 — Install Node.js (runs the MCP server this afternoon)

1. **Browser:** install the **LTS** version from `https://nodejs.org/`. Keep all defaults.
2. **PowerShell** — open a **new** one:

   ```powershell
   node -v
   ```

   You see `v20` or higher.

**Checkpoint ✅ (Topic 1 complete)**

| Check | You should see |
|---|---|
| **PowerShell:** `Get-Content C:\course-secrets\api-key.txt` | a 32-character key |
| **Browser:** `http://localhost:8500/kpm-mcp-coldfusion/reference/api/murid.cfm` | `{"error":"Missing or wrong API key."}` — **correct!** The browser sends no key |
| Postman | opens |
| **PowerShell:** `node -v` | `v20` or higher |

**Common problems**

| You see | Do this |
|---|---|
| `Server key is not configured` / 500 | The key file is missing or in another folder. Redo 1.1 |
| `node` is not recognised | Open a **new** PowerShell |

---

## Topic 2 — How a REST API works (concept)

You check the AI's API against these ideas, so learn the words first.

**Each action = a verb + a URL.** Our API is about **murid** (students):

| Verb | URL | Does | Success code |
|---|---|---|---|
| GET | `murid.cfm` | list all students | 200 |
| GET | `murid.cfm?id=3` | show student 3 | 200 |
| POST | `murid.cfm` | add a student | **201** |
| PUT | `murid.cfm?id=3` | change student 3 | 200 |
| DELETE | `murid.cfm?id=3` | delete student 3 | 200 |

**Status codes to know**

| Code | Means |
|---|---|
| **200** / **201** | OK / created |
| **400** | bad input — e.g. `tingkatan: 7` |
| **401** | missing or wrong key |
| **404** | not found |
| **500** | the server broke — details go to a log, never to the caller |

**Three rules**
- Every request sends the key in a header: `X-API-Key: <key>`. No key or wrong key → **401**, nothing
  else happens.
- Answers are **JSON**. Errors look like `{ "error": "text" }`.
- Bad input is **rejected, never quietly fixed**: `tingkatan: 7` is a 400, not "changed to 5".

**Checkpoint ✅** Which verb and code for "add a student"? (POST → 201.) For "wrong key"? (401.)

---

## Topic 3 — See a tiny API built by hand (trainer demo)

**Goal:** see what API code looks like, so you know what to check in the AI's code later.
**The trainer types — you watch.**

**Open:** `api-demo/pelajar.cfm` in VS Code, and
`http://localhost:8500/kpm-mcp-coldfusion/api-demo/pelajar.cfm` in the browser. The browser says
`"GET not implemented yet"`.

The file already has three helpers:
- `respond(body, status)` — sends JSON back, with a status code
- `readBody()` — reads the JSON the caller sent
- `rows(query)` — turns query results into a list

The trainer fills in the four `TODO`s. Each time: **replace the `respond({ "todo": … })` line under
the TODO** with the code below.

**TODO 1 — GET: list all, or one by id**

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

Save → **F5** in the browser → you see `{"data":[…]}` with 5 rows. Add `?id=1` to the URL → one row.

> **Why `AS "id"`?** Oracle returns column names in CAPITALS (`"ID"`). The alias keeps them lowercase.

**TODO 2 — POST: add a row.** Oracle gives out ids from a **sequence**: take the next number, insert
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

**TODO 3 — PUT: change a row**

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

**TODO 4 — DELETE: remove a row**

```cfml
if (!hasId) respond({ "error": "id required" }, 400);
queryExecute(
    "DELETE FROM pelajar WHERE id = :id",
    { id: { value: url.id, cfsqltype: "cf_sql_integer" } },
    { datasource: ds }
);
respond({ "deleted": true, "id": val(url.id) });
```

The browser can only send GET. The trainer tests TODO 2–4 in Postman. The finished file is
`api-demo/pelajar.reference.cfm`.

**Three things to check in the AI's API later**
1. **JSON** in and out.
2. **Every value is a bind parameter** (`:id`, `:name`) — the script version of `<cfqueryparam>`.
3. **A status code on every answer.**

This demo has **no key check and no input checks**. Yours will have both.

**Checkpoint ✅** `…/api-demo/pelajar.cfm` returns `{"data":[…]}`.

---

## Topic 4 — Build the REST API, one phase at a time

**Goal:** the AI builds `PHASES.md`. You prove each phase works before the next one starts.

**Start**
1. **PowerShell:**

   ```powershell
   code C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion\workspace\rest-api
   ```

2. Open Continue → **Agent** mode. Use **yesterday's chat** if you still have it. If not, start a new
   chat and paste:

   ```
   REQUIREMENTS.md and PHASES.md in this folder are approved. Read them, then build Phase 1 only.
   Stop after it and tell me exactly how to run its RUN TEST.
   ```

**Repeat for every phase**

| Step | You do |
|---|---|
| 1. Build | The AI edits files. Read each change it asks about, then accept it. |
| 2. Test | Run the phase's RUN TEST yourself — in the browser, Postman or DBeaver (**F5**). |
| 3a. Passed | Type: `RUN TEST passed: <what you saw>. Mark Phase 1 Verified in PHASES.md, then build Phase 2 only.` |
| 3b. Failed | Type: `RUN TEST failed. Expected <x>. Got <paste the answer or error>. Fix Phase 1 only.` |

**Rules**
- **One phase at a time.** If it builds two, type: `Stop. Only one phase at a time. Which phase is done?`
- **You run the test, not the AI.** "It should work" is not a test result.
- **Never paste the API key into the chat.** Paste answers and errors only.
- **Check the code** for the three things from Topic 3, and that the **key is checked first**.
- `.cfm` changes show after **F5**. A change to `Application.cfc` seems ignored? Ask the trainer to
  restart ColdFusion.

**Checkpoint ✅** Every phase in `PHASES.md` says **Verified**, and the web pages at
`…/workspace/rest-api/` still work.

**Common problems**

| You see | Do this |
|---|---|
| The AI says "done" but nothing changed | Type: `Which files did you change? Show me the diff.` |
| Every request gets 401 | The API reads the key from the wrong place, or the header is not named `X-API-Key` |
| A block of HTML stuck on the end of the JSON | Debug output is on. Turn it off: Day 1, Topic 1.2, step 5 |
| `Datasource cf_test_crud could not be found` | Type: `Application.cfc must set this.datasource = "cf_test_crud".` |

---

## Topic 5 — Test everything in Postman

**Goal:** run every test in one go — including a wrong key and bad input.

1. **Continue** — ask for a test file:

   ```
   Write a Postman collection (v2.1 JSON) to postman_collection.json that runs every acceptance check
   in REQUIREMENTS.md, in order. Use collection variables baseUrl and apiKey. Leave apiKey empty.
   ```

2. **Postman:** **Import** → choose `workspace\rest-api\postman_collection.json`.
3. **Add your key:** click the collection → **Variables** tab → `apiKey` → paste your key into
   **Current value** → **Save**. (Current values stay on your laptop. They are never shared.)
4. Check `baseUrl` points to **your** API.
5. Click the collection → **Run** → **Run**. Every test should be green.

**Compare with the reference tests.** Import `postman/Day2-murid-API.postman_collection.json` too, set
its `apiKey` the same way, and run it. It tests the reference API:

| # | Test | Expect |
|---|---|---|
| 1 | List all | **200** |
| 2 | List Form 4 only (`?tingkatan=4`) | **200**, every row is Form 4 |
| 3 | Get one (`?id=1`) | **200**, id 1 |
| 4 | Create | **201** |
| 5 | Update the new student | **200**, `kelas` changed |
| 6 | Delete the new student | **200**, `deleted: true` |
| 7 | Wrong key | **401** |
| 8 | Bad input (`tingkatan` 7, bad IC) | **400** |
| 9 | Not found (`?id=999999`) | **404** |

Did **your** collection test a wrong key and bad input? If not, type:
`Add Postman tests for a wrong key (401) and for bad input (400).`

**Checkpoint ✅** Your collection runs all green, including **401** for a wrong key and **400** for bad
input.

**Common problems**

| You see | Do this |
|---|---|
| A test fails | Good — that is what tests are for. Type: `This Postman test failed: <request and answer>. Fix the API, not the test.` |
| Everything is 401 | The `apiKey` **Current value** is empty. Fill it in and **Save** |

---

## Topic 6 — Write down how the API works (`API.md`)

**Goal:** the document the MCP server is built from this afternoon. If it is wrong, the MCP will be wrong.

1. **Continue** — type:

   ```
   Write API.md for a developer who will call this API from another program: base URL, the key header,
   every method and URL, body fields with their rules, example responses, and every error code.
   Do not include the key itself.
   ```

2. Compare it with `reference/api/API.md`. Tick each:
   - [ ] the base URL
   - [ ] the `X-API-Key` header
   - [ ] the five operations
   - [ ] every field, with its rule
   - [ ] the error codes (400, 401, 404)
   - [ ] **no key** written in it

**Milestone — end of the morning**
- [ ] every phase in `PHASES.md` is **Verified**
- [ ] Postman is all green, including **401** and **400**
- [ ] `API.md` is correct, with no key in it
- [ ] the web pages still work

> **Not finished by lunch?** No problem. This afternoon, use the **reference API** instead:
> `http://localhost:8500/kpm-mcp-coldfusion/reference/api/murid.cfm` and `reference/api/API.md`.

**Checkpoint ✅** `workspace\rest-api\API.md` exists and matches what your API really does.

---

## Topic 7 — How an MCP server works (concept)

Full version: [mcp-theory.md](mcp-theory.md), parts 4–7.

An **MCP server** is a small program that tells an AI app: *"here are the actions you may take, and
exactly what each one needs."* The AI decides **when** to use an action. Your code decides **what is
allowed**.

```
 You (plain English)
      |
 Claude Desktop            the AI app. It starts your server and talks to it directly
      |
 Your MCP server (Node.js)  list_murid  get_murid  create_murid  update_murid  delete_murid
      |   HTTP + X-API-Key
 Your REST API (ColdFusion)  --->  Oracle
```

| Word | Means |
|---|---|
| **Tool** | one action the AI may use, e.g. `create_murid` |
| **Description** | the sentence the AI reads to decide *when* to use the tool |
| **Input schema** | the exact fields and rules a tool accepts. Anything else is rejected |
| **stdio** | how the AI app talks to your server — no port, no URL |
| **Environment variables** | how the server gets the API URL and key — from the AI app's settings, never from the code |

**Three safety rules for the build**
- Treat every tool call from the AI as **untrusted**. Reject bad values; never "fix" them.
- **Delete needs `confirm: true`**, and its description tells the AI to ask you first.
- The **key never appears** in code, in an answer, in an error, or in the chat.

**Checkpoint ✅** Name the five tools. Which one needs a confirmation, and why?

---

## Topic 8 — Plan the MCP server with the AI

**Goal:** the same interview as Day 1 — this time you pick **MCP** at Question 1.

**Step 1 — make the workspace.** **PowerShell** — paste all five lines:

```powershell
cd C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion
New-Item -ItemType Directory -Force workspace\mcp-server | Out-Null
Copy-Item framework\START_PROMPT.md, framework\project_starter.json workspace\mcp-server
Copy-Item workspace\rest-api\API.md workspace\mcp-server
code workspace\mcp-server
```

> Using the reference API? Replace line 4 with: `Copy-Item reference\api\API.md workspace\mcp-server`

**Step 2 — run the interview.** New Continue chat → **Agent** → paste all of `START_PROMPT.md` → send.

| # | You answer |
|---|---|
| 1 | **2** — Node.js MCP server |
| 2 | "Let an AI assistant list, find, add, change and delete students in plain English, through the murid API." |
| 3 | the endpoints in `API.md` |
| 4 | **1** — All CRUD |
| 5 | **1** — Yes (the server sends the key on every call) |
| 6 | "Reject values that break the rules in API.md before calling the API. Delete only after the user confirms. Show the API's error message in plain words. Never show the key." |

**Step 3 — check the summary before you type *approved*:**
- [ ] Node.js, the official MCP SDK (`@modelcontextprotocol/sdk`), **stdio**
- [ ] the URL and key come from environment variables **`API_BASE_URL`** and **`API_KEY`**
- [ ] 5 tools, each with a clear description and fields that match `API.md`
- [ ] `delete_murid` requires `confirm: true`
- [ ] uses `console.error` only — never `console.log` (it breaks stdio)
- [ ] errors come back as a readable message — never a crash, never the key

**Checkpoint ✅** `workspace\mcp-server` has the approved `REQUIREMENTS.md` and `PHASES.md`.

---

## Topic 9 — First tool, end to end

**Goal:** one AI-ready action, reading real students from Oracle.

1. **Continue:** build the phases up to the first tool (usually: the project skeleton, then
   `list_murid`). Use the same loop as Topic 4.
2. **PowerShell** — test it with the **MCP Inspector**, a web page that runs your tools without any AI.
   Paste the lines one by one:

   ```powershell
   cd C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion\workspace\mcp-server
   npm install
   ```

   ```powershell
   $key = Get-Content C:\course-secrets\api-key.txt
   $url = "http://localhost:8500/kpm-mcp-coldfusion/reference/api/murid.cfm"
   ```

   Using **your own** API? Put its URL in `$url` instead.

   ```powershell
   npx @modelcontextprotocol/inspector -e "API_BASE_URL=$url" -e "API_KEY=$key" node index.js
   ```

   (If the AI named the main file something other than `index.js`, use that name.)
3. The Inspector opens in the browser (if not, open the link it prints). Click **Connect** →
   **Tools** → **List Tools** → **`list_murid`** → **Run Tool**.
4. You see the **6 students** from Oracle.

**Checkpoint ✅** `list_murid` returns the 6 students in the Inspector.

**Common problems**

| You see | Do this |
|---|---|
| Inspector says the server disconnected | The server crashed. Run `node index.js` alone and paste the error to the AI |
| `Cannot reach the app` | `$url` is wrong, or ColdFusion is stopped |
| `401` | The key was not passed. Run the `$key = …` line again, then the `npx` line |

---

## End of Day 2 — what you should have

- `C:\course-secrets\api-key.txt` — your API key, outside the course folder.
- `workspace\rest-api\` — the app **plus your REST API**, every phase **Verified**, with
  `postman_collection.json` and `API.md`.
- Postman — your tests (all green) and the reference tests.
- `workspace\mcp-server\` — the approved MCP plan, and **`list_murid`** working in the Inspector.

**Security recap**
- The API checks the key **first**. Missing or wrong → **401**, nothing else runs.
- Every SQL value is a **bind parameter**. Bad input → **400** with a readable reason.
- Errors are short — no SQL, no stack trace, no key.
- The MCP server gets its URL and key from **environment variables**, never from its code.

**Extra, if you finish early**
- Ask the AI to add a filter (e.g. `?kelas=Bestari`) as a new phase, with its own RUN TEST and Postman test.
- Build `get_murid` ahead of tomorrow.
- Compare your tool descriptions with `reference/mcp/index.js`.

**Tomorrow (Day 3):** the other four MCP tools, Claude Desktop, running the app in plain English —
then breaking it on purpose, and a final project.
