/**
 * Interface for CSRF token storage implementations in cbwire.
 *
 * Implementations must provide thread-safe storage and retrieval
 * of CSRF tokens with session-lifetime persistence.
 *
 * @author Ortus Solutions
 */
interface {

    /**
     * Stores a CSRF token for the current session/user context.
     *
     * @token The CSRF token to store
     *
     * @return The storage implementation instance (for method chaining)
     */
    any function set( required string token );

    /**
     * Retrieves the stored CSRF token for the current session/user context.
     *
     * @return The stored token, or empty string if no token exists
     */
    string function get();

    /**
     * Checks if a CSRF token exists in storage for the current session/user context.
     *
     * @return True if a token exists, false otherwise
     */
    boolean function exists();

    /**
     * Removes the CSRF token from storage (used for rotation/logout).
     *
     * @return The storage implementation instance (for method chaining)
     */
    any function delete();

    /**
     * Clears all CSRF-related data from storage.
     * Useful for cleanup or testing scenarios.
     *
     * @return The storage implementation instance (for method chaining)
     */
    any function clear();

}
