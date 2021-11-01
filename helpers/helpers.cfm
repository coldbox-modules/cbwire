<cfscript>
    /**
    * Returns the styles to be placed in HTML head
    */
    function wireStyles() {
        return getInstance( "CBWireHTML@cbwire" ).getStyles();
    }

    /**
    * Returns the JS to be placed in HTML body
    */
    function wireScripts() {
        return getInstance( "CBWireHTML@cbwire" ).getScripts();
    }

    /**
    * Renders a wire component.
    */
    function wire() {
        return getInstance( "CBWireRequest@cbwire" ).renderIt( argumentCollection=arguments );
    }
</cfscript>
