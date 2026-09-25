# Instructor run sheet

Timings assume 09:00-17:00, lunch 13:00-14:00, breaks at 10:30 and 15:30.

## Before the course

- [ ] **Dry run on a clean laptop** - all of `00-setup/SETUP.md`, then Modules 03-06 with the reference
      code. These are **untested on real Adobe CF + Oracle** and must be checked first:
      the datasource "Service Name" screen, `04-rest-api/reference/murid.cfm` (JSON numbers and dates),
      and `api-demo/pelajar.reference.cfm`.
- [ ] Participants download CF from Adobe's link in SETUP step 2. **Check it still works** a week before -
      Adobe has moved old installers before. Keep a copy on the USB kit (never on the public repo).
      Give participants access (private repo = add them, or share a download link).
- [ ] Send `SETUP.md` **one week before**. Ask each participant for a screenshot of the section 12 table.
- [ ] Each participant makes a free **Ollama** account (`ollama signin`). Check the free tier's usage
      limits cover a full day of Agent mode - if not, arrange paid seats.
- [ ] Each participant makes a **Token Harbor** account and key (SETUP 8c). It is pay-per-use:
      decide who pays, which model, and a budget per person **before** anyone tops up. Try the free models first.
- [ ] **USB kit** for bad Wi-Fi: every installer from SETUP.md, plus the Oracle image as a file:
      `docker save gvenzl/oracle-xe:21-slim-faststart -o oracle-xe.tar` (load with `docker load -i oracle-xe.tar`).
- [ ] Your own machine: reference API and reference MCP working in Claude Desktop - your demo and the class fallback.

## Day 1 - Foundations and the existing app

| Time | Module | You do | They do |
|------|--------|--------|---------|
| 09:00 | intro | Why MCP: the "staff entrance" story (`COURSE-OUTLINE.md` intro). The rule: human owns spec + environment, AI owns code. | listen |
| 09:30 | 00 | Run the section 12 check out loud, row by row | tick their table; raise hands |
| 10:00 | README | Tour of the repo: numbered folders = the three days | open the repo in VS Code |
| 10:45 | 01 | Live demo of `basics/`: syntax, logic, database. Change code, refresh, show the result. | follow along, change values |
| 14:00 | 02 | Run the CRUD app, then walk through the five pages (`02-crud-app/NOTES.md`) | add/edit/delete a student; read the code |
| 15:45 | 03 | Framework walkthrough. **Do one interview live** on the projector, including one mistake and the correction. | watch |
| 16:15 | 03 | Circulate. Check scope summaries (key file path!) before they approve. | own interview -> REQUIREMENTS.md + PHASES.md |

**End-of-day check:** everyone has both plan files. Anyone without them starts Day 2 by copying a neighbour's.

## Day 2 - Finish the app, pivot to MCP

| Time | Module | You do | They do |
|------|--------|--------|---------|
| 09:00 | 04 A | Fill in `api-demo/pelajar.cfm` live, TODO by TODO (`DEMO.md`) | watch; call it in the browser |
| 09:20 | 04 B | Show the phase loop once on the projector | build phases, RUN TEST each |
| 11:45 | 04 C-D | Show Postman import + Variables "Current value" | AI-made collection, run it; API.md |
| 12:45 | 04 | **Milestone check.** Not done = switch to the reference API. No shame, say it out loud. | |
| 14:00 | 05 A | MCP concepts: host, server, tool, description, schema, stdio | |
| 14:45 | 05 B | Circulate: check env-var and `confirm` in scope summaries | MCP interview -> plan |
| 15:45 | 05 C | Show the Inspector once | skeleton + `list_murid` working in the Inspector |

## Day 3 - Build, connect, verify

| Time | Module | You do | They do |
|------|--------|--------|---------|
| 09:00 | 05 D | Circulate. At 10:30, anyone stuck switches to the reference server. | remaining 4 tools, tested in the Inspector |
| 10:45 | 06 A-B | Show the config edit + full quit/restart once | connect Claude Desktop; prompts 1-7 |
| 12:00 | 06 C-D | Explain prompt injection before test 13 | break-it tests 8-13; findings log |
| 14:00 | 07 | Form groups, check each group's option choice | build |
| 16:00 | 07 | Presentations, 10 min each | present |
| 16:45 | wrap | How to reuse the starter on their own apps: "same as" answers, the security principles | |

## Fallbacks

| Problem | Do this |
|---------|---------|
| A laptop cannot run Docker | Pair them with a neighbour for the whole course (Docker-only is the setup choice). |
| Ollama Cloud slow / rate-limited | Switch to `gpt-oss 120B`, then to **Token Harbor (backup)** in Continue. If the whole room is blocked, drive from your machine on the projector while they follow. |
| Gemma misbehaves in the interview | `03-ai-framework/NOTES.md` recovery table. Last resort: `START_PROMPT.fallback-with-questions.md` in this folder (the questions written into the prompt). |
| Participant's API not done by lunch Day 2 | Reference API: `04-rest-api/reference/murid.cfm` + `reference/API.md`. |
| Participant's MCP not done by 10:30 Day 3 | Reference server: `05-mcp-server/reference` (`npm install` first). |
| Claude Desktop sign-in blocked by company network | Continue Agent mode as the MCP client (`00-setup/continue-config.yaml`, last block). |
| Data got messy | `docker exec cf-oracle sqlplus -s cfapp/cfapp123@//localhost:1521/XEPDB1 @/db/schema.sql` resets it. |

## Other files in this folder

- `COURSE-OUTLINE.md` - the original outline. **Still says Gemini CLI** - update it before it goes to the client.
- `ARCHITECTURE.md` - how the pieces fit, and what was deliberately left out.
- `START_PROMPT.fallback-with-questions.md` - the longer start prompt, with the 6 questions written in.
