# 00 - Setup: install everything before Day 1

Do this **at home or at the office, before the course**. Allow about **1.75 hours** (mostly downloads,
about 4 GB in total). Day 1 starts with a 30-minute check of section 12 - anything that does not work
by then is fixed together.

| # | Tool | Why you need it | When it is used |
|---|------|-----------------|-----------------|
| 1 | Docker Desktop | runs the Oracle database in a box | whole course |
| 2 | Adobe ColdFusion 2021 | runs the web app and the REST API | Day 1-3 |
| 3 | Git + this course repo | the notes, examples and answer keys | whole course |
| 4-5 | Oracle 21c XE (in Docker) | the database: tables `pelajar`, `murid` | whole course |
| 6 | ColdFusion datasource | connects ColdFusion to Oracle | whole course |
| 7 | API key file | the secret that protects the REST API | Day 2-3 |
| 8 | VS Code + Continue + Ollama / Token Harbor | the AI assistant that writes the code | Day 1 PM-3 |
| 9 | Node.js | runs the MCP server | Day 2 PM-3 |
| 10 | Postman | tests the REST API | Day 2 |
| 11 | Claude Desktop | the AI app that uses your MCP server | Day 3 |

---

## 0. Check your laptop

- Windows 10/11 64-bit, **admin rights**, **8 GB RAM minimum** (16 GB is comfortable), 15 GB free disk.
- **Virtualization enabled**: Task Manager > Performance > CPU > "Virtualization: Enabled".
  If it says Disabled, turn on Intel VT-x / AMD-V in the BIOS (ask IT if unsure). **Docker will not
  run without it, and the course has no way around Docker** - sort this out first.

## 1. Docker Desktop

1. Download from <https://www.docker.com/products/docker-desktop/> and install with the **WSL 2** option ticked.
2. Restart when asked. Start Docker Desktop and wait until it says **"Engine running"**.
3. Check in PowerShell - you should see both a **Client** and a **Server** section:

   ```powershell
   docker version
   ```

## 2. Adobe ColdFusion 2021

