<cfscript>  
    /**
    * Returns the styles to be placed in HTML head
    */
    function wireStyles() {
        return getInstance( "cbwire.models.WireHTML" ).getStyles();
    }

    /**
    * Returns the JS to be placed in HTML body
    */
    function wireScripts() {
        return getInstance( "cbwire.models.WireHTML" ).getScripts();
    }

    /**
    * Renders a wire component.
    */
    function wire() {
        return getInstance( "cbwire.models.WireRequest" ).renderIt( argumentCollection=arguments );
    }
</cfscript>
