component singleton {

    property name="wirebox" inject="wirebox";
    property name="settings" inject="coldbox:moduleSettings:cbwire";

    /** 
     * Generate a CSRF token.
     * 
     * @return string
     */
    function generate() {
        var csrf = hash( createUUID(), "SHA-256" );
        getCSRFStorage().set( "CBWIRE_CSRF", csrf );
        return csrf;
    }

    /** 
     * Verify a CSRF token.
     * 
     * @token string
     * 
     * @return boolean
     */
    function verify( token ) {
        if ( !getCSRFStorage().exists( "CBWIRE_CSRF" ) ) {
            throw( type="CSRF Expired", message="Page expired" );
        }
        return true;
    }

    /** 
     * Get the CSRF storage object.
     * 
     * @return any
     */
    function getCSRFStorage() {
        return wirebox.getInstance( settings.csrfStorage );
    }
}