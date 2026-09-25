# Day 1 — Foundations: ColdFusion, the Existing App & Planning with AI

> *Part of **MCP Development for Web Applications** — AI-driven development with ColdFusion, Oracle
> and Node.js (Day 1 of 3).*

**Use case for the whole course:** a school's **student records** app. It already exists — a
ColdFusion web app over an Oracle table of students (`murid`). Over three days you give it a
**REST API** (Representational State Transfer Application Programming Interface) and then an
**MCP server** (Model Context Protocol), so an AI (Artificial Intelligence) assistant can run the
app in plain English: *"Who is in Form 4?"*, *"Add a new student…"*.

**The one rule of this course:** you own the **specification** and the **environment**; the AI owns
the **code**, and the code is checked against your specification. You never have to write code —
but you always decide what "done" means, and you always run the test.

**Stack:** Adobe ColdFusion 2021 (Developer Edition), Oracle Database 21c Express Edition (XE),
DBeaver, Visual Studio Code (VS Code) with the Continue AI extension, Ollama Cloud (Gemma 4) and
Token Harbor as AI providers.

**New to ColdFusion? A 2-minute primer.** ColdFusion is an application server: it runs web pages
written in **CFML** (ColdFusion Markup Language). A `.cfm` file is an ordinary HTML page with extra
tags that start with `cf` — the server runs those tags and sends plain HTML to the browser.

- **`.cfm`** — a page. HTML plus CFML tags like `<cfquery>` and `<cfoutput>`.
- **`.cfc`** — a component (a class). `Application.cfc` is special: its settings apply to every page
  in its folder.
- **Datasource** — a named database connection, set up once in the **ColdFusion Administrator**, so
  pages say `datasource="cf_test_crud"` and never contain the database password.

**The request lifecycle in one line:** the browser asks for a `.cfm` page → ColdFusion runs its
`cf` tags (for example a `<cfquery>` against Oracle through the datasource) → it sends back HTML
(or, for an API, JSON — JavaScript Object Notation).

**The folders you'll actually touch today:**

| Folder / file | What lives there |
|---|---|
| `basics/` | three plain CFML lesson pages (no styling) |
| `crud/` | the existing student-records app (CRUD — Create, Read, Update, Delete) |
| `db/` | `create_user.sql` + `schema.sql` — the database user, the tables and the sample rows |
| `framework/` | `START_PROMPT.md` + `project_starter.json` — the AI framework |
| `config/` | ready-made settings for Continue and Claude Desktop |
| `workspace/` | **your own work** — created today, ignored by git |

**What you build today**
- A working local stack: **Oracle XE**, **ColdFusion 2021**, the course repo, the datasource, **DBeaver**
- A first feel for **CFML**: variables, logic, and reading a table
- The **existing app** running — and understood page by page
- An **AI assistant** in VS Code (Continue + Ollama Cloud + Token Harbor)
- **Your REST API plan**, written by the AI after interviewing you: `REQUIREMENTS.md` + `PHASES.md`

**What is NOT in scope today:** writing any code yourself, building the API (Day 2 morning), MCP
(Day 2 afternoon onward), Postman and Node.js (installed on Day 2), Claude Desktop (Day 3).

**How this day builds (each topic is a prerequisite for the next — easy first):**
1. Install and verify the tools → 2. What MCP is and how this course works (concept) →
3. ColdFusion basics: syntax and logic → 4. Read the database with ColdFusion → 5. Tour the `murid`
table in DBeaver → 6. Run and understand the CRUD app → 7. Set up the AI assistant → 8. The AI
framework (concept) → 9. **Plan your REST API with the AI.**

> We build **bottom-up**: the database and server first, then the language, then the app, then the
> AI. Nothing is "magic" later because you have seen each layer working on its own.

> **Do Topic 1 before the course.** The downloads are big (Oracle 2 GB, ColdFusion 1.2 GB) and the
> Oracle install alone takes 15–30 minutes. Day 1 starts by checking Topic 1's checkpoint together.

