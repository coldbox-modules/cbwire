component accessors="true" {

    property name="settings" inject="coldbox:modulesettings:cbwire";

    /**
     * Returns true if trimStringValues is enabled, either globally
     * or for the component.
     *
     * @return boolean
     */
    function trimStringValues() {
        return settings.keyExists( "trimStringValues" ) && settings.trimStringValues == true;
    }

    /**
     * Returns true if normalizeWhitespace is enabled globally.
     *
     * @return boolean
     */
    function normalizeWhitespace() {
        return settings.keyExists( "normalizeWhitespace" ) && settings.normalizeWhitespace == true;
    }

}