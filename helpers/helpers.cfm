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
                   .getEngine()
                   .mount( arguments.parameters )
                   .renderIt();
    }
</cfscript>