---

## Topic 1 — Install and verify your tools

You need a Windows 10/11 64-bit laptop with **admin rights**, **8 GB RAM minimum** (16 GB is
comfortable) and **20 GB free disk**, and no other Oracle database installed. Do the steps in order.

### 1.1 — Install Oracle Database 21c Express Edition (XE)

Oracle XE is Oracle's free database edition. It comes from Oracle's own server; no Oracle account
is needed.

1. Download (2 GB): **`https://download.oracle.com/otn-pub/otn_software/db-express/OracleXE213_Win64.zip`**
   (official page: `https://www.oracle.com/database/technologies/xe-downloads.html`).
2. Unzip it. Right-click `setup.exe` → **Run as administrator**. At each screen:

   | Screen | Choose |
   |---|---|
   | License | Accept |
   | Destination folder | **`C:\oraclexe\`** — type it in (the default breaks if your Windows user name has a space) |
   | Database passwords (SYS, SYSTEM, PDBADMIN) | Pick one, **letters and numbers only**, write it down — you need it once, in 1.4 |
   | Summary | Install |

3. Wait **15–30 minutes**. The last screen shows the connection `localhost:1521/XEPDB1`. Click
   **Finish**.

Oracle now runs as Windows services and **starts by itself** with Windows. `XEPDB1` is the name of
the database you will use (a *pluggable database*, PDB, inside Oracle).

### 1.2 — Install Adobe ColdFusion 2021

1. Download the installer (1.2 GB, from Adobe's own server — ColdFusion 2021 Update 5):
   **`https://cfdownload.adobe.com/pub/adobe/coldfusion/2021/cfinstaller/cf2021u5/ColdFusion_2021_GUI_WWEJ_win64.exe`**
2. Run it **as administrator**. At each screen:

   | Screen | Choose |
   |---|---|
   | Serial number | **Leave blank — Developer Edition** (free, localhost only) |
   | Installer configuration | **Server configuration** |
   | Packages / sub-components | Keep the defaults **and tick `Oracle`** (the database driver) |
   | Install folder | `C:\ColdFusion2021` (default) |
   | Web server | **Built-in web server** (port 8500) |
   | Admin password | Pick one and write it down |
   | RDS | Off |
   | Secure profile | Off (this is a local training machine) |

3. Open **`http://localhost:8500/CFIDE/administrator/`** and log in with the admin password.

> **Forgot to tick Oracle?** In an **administrator** PowerShell run
> `C:\ColdFusion2021\cfusion\bin\cfpm.bat install oracle`, then restart the Windows service
> **"ColdFusion 2021 Application Server"**.

### 1.3 — Install Git and get the course repo

1. Install Git from **`https://git-scm.com/download/win`** (all defaults).
2. Let your own account write into ColdFusion's web folder — **administrator** PowerShell, once:

   ```powershell
   icacls C:\ColdFusion2021\cfusion\wwwroot /grant "${env:USERNAME}:(OI)(CI)M"
   ```

3. Clone the course into that folder — **normal** PowerShell:

   ```powershell
   git clone https://github.com/luqmanyusof/kpm-mcp-coldfusion.git C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion
   ```

The folder **must** be called `kpm-mcp-coldfusion` — every link in these notes uses that name.
From now on, **"the course folder"** means `C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion`.

### 1.4 — Create the course user and load the tables

Open a **new** PowerShell window (so it finds `sqlplus`, which came with Oracle):

```powershell
cd C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion\db
sqlplus 'sys@//localhost:1521/XEPDB1' as sysdba '@create_user.sql'
```

It asks for a password — type the one you chose in 1.1 (nothing shows while you type). Expected:
`user cfapp ready`. Now load the tables and sample rows:

```powershell
sqlplus -s 'cfapp/cfapp123@//localhost:1521/XEPDB1' '@schema.sql'
```