1. Get `ColdFusion_2021_GUI_WWEJ_win64.exe` (1.2 GB) from the **download link your trainer sends you**
   (or the trainer's USB stick). It is not in the GitHub repo - it is too big for git, and Adobe's
   licence does not allow it to be shared publicly. **Do not upload it anywhere.**
2. Run it **as administrator**. At each screen:

   | Screen | Choose |
   |--------|--------|
   | Serial number | **Leave blank - Developer Edition** (free, localhost only) |
   | Installer configuration | **Server configuration** |
   | Packages / sub-components | Keep the defaults **and tick `Oracle`** (the database driver) |
   | Install folder | `C:\ColdFusion2021` (default) |
   | Web server | **Built-in web server** (port 8500) |
   | Admin password | Pick one and write it down |
   | RDS | Off |
   | Secure profile | Off (this is a local training machine) |

3. Open <http://localhost:8500/CFIDE/administrator/> and log in.

**Forgot to tick Oracle?** Run this in an **administrator** PowerShell, then restart the Windows
service **"ColdFusion 2021 Application Server"**:

```powershell
C:\ColdFusion2021\cfusion\bin\cfpm.bat install oracle
```

## 3. Git + the course repo

1. Install Git from <https://git-scm.com/download/win> (all defaults).
2. Let your own account write into ColdFusion's web folder - **administrator** PowerShell, once:

   ```powershell
   icacls C:\ColdFusion2021\cfusion\wwwroot /grant "${env:USERNAME}:(OI)(CI)M"
   ```

3. Clone the course into that folder - **normal** PowerShell:

   ```powershell
   git clone https://github.com/luqmanyusof/kpm-mcp-coldfusion.git C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion
   ```

   The folder **must** be called `kpm-mcp-coldfusion` - every link in the notes uses that name.

## 4. Start Oracle

```powershell
cd C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion\00-setup
docker compose up -d
```

The first run downloads about 2 GB. Wait until `docker ps` shows **(healthy)** for `cf-oracle`
(about 1 minute after the download).

## 5. Load the tables

```powershell
docker exec cf-oracle sqlplus -s cfapp/cfapp123@//localhost:1521/XEPDB1 @/db/schema.sql
```

Expected last lines: `pelajar rows: 5` and `murid rows: 6`.
Run the same command any time to **reset** the data to the starting state.
The tables are described in [DATABASE.md](DATABASE.md).

## 6. The datasource (ColdFusion -> Oracle)

The pages ask for a datasource called `cf_test_crud`. Create it once:

1. Administrator > **Data & Services > Data Sources**.
2. Data Source Name: `cf_test_crud` - Driver: **Oracle** - click **Add**.
3. Fill in:

   | Field | Value |
   |-------|-------|
   | SID Name / Service Name | `XEPDB1` (if there is a "Service Name" choice, pick it) |
   | Server | `localhost` |
   | Port | `1521` |
   | User name | `cfapp` |
   | Password | `cfapp123` |

4. Click **Submit**. The list should show `cf_test_crud` with status **OK**.

**Error mentioning SID or listener?** `XEPDB1` is a *service name*, not a SID. Edit the datasource,
clear the SID field, open **Show Advanced Settings**, and put this in **Connection String**:
`ServiceName=XEPDB1`. Submit again.

## 7. The API key file

The REST API (Day 2) only answers requests that carry this key. It lives **outside** the web folder,
so it is never in the code, in git, or in anything the AI reads.

```powershell
New-Item -ItemType Directory -Force C:\course-secrets | Out-Null
[guid]::NewGuid().ToString("N") | Set-Content -NoNewline C:\course-secrets\api-key.txt
Get-Content C:\course-secrets\api-key.txt
```

The last line prints your key. You will paste it into **Postman** and **Claude Desktop** only -
**never into the AI chat**.

## 8. The AI assistant: VS Code + Continue + two AI providers

Continue (inside VS Code) is the AI assistant that writes the code. It can use two providers:

| Provider | Models | Cost | Key needed in Continue? |
|----------|--------|------|-------------------------|
| **Ollama Cloud** (main) | Gemma 4, gpt-oss | free account, with usage limits | no - the Ollama app signs you in |
| **Token Harbor** (backup) | GPT, Claude, Gemini, DeepSeek, Qwen... | pay per use; the account is free | yes - one `thk_live_...` key |

### 8a. VS Code

Install from <https://code.visualstudio.com/> (all defaults).

### 8b. Ollama account + app

1. Go to <https://ollama.com> > **Sign up**. Use your work email (or Google), confirm the email.
2. Download and install the app: <https://ollama.com/download>.
3. In a **new** PowerShell window:

   ```powershell
   ollama signin
   ```

   The browser opens - log in and click **Connect** to link this laptop to your account.
4. Test the cloud model (it runs on Ollama's servers, not your laptop):

   ```powershell
   ollama run gemma4:31b-cloud "Say hello in five words"
   ```

   A short reply = done. Your usage so far is at <https://ollama.com/settings> - the free plan has
   hourly and weekly limits, so check it if replies suddenly stop.

### 8c. Token Harbor account + API key

1. Go to <https://tokenharbor.ai> > **Sign up**. The account is free and needs no card; the wallet
   starts at $0. **Top up only if your trainer says so** - the course runs on Ollama.
2. Dashboard > **API keys**. Copy the **Universal Key** (`thk_live_...`) **straight away** - it is
   shown only once. Lost it? Delete it and create a new one.
3. Store the key where Continue can read it, but the AI and git cannot - Continue's own `.env` file
   in your user folder:

   ```powershell
   New-Item -ItemType Directory -Force $HOME\.continue | Out-Null
   Add-Content $HOME\.continue\.env "TOKEN_HARBOR_API_KEY=paste-your-thk_live-key-here"
   notepad $HOME\.continue\.env      # check it: one line, no spaces around =
   ```

   **Never** put this key in the course folder, in a chat message, or in a screenshot. It spends real
   money. If it leaks: dashboard > API keys > delete it, then make a new one.

### 8d. Continue

1. In VS Code: Extensions (Ctrl+Shift+X) > search **Continue** > Install.
2. Give Continue the course models - copy the course config over Continue's own:

   ```powershell
   Copy-Item C:\ColdFusion2021\cfusion\wwwroot\kpm-mcp-coldfusion\00-setup\continue-config.yaml $HOME\.continue\config.yaml
   ```

   The config refers to the key as `${{ secrets.TOKEN_HARBOR_API_KEY }}` - Continue fills it in from
   the `.env` file, so the key is never written in the config.
3. Reload VS Code (Ctrl+Shift+P > **Reload Window**). Open the Continue panel (its icon on the left
   bar), switch the mode to **Agent**, and test both providers:
   - pick **Gemma 4 31B (Ollama Cloud)**, type `hello` - a reply
   - pick **Token Harbor (backup)**, type `hello` - a reply

## 9. Node.js

Install the **LTS** version from <https://nodejs.org/> (all defaults). Check:

```powershell
node -v      # v20 or newer
npm -v
```

## 10. Postman

Install from <https://www.postman.com/downloads/>. Sign in with a free account (or use the
lightweight client without an account).

## 11. Claude Desktop

Install from <https://claude.ai/download> and sign in (a free account is enough for this course).
You will connect it to your own MCP server on Day 3 - nothing to configure yet.

---

## 12. Final check - bring this to Day 1

| # | Check | You should see |
|---|-------|----------------|
| 1 | `docker ps` | `cf-oracle` ... `(healthy)` |
| 2 | <http://localhost:8500/kpm-mcp-coldfusion/01-cf-basics/basics/03-database.cfm> | a table of 5 `pelajar` rows |
| 3 | <http://localhost:8500/kpm-mcp-coldfusion/02-crud-app/crud/> | the list of 6 students |
| 4 | <http://localhost:8500/kpm-mcp-coldfusion/04-rest-api/api-demo/pelajar.reference.cfm> | JSON: `{"data":[{"id":1,...` |
| 5 | <http://localhost:8500/kpm-mcp-coldfusion/04-rest-api/reference/murid.cfm> | `{"error":"Missing or wrong API key."}` - **correct!** The browser sends no key |
| 6 | Continue panel, Agent mode, `hello` | a reply from **Gemma 4** and from **Token Harbor** |
| 7 | `node -v` | v20 or newer |
| 8 | Postman and Claude Desktop | both open and signed in |

All eight = you are ready.

---

## Every day after that

1. Start **Docker Desktop**, then in `kpm-mcp-coldfusion\00-setup`: `docker compose up -d`.
2. ColdFusion starts by itself with Windows (it is a service).
3. `.cfm` edits show on the next page refresh - no restart needed.

To stop Oracle: `docker compose down` (data kept). `docker compose down -v` wipes it - then run step 5 again.

## When something is wrong

| You see | Fix |
|---------|-----|
| `docker: error during connect` | Docker Desktop is not running. Start it and wait for "Engine running". |
| Docker says virtualization / WSL is missing | Step 0: enable virtualization in the BIOS, then `wsl --install` and restart. |
| `port is already allocated` (1521) | Another Oracle is on the laptop. Stop it, or change `"1521:1521"` to `"1522:1521"` in `docker-compose.yml` and use port 1522 in step 6. |
| `ORA-01017` | Wrong user/password: `cfapp` / `cfapp123`. |
| `ORA-00942: table or view does not exist` | Step 5 was skipped. Run it. |
| `Datasource cf_test_crud could not be found` | Step 6 not done, or the name is spelled differently. |
| `Driver not found` / no Oracle in the driver list | Step 2: `cfpm.bat install oracle`, restart the service. |
| `localhost:8500` does not open | Windows Services > start "ColdFusion 2021 Application Server". |
| `404` on a course page | The repo folder is not named `kpm-mcp-coldfusion`, or not inside `wwwroot` (step 3). |
| `git clone` / VS Code save says "Access denied" | Step 3.2 (`icacls`) was skipped. |
| Check 5 says `Server key is not configured` / 500 | Step 7 was skipped, or the file is in a different folder. |
| `ollama` not recognised | Close and reopen PowerShell after installing Ollama. |
| Continue shows no Gemma / Token Harbor model | Step 8d - the config file was not copied. Reload VS Code (Ctrl+Shift+P > "Reload Window"). |
| Gemma: `unauthorized` or no reply | Run `ollama signin` again. Still failing: check usage limits at ollama.com/settings. |
| Token Harbor: `401` / `invalid api key` | The `.env` line is wrong (check spelling `TOKEN_HARBOR_API_KEY=`, no quotes or spaces), then Reload Window. |
| Token Harbor: `402` / `insufficient balance` | The model needs credit. Pick a free model in the config, or top up (ask your trainer first). |
| Token Harbor: `model not found` | The model ID in `config.yaml` is not in the catalog - copy the exact ID from tokenharbor.ai/models. |

> **Local training only.** The passwords here and in `docker-compose.yml` are throwaway values for
> this laptop. Never reuse them, and never point these apps at a real database.
