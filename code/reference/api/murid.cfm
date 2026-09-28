<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfscript>
    /*
     * REFERENCE REST API for the `murid` table - the answer key for Day 2.
     * The contract (URLs, fields, errors) is in API.md next to this file.
     *
     * Every request needs the header  X-API-Key: <key>
     * The key lives in a file OUTSIDE the web folder, so it is never in the code, in git,
     * or in anything the AI assistant reads. Create it with day2.md, Topic 1.1.
     */
    KEY_FILE = "C:\course-secrets\api-key.txt";
    COLUMNS  = "id, nama, no_kp, jantina, tingkatan, kelas, tarikh_lahir, bangsa, agama, pendapatan_isi_rumah, bilangan_adik_beradik";
    JANTINA  = "Lelaki,Perempuan";
    BANGSA   = "Melayu,Cina,India,Lain-lain";
    FIELDS   = "nama,no_kp,jantina,tingkatan,kelas,tarikh_lahir,bangsa,agama,pendapatan_isi_rumah,bilangan_adik_beradik";

    // ---- small helpers ---------------------------------------------------

    function out(required numeric status, required struct body) {
        return { status: arguments.status, body: arguments.body };
    }

    function keyIsValid() {
        if (!fileExists(KEY_FILE)) return false;
        var expected = trim(fileRead(KEY_FILE));
        var headers  = getHttpRequestData().headers;
        var given    = structKeyExists(headers, "X-API-Key") ? trim(headers["X-API-Key"]) : "";
        return len(expected) && compare(given, expected) == 0;
    }

    // One Oracle row -> one clean JSON object (lowercase keys, real numbers, yyyy-mm-dd dates).
    function toRow(required query q, numeric r = 1) {
        return {
            "id"                    : javaCast("int",    q.id[r]),
            "nama"                  : q.nama[r],
            "no_kp"                 : q.no_kp[r],
            "jantina"               : q.jantina[r],
            "tingkatan"             : javaCast("int",    q.tingkatan[r]),
            "kelas"                 : q.kelas[r],
            "tarikh_lahir"          : dateFormat(q.tarikh_lahir[r], "yyyy-mm-dd"),
            "bangsa"                : q.bangsa[r],
            "agama"                 : q.agama[r],
            "pendapatan_isi_rumah"  : javaCast("double", q.pendapatan_isi_rumah[r]),
            "bilangan_adik_beradik" : javaCast("int",    q.bilangan_adik_beradik[r])
        };
    }

    function findOne(required numeric id) {
        return queryExecute(
            "SELECT #COLUMNS# FROM murid WHERE id = :id",
            { id: { value: arguments.id, cfsqltype: "cf_sql_integer" } }
        );
    }

    function readBody() {
        var raw = toString(getHttpRequestData().content, "UTF-8");
        if (!len(trim(raw))) return {};
        var b = deserializeJSON(raw);          // bad JSON throws -> caught in handle()
        if (!isStruct(b)) throw(type = "BadBody");
        return b;
    }

    function isText(v, numeric maxLen) {
        return isSimpleValue(v) && len(trim(v)) && len(trim(v)) <= maxLen;
    }

    // Checks a full record. Returns an array of problems (empty = valid). Never "fixes" bad input.
    function validate(required struct m) {
        var e = [];
        if (!isText(m.nama, 100))                                         e.append("nama: required, max 100 characters.");
        if (!isSimpleValue(m.no_kp) || !reFind("^\d{6}-\d{2}-\d{4}$", m.no_kp)) e.append("no_kp: must look like 090312-10-5217.");
        if (!isSimpleValue(m.jantina) || !listFind(JANTINA, m.jantina))   e.append("jantina: must be Lelaki or Perempuan.");
        if (!isValid("integer", m.tingkatan) || m.tingkatan < 1 || m.tingkatan > 5) e.append("tingkatan: must be a whole number 1-5.");
        if (!isText(m.kelas, 30))                                         e.append("kelas: required, max 30 characters.");
        if (!isSimpleValue(m.tarikh_lahir) || !reFind("^\d{4}-\d{2}-\d{2}$", m.tarikh_lahir) || !isDate(m.tarikh_lahir))
                                                                          e.append("tarikh_lahir: must be a real date, yyyy-mm-dd.");
        if (!isSimpleValue(m.bangsa) || !listFind(BANGSA, m.bangsa))      e.append("bangsa: must be Melayu, Cina, India or Lain-lain.");
        if (!isText(m.agama, 30))                                         e.append("agama: required, max 30 characters.");
        if (!isNumeric(m.pendapatan_isi_rumah) || m.pendapatan_isi_rumah < 0 || m.pendapatan_isi_rumah > 99999999.99)
                                                                          e.append("pendapatan_isi_rumah: must be a number, 0 or more.");
        if (!isValid("integer", m.bilangan_adik_beradik) || m.bilangan_adik_beradik < 0 || m.bilangan_adik_beradik > 30)
                                                                          e.append("bilangan_adik_beradik: must be a whole number 0-30.");
        return e;
    }

    function unknownKeys(required struct b) {
        var bad = [];
        for (var k in arguments.b) if (!listFindNoCase(FIELDS, k)) bad.append(k);
        return bad;
    }

    function params(required struct m) {
        return {
            nama                  : { value: trim(m.nama),             cfsqltype: "cf_sql_varchar" },
            no_kp                 : { value: trim(m.no_kp),            cfsqltype: "cf_sql_varchar" },
            jantina               : { value: m.jantina,                cfsqltype: "cf_sql_varchar" },
            tingkatan             : { value: m.tingkatan,              cfsqltype: "cf_sql_integer" },
            kelas                 : { value: trim(m.kelas),            cfsqltype: "cf_sql_varchar" },
            tarikh_lahir          : { value: m.tarikh_lahir,           cfsqltype: "cf_sql_date"    },
            bangsa                : { value: m.bangsa,                 cfsqltype: "cf_sql_varchar" },
            agama                 : { value: trim(m.agama),            cfsqltype: "cf_sql_varchar" },
            pendapatan_isi_rumah  : { value: m.pendapatan_isi_rumah,   cfsqltype: "cf_sql_decimal", scale: 2 },
            bilangan_adik_beradik : { value: m.bilangan_adik_beradik,  cfsqltype: "cf_sql_integer" }
        };
    }

    function isDuplicate(e) {
        return findNoCase("ORA-00001", e.message & " " & e.detail) > 0;
    }

    // ---- the request -----------------------------------------------------

    function handle() {
        if (!keyIsValid()) return out(401, { "error": "Missing or wrong API key." });

        var method = ucase(cgi.request_method);
        var hasId  = structKeyExists(url, "id") && len(url.id);
        if (hasId && (!isValid("integer", url.id) || url.id < 1)) return out(400, { "error": "id must be a whole number above 0." });

        // GET one / GET list (optional filters: ?tingkatan=5  ?q=part of a name)
        if (method == "GET") {
            if (hasId) {
                var one = findOne(url.id);
                return one.recordCount ? out(200, { "data": toRow(one) }) : out(404, { "error": "Not found." });
            }
            var sql = "SELECT #COLUMNS# FROM murid WHERE 1 = 1";
            var p   = {};
            if (structKeyExists(url, "tingkatan") && len(url.tingkatan)) {
                if (!isValid("integer", url.tingkatan) || url.tingkatan < 1 || url.tingkatan > 5) return out(400, { "error": "tingkatan filter must be 1-5." });
                sql &= " AND tingkatan = :tingkatan";
                p.tingkatan = { value: url.tingkatan, cfsqltype: "cf_sql_integer" };
            }
            if (structKeyExists(url, "q") && len(trim(url.q))) {
                sql &= " AND LOWER(nama) LIKE :q";
                p.q = { value: "%" & lcase(trim(url.q)) & "%", cfsqltype: "cf_sql_varchar" };
            }
            var all  = queryExecute(sql & " ORDER BY tingkatan, kelas, nama", p);
            var rows = [];
            for (var r = 1; r <= all.recordCount; r++) rows.append(toRow(all, r));
            return out(200, { "data": rows });
        }

        // POST - create
        if (method == "POST") {
            var b   = readBody();
            var bad = unknownKeys(b);
            if (bad.len()) return out(400, { "error": "Unknown field(s): " & bad.toList(", ") });
            var m = { nama: "", no_kp: "", jantina: "", tingkatan: "", kelas: "", tarikh_lahir: "",
                      bangsa: "Melayu", agama: "", pendapatan_isi_rumah: 0, bilangan_adik_beradik: 0 };
            m.append(b, true);
            var errs = validate(m);
            if (errs.len()) return out(400, { "error": errs.toList(" ") });

            var newId = queryExecute("SELECT murid_seq.NEXTVAL AS id FROM dual").id;
            var ps    = params(m);
            ps.id     = { value: newId, cfsqltype: "cf_sql_integer" };
            try {
                queryExecute(
                    "INSERT INTO murid (id, nama, no_kp, jantina, tingkatan, kelas, tarikh_lahir, bangsa, agama, pendapatan_isi_rumah, bilangan_adik_beradik)
                     VALUES (:id, :nama, :no_kp, :jantina, :tingkatan, :kelas, :tarikh_lahir, :bangsa, :agama, :pendapatan_isi_rumah, :bilangan_adik_beradik)",
                    ps
                );
            } catch (database e) {
                if (isDuplicate(e)) return out(400, { "error": "no_kp already exists." });
                rethrow;
            }
            return out(201, { "data": toRow(findOne(newId)) });
        }

        // PUT - update (send only the fields you want to change)
        if (method == "PUT") {
            if (!hasId) return out(400, { "error": "id required, e.g. murid.cfm?id=3" });
            var cur = findOne(url.id);
            if (!cur.recordCount) return out(404, { "error": "Not found." });
            var b2   = readBody();
            var bad2 = unknownKeys(b2);
            if (bad2.len()) return out(400, { "error": "Unknown field(s): " & bad2.toList(", ") });
            if (!b2.count()) return out(400, { "error": "Send at least one field to change." });
            var m2 = toRow(cur);
            structDelete(m2, "id");
            m2.append(b2, true);
            var errs2 = validate(m2);
            if (errs2.len()) return out(400, { "error": errs2.toList(" ") });

            var ps2 = params(m2);
            ps2.id  = { value: url.id, cfsqltype: "cf_sql_integer" };
            try {
                queryExecute(
                    "UPDATE murid SET nama = :nama, no_kp = :no_kp, jantina = :jantina, tingkatan = :tingkatan,
                            kelas = :kelas, tarikh_lahir = :tarikh_lahir, bangsa = :bangsa, agama = :agama,
                            pendapatan_isi_rumah = :pendapatan_isi_rumah, bilangan_adik_beradik = :bilangan_adik_beradik
                     WHERE id = :id",
                    ps2
                );
            } catch (database e) {
                if (isDuplicate(e)) return out(400, { "error": "no_kp already exists." });
                rethrow;
            }
            return out(200, { "data": toRow(findOne(url.id)) });
        }

        // DELETE - one row by id (the MCP tool asks for confirmation before calling this)
        if (method == "DELETE") {
            if (!hasId) return out(400, { "error": "id required, e.g. murid.cfm?id=3" });
            if (!findOne(url.id).recordCount) return out(404, { "error": "Not found." });
            queryExecute("DELETE FROM murid WHERE id = :id", { id: { value: url.id, cfsqltype: "cf_sql_integer" } });
            return out(200, { "deleted": true, "id": javaCast("int", val(url.id)) });
        }

        return out(405, { "error": "Method #method# not supported." });
    }

    // Run it. Any unexpected failure becomes a short, safe message - never SQL or a stack trace.
    try {
        res = handle();
    } catch (any e) {
        if (e.type == "BadBody" || findNoCase("JSON", e.message)) {
            res = out(400, { "error": "Body must be a JSON object." });
        } else {
            writeLog(file = "murid-api", type = "error", text = e.message & " " & e.detail);
            res = out(500, { "error": "Server error. The details are in the ColdFusion log murid-api.log." });
        }
    }

    cfheader(name = "Content-Type", value = "application/json; charset=utf-8");
    cfheader(statusCode = res.status);
    writeOutput(serializeJSON(res.body));
</cfscript>