Expected last lines: `pelajar rows: 5` and `murid rows: 6`.

> **Reset any time.** That second command drops and reloads both tables — run it whenever the data
> gets messy during the course.

### 1.5 — Install DBeaver (see inside the database)

DBeaver shows tables and rows in a window. You use it all course to check what the app — and later
the AI — **really** changed.

1. Download **DBeaver Community** (free): **`https://dbeaver.io/files/dbeaver-ce-latest-windows-x86_64.exe`**
   (from `https://dbeaver.io/download/`). Install with the defaults.
2. **Database → New Database Connection → Oracle → Next.** On the **Main** tab:

   | Field | Value |
   |---|---|
   | Host | `localhost` |
   | Port | `1521` |
   | Database | `XEPDB1`, and choose **Service Name** (not SID) |
   | Authentication | Oracle Database Native |
   | Username / Password | `cfapp` / `cfapp123` — tick **Save password** |

3. **Test Connection.** The first time, DBeaver offers to **download the Oracle driver** — click
   **Download**. You should see **Connected**. Click **Finish**.

### 1.6 — Create the datasource (ColdFusion → Oracle)

The pages ask for a datasource called `cf_test_crud`. In the Administrator:

1. **Data & Services → Data Sources.**
2. Data Source Name `cf_test_crud` — Driver **Oracle** — **Add**.
3. Fill in:

   | Field | Value |
   |---|---|
   | SID Name / Service Name | `XEPDB1` (pick "Service Name" if there is a choice) |
   | Server | `localhost` |
   | Port | `1521` |
   | User name / Password | `cfapp` / `cfapp123` |

4. **Submit.** The list shows `cf_test_crud` with status **OK**.

> **Error mentioning SID or listener?** `XEPDB1` is a *service name*, not a SID. Edit the datasource,
> clear the SID field, open **Show Advanced Settings**, put `ServiceName=XEPDB1` in **Connection
> String**, and submit again.

### 1.7 — Install VS Code (code editor)

1. Download from **`https://code.visualstudio.com/`** and install (tick **"Open with Code"** on the
   "Select Additional Tasks" screen).
2. Open the course folder: **File → Open Folder…** → the course folder.

**Checkpoint ✅ (Topic 1 complete)**
- PowerShell `Get-Service Oracle*` shows `OracleServiceXE` and the `…TNSListener` service **Running**.
- DBeaver: **CFAPP → Tables → MURID → Data** shows **6 students**.
- `http://localhost:8500/kpm-mcp-coldfusion/basics/03-database.cfm` shows a table of **5** `pelajar` rows.
- `http://localhost:8500/kpm-mcp-coldfusion/crud/` shows the list of **6** students.

**Common problems**
- *Oracle installer fails or stops half way* → uninstall it (Apps → Oracle Database 21c Express
  Edition), restart, and install again to `C:\oraclexe\` as administrator.
- *`sqlplus` is not recognised* → open a **new** PowerShell. Still missing: use
  `C:\oraclexe\dbhomeXE\bin\sqlplus.exe`.
- *`ORA-12541: no listener`* → Windows **Services** → start the `Oracle…TNSListener` service.
- *`ORA-12514: listener does not currently know of service`* → Oracle is still starting; wait 2
  minutes. Still failing: restart `OracleServiceXE`.
- *`ORA-01017: invalid username/password`* → the first 1.4 command needs the SYS password from 1.1;
  everything else is `cfapp` / `cfapp123`.
- *`ORA-00942: table or view does not exist`* → the second 1.4 command was skipped.
- *DBeaver cannot download the Oracle driver* → a company proxy blocks it; ask the trainer for the
  USB copy.
- *`Datasource cf_test_crud could not be found`* → 1.6 not done, or the name is spelled differently.
- *`localhost:8500` does not open* → Windows **Services** → start **ColdFusion 2021 Application Server**.
- *`404` on a course page* → the folder is not called `kpm-mcp-coldfusion`, or not inside `wwwroot`.
- *`git clone` or saving in VS Code says "Access denied"* → the `icacls` step in 1.3 was skipped.

---

## Topic 2 — What MCP is, and how this course works (concept)

**Prerequisite:** none — read this while the class finishes Topic 1.

**Goal:** know *why* we are building each piece before building it.

**Web apps are built for people.** You log in, click, fill forms. Nothing happens unless someone is
there doing it. An **MCP server** gives an AI assistant its own entrance — a **"staff entrance"**
next to the front door for humans. The AI can then operate the app on request, in plain English,
while the app still holds the data and enforces the rules.

**The pieces you will have by Day 3:**

```
 You, in plain English
        |
 Claude Desktop ---- MCP (stdio) ----> MCP server (Node.js)          <- Day 2 PM - Day 3, built by the AI
                                             |  HTTP + X-API-Key
                                             v
 Web pages (crud/) --------------------> REST API (ColdFusion)       <- Day 2 AM, built by the AI
        |                                    |
        +----------------> Oracle XE (murid table) <-----------------+   <- today
