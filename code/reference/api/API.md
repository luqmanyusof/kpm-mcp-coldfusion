# murid API - contract

The blueprint the MCP server is built from. If the API and this file disagree, the API is wrong.

- **Base URL:** `http://localhost:8500/kpm-mcp-coldfusion/code/reference/api/murid.cfm`
- **Auth:** every request sends header `X-API-Key: <key>`. The key is in `C:\course-secrets\api-key.txt`
  (outside the web folder). Missing or wrong key -> `401`.
- **Body:** JSON, header `Content-Type: application/json`.
- **Responses:** a record or list is wrapped in `data`. An error is `{ "error": "text" }`.

## Endpoints

| Action | Method + URL | Body | Success |
|--------|--------------|------|---------|
| List | `GET murid.cfm` | - | `200 { "data": [ record, ... ] }` |
| List, filtered | `GET murid.cfm?tingkatan=5&q=ali` | - | same; `tingkatan` 1-5, `q` = part of the name |
| Get one | `GET murid.cfm?id=3` | - | `200 { "data": record }` |
| Create | `POST murid.cfm` | all required fields | `201 { "data": record }` |
| Update | `PUT murid.cfm?id=3` | only the fields to change | `200 { "data": record }` |
| Delete | `DELETE murid.cfm?id=3` | - | `200 { "deleted": true, "id": 3 }` |

## Record

```json
{
  "id": 3,
  "nama": "Tan Wei Jie",
  "no_kp": "111103-07-5419",
  "jantina": "Lelaki",
  "tingkatan": 3,
  "kelas": "Bestari",
  "tarikh_lahir": "2011-11-03",
  "bangsa": "Cina",
  "agama": "Buddha",
  "pendapatan_isi_rumah": 12000.0,
  "bilangan_adik_beradik": 1
}
```

| Field | Rule | Required on create |
|-------|------|--------------------|
| `id` | set by the database - never send it | - |
| `nama` | text, max 100 | yes |
| `no_kp` | `######-##-####`, unique | yes |
| `jantina` | `Lelaki` or `Perempuan` | yes |
| `tingkatan` | whole number 1-5 | yes |
| `kelas` | text, max 30 | yes |
| `tarikh_lahir` | real date, `yyyy-mm-dd` | yes |
| `bangsa` | `Melayu`, `Cina`, `India`, `Lain-lain` | no (default `Melayu`) |
| `agama` | text, max 30 | yes |
| `pendapatan_isi_rumah` | number, 0 or more (RM per month) | no (default 0) |
| `bilangan_adik_beradik` | whole number 0-30 | no (default 0) |

## Errors

| Status | When | Example body |
|--------|------|--------------|
| 400 | bad id, bad JSON, unknown field, a rule above broken, duplicate `no_kp` | `{ "error": "tingkatan: must be a whole number 1-5." }` |
| 401 | missing or wrong `X-API-Key` | `{ "error": "Missing or wrong API key." }` |
| 404 | no record with that id | `{ "error": "Not found." }` |
| 405 | any other method | `{ "error": "Method PATCH not supported." }` |
| 500 | unexpected failure - details go to the ColdFusion log, never to the caller | `{ "error": "Server error. ..." }` |

Bad input is **rejected, never silently fixed**: `tingkatan: 7` is an error, not "clamped to 5".
