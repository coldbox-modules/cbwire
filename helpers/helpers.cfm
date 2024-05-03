<cfscript>
    /**
    * Returns the styles to be placed in HTML head
    */
    function wireStyles() {
        return getInstance( "CBWIREController@cbwire" ).getStyles();
    }

    /**
    * Returns the JS to be placed in HTML body
    */
    function wireScripts() {
        return getInstance( "CBWIREController@cbwire" ).getScripts();
    }

    /**
     * Returns a reference to the LivewireJS entangle method
     * which provides model binding between AlpineJS and CBWIRE.
     */
    function entangle() {
        return getInstance( "CBWIREController@cbwire" ).entangle( argumentCollection=arguments );
    }

    /**
     * Instantiates a CBWIRE component, mounts it,
     * and then calls its internal renderIt() method.
     *
     * @param name The name of the component to load.
     * @param params The parameters you want mounted initially. Defaults to an empty struct.
     * @param key An optional key parameter. Defaults to an empty string.
     *
     * @return An instance of the specified component after rendering.
     */
    function wire(required string name, struct params = {}, string key = "") {
        return getInstance("CBWIREController@cbwire").wire( argumentCollection=arguments );
    }
</cfscript>
