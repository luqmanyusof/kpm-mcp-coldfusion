<cfsetting enablecfoutputonly="true" showdebugoutput="false">
<cfscript>
    /*
     * MODULE 04 DEMO - THE TRAINER FILLS THIS IN LIVE.
     *
     * A simple JSON API for the `pelajar` table (id, name, email).
     * Open DEMO.md and paste the snippet for each TODO below, one at a time.
     * The helpers (respond, readBody, rows) are already written for you.
     *
     *   GET    /api/pelajar.cfm         -> list all
     *   GET    /api/pelajar.cfm?id=1    -> one row
     *   POST   /api/pelajar.cfm         -> create   (JSON body: {"name":..,"email":..})
     *   PUT    /api/pelajar.cfm?id=1    -> update   (JSON body: {"name":..,"email":..})
     *   DELETE /api/pelajar.cfm?id=1    -> delete
     */

    cfheader(name="Content-Type", value="application/json; charset=utf-8");

    // --- helpers (already written) ---
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
            // TODO 1 (see DEMO.md): if hasId return one row, else return all rows.
            respond({ "todo": "GET not implemented yet" }, 501);

        case "POST":
            // TODO 2: read the JSON body, INSERT a new pelajar, return the created row.
            respond({ "todo": "POST not implemented yet" }, 501);

        case "PUT":
            // TODO 3: read the JSON body, UPDATE the row with :id.
            respond({ "todo": "PUT not implemented yet" }, 501);

        case "DELETE":
            // TODO 4: DELETE the row with :id.
            respond({ "todo": "DELETE not implemented yet" }, 501);

        default:
            respond({ "error": "Method #method# not supported." }, 405);
    }
</cfscript>
