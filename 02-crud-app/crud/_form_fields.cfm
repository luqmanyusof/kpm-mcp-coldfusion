<!--- Shared form for create.cfm + edit.cfm. Caller sets form.*, formAction, submitLabel. --->
<cfparam name="submitLabel" default="Simpan">
<cfparam name="formAction"  default="#cgi.script_name#">

<cfoutput>
<form method="post" action="#formAction#" class="row g-3" style="max-width:520px">

    <div class="col-12">
        <label class="form-label">Nama Penuh *</label>
        <input class="form-control" name="nama" value="#encodeForHTMLAttribute(form.nama)#" required>
    </div>
    <div class="col-md-6">
        <label class="form-label">No. KP * <span class="text-muted">(090312-10-5217)</span></label>
        <input class="form-control" name="no_kp" value="#encodeForHTMLAttribute(form.no_kp)#" required>
    </div>
    <div class="col-md-6">
        <label class="form-label">Jantina *</label>
        <select class="form-select" name="jantina" required>
            <option value="">-- Pilih --</option>
            <option value="Lelaki"    <cfif form.jantina EQ "Lelaki">selected</cfif>>Lelaki</option>
            <option value="Perempuan" <cfif form.jantina EQ "Perempuan">selected</cfif>>Perempuan</option>
        </select>
    </div>
    <div class="col-md-6">
        <label class="form-label">Tingkatan *</label>
        <select class="form-select" name="tingkatan" required>
            <option value="">-- Pilih --</option>
            <cfloop index="t" from="1" to="5"><option value="#t#" <cfif form.tingkatan EQ t>selected</cfif>>Tingkatan #t#</option></cfloop>
        </select>
    </div>
    <div class="col-md-6">
        <label class="form-label">Kelas *</label>
        <input class="form-control" name="kelas" value="#encodeForHTMLAttribute(form.kelas)#" required>
    </div>
    <div class="col-md-6">
        <label class="form-label">Tarikh Lahir * <span class="text-muted">(YYYY-MM-DD)</span></label>
        <input class="form-control" name="tarikh_lahir" value="#encodeForHTMLAttribute(form.tarikh_lahir)#" required>
    </div>
    <div class="col-md-6">
        <label class="form-label">Bangsa</label>
        <select class="form-select" name="bangsa">
            <cfloop array="#['Melayu','Cina','India','Lain-lain']#" item="b"><option value="#b#" <cfif form.bangsa EQ b>selected</cfif>>#b#</option></cfloop>
        </select>
    </div>
    <div class="col-md-6">
        <label class="form-label">Agama</label>
        <input class="form-control" name="agama" value="#encodeForHTMLAttribute(form.agama)#">
    </div>
    <div class="col-md-6">
        <label class="form-label">Pendapatan Isi Rumah (RM)</label>
        <input type="number" step="0.01" min="0" class="form-control" name="pendapatan_isi_rumah" value="#encodeForHTMLAttribute(form.pendapatan_isi_rumah)#">
    </div>
    <div class="col-md-6">
        <label class="form-label">Bilangan Adik-Beradik</label>
        <input type="number" min="0" class="form-control" name="bilangan_adik_beradik" value="#encodeForHTMLAttribute(form.bilangan_adik_beradik)#">
    </div>

    <div class="col-12 d-flex gap-2">
        <button type="submit" class="btn btn-primary">#encodeForHTML(submitLabel)#</button>
        <a class="btn btn-outline-secondary" href="list.cfm">Batal</a>
    </div>
</form>
</cfoutput>