```

**Who does what**

| You (the human) | The AI (Continue + Gemma 4) |
|---|---|
| install and run the environment | reads the existing code |
| answer the interview, approve the plan | writes `REQUIREMENTS.md` and `PHASES.md` |
| run every test and report what you saw | writes and fixes the code, one phase at a time |
| decide when something is "done" | never marks its own work as tested |

**Checkpoint ✅** You can explain, in one sentence each: what an MCP server is for, and why the AI
does not get to decide when a phase is finished.

---

## Topic 3 — ColdFusion basics: syntax and logic

**Prerequisite:** Topic 1 (the `basics/` pages load).

**Goal:** read CFML well enough to follow what the AI writes later. Trainer demo — you follow along
in the browser (`http://localhost:8500/kpm-mcp-coldfusion/basics/`) and in VS Code (`basics/`).

**How CFML works.** A `.cfm` file is an HTML file. The server runs any tag starting with `cf` and
sends plain HTML to the browser. You freely mix CFML and HTML in the same file.

### 3.1 — Variables and output (`01-syntax.cfm`)

- `<cfset x = ...>` creates a variable (shows nothing).
- `<cfoutput> … </cfoutput>` prints, and text between `#hashes#` inside it is read as a variable.
- Outside `<cfoutput>`, a `#` is just a normal character.

```cfml
<cfset name = "Ahmad Danish">
<cfoutput>Name: #name#, uppercase: #ucase(name)#</cfoutput>
```

> The most common beginner mistake is forgetting `<cfoutput>` — then `#name#` prints literally.

### 3.2 — Logic, loops and data (`02-logic.cfm`)

- `<cfif> / <cfelseif> / <cfelse>` with word operators: `EQ NEQ GT LT GTE LTE`.
- `<cfloop index="i" from="1" to="5">` repeats.
- Arrays `["a","b"]` (they **start at index 1**) and structs `{ key = "value" }`.

A struct is a set of key/value pairs — the same shape as **one database row**, which leads into the
next topic.

**Try it:** change a value in `01-syntax.cfm`, save, refresh the browser. `.cfm` changes show on the
next refresh — no restart needed.

**Checkpoint ✅** You changed a variable in `01-syntax.cfm` and saw the new value in the browser.

---

## Topic 4 — Read the database with ColdFusion

**Prerequisite:** Topic 3, and the datasource from 1.6.

**Goal:** see how a page reads Oracle — the pattern every page in the app (and the API) uses.
Open `basics/03-database.cfm` in the browser and in VS Code.

- The **datasource** `cf_test_crud` is defined once in the ColdFusion Administrator (1.6), so every
  page can use it **without knowing the password**.
- `<cfquery name="pelajar" datasource="cf_test_crud"> SELECT … </cfquery>` runs SQL (Structured
  Query Language) and stores the result in `pelajar`.
