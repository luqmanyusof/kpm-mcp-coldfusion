# 00 - Setup: install everything before Day 1

Do this **at home or at the office, before the course**. Allow about **1.5 hours** (mostly downloads,
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
| 8 | VS Code + Continue + Ollama | the AI assistant that writes the code | Day 1 PM-3 |
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

1. Download `ColdFusion_2021_GUI_WWEJ_win64.exe` (1.2 GB) from the course repo's **Releases** page
   (link from your trainer). It is not inside the repo itself - it is too big for git.
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
   git clone <course-repo-url> C:\ColdFusion2021\cfusion\wwwroot\cf-mcp-course
   ```

   The folder **must** be called `cf-mcp-course` - every link in the notes uses that name.

## 4. Start Oracle

```powershell
cd C:\ColdFusion2021\cfusion\wwwroot\cf-mcp-course\00-setup
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

## 8. VS Code + Continue + Ollama (the AI assistant)

1. **VS Code** - <https://code.visualstudio.com/> (all defaults).
2. **Ollama** - <https://ollama.com/download>, install, then in PowerShell:

   ```powershell
   ollama signin                              # opens the browser - create / log in to your Ollama account
   ollama run gemma4:31b-cloud "Say hello in five words"
   ```

   A short reply = your account can reach the cloud model. (It runs on Ollama's servers, not your laptop.)
3. **Continue** - in VS Code: Extensions (Ctrl+Shift+X) > search **Continue** > Install.
4. Give Continue the course models - copy the course config over Continue's own:

   ```powershell
   New-Item -ItemType Directory -Force $HOME\.continue | Out-Null
   Copy-Item C:\ColdFusion2021\cfusion\wwwroot\cf-mcp-course\00-setup\continue-config.yaml $HOME\.continue\config.yaml
   ```

5. Open the Continue panel (its icon on the left bar), pick **Gemma 4 31B (Ollama Cloud)**, switch the
   mode to **Agent**, and type `hello`. A reply = done.

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
| 2 | <http://localhost:8500/cf-mcp-course/01-cf-basics/basics/03-database.cfm> | a table of 5 `pelajar` rows |
| 3 | <http://localhost:8500/cf-mcp-course/02-crud-app/crud/> | the list of 6 students |
| 4 | <http://localhost:8500/cf-mcp-course/04-rest-api/api-demo/pelajar.reference.cfm> | JSON: `{"data":[{"id":1,...` |
| 5 | <http://localhost:8500/cf-mcp-course/04-rest-api/reference/murid.cfm> | `{"error":"Missing or wrong API key."}` - **correct!** The browser sends no key |
| 6 | Continue panel, Agent mode, `hello` | a reply from Gemma 4 |
| 7 | `node -v` | v20 or newer |
| 8 | Postman and Claude Desktop | both open and signed in |

All eight = you are ready.

---

## Every day after that

1. Start **Docker Desktop**, then in `cf-mcp-course\00-setup`: `docker compose up -d`.
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
| `404` on a course page | The repo folder is not named `cf-mcp-course`, or not inside `wwwroot` (step 3). |
| `git clone` / VS Code save says "Access denied" | Step 3.2 (`icacls`) was skipped. |
| Check 5 says `Server key is not configured` / 500 | Step 7 was skipped, or the file is in a different folder. |
| `ollama` not recognised | Close and reopen PowerShell after installing Ollama. |
| Continue shows no Gemma model | Step 8.4 - the config file was not copied. Reload VS Code (Ctrl+Shift+P > "Reload Window"). |

> **Local training only.** The passwords here and in `docker-compose.yml` are throwaway values for
> this laptop. Never reuse them, and never point these apps at a real database.
