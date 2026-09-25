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

> **Before Day 1:** do **[Day 1 Topic 1](day1.md#topic-1--install-and-verify-your-tools)** at home or
> at the office — the downloads are large (Oracle 2 GB, ColdFusion 1.2 GB).

---

## Day 1 — [Foundations: ColdFusion, the Existing App & Planning with AI](day1.md)

*Install the stack, learn just enough CFML to read the code, run the existing student-records app,
set up the AI assistant, and let the AI interview you and write the REST API plan. No code is written
today — by you or by the AI.*

| # | Topic | Objective | Outcome |
|---|---|---|---|
| 1 | [Install & verify your tools](day1.md#topic-1--install-and-verify-your-tools) | Install Oracle XE, ColdFusion 2021, Git + the repo, the course user and tables, DBeaver, the datasource and VS Code | Oracle services running; DBeaver shows 6 students; `basics/` and `crud/` load |
| 2 | [What MCP is & how this course works](day1.md#topic-2--what-mcp-is-and-how-this-course-works-concept) | Understand the "staff entrance" idea and who does what — human vs AI | Can explain what an MCP server is for, and why the human decides "done" |
| 3 | [ColdFusion basics: syntax & logic](day1.md#topic-3--coldfusion-basics-syntax-and-logic) | Read variables, output, conditions, loops, arrays and structs | Changed a value in `01-syntax.cfm` and saw it in the browser |
| 4 | [Read the database with ColdFusion](day1.md#topic-4--read-the-database-with-coldfusion) | See the datasource, `<cfquery>` and the `<cfqueryparam>` safety rule | Can point to all three in `03-database.cfm` |
| 5 | [Tour the `murid` table in DBeaver](day1.md#topic-5--tour-the-murid-table-in-dbeaver) | Know the columns and the rules the database enforces | Can name three rules on `murid` (unique IC, form 1–5, …) |
| 6 | [Run & understand the CRUD app](day1.md#topic-6--run-and-understand-the-crud-app) | Use the existing app, then read how its five pages work | Added/edited/deleted a student and saw each change in DBeaver |
| 7 | [Set up the AI assistant](day1.md#topic-7--set-up-the-ai-assistant-continue--ollama-cloud--token-harbor) | Install Continue with Ollama Cloud (Gemma 4) and Token Harbor | Both models reply in Continue's Agent mode |
| 8 | [The AI framework (concept)](day1.md#topic-8--the-ai-framework-concept) | Understand `START_PROMPT.md` + `project_starter.json` and the 6 questions | Can say what `REQUIREMENTS.md` and `PHASES.md` are, and who approves them |
| 9 | [Plan your REST API with the AI](day1.md#topic-9--plan-your-rest-api-with-the-ai) | Let the AI interview you and write the plan | Approved `REQUIREMENTS.md` + `PHASES.md` in `workspace\rest-api` |

---

## Day 2 — [Build the REST API, then Pivot to MCP](day2.md)

*The AI builds the API one tested phase at a time, and Postman proves it. Then you learn what an MCP
server is, plan one with the same framework, and get its first tool working.*

| # | Topic | Objective | Outcome |
|---|---|---|---|
| 1 | [Ready your Day 2 tools](day2.md#topic-1--ready-your-day-2-tools) | Create the API key file, install Postman and Node.js | The reference API answers `401` in the browser; `node -v` works |
| 2 | [REST fundamentals (concept)](day2.md#topic-2--rest-fundamentals-concept) | Learn resources, verbs, status codes, JSON and the key "doorway" | Can pick the verb + status for an action (add → POST → 201; wrong key → 401) |
| 3 | [What an API looks like inside (demo)](day2.md#topic-3--what-an-api-looks-like-inside-trainer-demo) | Watch a tiny `pelajar` API built by hand | Know the three things to check in the AI's code |
| 4 | [Build the REST API, one phase at a time](day2.md#topic-4--build-the-rest-api-one-phase-at-a-time) | Drive the AI through `PHASES.md` with the build → test → Verified loop | Every phase Verified; the web pages still work |
| 5 | [Test everything in Postman](day2.md#topic-5--test-everything-in-postman) | Have the AI write a Postman collection and run it; compare with the reference | All green, including 401 (wrong key) and 400 (bad input) |
| 6 | [Write down how the API works](day2.md#topic-6--write-down-how-the-api-works-apimd) | Produce `API.md` — the blueprint for the MCP | `API.md` matches the real API, with no key in it |
| 7 | [MCP architecture (concept)](day2.md#topic-7--mcp-architecture-concept) | Learn host, server, tool, description, schema, stdio | Can name the five tools and why delete needs confirmation |
| 8 | [Plan the MCP server with the AI](day2.md#topic-8--plan-the-mcp-server-with-the-ai) | Run the interview again, choosing MCP | Approved MCP `REQUIREMENTS.md` + `PHASES.md` |
| 9 | [First tool, end to end](day2.md#topic-9--first-tool-end-to-end-mcp-inspector) | Build the skeleton + `list_murid` and test it in the MCP Inspector | `list_murid` returns the students from Oracle |

---

## Day 3 — [Build the MCP, Connect & Verify](day3.md)

*Finish the tools, connect Claude Desktop, operate the app in plain English, break it on purpose, and
present a final group project.*

| # | Topic | Objective | Outcome |
|---|---|---|---|
| 1 | [Ready your Day 3 tools](day3.md#topic-1--ready-your-day-3-tools) | Install Claude Desktop; confirm yesterday's tool | Claude Desktop signed in; `list_murid` still works |
| 2 | [Build the other four tools](day3.md#topic-2--build-the-other-four-tools) | Get, create, update, delete — each proven in the Inspector | Every tool passes its happy path and its rejection test |
| 3 | [Connect Claude Desktop](day3.md#topic-3--connect-claude-desktop) | Register the MCP server in Claude Desktop's config | Claude lists the **murid** server with 5 tools |
| 4 | [The payoff: talk to your app](day3.md#topic-4--the-payoff-talk-to-your-app) | Run seven plain-English prompts | Every change confirmed in the web page or DBeaver |
| 5 | [Break it on purpose](day3.md#topic-5--break-it-on-purpose) | Bad input, missing data, bulk delete, app down, wrong key, prompt injection | A findings log; every failure refused, explained and harmless |
| 6 | [The safety review (concept)](day3.md#topic-6--the-safety-review-concept) | Name the guardrails and where each is enforced | A checklist you can reuse on your own apps |
| 7 | [Final project](day3.md#topic-7--final-project) | Add one new AI ability in groups, using the full cycle | A live demo + presentation |

---

## What is in the repo

| Path | What |
|---|---|
| `day1.md` · `day2.md` · `day3.md` | the lab notes |
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
[`COURSE-OUTLINE.md`](COURSE-OUTLINE.md) (original course outline).*
