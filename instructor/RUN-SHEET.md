# Instructor run sheet

Timings assume 09:00–17:00, lunch 13:00–14:00, breaks at 10:30 and 15:30. "D1 T3" = `day1.md`, Topic 3.

## Before the course

- [ ] **Dry run on a clean laptop** — D1 T1 end to end, then every topic with the reference code. These are
      **untested on real Adobe CF + Oracle XE** and must be checked first: the Oracle XE install and
      `db/create_user.sql`, the datasource "Service Name" screen, DBeaver's connection, `reference/api/murid.cfm`
      (JSON numbers and dates), and `api-demo/pelajar.reference.cfm`.
- [ ] Check Adobe's CF download link (D1 T1.2) still works a week before — Adobe has moved old installers
      before. Keep a copy on the USB kit (never on the public repo).
- [ ] Send the repo link **one week before**: "do Day 1 Topic 1 before the course". Ask each participant for
      a screenshot of the Topic 1 checkpoint.
- [ ] Each participant makes a free **Ollama** account (D1 T7.1). Check the free tier's usage limits cover a
      full day of Agent mode — if not, arrange paid seats.
- [ ] Each participant makes a **Token Harbor** account and key (D1 T7.2). It is pay-per-use: decide who pays,
      which model, and a budget per person **before** anyone tops up. Set the model ID in
      `config/continue-config.yaml` to the one you use.
- [ ] **USB kit** for bad Wi-Fi: `OracleXE213_Win64.zip`, the CF installer, DBeaver, DBeaver's Oracle driver
      (for proxied networks), Node.js, Postman, VS Code.
- [ ] Your own machine: reference API and reference MCP working in Claude Desktop — your demo and the class
      fallback.

## Day 1 — Foundations: ColdFusion, the existing app & planning with AI

| Time | Topic | You do | They do |
|---|---|---|---|
| 09:00 | D1 T2 | Why MCP: the "staff entrance" story (`COURSE-OUTLINE.md` intro). The rule: human owns spec + environment, AI owns code. | listen |
| 09:30 | D1 T1 | Run the Topic 1 checkpoint out loud, row by row | tick it; raise hands |
| 10:45 | D1 T3–T4 | Live demo of `basics/`: change code, refresh, show the result | follow along, change values |
| 11:45 | D1 T5 | Tour `MURID` in DBeaver; point out the CHECK and UNIQUE rules | open the table, find the rules |
| 14:00 | D1 T6 | Run the CRUD app, then walk the five pages | add/edit/delete; watch DBeaver |
| 15:00 | D1 T7 | Circulate — Continue config and the Token Harbor `.env` | both models reply |
| 15:45 | D1 T8 | Framework walkthrough. **Do one interview live** on the projector, including one mistake and the correction. | watch |
| 16:15 | D1 T9 | Circulate. Check scope summaries (key file path!) before they approve. | own interview → `REQUIREMENTS.md` + `PHASES.md` |

**End-of-day check:** everyone has both plan files. Anyone without them starts Day 2 by copying a neighbour's.

## Day 2 — Build the REST API, then pivot to MCP

| Time | Topic | You do | They do |
|---|---|---|---|
| 09:00 | D2 T1–T2 | Key file + installs; REST vocabulary | create the key, install Postman + Node |
| 09:30 | D2 T3 | Fill in `api-demo/pelajar.cfm` live, TODO by TODO | watch; call it in the browser |
| 10:00 | D2 T4 | Show the phase loop once on the projector | build phases, RUN TEST each |
| 11:45 | D2 T5–T6 | Show Postman import + Variables "Current value" | AI-made collection, run it; `API.md` |
| 12:45 | D2 T6 | **Milestone check.** Not done = switch to the reference API. No shame — say it out loud. | |
| 14:00 | D2 T7 | MCP concepts: host, server, tool, description, schema, stdio | |
| 14:45 | D2 T8 | Circulate: check env vars and `confirm` in scope summaries | MCP interview → plan |
| 15:45 | D2 T9 | Show the Inspector once | skeleton + `list_murid` in the Inspector |

## Day 3 — Build the MCP, connect & verify

| Time | Topic | You do | They do |
|---|---|---|---|
| 09:00 | D3 T1–T2 | Circulate. At 10:30, anyone stuck switches to `reference/mcp`. | remaining 4 tools, tested in the Inspector |
| 10:45 | D3 T3–T4 | Show the config edit + full quit/restart once | connect Claude Desktop; prompts 1–7 |
| 12:00 | D3 T5–T6 | Explain prompt injection before test 13 | break-it tests 8–13; findings log |
| 14:00 | D3 T7 | Form groups, check each group's option choice | build |
| 16:00 | D3 T7 | Presentations, 10 min each | present |
| 16:45 | wrap | How to reuse the framework on their own apps: "same as" answers, the security principles | |

## Fallbacks

| Problem | Do this |
|---|---|
| Oracle XE will not install on a laptop | Reinstall to `C:\oraclexe\` as administrator. Still failing: pair them with a neighbour for the whole course. |
| Ollama Cloud slow / rate-limited | Switch to `gpt-oss 120B`, then to **Token Harbor (backup)** in Continue. Whole room blocked: drive from your machine on the projector. |
| Gemma misbehaves in the interview | The recovery table in D1 T9. Last resort: `START_PROMPT.fallback-with-questions.md` in this folder (the questions written into the prompt). |
| Participant's API not done by lunch Day 2 | Reference API: `reference/api/murid.cfm` + `reference/api/API.md`. |
| Participant's MCP not done by 10:30 Day 3 | Reference server: `reference/mcp` (`npm install` first). |
| Claude Desktop sign-in blocked by company network | Continue Agent mode as the MCP client (`config/continue-config.yaml`, last block). |
| Data got messy | In the course folder: `cd db; sqlplus -s 'cfapp/cfapp123@//localhost:1521/XEPDB1' '@schema.sql'` |

## Other files in this folder

- `ARCHITECTURE.md` — how the pieces fit, and what was deliberately left out.
- `START_PROMPT.fallback-with-questions.md` — the longer start prompt, with the 6 questions written in.
- The original outline is `COURSE-OUTLINE.md` in the repo root. **It still says Gemini CLI and Oracle 19c** —
  update it before it goes to the client.
