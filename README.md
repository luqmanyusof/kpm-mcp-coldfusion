# MCP Development for Web Applications

A 3-day hands-on course: take an existing web app (Adobe ColdFusion 2021 + Oracle), give it a REST API,
then build an **MCP server** so an AI assistant can operate the app in plain English.

**You do not write the code.** You direct an AI assistant (Continue + Gemma 4) with a structured
framework: you own the **specification** and the **environment**, the AI owns the **code**, and every
step is checked by a test **you** run.

**Start here:** [00-setup/SETUP.md](00-setup/SETUP.md) - install everything **before Day 1**.

---

## The course map

Work through the folders in number order. Each has a `NOTES.md` - that is your study note for the session.

| Day | Session | Folder | What you do |
|-----|---------|--------|-------------|
| before | at home | [00-setup](00-setup/SETUP.md) | Install Docker, ColdFusion, Oracle, VS Code + Continue, Node.js, Postman, Claude Desktop |
| **1** | morning | [01-cf-basics](01-cf-basics/NOTES.md) | ColdFusion basics - follow the trainer's demo |
| 1 | afternoon | [02-crud-app](02-crud-app/NOTES.md) | Run the existing student-records app and understand it |
| 1 | afternoon | [03-ai-framework](03-ai-framework/NOTES.md) | The AI interviews you and writes the plan for your REST API |
| **2** | morning | [04-rest-api](04-rest-api/NOTES.md) | The AI builds the API phase by phase; you test it with Postman |
| 2 | afternoon | [05-mcp-server](05-mcp-server/NOTES.md) | What an MCP is; plan it; first AI tool working end to end |
| **3** | morning | [05-mcp-server](05-mcp-server/NOTES.md) | Build the remaining tools |
| 3 | late morning | [06-connect-verify](06-connect-verify/NOTES.md) | Connect Claude Desktop, run the app in plain English, break it on purpose |
| 3 | afternoon | [07-final-project](07-final-project/BRIEF.md) | Group project + presentation |

## How it fits together

```
 You, in plain English
        |
 Claude Desktop ---- MCP (stdio) ----> MCP server (Node.js)          <- 05, built by the AI
                                             |  HTTP + X-API-Key
                                             v
 Web pages (02) ----------------------> REST API (ColdFusion)         <- 04, built by the AI
        |                                    |
        +----------------> Oracle 21c XE (Docker) <------------------+   <- 00
```

## What is in the repo

| Path | What |
|------|------|
| `00-setup/` | setup guide, Oracle `docker-compose.yml`, `db/schema.sql`, Continue config, [DATABASE.md](00-setup/DATABASE.md) |
| `01-cf-basics/basics/` | plain CFML demo pages |
| `02-crud-app/crud/` | the existing app: CRUD for the `murid` table |
| `03-ai-framework/` | `START_PROMPT.md` + `project_starter.json` - the AI framework |
| `04-rest-api/api-demo/` | small `pelajar` API the trainer builds live |
| `04-rest-api/reference/` | answer key: `murid` REST API, `API.md` contract, Postman collection |
| `05-mcp-server/reference/` | answer key: Node.js MCP server with 5 tools + a self-test |
| `06-connect-verify/` | Claude Desktop config example |
| `instructor/` | run sheet, fallbacks, original outline, architecture notes |
| `*/workspace/` | **your own work** (created during the course, ignored by git) |

The Adobe ColdFusion 2021 installer (1.2 GB) is **not** in this repo - your trainer sends a download link.
It must not be uploaded here: this repo is public, and Adobe's licence does not allow public redistribution.

## Notes

- Local training only: throwaway passwords, a training database, a training API key. Never point any
  of this at production.
- Source is ASCII-only by design (no smart quotes, em-dashes or emojis).
