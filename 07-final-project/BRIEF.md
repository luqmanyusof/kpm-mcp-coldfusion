# 07 - Final project

> **Day 3, afternoon.** Groups of 2-3. **2 hours to build, 10 minutes each to present.**
> You run the whole cycle again - interview, plan, build, test, connect - on a new feature, faster.

## The brief

The school office likes the AI assistant, and wants **one more thing it can do**. Pick **one**:

| Option | The office asks | You build |
|--------|-----------------|-----------|
| **A - Summary** | "How many students per form, and what is the average household income?" | a read-only API endpoint + one MCP tool |
| **B - Better search** | "Find students by class, ethnicity, or an income range." | extra filters on the list endpoint + the MCP tool updated |
| **C - Second table** | "Can the assistant manage the `pelajar` contact list too?" | a `pelajar` API with a key + 5 MCP tools |

## How to run it

1. Copy the starter into **your existing workspace** (the API one first, then the MCP one).
2. Paste `START_PROMPT.md`. For answers that have not changed, reuse them:
   *"Same as the murid project - see REQUIREMENTS.md."* The interview should take 10-15 minutes.
3. Approve the plan, build phase by phase, **RUN TEST** every phase.
4. Update Postman (API) and test in the MCP Inspector, then in Claude Desktop.
5. Run at least **two** break-it tests from Module 06 against your new feature.

## Present (10 minutes)

1. **The ask** - which option, and your answer to interview Question 2 (1 min)
2. **The plan** - show `PHASES.md` with every phase Verified (2 min)
3. **Live demo** - plain English in Claude Desktop, and the change visible in the web page (3 min)
4. **Break it** - one safety test, live (2 min)
5. **One lesson** - where the AI went wrong, and how you caught it (2 min)

## Done means

- [ ] the new feature works from Claude Desktop, in plain English
- [ ] every phase has a RUN TEST that you ran and marked Verified
- [ ] a wrong key and a bad input are both rejected
- [ ] the key is not in any file you wrote, or in the chat
- [ ] the original CRUD pages and the 5 original tools still work
