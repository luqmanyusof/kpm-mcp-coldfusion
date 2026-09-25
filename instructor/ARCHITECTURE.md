# Architecture (v3 - as built)

Replaces the v2 design draft. v2's generic "data gateway" and `descriptor.json` were dropped in favour
of a plain per-app REST API and the interview framework.

## Stack

| Layer | Choice | Why |
|-------|--------|-----|
| App server | Adobe ColdFusion 2021, Developer Edition, built-in server :8500 | course target; free for localhost |
| Database | Oracle 21c XE in Docker (`gvenzl/oracle-xe:21-slim-faststart`) | free, ~2 GB, 1-minute start; the SQL is valid on 19c |
| Build AI | Continue (VS Code) Agent mode -> Ollama Cloud, `gemma4:31b-cloud`; backup `gpt-oss:120b-cloud`; second provider Token Harbor (OpenAI-compatible, `https://tokenharbor.ai/v1`) | edits files directly; Ollama via `ollama signin`, Token Harbor key in `~/.continue/.env`, never in the config |
| MCP server | Node.js, `@modelcontextprotocol/sdk` + `zod`, stdio | the official SDK; stdio needs no port |
| MCP client | Claude Desktop; Continue Agent mode as the alternative | the finale runs in a mainstream AI app |
| API testing | Postman, AI-generated collection; reference collection as comparison | |

## Flow

```
02 existing app (murid) --copy--> 04 workspace --interview--> REQUIREMENTS.md + PHASES.md
                                        |  build phase by phase, RUN TEST each
                                        v
                                  REST API + API.md (the contract)
                                        |  API.md copied into
                                        v
                              05 workspace --interview--> plan --> Node MCP server (5 tools)
                                        |
                                        v
                              06 Claude Desktop: plain English -> tool -> API -> Oracle
```

## Security decisions

- **Key:** one random key per laptop in `C:\course-secrets\api-key.txt`, outside the web root. The API
  reads it on every request; the MCP gets it through the client config's `env`. Never in code, git, or chat.
- **Two layers of validation:** the MCP schema rejects bad tool calls; the API validates again.
- **Delete:** `confirm: true` in the tool schema + per-call approval in Claude Desktop. No bulk tools.
- **Errors:** short and safe. Details go to the ColdFusion log (`murid-api.log`), never to the caller.
- **AI provider keys:** Token Harbor's `thk_live_...` key lives in `%USERPROFILE%\.continue\.env` (outside the repo and the workspace the agent reads). Ollama needs no key.
- **Datasource password** lives in the CF Administrator, not in `Application.cfc`.

## Deliberately not done

- No generic "any table" gateway - too large a safety surface for a course.
- No Gemini CLI, no copy-paste-from-chat build loop.
- No HTTP/remote MCP transport - stdio only, local only.
- No Oracle 19c enterprise image, no shared DB server - Docker XE on every laptop.
