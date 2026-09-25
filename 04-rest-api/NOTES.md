# 04 - Build and test the REST API

> **Day 2, morning.** The AI builds yesterday's plan one phase at a time, you test every phase, and
> by lunch the CRUD app has a second door - a REST API protected by a key - that the MCP will use.

**Why an API first?** The web pages are a door for *people*. An AI (through the MCP) needs a door for
*programs*: fixed URLs, JSON in and out, and a key. The MCP never touches the database - it only
knocks on this door, so all the app's rules still apply.

| Folder | What it is |
|--------|-----------|
| [api-demo/](api-demo/) | 20-minute trainer demo: a tiny API for `pelajar`, filled in live ([DEMO.md](api-demo/DEMO.md)) |
| `workspace/` | **yours** - the CRUD copy + your plan from Module 03. The AI builds here. |
| [reference/](reference/) | the answer key: a finished `murid` API, its contract [API.md](reference/API.md) and a Postman collection |

---

## Part A - What an API looks like inside (trainer demo, 20 min)

Watch the trainer fill in the four TODOs of `api-demo/pelajar.cfm`. Notice three things you will
check in your own API: **JSON in and out**, **every value in a bind parameter**, and a **status code**
for every answer (200, 201, 400, 404). The demo has **no key** - yours will.

## Part B - Build it, one phase at a time

Open your workspace (`code 04-rest-api\workspace`), Continue in **Agent** mode, **same chat as
yesterday** if you still have it. If not, start a new chat and paste:

```
REQUIREMENTS.md and PHASES.md in this folder are approved. Read them, then build Phase 1 only.
Stop after it and tell me exactly how to run its RUN TEST.
```

Then repeat this loop for every phase:

| Step | You type (or do) |
|------|------------------|
| 1. Build | *(the AI edits files - approve each file change it asks about)* |
| 2. Test | Run the RUN TEST yourself - browser, Postman or the command it gives you |
| 3a. Passed | `RUN TEST passed: <what you saw>. Mark Phase 1 Verified in PHASES.md, then build Phase 2 only.` |
| 3b. Failed | `RUN TEST failed. Expected <x>. Got <paste the response or error>. Fix Phase 1 only.` |

**Rules that save you time**

- **One phase at a time.** If it builds two, type: `Stop. Only one phase at a time. Which phase is done?`
- **You run the test, not the AI.** "It should work" is not a test result.
- **Never paste the API key into the chat.** Paste responses and errors - not the key.
- `.cfm` changes work on the next refresh. If a change to `Application.cfc` seems ignored, ask the
  trainer to restart ColdFusion.

## Part C - Test everything with Postman

1. Ask the AI for a test collection:

   ```
   Write a Postman collection (v2.1 JSON) to postman_collection.json that runs every acceptance check
   in REQUIREMENTS.md, in order. Use collection variables baseUrl and apiKey. Leave apiKey empty.
   ```

2. Postman > **Import** > choose `postman_collection.json`.
3. Open the collection > **Variables** > put your key (from `C:\course-secrets\api-key.txt`) in the
   **Current value** of `apiKey`. Current values stay on your laptop - they are never shared or exported.
4. **Run** the collection (Runner). Every test should pass.
5. Something fails? That is the build-and-check rhythm working. Paste the failing request and response
   to the AI: `This Postman test failed: ... Fix the API, not the test.`

**Compare:** import [reference/murid-api.postman_collection.json](reference/murid-api.postman_collection.json)
too. Did your AI's collection test the wrong-key and bad-input cases? If not, ask it to add them.

## Part D - Write down how it works (the blueprint for the MCP)

```
Write API.md for a developer who will call this API from another program: base URL, the key header,
every method and URL, body fields with their rules, example responses, and every error code.
Do not include the key itself.
```

Compare it with [reference/API.md](reference/API.md). This file is what the MCP server is built from
this afternoon - if it is wrong, the MCP will be wrong.

---

## Milestone - end of the application block

- [ ] every phase in `PHASES.md` is marked **Verified**
- [ ] the Postman run is all green, including **401 for a wrong key** and **400 for bad input**
- [ ] `API.md` describes the API correctly, with no key in it
- [ ] the CRUD web pages still work (the API did not break the app)

**Not finished by lunch?** No problem - the afternoon uses the **reference API** instead:
`http://localhost:8500/cf-mcp-course/04-rest-api/reference/murid.cfm` with [reference/API.md](reference/API.md).
Everyone starts Module 05 on equal footing.

Next: **[05 - Build the MCP server](../05-mcp-server/NOTES.md)**.