- `<cfoutput query="pelajar"> … </cfoutput>` repeats its body once per row; `pelajar.recordCount`
  is the row count.

```cfml
<cfquery name="pelajar" datasource="cf_test_crud">
    SELECT id, name, email FROM pelajar ORDER BY name
</cfquery>

<cfoutput query="pelajar">#pelajar.name# - #pelajar.email#<br></cfoutput>
```

**The one safety rule.** When a query uses a value from the user (like `url.id`), never paste it
into the SQL. Wrap it in `<cfqueryparam>` so it cannot be abused (**SQL injection**):

```cfml
WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
```

> This rule comes back on Day 2 as a line in the AI's security principles — and you will check the
> AI's code for it.

**Checkpoint ✅** You can point to the datasource name, the `<cfquery>`, and the `<cfqueryparam>` in
`03-database.cfm`.

---

## Topic 5 — Tour the `murid` table in DBeaver

**Prerequisite:** DBeaver connected (1.5).

**Goal:** know the data the whole course is about, and the rules the database already enforces.

In DBeaver open **CFAPP → Tables → MURID**. The **Properties → Columns** tab shows the structure;
the **Data** tab shows the 6 students.

| Column | Type | Rule | Meaning |
|---|---|---|---|
| `id` | `NUMBER(10)` | primary key, from sequence `murid_seq` | set by the database |
| `nama` | `VARCHAR2(100)` | required | full name |
| `no_kp` | `VARCHAR2(14)` | required, **unique** | IC (identity card) number, e.g. `090312-10-5217` |
| `jantina` | `VARCHAR2(10)` | `Lelaki` or `Perempuan` | gender |
| `tingkatan` | `NUMBER(1)` | 1–5 | form (school year) |
| `kelas` | `VARCHAR2(30)` | required | class name |
| `tarikh_lahir` | `DATE` | required | date of birth |
| `bangsa` | `VARCHAR2(10)` | `Melayu`, `Cina`, `India`, `Lain-lain`; default `Melayu` | ethnicity |
| `agama` | `VARCHAR2(30)` | required | religion |
| `pendapatan_isi_rumah` | `NUMBER(10,2)` | default 0 | household income, RM (Malaysian ringgit) per month |
| `bilangan_adik_beradik` | `NUMBER(3)` | default 0 | number of siblings |
| `created_at` / `updated_at` | `TIMESTAMP` | set automatically (a trigger keeps `updated_at` current) | audit times |

The small `pelajar` table (`id`, `name`, `email`) is only for the lessons and the Day 2 demo.

> **Oracle vs MySQL, if you know MySQL:** no `AUTO_INCREMENT` — ids come from a **sequence**; no
> `ENUM` — allowed values are a **CHECK constraint**; column names come back in CAPITALS.

**Tip:** DBeaver does not refresh by itself — click the table and press **F5**. Use DBeaver to
**look**, not to edit: if you change rows by hand during a test, you cannot tell what the AI did.

**Checkpoint ✅** You can name three rules the database enforces on `murid` (for example: unique
`no_kp`, `tingkatan` 1–5, `jantina` only two values).

---

## Topic 6 — Run and understand the CRUD app

**Prerequisite:** Topics 4 and 5.

**Goal:** use the existing app like a user, then see how each page works. This is the "existing
app" the rest of the course connects an AI to — **nothing here is written by you**.

Open **`http://localhost:8500/kpm-mcp-coldfusion/crud/`** (the home page redirects to the list).
Add a student, open them, edit them, delete them — and after each step press **F5** in DBeaver.

**How it runs**
1. **The datasource** — `crud/Application.cfc` makes `cf_test_crud` this app's default.
2. **The shared layout** — `includes/_header.cfm` and `_footer.cfm` hold the page top (Bootstrap +
   navigation) and bottom; each page pulls them in with `<cfinclude template="includes/_header.cfm">`.

**The five pages**

