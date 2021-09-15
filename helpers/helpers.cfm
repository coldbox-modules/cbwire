<cfscript>
    /**
    * Returns the styles to be placed in HTML head
    */
    function wireStyles() {
        return getInstance( "WireHTML@cbwire" ).getStyles();
    }

    /**
    * Returns the JS to be placed in HTML body
    */
    function wireScripts() {
        return getInstance( "WireHTML@cbwire" ).getScripts();
    }

    /**
    * Renders a wire component.
    */
    function wire() {
        return getInstance( "WireRequest@cbwire" ).renderIt( argumentCollection=arguments );
    }
</cfscript>
