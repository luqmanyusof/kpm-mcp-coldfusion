<cfset pageTitle = "Edit Murid">
<cfparam name="url.id" default="0">

<cfparam name="form.nama"                  default="">
<cfparam name="form.no_kp"                 default="">
<cfparam name="form.jantina"               default="">
<cfparam name="form.tingkatan"             default="">
<cfparam name="form.kelas"                 default="">
<cfparam name="form.tarikh_lahir"          default="">
<cfparam name="form.bangsa"                default="Melayu">
<cfparam name="form.agama"                 default="">
<cfparam name="form.pendapatan_isi_rumah"  default="0">
<cfparam name="form.bilangan_adik_beradik" default="0">
<cfset errors = []>
<cfset notFound = false>

<cfif cgi.request_method EQ "POST">
    <cfif NOT len(trim(form.nama))>      <cfset errors.append("Nama wajib diisi.")></cfif>
    <cfif NOT len(trim(form.no_kp))>     <cfset errors.append("No. KP wajib diisi.")></cfif>
    <cfif NOT len(form.jantina)>         <cfset errors.append("Sila pilih jantina.")></cfif>
    <cfif NOT isNumeric(form.tingkatan)> <cfset errors.append("Tingkatan tidak sah.")></cfif>
    <cfif NOT len(trim(form.kelas))>     <cfset errors.append("Kelas wajib diisi.")></cfif>
    <cfif NOT isDate(form.tarikh_lahir)> <cfset errors.append("Tarikh lahir tidak sah.")></cfif>

    <cfif arrayLen(errors) EQ 0>
        <cfquery datasource="cf_test_crud">
            UPDATE murid SET
                nama                  = <cfqueryparam value="#trim(form.nama)#"                 cfsqltype="cf_sql_varchar">,
                no_kp                 = <cfqueryparam value="#trim(form.no_kp)#"                cfsqltype="cf_sql_varchar">,
                jantina               = <cfqueryparam value="#form.jantina#"                    cfsqltype="cf_sql_varchar">,
                tingkatan             = <cfqueryparam value="#form.tingkatan#"                  cfsqltype="cf_sql_integer">,
                kelas                 = <cfqueryparam value="#trim(form.kelas)#"                cfsqltype="cf_sql_varchar">,
                tarikh_lahir          = <cfqueryparam value="#form.tarikh_lahir#"               cfsqltype="cf_sql_date">,
                bangsa                = <cfqueryparam value="#form.bangsa#"                     cfsqltype="cf_sql_varchar">,
                agama                 = <cfqueryparam value="#trim(form.agama)#"                cfsqltype="cf_sql_varchar">,
                pendapatan_isi_rumah  = <cfqueryparam value="#val(form.pendapatan_isi_rumah)#"  cfsqltype="cf_sql_decimal">,
                bilangan_adik_beradik = <cfqueryparam value="#val(form.bilangan_adik_beradik)#" cfsqltype="cf_sql_integer">
            WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
        </cfquery>
        <cflocation url="list.cfm?msg=updated" addtoken="false">
    </cfif>
<cfelse>
    <cfquery name="rec" datasource="cf_test_crud">
        SELECT nama, no_kp, jantina, tingkatan, kelas, tarikh_lahir,
               bangsa, agama, pendapatan_isi_rumah, bilangan_adik_beradik
        FROM murid WHERE id = <cfqueryparam value="#url.id#" cfsqltype="cf_sql_integer">
    </cfquery>
    <cfif rec.recordCount EQ 0>
        <cfset notFound = true>
    <cfelse>
        <cfloop list="nama,no_kp,jantina,tingkatan,kelas,bangsa,agama,pendapatan_isi_rumah,bilangan_adik_beradik" index="c">
            <cfset form[c] = rec[c][1]>
        </cfloop>
        <cfset form.tarikh_lahir = dateFormat(rec.tarikh_lahir, "yyyy-mm-dd")>
    </cfif>
</cfif>

<cfinclude template="includes/_header.cfm">

<cfif notFound>
    <div class="alert alert-danger">Tiada murid dengan ID <cfoutput>#encodeForHTML(url.id)#</cfoutput>.</div>
    <a class="btn btn-primary" href="list.cfm"><- Senarai</a>
    <cfinclude template="includes/_footer.cfm"><cfabort>
</cfif>

<cfoutput><h1 class="h3">Edit Murid ###encodeForHTML(url.id)# <small class="text-muted">(Update)</small></h1></cfoutput>

<cfif arrayLen(errors)>
    <div class="alert alert-danger"><cfoutput><cfloop array="#errors#" item="e">#e#<br></cfloop></cfoutput></div>
</cfif>

<cfset formAction  = "/edit.cfm?id=" & url.id>
<cfset submitLabel = "Kemas Kini">
<cfinclude template="_form_fields.cfm">
<cfinclude template="includes/_footer.cfm">
