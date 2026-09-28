<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfscript>
    /*
     * REFERENCE SOLUTION for the Day 2 demo. The finished pelajar.cfm looks like this.
     * Try to write pelajar.cfm yourself first (day2.md, Topic 3); use this to compare.
     */

    cfheader(name="Content-Type", value="application/json; charset=utf-8");

    function respond(required any body, numeric status = 200) {
        cfheader(statusCode = arguments.status);
        writeOutput(serializeJSON(arguments.body));
        abort;
    }
    function readBody() {
        var raw = toString(getHttpRequestData().content);
        return len(trim(raw)) ? deserializeJSON(raw) : {};
    }
    function rows(required query q) {
        var a = [];
        for (var r in arguments.q) a.append(r);
        return a;
    }

    ds     = "cf_test_crud";
    method = ucase(cgi.request_method);
    hasId  = structKeyExists(url, "id") && len(url.id);

    switch (method) {

        case "GET":
            if (hasId) {
                one = queryExecute(
                    'SELECT id AS "id", name AS "name", email AS "email" FROM pelajar WHERE id = :id',
                    { id: { value: url.id, cfsqltype: "cf_sql_integer" } },
                    { datasource: ds }
                );
                if (!one.recordCount) respond({ "error": "Not found" }, 404);
                respond(rows(one)[1]);
            }
            all = queryExecute('SELECT id AS "id", name AS "name", email AS "email" FROM pelajar ORDER BY name', {}, { datasource: ds });
            respond({ "data": rows(all) });

        case "POST":
            b = readBody();
            newId = queryExecute("SELECT pelajar_seq.NEXTVAL AS id FROM dual", {}, { datasource: ds }).id;
            queryExecute(
                "INSERT INTO pelajar (id, name, email) VALUES (:id, :name, :email)",
                { id:    { value: newId,   cfsqltype: "cf_sql_integer" },
                  name:  { value: b.name,  cfsqltype: "cf_sql_varchar" },
                  email: { value: b.email, cfsqltype: "cf_sql_varchar" } },
                { datasource: ds }
            );
            created = queryExecute(
                'SELECT id AS "id", name AS "name", email AS "email" FROM pelajar WHERE id = :id',
                { id: { value: newId, cfsqltype: "cf_sql_integer" } },
                { datasource: ds }
            );
            respond(rows(created)[1], 201);

        case "PUT":
            if (!hasId) respond({ "error": "id required" }, 400);
            b = readBody();
            queryExecute(
                "UPDATE pelajar SET name = :name, email = :email WHERE id = :id",
                { name:  { value: b.name,  cfsqltype: "cf_sql_varchar" },
                  email: { value: b.email, cfsqltype: "cf_sql_varchar" },
                  id:    { value: url.id,  cfsqltype: "cf_sql_integer" } },
                { datasource: ds }
            );
            respond({ "updated": true, "id": val(url.id) });

        case "DELETE":
            if (!hasId) respond({ "error": "id required" }, 400);
            queryExecute(
                "DELETE FROM pelajar WHERE id = :id",
                { id: { value: url.id, cfsqltype: "cf_sql_integer" } },
                { datasource: ds }
            );
            respond({ "deleted": true, "id": val(url.id) });

        default:
            respond({ "error": "Method #method# not supported." }, 405);
    }
</cfscript>
