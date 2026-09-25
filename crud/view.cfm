<cfset pageTitle = "Butiran Murid">
<cfinclude template="includes/_header.cfm">
<cfparam name="url.id" default="0">

<cfquery name="murid" datasource="cf_test_crud">
    SELECT id, nama, no_kp, jantina, tingkatan, kelas, tarikh_lahir,
           bangsa, agama, pendapatan_isi_rumah, bilangan_adik_beradik
    FROM murid WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
</cfquery>

<cfif murid.recordCount EQ 0>
    <div class="alert alert-danger">Tiada murid dengan ID <cfoutput>#encodeForHTML(url.id)#</cfoutput>.</div>
    <a class="btn btn-primary" href="list.cfm"><- Senarai</a>
    <cfinclude template="includes/_footer.cfm"><cfabort>
</cfif>

<cfoutput>
    <h1 class="h3">#encodeForHTML(murid.nama)#</h1>
    <p class="text-muted">ID ###murid.id#</p>
    <table class="table">
        <tr><th style="width:220px">No. KP</th><td>#murid.no_kp#</td></tr>
        <tr><th>Jantina</th><td>#murid.jantina#</td></tr>
        <tr><th>Tingkatan &amp; Kelas</th><td>Tingkatan #murid.tingkatan# #encodeForHTML(murid.kelas)#</td></tr>
        <tr><th>Tarikh Lahir</th><td>#dateFormat(murid.tarikh_lahir, "dd mmmm yyyy")#</td></tr>
        <tr><th>Bangsa</th><td>#murid.bangsa#</td></tr>
        <tr><th>Agama</th><td>#encodeForHTML(murid.agama)#</td></tr>
        <tr><th>Pendapatan Isi Rumah</th><td>RM #numberFormat(murid.pendapatan_isi_rumah, "9,999.00")#</td></tr>
        <tr><th>Bilangan Adik-Beradik</th><td>#murid.bilangan_adik_beradik#</td></tr>
    </table>
    <div class="d-flex gap-2">
        <a class="btn btn-outline-secondary" href="list.cfm"><- Senarai</a>
        <a class="btn btn-primary" href="edit.cfm?id=#murid.id#">Edit</a>
        <a class="btn btn-danger" href="delete.cfm?id=#murid.id#">Padam</a>
    </div>
</cfoutput>

<cfinclude template="includes/_footer.cfm">
