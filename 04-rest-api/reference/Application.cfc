component {

    this.name = "cf_reference_murid_api";
    this.applicationTimeout = createTimeSpan(0, 2, 0, 0);
    this.sessionManagement = false;

    // Keep struct keys exactly as written ("nama", not "NAMA") when turning them into JSON.
    this.serialization.preserveCaseForStructKey = true;

    // Datasource defined once in the ColdFusion Administrator (00-setup/SETUP.md, step 6).
    this.datasource = "cf_test_crud";

}
