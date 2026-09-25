component {

    this.name = "cf_crud";
    this.applicationTimeout = createTimeSpan(0, 2, 0, 0);
    this.sessionManagement = false;

    /*
     * The datasource "cf_test_crud" is defined once in the ColdFusion Administrator
     * (Data & Services > Data Sources, driver: Oracle). See 00-setup/SETUP.md, step 6.
     * Keeping it there means no database password lives in the code.
     */
    this.datasource = "cf_test_crud";

    public boolean function onApplicationStart() {
        return true;
    }

    public boolean function onRequestStart(required string targetPage) {
        return true;
    }

}
