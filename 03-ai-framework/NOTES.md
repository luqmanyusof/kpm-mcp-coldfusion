# 03 - The AI framework: plan before you build

> **Day 1, afternoon.** You stop reading code and start *directing* the AI. By the end of today the AI
> has interviewed you and written the plan for your REST API. Tomorrow morning it builds that plan.

**The one rule of this course:** you own the **specification** and the **environment**; the AI owns the
**code**, and the code is checked against your specification. You never have to write code - but you
always decide what "done" means, and you always run the test.

---

## What is in this folder

| File | What it is |
|------|-----------|
| [START_PROMPT.md](START_PROMPT.md) | The short message you paste into Continue to begin. |
| [project_starter.json](project_starter.json) | The AI's **operating instructions**: the 6 interview questions, the rules, the security principles, and the format of the plan it must write. You do not edit it. |

The same two files are used twice: for the **REST API** (today) and for the **MCP server** (Day 2 afternoon).
Question 1 of the interview is where you choose.

## How the framework works

```
 you paste START_PROMPT.md
          |
          v
 AI reads the project quietly  --->  asks 6 questions, ONE at a time  --->  you answer
          |
          v
 AI shows a scope summary + acceptance checks  --->  you correct it  --->  you say "approved"
          |
          v
 AI writes REQUIREMENTS.md (what)  +  PHASES.md (how, in small steps)
          |
          v
 Tomorrow: one phase at a time  --->  RUN TEST  --->  you mark it Verified  --->  next phase
```

## The 6 questions (prepare your answers)

| # | Question | Type | Suggested answer for the REST API |
|---|----------|------|-----------------------------------|
| 1 | What are we building in this project? | pick | **1** - REST API endpoint |
| 2 | In one sentence, what should it do and what problem does that solve? | type | "Let other programs - and later an AI - read and manage student records without using the web pages." |
| 3 | Which of these should this project work with? | type | the `murid` table (the AI lists what it found in the code) |
| 4 | Which operations should it expose? | pick | **1** - All CRUD |
| 5 | Should access require a secret key, such as an X-API-Key header? | pick | **1** - Yes |
| 6 | What must be rejected as invalid, and what should happen when something goes wrong? | type | "Reject missing required fields, a wrong IC format, tingkatan outside 1-5, and unknown fields. On any error return a short message - never SQL or a stack trace." |

Your own words are fine. Short and specific beats long.

---

## Hands-on: plan your REST API

**1. Make your workspace** - a copy of the CRUD app with the starter dropped in (PowerShell):

```powershell
cd C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion
Copy-Item 02-crud-app\crud 04-rest-api\workspace -Recurse
Copy-Item 03-ai-framework\START_PROMPT.md, 03-ai-framework\project_starter.json 04-rest-api\workspace
code 04-rest-api\workspace
```

Check the copy runs: <http://localhost:8500/kpm-mcp-coldfusion/04-rest-api/workspace/>.
(`workspace` folders are yours - git ignores them.)

**2. Start the interview.** In VS Code open the Continue panel, choose **Gemma 4 31B**, mode **Agent**.
Open `START_PROMPT.md`, copy all of it, paste it into Continue, send.

**3. Answer the 6 questions**, one at a time. Expect: `Question 3 of 6: ...` followed by a `Hint:` line.

**4. Check the scope summary before you approve.** Look for:

- [ ] only the `murid` table, and the operations you picked
- [ ] every request needs the `X-API-Key` header; a wrong or missing key gets **401**
- [ ] the key is read from **`C:\course-secrets\api-key.txt`** - if the summary says anything else,
      type: *"The key must be read from the file C:\course-secrets\api-key.txt, never written in code."*
- [ ] SQL uses bind parameters only
- [ ] acceptance checks: one per operation, one rejected input, one wrong key
- [ ] delete asks for confirmation (the API can delete by id; the *AI tools* will ask first - Module 05)

Fix anything wrong in plain words, then type **approved**.

**5. Read the two files it writes.** `REQUIREMENTS.md` is *what* you agreed. `PHASES.md` is the build
plan: every phase ends in a **RUN TEST** with an expected result. If a phase has no test you can run,
ask the AI to merge it with the next one.

**Done for today** when both files exist and you agree with them. **Do not let it start coding yet.**

---

## When the AI misbehaves (it will - this is part of the skill)

Gemma is capable but not perfect. Stay calm, and correct it with a short, direct message.

| It... | You type |
|-------|----------|
| asks several questions at once, or answers for you | `Stop. You answered for me. Ask Question 3 again and wait for my answer.` |
| asks a question that is not one of the 6 | `That question is not in the interview array. Ask Question 4 from project_starter.json, word for word.` |
| asks which database or which fields | `Do not ask me that - read it from the code, as the defaults say.` |
| starts writing code or files before you approved | `Undo that. No code or files until I type approved.` |
| uses emojis, tables or strange symbols | `Plain text only, as message_format in the starter says.` |
| goes round in circles or forgets the rules | Start a **new chat** in Continue and paste `START_PROMPT.md` again. |
| is slow or keeps failing | Switch the model to **gpt-oss 120B**, or to **Token Harbor (backup)** if Ollama is down or over its limit, and start a new chat. |

**Why this matters:** in real projects the AI makes the same mistakes. The framework does not make it
perfect - it makes its mistakes *visible and easy to correct*.

Next: **[04 - Build and test the REST API](../04-rest-api/NOTES.md)**.