| Page | Does | Worth noticing |
|---|---|---|
| `list.cfm` | Read all | one `SELECT`, looped into a table; a green banner from `url.msg` after a change |
| `view.cfm` | Read one | `<cfparam name="url.id" default="0">`; the id is guarded with `<cfqueryparam>`; "not found" + `<cfabort>` |
| `create.cfm` | Create | acts only on `POST`; validates into an `errors` array; `INSERT` with every value in `<cfqueryparam>`; then **Post/Redirect/Get** (`<cflocation url="list.cfm?msg=created">`) |
| `_form_fields.cfm` | the shared form | used by both create and edit; every value printed with `encodeForHTMLAttribute()` |
| `edit.cfm` | Update | `GET` pre-fills the form from the row; `POST` validates and runs `UPDATE … WHERE id = <cfqueryparam …>` |
| `delete.cfm` | Delete | `GET` shows what will be deleted; the delete itself is a **POST** button, never a link |

**The ideas worth remembering**
- **`cgi.request_method`** tells GET from POST — one page both shows a form and handles it.
- **`<cfqueryparam>`** on every user value stops SQL injection — non-negotiable.
- **Post/Redirect/Get** (`<cflocation>` after a write) stops double submits.
- **`encodeForHTML()` / `encodeForHTMLAttribute()`** when printing user data stops broken pages and
  XSS (cross-site scripting).
- **Delete needs a confirmation step.** The MCP you build keeps this idea for the AI.

**Checkpoint ✅** You added, edited and deleted a student in the app, and saw each change in DBeaver.

---

## Topic 7 — Set up the AI assistant (Continue + Ollama Cloud + Token Harbor)

**Prerequisite:** VS Code (1.7).

**Goal:** get an AI assistant inside VS Code that can read and edit the course files. **Continue**
is the VS Code extension; it talks to two AI providers:

| Provider | Models | Cost | Key needed in Continue? |
|---|---|---|---|
| **Ollama Cloud** (main) | Gemma 4, gpt-oss | free account, with usage limits | no — the Ollama app signs you in |
| **Token Harbor** (backup) | GPT, Claude, Gemini, DeepSeek, Qwen… | pay per use; the account is free | yes — one `thk_live_…` key |

### 7.1 — Ollama account and app

1. Go to **`https://ollama.com`** → **Sign up** (work email or Google), confirm the email.
2. Install the app from **`https://ollama.com/download`**.
3. In a **new** PowerShell window run `ollama signin`. The browser opens — log in and click
   **Connect** to link this laptop to your account.
