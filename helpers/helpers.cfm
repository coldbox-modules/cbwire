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
     * Returns a reference to the LivewireJS entangle method
     * which provides model binding between AlpineJS and CBWIRE.
     */
    function entangle() {
        return getInstance( "CBWIREHTML@cbwire" ).entangle( argumentCollection=arguments );
    }

    /**
	 * Instantiates our cbwire component, mounts it,
	 * and then calls it's internal renderIt() method.
	 *
	 * @componentName String | The name of the component to load.
	 * @parameters Struct | The parameters you want mounted initially.
	 *
	 * @return Component
	 */
    function wire( componentName, parameters = {} ) {
        return getInstance( "CBWireManager@cbwire" )
                   .getComponentInstance( arguments.componentName )
                   ._mount( arguments.parameters )
                   .renderIt();
    }
</cfscript>
