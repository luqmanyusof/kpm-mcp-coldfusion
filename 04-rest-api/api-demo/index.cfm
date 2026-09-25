<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <title>API project - CF Learn</title>
</head>
<body>
    <h1>04 - API demo: a simple JSON API</h1>
    <p>
        In this project you write a small JSON API for the <code>pelajar</code> table
        (<code>id</code>, <code>name</code>, <code>email</code>). Follow
        <code>04-rest-api/api-demo/DEMO.md</code> and fill in the four TODOs in <code>pelajar.cfm</code>.
    </p>

    <h2>Endpoints (once you finish)</h2>
    <ul>
        <li>GET <a href="pelajar.cfm">/pelajar.cfm</a> - list all</li>
        <li>GET <a href="pelajar.cfm?id=1">/pelajar.cfm?id=1</a> - one row</li>
        <li>POST /pelajar.cfm - create (JSON body: name, email)</li>
        <li>PUT /pelajar.cfm?id=1 - update</li>
        <li>DELETE /pelajar.cfm?id=1 - delete</li>
    </ul>

    <h2>Files</h2>
    <ul>
        <li><code>pelajar.cfm</code> - you edit this (starts as a skeleton with TODOs).</li>
        <li><code>pelajar.reference.cfm</code> - the finished version, for comparison. Try:
            <a href="pelajar.reference.cfm">/pelajar.reference.cfm</a></li>
    </ul>

    <p>Tip: <code>.cfm</code> edits are picked up on the next request - no server restart needed.</p>
</body>
</html>
