<cfset pageTitle = "Senarai Murid">
<cfinclude template="includes/_header.cfm">
<cfparam name="url.msg" default="">

<div class="d-flex justify-content-between align-items-center">
    <h1 class="h3 mb-0">Senarai Murid <small class="text-muted">(Read)</small></h1>
    <a class="btn btn-primary" href="create.cfm">+ Tambah Murid</a>
</div>

<cfif url.msg NEQ "">
    <cfoutput><div class="alert alert-success py-2 mt-3">
        <cfswitch expression="#url.msg#">
            <cfcase value="created">Rekod berjaya ditambah.</cfcase>
            <cfcase value="updated">Rekod berjaya dikemas kini.</cfcase>
            <cfcase value="deleted">Rekod berjaya dipadam.</cfcase>
            <cfdefaultcase>Selesai.</cfdefaultcase>
        </cfswitch>
    </div></cfoutput>
</cfif>

<cfquery name="murid" datasource="cf_test_crud">
    SELECT id, nama, no_kp, jantina, tingkatan, kelas, bangsa
    FROM murid ORDER BY tingkatan, kelas, nama
</cfquery>

<table class="table table-hover align-middle mt-3">
    <thead><tr><th>ID</th><th>Nama</th><th>No. KP</th><th>Jantina</th><th>Ting.</th><th>Kelas</th><th></th></tr></thead>
    <tbody>
        <cfoutput query="murid">
            <tr>
                <td>#murid.id#</td>
                <td><a href="view.cfm?id=#murid.id#">#encodeForHTML(murid.nama)#</a></td>
                <td>#murid.no_kp#</td>
                <td>#murid.jantina#</td>
                <td>#murid.tingkatan#</td>
                <td>#encodeForHTML(murid.kelas)#</td>
                <td class="text-nowrap">
                    <a class="btn btn-sm btn-outline-secondary" href="edit.cfm?id=#murid.id#">Edit</a>
                    <a class="btn btn-sm btn-outline-danger" href="delete.cfm?id=#murid.id#">Padam</a>
                </td>
            </tr>
        </cfoutput>
    </tbody>
</table>

<cfinclude template="includes/_footer.cfm">
