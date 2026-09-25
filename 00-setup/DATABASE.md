# Database Structure - `cf_test_crud`

Oracle schema `cfapp` with two tables. DDL source of truth: [`db/schema.sql`](db/schema.sql).

- **Engine:** Oracle Database 21c Express Edition, installed on Windows; the SQL is also valid on 19c
- **Viewer:** DBeaver (setup step 5)
- **Connection:** `localhost:1521`, service `XEPDB1`, user `cfapp` - via datasource `cf_test_crud` in the ColdFusion Administrator

Apply / reset it any time:

```powershell
cd 00-setup\db; sqlplus -s 'cfapp/cfapp123@//localhost:1521/XEPDB1' '@schema.sql'
```

---

## Table: `pelajar`  (Basics + API modules)

A deliberately tiny table so the basics and the learner-written API stay simple.

| Column  | Type                          | Null | Notes       |
|---------|-------------------------------|------|-------------|
| `id`    | `NUMBER(10)` from sequence | no   | Primary key |
| `name`  | `VARCHAR2(100)`                | no   | Student name |
| `email` | `VARCHAR2(150)`                | no   | Email        |

API JSON shape (one row):

```json
{ "id": 1, "name": "Ahmad Danish", "email": "ahmad.danish@example.com" }
```

---

## Table: `murid`  (CRUD module)

A fuller student record for the pre-built CRUD app.

| Column                  | Type                                          | Null | Default             | Notes |
|-------------------------|-----------------------------------------------|------|---------------------|-------|
| `id`                    | `NUMBER(10)` from sequence                 | no   | -                   | Primary key |
| `nama`                  | `VARCHAR2(100)`                                | no   | -                   | Full name |
| `no_kp`                 | `VARCHAR2(14)`                                    | no   | -                   | IC no., e.g. `090312-10-5217`. Unique |
| `jantina`               | `VARCHAR2(10)` + CHECK Lelaki/Perempuan     | no   | -                   | Gender |
| `tingkatan`             | `NUMBER(1)` + CHECK 1-5                      | no   | -                   | Form, 1-5 |
| `kelas`                 | `VARCHAR2(30)`                                 | no   | -                   | Class name |
| `tarikh_lahir`          | `DATE`                                        | no   | -                   | Date of birth |
| `bangsa`                | `VARCHAR2(10)` + CHECK Melayu/Cina/India/Lain-lain | no   | `'Melayu'`          | Ethnicity |
| `agama`                 | `VARCHAR2(30)`                                 | no   | -                   | Religion |
| `pendapatan_isi_rumah`  | `NUMBER(10,2)`                               | no   | `0.00`              | Household monthly income (RM) |
| `bilangan_adik_beradik` | `NUMBER(3)`                                   | no   | `0`                 | Number of siblings |
| `created_at`            | `TIMESTAMP`                                   | no   | `SYSTIMESTAMP` | Set on insert |
| `updated_at`            | `TIMESTAMP`                                   | no   | on update           | Auto-updated by trigger `trg_murid_updated` |

Keys and indexes: `pk_murid(id)`, `uq_murid_no_kp(no_kp)` unique, `idx_murid_tingkatan`, `idx_murid_nama`.
Ids come from sequences `pelajar_seq` / `murid_seq` (column DEFAULT).

Oracle returns column names in CAPITALS; the API uses quoted aliases (`id AS "id"`) to keep JSON keys lowercase.
