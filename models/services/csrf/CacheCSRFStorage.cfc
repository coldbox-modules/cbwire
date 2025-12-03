/**
 * Cache-based CSRF token storage using cbstorages cacheStorage.
 * Suitable for distributed/clustered environments where session replication
 * is not available or desired.
 *
 * Tokens are stored in the configured CacheBox cache provider.
 * Does not require session management to be enabled - uses cookie/URL fallback.
 *
 * @author Ortus Solutions
 */
component
    accessors="true"
    singleton
    implements="cbwire.models.interfaces.ICSRFStorage"
{

    property name="cacheStorage" inject="cacheStorage@cbstorages";

    /**
     * The storage key used for cbwire tokens
     */
    variables.STORAGE_KEY = "_cbwire_token";

    /**
     * Stores a CSRF token in cache storage
     *
     * @token The CSRF token to store
     */
    function set( required string token ) {
        cacheStorage.set(
            variables.STORAGE_KEY,
            { "token": arguments.token, "createdAt": now() }
        );
        return this;
    }

    /**
     * Retrieves the stored CSRF token from cache
     *
     * @return The stored token, or empty string if none exists
     */
    string function get() {
        var data = cacheStorage.get( variables.STORAGE_KEY, {} );
        return data.keyExists( "token" ) ? data.token : "";
    }

    /**
     * Checks if a token exists in cache storage
     */
    boolean function exists() {
        var data = cacheStorage.get( variables.STORAGE_KEY, {} );
        return data.keyExists( "token" ) && len( data.token ) > 0;
    }

    /**
     * Removes the token from cache storage
     */
    function delete() {
        cacheStorage.delete( variables.STORAGE_KEY );
        return this;
    }

    /**
     * Clears all CSRF data (same as delete for cache storage)
     */
    function clear() {
        return delete();
    }

}
