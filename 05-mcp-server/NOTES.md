# 05 - Build the MCP server

> **Day 2 afternoon** - what an MCP is, plan it with the framework, get **one tool** working end to end.
> **Day 3 morning** - build the other tools, each one tested before the next.

---

## Part A - What an MCP is (trainer, 45 min)

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
 Your REST API (ColdFusion, Module 04)  --->  Oracle
```

| Word | Meaning here |
|------|--------------|
| **Tool** | one action the AI may call, e.g. `create_murid` |
| **Description** | the sentence the AI reads to decide *when* to use the tool - write it for the AI |
| **Input schema** | the exact fields and rules a tool accepts. A call that breaks them is rejected before it reaches your app |
| **stdio** | the AI app starts your server as a program and talks through its input/output - no port, no URL |
| **Environment variables** | how the server gets the API URL and key - from the AI app's config, never from the code |

**Three safety ideas to carry through the build**

- The AI's tool call is an **untrusted request** - check it against the rules, reject bad values, never "fix" them.
- **Delete is special**: the tool demands `confirm: true`, and its description tells the AI to ask you first.
- The **key never appears** in code, in a tool result, in an error message, or in the chat.

## Part B - Plan it with the framework

**1. Make the workspace** (PowerShell):

```powershell
cd C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion
New-Item -ItemType Directory 05-mcp-server\workspace | Out-Null
Copy-Item 03-ai-framework\START_PROMPT.md, 03-ai-framework\project_starter.json 05-mcp-server\workspace
Copy-Item 04-rest-api\workspace\API.md 05-mcp-server\workspace      # yours - or use reference\API.md
code 05-mcp-server\workspace
```

Using the reference API instead of your own? Copy `04-rest-api\reference\API.md` in that last step.

**2. Run the interview** - new Continue chat, Agent mode, paste `START_PROMPT.md`.

| # | Suggested answer for the MCP |
|---|------------------------------|
| 1 | **2** - Node.js MCP server |
| 2 | "Let an AI assistant list, find, add, change and delete students in plain English, through the murid API." |
| 3 | the endpoints in `API.md` |
| 4 | **1** - All CRUD |
| 5 | **1** - Yes (the server sends the key on every call) |
| 6 | "Reject values that break the rules in API.md before calling the API. Delete only after the user confirms. Show the API's error message in plain words. Never show the key." |

**3. Check the scope summary** before you type *approved*:

- [ ] Node.js, the official MCP SDK (`@modelcontextprotocol/sdk`), **stdio** transport
- [ ] base URL and key come from environment variables **`API_BASE_URL`** and **`API_KEY`**
- [ ] 5 tools; each has a clear description and an input schema matching `API.md`
- [ ] `delete_murid` requires `confirm: true`
- [ ] nothing is ever written to the console with `console.log` (it would break stdio) - `console.error` only
- [ ] errors come back as a readable tool error, never a crash, never the key

## Part C - First tool, end to end (Day 2 finish line)

Build the phases up to the first tool (usually: project skeleton + `list_murid`). To test a tool
without any AI app, use the **MCP Inspector** - a web page that calls your tools directly:

```powershell
cd C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion\05-mcp-server\workspace
npm install
npx @modelcontextprotocol/inspector -e "API_BASE_URL=<your API URL>" -e "API_KEY=$(Get-Content C:\course-secrets\api-key.txt)" node index.js
```

In the Inspector page: **Connect** > **Tools** > **List Tools** > `list_murid` > **Run Tool**.
You should see the students from Oracle. **That is an AI-ready action, working end to end.**

`<your API URL>` is your own API from Module 04, or the reference:
`http://localhost:8500/kpm-mcp-coldfusion/04-rest-api/reference/murid.cfm`

## Part D - The other four tools (Day 3 morning)

Same loop as Module 04: **one phase, then RUN TEST in the Inspector, then Verified**. For each tool,
test two things:

| Tool | Happy path | Must be rejected |
|------|-----------|------------------|
| `get_murid` | id 1 returns Ahmad | id 999999 -> a readable "not found" |
| `create_murid` | a new student appears in the CRUD web page | `tingkatan: 7` -> error, nothing saved |
| `update_murid` | change `kelas`, check it in the web page | no fields given -> error |
| `delete_murid` | with `confirm: true`, the row is gone | without `confirm` -> refused |

Also test once with a **wrong key** (edit `API_KEY` in the Inspector's left panel): you get a readable
401 error, and the wrong key is **not** shown in it.

---

## Stuck? The answer key

[reference/](reference/) is a finished server with the same 5 tools, plus a test that checks all of
them against a fake API (no ColdFusion needed):

```powershell
cd 05-mcp-server\reference
npm install
npm test          # 12 checks, should end with ALL PASSED
```

Compare its tool descriptions and input schemas with yours - that is where most MCP quality lives.
If yours is not working by 10:30 on Day 3, use the reference server for Module 06.

Next: **[06 - Connect and verify](../06-connect-verify/NOTES.md)**.
