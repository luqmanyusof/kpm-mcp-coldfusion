<cfparam name="pageTitle" default="CRUD Murid">
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title><cfoutput>#pageTitle#</cfoutput> - CRUD Murid</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
</head>
<body class="bg-light">
    <nav class="navbar navbar-expand navbar-dark bg-dark">
        <div class="container">
            <a class="navbar-brand" href="index.cfm">CRUD Murid</a>
            <div class="navbar-nav">
                <a class="nav-link" href="list.cfm">Senarai</a>
                <a class="nav-link" href="create.cfm">Tambah</a>
            </div>
        </div>
    </nav>
    <main class="container my-4" style="max-width:820px">
