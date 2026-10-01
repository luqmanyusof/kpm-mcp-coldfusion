<cfscript>
    /*
    * API for Student (Murid) Management
    * 
    * Provides RESTful endpoints to manage student records in the 'murid' table.
    * Supports:
    * - GET /api_murid.cfm       : List all students
    * - GET /api_murid.cfm?id=X  : Get a single student by ID
    * - POST /api_murid.cfm     : Create a new student record
    * - PUT /api_murid.cfm?id=X  : Update an existing student record
    * - DELETE /api_murid.cfm?id=X: Remove a student record
    * 
    * Constraints:
    * - Returns JSON responses.
    * - Uses bind parameters for security.
    * - Validates IC (12 digits) and Tingkatan (1-5).
    */
    // Set headers for JSON response

    cfheader(name="Content-Type", value="application/json");

    // Helper function for validation
    function validateStudentInput(input) {
        var allowedFields = ["nama", "no_kp", "jantina", "tingkatan", "kelas", "tarikh_lahir", "bangsa", "agama", "pendapatan_isi_rumah", "bilangan_adik_beradik"];
        
        // 1. Check for unknown fields
        for (var key in input) {
            if (!arrayContains(allowedFields, key)) {
                return { "valid": false, "error": "Unknown field: #key#" };
            }
        }


        // 2. Required fields check
        var requiredFields = ["nama", "no_kp", "jantina", "tingkatan", "kelas"];
        for (var field in requiredFields) {
            if (!structKeyExists(input, field) || len(trim(input[field])) eq 0) {
                return { "valid": false, "error": "Missing required field: #field#" };
            }
        }

        // 3. Tingkatan range check (1-5)
        if (!isNumeric(input.tingkatan) || input.tingkatan lt 1 || input.tingkatan gt 5) {
            return { "valid": false, "error": "Tingkatan must be a number between 1 and 5." };
        }

        // 4. IC format validation (12 digits)
        if (!reFind("^([0-9]{12})$", input.no_kp)) {
            return { "valid": false, "error": "Invalid IC format for no_kp. Please provide exactly 12 digits." };
        }

        return { "valid": true };
    }

    try {
        // Route based on HTTP Method
        method = cgi.request_method;
        
        if (method eq "GET") {
            // Get Single Student
            if (structKeyExists(url, "id")) {
                qStudent = queryExecute(
                    "SELECT id, nama, no_kp, jantina, tingkatan, kelas, tarikh_lahir, bangsa, agama, pendapatan_isi_rumah, bilangan_adik_beradik FROM murid WHERE id = :studentId",
                    { studentId = { value: url.id, cfsqltype: "cf_sql_integer" } },
                    { datasource="cf_test_crud" }
                );

                if (qStudent.recordCount eq 0) {
                    cfheader(statusCode="404", statusText="Not Found");
                    writeOutput(serializeJSON({ "error": "Student record not found." }));
                    cabort;
                }

                local.student = {
                    "id" = qStudent.id[1],
                    "nama" = qStudent.nama[1],
                    "no_kp" = qStudent.no_kp[1],
                    "jantina" = qStudent.jantina[1],
                    "tingkatan" = qStudent.tingkatan[1],
                    "kelas" = qStudent.kelas[1],
                    "tarikh_lahir" = qStudent.tarikh_lahir[1],
                    "bangsa" = qStudent.bangsa[1],
                    "agama" = qStudent.agama[1],
                    "pendapatan_isi_rumah" = qStudent.pendapatan_isi_rumah[1],
                    "bilangan_adik_beradik" = qStudent.bilangan_adik_beradik[1]
                };
                writeOutput(serializeJSON({ "data": local.student }));
            } else {
                // Phase 1: List Students
                qMurid = queryExecute(
                    "SELECT id, nama, no_kp, jantina, tingkatan, kelas, tarikh_lahir, bangsa, agama, pendapatan_isi_rumah, bilangan_adik_beradik FROM murid ORDER BY tingkatan, kelas, nama",
                    {},
                    {datasource="cf_test_crud"}
                );

                local.data = [];
                for (row in qMurid) {
                    local.data.append({
                        "id" = row.id,
                        "nama" = row.nama,
                        "no_kp" = row.no_kp,
                        "jantina" = row.jantina,
                        "tingkatan" = row.tingkatan,
                        "kelas" = row.kelas,
                        "tarikh_lahir" = row.tarikh_lahir,
                        "bangsa" = row.bangsa,
                        "agama" = row.agama,
                        "pendapatan_isi_rumah" = row.pendapatan_isi_rumah,
                        "bilangan_adik_beradik" = row.bilangan_adik_beradik
                    });
                }
                writeOutput(serializeJSON({ "data": local.data }));
            }
        } else if (method eq "POST") {
            // Phase 3: Create Student
            local.rawBody = "";
            try {
                local.rawBody = getHTTPRequestData().content;
            } catch (any e) {
                local.rawBody = "";
            }
            
            if (len(trim(local.rawBody)) eq 0) {
                cfheader(statusCode="400", statusText="Bad Request");
                writeOutput(serializeJSON({ "error": "Empty request body." }));
                cabort;
            }
            
            local.input = deserializeJSON(local.rawBody);
            
            // Phase 6: Robustness Validation
            local.validation = validateStudentInput(local.input);
            if (!local.validation.valid) {
                cfheader(statusCode="400", statusText="Bad Request");
                writeOutput(serializeJSON({ "error": local.validation.error }));
                cabort;
            }
            
            local.finalDate = ""; 
            if (structKeyExists(local.input, "tarikh_lahir") && len(local.input.tarikh_lahir)) {
                try {
                    local.finalDate = parseDateTime(local.input.tarikh_lahir);
                } catch (any dateErr) {
                    cfheader(statusCode="400", statusText="Bad Request");
                    writeOutput(serializeJSON({ "error": "Invalid date format for tarikh_lahir. Please use YYYY-MM-DD." }));
                    cabort;
                }
            }
            
                queryExecute(
                    "INSERT INTO murid (nama, no_kp, jantina, tingkatan, kelas, tarikh_lahir, bangsa, agama, pendapatan_isi_rumah, bilangan_adik_beradik) 
                     VALUES (:nama, :no_kp, :jantina, :tingkatan, :kelas, :tarikh_lahir, :bangsa, :agama, :pendapatan, :bilangan)",
                    {
                        nama = { value: local.input.nama, cfsqltype: "cf_sql_varchar" },
                        no_kp = { value: local.input.no_kp, cfsqltype: "cf_sql_varchar" },
                        jantina = { value: local.input.jantina, cfsqltype: "cf_sql_varchar" },
                        tingkatan = { value: val(local.input.tingkatan), cfsqltype: "cf_sql_integer" },
                        kelas = { value: local.input.kelas, cfsqltype: "cf_sql_varchar" },
                        tarikh_lahir = { value: (len(local.finalDate)) ? local.finalDate : null, cfsqltype: "cf_sql_date" },
                        bangsa = { value: structKeyExists(local.input, "bangsa") ? local.input.bangsa : "", cfsqltype: "cf_sql_varchar" },
                        agama = { value: structKeyExists(local.input, "agama") ? local.input.agama : "", cfsqltype: "cf_sql_varchar" },
                        pendapatan = { value: structKeyExists(local.input, "pendapatan_isi_rumah") ? val(local.input.pendapatan_isi_rumah) : null, cfsqltype: "cf_sql_numeric" },
                        bilangan = { value: structKeyExists(local.input, "bilangan_adik_beradik") ? val(local.input.bilangan_adik_beradik) : null, cfsqltype: "cf_sql_integer" }
                    },
                    { datasource="cf_test_crud" }
                );
            
            cfheader(statusCode="201", statusText="Created");
            writeOutput(serializeJSON({ "message": "Student created successfully." }));
            
        } else if (method eq "PUT") {
            // Phase 4: Update Student
            if (!structKeyExists(url, "id")) {
                cfheader(statusCode="400", statusText="Bad Request");
                writeOutput(serializeJSON({ "error": "Student ID is required for update." }));
                cabort;
            }

            local.rawBody = "";
            try {
                local.rawBody = getHTTPRequestData().content;
            } catch (any e) {
                local.rawBody = "";
            }

            if (len(trim(local.rawBody)) eq 0) {
                cfheader(statusCode="400", statusText="Bad Request");
                writeOutput(serializeJSON({ "error": "Empty request body." }));
                cabort;
            }

            local.input = deserializeJSON(local.rawBody);

            // Check if student exists
            qCheck = queryExecute(
                "SELECT id FROM murid WHERE id = :studentId",
                { studentId = { value: url.id, cfsqltype: "cf_sql_integer" } },
                { datasource="cf_test_crud" }
            );

            if (qCheck.recordCount eq 0) {
                cfheader(statusCode="404", statusText="Not Found");
                writeOutput(serializeJSON({ "error": "Student record not found." }));
                cabort;
            }

            // Phase 6: Robustness Validation
            local.validation = validateStudentInput(local.input);
            if (!local.validation.valid) {
                cfheader(statusCode="400", statusText="Bad Request");
                writeOutput(serializeJSON({ "error": local.validation.error }));
                cabort;
            }

            local.finalDate = ""; 
            if (structKeyExists(local.input, "tarikh_lahir") && len(local.input.tarikh_lahir)) {
                try {
                    local.finalDate = parseDateTime(local.input.tarikh_lahir);
                } catch (any dateErr) {
                    cfheader(statusCode="400", statusText="Bad Request");
                    writeOutput(serializeJSON({ "error": "Invalid date format for tarikh_lahir. Please use YYYY-MM-DD." }));
                    cabort;
                }
            }

                queryExecute(
                    "UPDATE murid SET 
                        nama = :nama, 
                        no_kp = :no_kp, 
                        jantina = :jantina, 
                        tingkatan = :tingkatan, 
                        kelas = :kelas, 
                        tarikh_lahir = :tarikh_lahir, 
                        bangsa = :bangsa, 
                        agama = :agama, 
                        pendapatan_isi_rumah = :pendapatan, 
                        bilangan_adik_beradik = :bilangan 
                     WHERE id = :studentId",
                    {
                        studentId = { value: url.id, cfsqltype: "cf_sql_integer" },
                        nama = { value: local.input.nama, cfsqltype: "cf_sql_varchar" },
                        no_kp = { value: local.input.no_kp, cfsqltype: "cf_sql_varchar" },
                        jantina = { value: local.input.jantina, cfsqltype: "cf_sql_varchar" },
                        tingkatan = { value: val(local.input.tingkatan), cfsqltype: "cf_sql_integer" },
                        kelas = { value: local.input.kelas, cfsqltype: "cf_sql_varchar" },
                        tarikh_lahir = { value: (len(local.finalDate)) ? local.finalDate : null, cfsqltype: "cf_sql_date" },
                        bangsa = { value: structKeyExists(local.input, "bangsa") ? local.input.bangsa : "", cfsqltype: "cf_sql_varchar" },
                        agama = { value: structKeyExists(local.input, "agama") ? local.input.agama : "", cfsqltype: "cf_sql_varchar" },
                        pendapatan = { value: structKeyExists(local.input, "pendapatan_isi_rumah") ? val(local.input.pendapatan_isi_rumah) : null, cfsqltype: "cf_sql_numeric" },
                        bilangan = { value: structKeyExists(local.input, "bilangan_adik_beradik") ? val(local.input.bilangan_adik_beradik) : null, cfsqltype: "cf_sql_integer" }
                    },
                    { datasource="cf_test_crud" }
                );

            cfheader(statusCode="200", statusText="OK");
            writeOutput(serializeJSON({ "message": "Student updated successfully." }));
            
        } else if (method eq "DELETE") {
            // Phase 5: Delete Student
            if (!structKeyExists(url, "id")) {
                cfheader(statusCode="400", statusText="Bad Request");
                writeOutput(serializeJSON({ "error": "Student ID is required for deletion." }));
                cabort;
            }

            // Check if student exists
            qCheck = queryExecute(
                "SELECT id FROM murid WHERE id = :studentId",
                { studentId = { value: url.id, cfsqltype: "cf_sql_integer" } },
                { datasource="cf_test_crud" }
            );

            if (qCheck.recordCount eq 0) {
                cfheader(statusCode="404", statusText="Not Found");
                writeOutput(serializeJSON({ "error": "Student record not found." }));
                cabort;
            }

            queryExecute(
                "DELETE FROM murid WHERE id = :studentId",
                { studentId = { value: url.id, cfsqltype: "cf_sql_integer" } },
                { datasource="cf_test_crud" }
            );

            cfheader(statusCode="200", statusText="OK");
            writeOutput(serializeJSON({ "message": "Student deleted successfully." }));
            
        } else {
            cfheader(statusCode="405", statusText="Method Not Allowed");
            writeOutput(serializeJSON({ "error": "Method not allowed. Only GET, POST, PUT, and DELETE are implemented." }));
        }

    } catch (any e) {
        cfheader(statusCode="500", statusText="Internal Server Error");
        writeOutput(serializeJSON({ "error": "An internal server error occurred: #e.message#" }));
    }
</cfscript>
