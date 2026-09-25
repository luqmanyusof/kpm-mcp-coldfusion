<cfset pageTitle = "Tambah Murid">

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

<cfif cgi.request_method EQ "POST">
    <cfif NOT len(trim(form.nama))>      <cfset errors.append("Nama wajib diisi.")></cfif>
    <cfif NOT len(trim(form.no_kp))>     <cfset errors.append("No. KP wajib diisi.")></cfif>
    <cfif NOT len(form.jantina)>         <cfset errors.append("Sila pilih jantina.")></cfif>
    <cfif NOT isNumeric(form.tingkatan)> <cfset errors.append("Tingkatan tidak sah.")></cfif>
    <cfif NOT len(trim(form.kelas))>     <cfset errors.append("Kelas wajib diisi.")></cfif>
    <cfif NOT isDate(form.tarikh_lahir)> <cfset errors.append("Tarikh lahir tidak sah (YYYY-MM-DD).")></cfif>

    <cfif arrayLen(errors) EQ 0>
        <cfquery datasource="cf_test_crud">
            INSERT INTO murid (nama, no_kp, jantina, tingkatan, kelas, tarikh_lahir,
                               bangsa, agama, pendapatan_isi_rumah, bilangan_adik_beradik)
            VALUES (
                <cfqueryparam value="#trim(form.nama)#"                 cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#trim(form.no_kp)#"                cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.jantina#"                    cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.tingkatan#"                  cfsqltype="cf_sql_integer">,
                <cfqueryparam value="#trim(form.kelas)#"                cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#form.tarikh_lahir#"               cfsqltype="cf_sql_date">,
                <cfqueryparam value="#form.bangsa#"                     cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#trim(form.agama)#"                cfsqltype="cf_sql_varchar">,
                <cfqueryparam value="#val(form.pendapatan_isi_rumah)#"  cfsqltype="cf_sql_decimal">,
                <cfqueryparam value="#val(form.bilangan_adik_beradik)#" cfsqltype="cf_sql_integer">
            )
        </cfquery>
        <cflocation url="list.cfm?msg=created" addtoken="false">
    </cfif>
</cfif>

<cfinclude template="includes/_header.cfm">
<h1 class="h3">Tambah Murid <small class="text-muted">(Create)</small></h1>

<cfif arrayLen(errors)>
    <div class="alert alert-danger"><cfoutput><cfloop array="#errors#" item="e">#e#<br></cfloop></cfoutput></div>
</cfif>

<cfset formAction  = "/create.cfm">
<cfset submitLabel = "Simpan Murid">
<cfinclude template="_form_fields.cfm">
<cfinclude template="includes/_footer.cfm">
