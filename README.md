# MCP Development for Web Applications

*AI-driven development with Adobe ColdFusion 2021, Oracle and Node.js — from an existing web app to an
AI assistant that runs it in plain English. A hands-on 3-day course.*

**Table of contents.** Each day is one Markdown file of step-by-step lab notes for participants with
little or no coding background, sized for ~5–5.5 hours. The flow is **existing app → plan with AI →
REST API → MCP server → AI in plain English**.

**Acronyms used throughout** (each is also expanded on first use inside each day's file):
**MCP** = Model Context Protocol · **AI** = Artificial Intelligence · **API** = Application
Programming Interface · **REST** = Representational State Transfer · **CRUD** = Create, Read, Update,
Delete · **CFML** = ColdFusion Markup Language · **JSON** = JavaScript Object Notation · **HTTP** =
Hypertext Transfer Protocol · **URL** = Uniform Resource Locator · **SQL** = Structured Query
Language · **XE** = Oracle Express Edition · **PDB** = Pluggable Database (`XEPDB1`) · **SDK** =
Software Development Kit · **stdio** = standard input/output (how the AI app talks to the MCP server)
· **IC** = identity card number (`no_kp`) · **VS Code** = Visual Studio Code.

**The three days**
- **[Day 1 — Foundations: ColdFusion, the Existing App & Planning with AI](day1.md)**
- **[Day 2 — Build the REST API, then Pivot to MCP](day2.md)**
- **[Day 3 — Build the MCP, Connect & Verify](day3.md)**

**The theory:** **[MCP Explained — the Theory, in Plain Words](mcp-theory.md)** — what MCP is, how it
works, what a server should and should not do, and best practice, with as little jargon as possible.
Each day links to the parts it needs.

**How to read this:** every topic follows the same shape — a short **Goal** (what you set out to do),
the **steps**, and a **Checkpoint ✅** you can verify. Topics are ordered *prerequisites first, easy
first* — each one builds on the last.

**The one rule of this course:** you own the **specification** and the **environment**; the AI owns
the **code**, and the code is checked against your specification. You never write code — but you
always run the test.

**Course-level learning outcomes.** By the end, participants can: explain what an MCP server is and
how it connects an AI assistant to a web application; run and read a ColdFusion + Oracle app; use a
structured AI framework to have the AI interview them and write the plan (`REQUIREMENTS.md` +
`PHASES.md`); drive an AI assistant to build a key-protected REST API and a Node.js MCP server phase by
phase, testing every phase; test APIs in Postman and MCP tools in the MCP Inspector; connect Claude
Desktop to their MCP server and operate the app in plain English; and verify AI output, test failure
cases (including prompt injection) and apply basic security practice.

> **Before Day 1:** do **[Day 1 Topic 1](day1.md#topic-1--install-and-check-your-tools)** at home or
> at the office — the downloads are large (Oracle 2 GB, ColdFusion 1.2 GB).

---

## Day 1 — [Foundations: ColdFusion, the Existing App & Planning with AI](day1.md)

*Install the stack, learn just enough CFML to read the code, run the existing student-records app,
set up the AI assistant, and let the AI interview you and write the REST API plan. The AI writes no
code today; you only change a few lines in the lesson pages.*

| # | Topic | Objective | Outcome |
|---|---|---|---|
| 1 | [Install & check your tools](day1.md#topic-1--install-and-check-your-tools) | Install Oracle XE, ColdFusion 2021, the course files, the course user and tables, DBeaver, the datasource and VS Code | Oracle services running; DBeaver shows 6 students; `basics/` and `crud/` load |
| 2 | [What MCP is & how this course works](day1.md#topic-2--what-mcp-is-and-how-this-course-works-concept) | Understand the "staff entrance" idea and who does what — human vs AI | Can explain what an MCP server is for, and why the human decides "done" |
| 3 | [Your first ColdFusion code](day1.md#topic-3--your-first-coldfusion-code) | Change variables, conditions, loops and arrays; save, refresh, see the result | Changed a value in each lesson page and saw it after F5 |
| 4 | [Read the database with ColdFusion](day1.md#topic-4--read-the-database-with-coldfusion) | Change a `<cfquery>` (sort, filter, wrong datasource) and learn the `<cfqueryparam>` safety rule | Changed the query, saw the result, put the page back |
| 5 | [Look at the `murid` table in DBeaver](day1.md#topic-5--look-at-the-murid-table-in-dbeaver) | Know the columns and the rules the database enforces | Can name three rules on `murid` (unique IC, form 1–5, …) |
| 6 | [Use the existing student app](day1.md#topic-6--use-the-existing-student-app) | Use the existing app, then see which file does what | Added/edited/deleted a student and saw each change in DBeaver |
| 7 | [Set up the AI in VS Code](day1.md#topic-7--set-up-the-ai-in-vs-code) | Install Continue with Ollama Cloud (Gemma 4) and Token Harbor | Both models reply in Continue's Agent mode |
| 8 | [How the AI plans before it builds (concept)](day1.md#topic-8--how-the-ai-plans-before-it-builds-concept) | Understand `START_PROMPT.md` + `project_starter.json` and the 6 questions | Can say what `REQUIREMENTS.md` and `PHASES.md` are, and who approves them |
| 9 | [Plan your REST API with the AI](day1.md#topic-9--plan-your-rest-api-with-the-ai) | Let the AI interview you and write the plan | Approved `REQUIREMENTS.md` + `PHASES.md` in `workspace\rest-api` |

---

## Day 2 — [Build the REST API, then Pivot to MCP](day2.md)

*The AI builds the API one tested phase at a time, and Postman proves it. Then you learn what an MCP
server is, plan one with the same framework, and get its first tool working.*

| # | Topic | Objective | Outcome |
|---|---|---|---|
| 1 | [Get today's tools ready](day2.md#topic-1--get-todays-tools-ready) | Create the API key file, install Postman and Node.js | The reference API answers `401` in the browser; `node -v` works |
| 2 | [How a REST API works (concept)](day2.md#topic-2--how-a-rest-api-works-concept) | Learn resources, verbs, status codes, JSON and the key "doorway" | Can pick the verb + status for an action (add → POST → 201; wrong key → 401) |
| 3 | [See a tiny API built by hand (demo)](day2.md#topic-3--see-a-tiny-api-built-by-hand-trainer-demo) | Watch a tiny `pelajar` API built by hand | Know the three things to check in the AI's code |
| 4 | [Build the REST API, one phase at a time](day2.md#topic-4--build-the-rest-api-one-phase-at-a-time) | Drive the AI through `PHASES.md` with the build → test → Verified loop | Every phase Verified; the web pages still work |
| 5 | [Test everything in Postman](day2.md#topic-5--test-everything-in-postman) | Have the AI write a Postman collection and run it; compare with the reference | All green, including 401 (wrong key) and 400 (bad input) |
| 6 | [Write down how the API works](day2.md#topic-6--write-down-how-the-api-works-apimd) | Produce `API.md` — the blueprint for the MCP | `API.md` matches the real API, with no key in it |
| 7 | [How an MCP server works (concept)](day2.md#topic-7--how-an-mcp-server-works-concept) | Learn host, server, tool, description, schema, stdio | Can name the five tools and why delete needs confirmation |
| 8 | [Plan the MCP server with the AI](day2.md#topic-8--plan-the-mcp-server-with-the-ai) | Run the interview again, choosing MCP | Approved MCP `REQUIREMENTS.md` + `PHASES.md` |
| 9 | [First tool, end to end](day2.md#topic-9--first-tool-end-to-end) | Build the skeleton + `list_murid` and test it in the MCP Inspector | `list_murid` returns the students from Oracle |

---

## Day 3 — [Build the MCP, Connect & Verify](day3.md)

*Finish the tools, connect Claude Desktop, operate the app in plain English, break it on purpose, and
present a final group project.*

| # | Topic | Objective | Outcome |
|---|---|---|---|
| 1 | [Get today's tools ready](day3.md#topic-1--get-todays-tools-ready) | Install Claude Desktop; confirm yesterday's tool | Claude Desktop signed in; `list_murid` still works |
| 2 | [Build the other four tools](day3.md#topic-2--build-the-other-four-tools) | Get, create, update, delete — each proven in the Inspector | Every tool passes its happy path and its rejection test |
| 3 | [Connect Claude Desktop](day3.md#topic-3--connect-claude-desktop) | Register the MCP server in Claude Desktop's config | Claude lists the **murid** server with 5 tools |
| 4 | [Talk to your app](day3.md#topic-4--talk-to-your-app) | Run seven plain-English prompts | Every change confirmed in the web page or DBeaver |
| 5 | [Break it on purpose](day3.md#topic-5--break-it-on-purpose) | Bad input, missing data, bulk delete, app down, wrong key, prompt injection | A findings log; every failure refused, explained and harmless |
| 6 | [The safety review (concept)](day3.md#topic-6--the-safety-review-concept) | Name the guardrails and where each is enforced | A checklist you can reuse on your own apps |
| 7 | [Final project](day3.md#topic-7--final-project) | Add one new AI ability in groups, using the full cycle | A live demo + presentation |

---

## What is in the repo

| Path | What |
|---|---|
| `day1.md` · `day2.md` · `day3.md` | the lab notes |
| `mcp-theory.md` | MCP theory in plain words — read alongside the days |
| `basics/` | three plain CFML lesson pages (Day 1) |
| `crud/` | the existing student-records app (Day 1) |
| `api-demo/` | small `pelajar` API the trainer builds live (Day 2) |
| `db/` | `create_user.sql` + `schema.sql` (reset the data any time) |
| `framework/` | `START_PROMPT.md` + `project_starter.json` — the AI framework |
| `config/` | Continue config, Claude Desktop config example |
| `postman/` | `Day2-murid-API.postman_collection.json` (tests the reference API) |
| `reference/api/` | answer key: `murid` REST API + `API.md` contract |
| `reference/mcp/` | answer key: Node.js MCP server with 5 tools + a self-test |
| `instructor/` | run sheet, fallbacks, architecture notes |
| `workspace/` | **your own work** — created during the course, ignored by git |

The Adobe ColdFusion 2021 installer (1.2 GB) is **not** in this repo — download it from Adobe (link in
Day 1, Topic 1.2). Never upload it here: Adobe's licence does not allow redistribution.

> **Local training only:** throwaway passwords, a training database, a training API key. Never point
> any of this at production.

---

*Files in this folder: [`day1.md`](day1.md) · [`day2.md`](day2.md) · [`day3.md`](day3.md) ·
[`mcp-theory.md`](mcp-theory.md) (MCP theory) · [`COURSE-OUTLINE.md`](COURSE-OUTLINE.md) (original course outline).*
