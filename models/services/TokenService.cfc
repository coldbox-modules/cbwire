/**
 * CBWIRE-specific token service for preventing CSRF attacks
 * without interfering with cbcsrf module settings.
 *
 * Delegates storage operations to a configurable ICSRFStorage implementation.
 *
 * @author Ortus Solutions
 */
component accessors="true" singleton {

    property name="moduleSettings" inject="coldbox:modulesettings:cbwire";
    property name="wirebox" inject="wirebox";

    /**
     * Lazy-loaded CSRF storage service
     */
    variables.csrfService = "";

    /**
     * Cache for application metadata to avoid repeated lookups
     */
    variables.appMetadata = {};

    /**
     * Generates a CBWIRE-specific token that doesn't expire.
     * Stored using the configured storage implementation and lasts for session lifetime.
     *
     * @return The generated or existing token
     */
    function generate() {
        // If we don't have a token yet, generate one
        if ( !getCSRFService().exists() ) {
            var newToken = generateNewToken();
            getCSRFService().set( newToken );
        }

        return getCSRFService().get();
    }

    /**
     * Verifies a CBWIRE token
     *
     * @token The token to verify
     *
     * @return True if valid, false otherwise
     */
    function verify( required string token ) {
        // Verify token exists and matches
        return getCSRFService().exists() && getCSRFService().get() == arguments.token;
    }

    /**
     * Rotates the token (for logout, etc)
     *
     * @return TokenService instance for chaining
     */
    function rotate() {
        getCSRFService().delete();
        return this;
    }

    // Private methods

    /**
     * Lazy-loads the CSRF storage service based on module settings
     *
     * @return The configured ICSRFStorage implementation
     */
    private function getCSRFService() {
        if ( !isObject( variables.csrfService ) ) {
            variables.csrfService = wirebox.getInstance( moduleSettings.csrfService );
        }
        return variables.csrfService;
    }

    private function generateNewToken() {
        // Generate a cryptographically secure random token
        var tokenBase = "#createUUID()##getRealIP()##randRange( 0, 65535, "SHA1PRNG" )##getTickCount()#";
        
        // Include session ID if sessions are enabled (cross-platform check)
        var sessionId = "";
        if ( isSessionManagementEnabled() ) {
            try {
                sessionId = session.sessionid;
            } catch ( any e ) {
                // Handle cases where session scope exists but sessionid property is not yet available,
                // or when session operations fail during application startup
            }
        }
        
        return uCase( left( hash( tokenBase & sessionId, "SHA-256" ), 40 ) );
    }

    /**
     * Checks if session management is enabled in the application (cross-platform)
     *
     * @return True if session management is enabled, false otherwise
     */
    private function isSessionManagementEnabled() {
        if ( !structCount( variables.appMetadata ) ) {
            variables.appMetadata = getApplicationMetadata();
        }
        return structKeyExists( variables.appMetadata, "sessionManagement" ) && variables.appMetadata.sessionManagement;
    }

    private function getRealIP() {
        var headers = getHTTPRequestData().headers;

        if ( structKeyExists( headers, "x-cluster-client-ip" ) ) {
            return headers[ "x-cluster-client-ip" ];
        }
        if ( structKeyExists( headers, "X-Forwarded-For" ) ) {
            return headers[ "X-Forwarded-For" ];
        }

        return len( CGI.REMOTE_ADDR ) ? CGI.REMOTE_ADDR : "127.0.0.1";
    }
}