4. Test the cloud model (it runs on Ollama's servers, not your laptop):

   ```powershell
   ollama run gemma4:31b-cloud "Say hello in five words"
   ```

A short reply = done. Your usage is at `https://ollama.com/settings` — the free plan has hourly and
weekly limits.

### 7.2 — Token Harbor account and API key

1. Go to **`https://tokenharbor.ai`** → **Sign up**. Free, no card; the wallet starts at $0.
   **Top up only if your trainer says so** — the course runs on Ollama.
2. Dashboard → **API keys**. Copy the **Universal Key** (`thk_live_…`) **straight away** — it is shown
   only once.
3. Store it where Continue can read it, but the AI and git cannot — Continue's own `.env` file:

   ```powershell
   New-Item -ItemType Directory -Force $HOME\.continue | Out-Null
   Add-Content $HOME\.continue\.env "TOKEN_HARBOR_API_KEY=paste-your-thk_live-key-here"
   notepad $HOME\.continue\.env      # check it: one line, no spaces around =
   ```

> **Never** put this key in the course folder, in a chat message, or in a screenshot — it spends real
> money. If it leaks: dashboard → API keys → delete it, make a new one.

### 7.3 — Continue

1. VS Code → **Extensions** (Ctrl+Shift+X) → search **Continue** → **Install**.
2. Give Continue the course models:

   ```powershell
   Copy-Item C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion\config\continue-config.yaml $HOME\.continue\config.yaml
   ```

   The config refers to the key as `${{ secrets.TOKEN_HARBOR_API_KEY }}` — Continue fills it in from
   the `.env` file, so the key is never written in the config.
3. **Ctrl+Shift+P → Reload Window.** Open the Continue panel (its icon on the left bar), set the mode
   to **Agent**, and type `hello` once with **Gemma 4 31B (Ollama Cloud)** and once with **Token
   Harbor (backup)**.

**Checkpoint ✅** Both models reply to `hello` in Agent mode.

**Common problems**
- *`ollama` is not recognised* → close and reopen PowerShell after installing Ollama.
- *No Gemma / Token Harbor model in Continue* → the config was not copied (7.3 step 2); Reload Window.
- *Gemma: `unauthorized` or no reply* → run `ollama signin` again; check usage limits.
- *Token Harbor `401` / `invalid api key`* → fix the `.env` line (`TOKEN_HARBOR_API_KEY=…`, no quotes
  or spaces), Reload Window.
- *Token Harbor `402` / `insufficient balance`* → that model needs credit; ask the trainer.
- *Token Harbor `model not found`* → copy the exact model ID from `https://tokenharbor.ai/models`
  into `config.yaml`.

---

## Topic 8 — The AI framework (concept)

**Prerequisite:** Topic 7 (the AI replies), Topic 6 (you know the app).

**Goal:** understand the two files that make the AI **plan before it builds** — so it builds the
project instead of just describing it.

| File (in `framework/`) | What it is |
|---|---|
| `START_PROMPT.md` | The short message you paste into Continue to begin. |
| `project_starter.json` | The AI's **operating instructions**: the 6 interview questions, the rules, the security principles, and the format of the plan it must write. You do not edit it. |

The same two files are used **twice** — for the **REST API** (today) and for the **MCP server**
(Day 2 afternoon). Question 1 of the interview is where you choose.

**How the framework works**

```
 you paste START_PROMPT.md
          |
          v
 AI reads the project quietly  --->  asks 6 questions, ONE at a time  --->  you answer
          |
          v
 AI shows a scope summary + acceptance checks  --->  you correct it  --->  you type "approved"
          |
          v
 AI writes REQUIREMENTS.md (what)  +  PHASES.md (how, in small steps)
          |
          v
 Day 2: one phase at a time  --->  RUN TEST  --->  you mark it Verified  --->  next phase
```

**The 6 questions (prepare your answers)**

| # | Question | Type | Suggested answer for the REST API |
|---|---|---|---|
| 1 | What are we building in this project? | pick | **1** — REST API endpoint |
| 2 | In one sentence, what should it do and what problem does that solve? | type | "Let other programs — and later an AI — read and manage student records without using the web pages." |
| 3 | Which of these should this project work with? | type | the `murid` table (the AI lists what it found in the code) |
| 4 | Which operations should it expose? | pick | **1** — All CRUD |
| 5 | Should access require a secret key, such as an X-API-Key header? | pick | **1** — Yes |
| 6 | What must be rejected as invalid, and what should happen when something goes wrong? | type | "Reject missing required fields, a wrong IC format, tingkatan outside 1–5, and unknown fields. On any error return a short message — never SQL or a stack trace." |

Your own words are fine. Short and specific beats long.

**Checkpoint ✅** You can say what `REQUIREMENTS.md` and `PHASES.md` are, and who approves them.

---

## Topic 9 — Plan your REST API with the AI

**Prerequisite:** Topic 8.

**Goal:** let the AI interview you and write the plan for the REST API. **No code today.**

**Step 1 — make your workspace** (a copy of the CRUD app with the framework dropped in):

```powershell
cd C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion
Copy-Item crud workspace\rest-api -Recurse
Copy-Item framework\START_PROMPT.md, framework\project_starter.json workspace\rest-api
code workspace\rest-api
```

Check the copy runs: `http://localhost:8500/kpm-mcp-coldfusion/workspace/rest-api/`.

**Step 2 — start the interview.** In the new VS Code window open Continue, pick **Gemma 4 31B**,
mode **Agent**. Open `START_PROMPT.md`, copy all of it, paste it into Continue, send.

**Step 3 — answer the 6 questions**, one at a time. Expect `Question 3 of 6: …` followed by a
`Hint:` line.

**Step 4 — check the scope summary before you approve:**
- [ ] only the `murid` table, and the operations you picked
- [ ] every request needs the `X-API-Key` header; a wrong or missing key gets **401**
- [ ] the key is read from **`C:\course-secrets\api-key.txt`** — if it says anything else, type:
      *"The key must be read from the file C:\course-secrets\api-key.txt, never written in code."*
- [ ] SQL uses bind parameters only (the `<cfqueryparam>` rule from Topic 4)
- [ ] acceptance checks: one per operation, one rejected input, one wrong key

Fix anything wrong in plain words, then type **approved**.

**Step 5 — read the two files it writes.** `REQUIREMENTS.md` is *what* you agreed. `PHASES.md` is the
build plan: every phase ends in a **RUN TEST** with an expected result. A phase with no test you can
run? Ask the AI to merge it with the next one. **Do not let it start coding yet.**

**When the AI misbehaves** (it will — correcting it is part of the skill)

| It… | You type |
|---|---|
| asks several questions at once, or answers for you | `Stop. You answered for me. Ask Question 3 again and wait for my answer.` |
| asks a question that is not one of the 6 | `That question is not in the interview array. Ask Question 4 from project_starter.json, word for word.` |
| asks which database or which fields | `Do not ask me that - read it from the code, as the defaults say.` |
| starts writing code or files before you approved | `Undo that. No code or files until I type approved.` |
| uses emojis, tables or strange symbols | `Plain text only, as message_format in the starter says.` |
| goes round in circles or forgets the rules | start a **new chat** and paste `START_PROMPT.md` again |
| is slow or keeps failing | switch to **gpt-oss 120B**, or to **Token Harbor (backup)**, and start a new chat |

> **Why this matters:** in real projects the AI makes the same mistakes. The framework does not make
> it perfect — it makes its mistakes *visible and easy to correct*.

**Checkpoint ✅** `workspace\rest-api` contains `REQUIREMENTS.md` and `PHASES.md`, and you agree with
both.

---

## End-of-Day 1 — final working state

You should now have:
- **Oracle XE** running as a Windows service, with the `cfapp` user and the `murid` + `pelajar` tables.
- **ColdFusion 2021** at `http://localhost:8500`, with the `cf_test_crud` datasource **OK**.
- **DBeaver** connected to `XEPDB1` as `cfapp`.
- The course repo in `C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion`, with `basics/` and
  `crud/` working in the browser.
- **Continue** in VS Code, answering from **Gemma 4** and **Token Harbor**.
- `workspace\rest-api\` — a copy of the app, plus the approved **`REQUIREMENTS.md`** and
  **`PHASES.md`** for your REST API.

**Security recap**
- The database password lives in the **ColdFusion Administrator**, not in any `.cfm` or `.cfc` file.
- The Token Harbor key lives in `%USERPROFILE%\.continue\.env` — outside the repo, outside anything
  the AI reads.
- Every value from a user goes through **`<cfqueryparam>`**.

**Stretch goals (if time remains)**
- Add one new field to the lesson page `02-logic.cfm` (a struct with your own details) and print it.
- In DBeaver, run `SELECT tingkatan, COUNT(*) FROM murid GROUP BY tingkatan` — what would a plain-English
  question for this look like?
- Read `framework/project_starter.json` → `security_principles`. Which one did the CRUD app already follow?

**Tomorrow (Day 2):** the AI builds your REST API one phase at a time and you test it with Postman;
in the afternoon you plan the MCP server and get its first tool working.
