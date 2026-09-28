<cfset pageTitle = "Padam Murid">
<cfparam name="url.id" default="0">

<cfif cgi.request_method EQ "POST">
    <cfquery datasource="cf_test_crud">
        DELETE FROM murid WHERE id = <cfqueryparam value="#form.id#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cflocation url="list.cfm?msg=deleted" addtoken="false">
</cfif>

<cfquery name="murid" datasource="cf_test_crud">
    SELECT id, nama, no_kp, tingkatan, kelas FROM murid
    WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfinclude template="includes/_header.cfm">

<cfif murid.recordCount EQ 0>
    <div class="alert alert-danger">Tiada murid dengan ID <cfoutput>#encodeForHTML(url.id)#</cfoutput>.</div>
    <a class="btn btn-primary" href="list.cfm"><- Senarai</a>
    <cfinclude template="includes/_footer.cfm"><cfabort>
</cfif>

<h1 class="h3">Padam Murid <small class="text-muted">(Delete)</small></h1>
<div class="alert alert-danger">Tindakan ini tidak boleh dibatalkan. Anda pasti?</div>

<cfoutput>
    <table class="table">
        <tr><th style="width:160px">ID</th><td>#murid.id#</td></tr>
        <tr><th>Nama</th><td>#encodeForHTML(murid.nama)#</td></tr>
        <tr><th>No. KP</th><td>#murid.no_kp#</td></tr>
    </table>
    <form method="post" action="delete.cfm" class="d-flex gap-2">
        <input type="hidden" name="id" value="#murid.id#">
        <button type="submit" class="btn btn-danger">Ya, padam rekod ini</button>
        <a class="btn btn-outline-secondary" href="list.cfm">Batal</a>
    </form>
</cfoutput>

<cfinclude template="includes/_footer.cfm">
