/**
 * Session-based CSRF token storage using cbstorages sessionStorage.
 * This is the default storage mechanism for cbwire CSRF tokens.
 *
 * Tokens are stored in the session scope and persist for the session lifetime.
 * Requires this.sessionManagement = true in Application.cfc.
 *
 * @author Ortus Solutions
 */
component
    accessors="true"
    singleton
    implements="cbwire.models.interfaces.ICSRFStorage"
{

    property name="sessionStorage" inject="sessionStorage@cbstorages";

    /**
     * The storage key used for cbwire tokens
     */
    variables.STORAGE_KEY = "_cbwire_token";

    /**
     * Stores a CSRF token in session storage
     *
     * @token The CSRF token to store
     */
    function set( required string token ) {
        sessionStorage.set(
            variables.STORAGE_KEY,
            { "token": arguments.token, "createdAt": now() }
        );
        return this;
    }

    /**
     * Retrieves the stored CSRF token from session
     *
     * @return The stored token, or empty string if none exists
     */
    string function get() {
        var data = sessionStorage.get( variables.STORAGE_KEY, {} );
        return data.keyExists( "token" ) ? data.token : "";
    }

    /**
     * Checks if a token exists in session storage
     */
    boolean function exists() {
        return sessionStorage.exists( variables.STORAGE_KEY ) &&
               len( get() ) > 0;
    }

    /**
     * Removes the token from session storage
     */
    function delete() {
        sessionStorage.delete( variables.STORAGE_KEY );
        return this;
    }

    /**
     * Clears all CSRF data (same as delete for session storage)
     */
    function clear() {
        return delete();
    }

}
