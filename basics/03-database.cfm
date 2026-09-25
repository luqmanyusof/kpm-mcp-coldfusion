<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>Basics 3: Database - CF Learn</title>
</head>
<body>
    <p><a href="index.cfm">Back to 01 - Basics</a></p>
    <h1>3. Connecting to the database</h1>

    <p>
        A <b>datasource</b> is a named database connection. Ours is called
        <code>cf_test_crud</code> and is defined once in the ColdFusion Administrator,
        so every page can use it without repeating any connection details.
    </p>

    <h2>Run a query with cfquery</h2>
    <p>
        <code>&lt;cfquery&gt;</code> sends SQL to the datasource and stores the result in a variable
        (here, <code>pelajar</code>). Each column is then available as <code>pelajar.columnName</code>.
    </p>
    <pre>
&lt;cfquery name="pelajar" datasource="cf_test_crud"&gt;
    SELECT id, name, email FROM pelajar ORDER BY name
&lt;/cfquery&gt;
    </pre>

    <cfquery name="pelajar" datasource="cf_test_crud">
        SELECT id, name, email FROM pelajar ORDER BY name
    </cfquery>

    <h2>Loop the rows with cfoutput query=""</h2>
    <p>
        Give <code>&lt;cfoutput&gt;</code> a <code>query</code> attribute and it repeats its body once
        per row. <code>#pelajar.recordCount#</code> is how many rows came back.
    </p>
    <pre>
&lt;cfoutput query="pelajar"&gt;#pelajar.id# - #pelajar.name# - #pelajar.email#&lt;br&gt;&lt;/cfoutput&gt;
    </pre>

    <p><b>Output:</b> <cfoutput>#pelajar.recordCount#</cfoutput> rows</p>
    <table border="1" cellpadding="6">
        <tr><th>ID</th><th>Name</th><th>Email</th></tr>
        <cfoutput query="pelajar">
            <tr><td>#pelajar.id#</td><td>#encodeForHTML(pelajar.name)#</td><td>#encodeForHTML(pelajar.email)#</td></tr>
        </cfoutput>
    </table>

    <h2>One safety rule: cfqueryparam</h2>
    <p>
        When a query uses a value from the user (like <code>url.id</code>), never paste it straight
        into the SQL. Wrap it so it cannot be abused (SQL injection):
    </p>
    <pre>
&lt;cfquery name="one" datasource="cf_test_crud"&gt;
    SELECT id, name, email FROM pelajar
    WHERE  id = &lt;cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer"&gt;
&lt;/cfquery&gt;
    </pre>

    <p>That is everything you need to read data. 02 (CRUD app) and 04 (REST API) build on it.</p>
    <p><a href="index.cfm">Back to Home</a></p>
</body>
</html>
