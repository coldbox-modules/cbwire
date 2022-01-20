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
    function wire( required string componentName ) {
        var cbwireManager = getInstance( "CBWireManager@cbwire" );
        arguments[ "cbwireComponent" ] = cbwireManager.getComponentInstance( arguments.componentName );
        return getInstance( "CBWireInstanceRequest@cbwire" ).handle( argumentCollection=arguments );
    }
</cfscript>
