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
     * @name string | The name of the component to load.
     * @params struct | The parameters you want mounted initially. Defaults to an empty struct.
     * @key string | An optional key parameter. Defaults to an empty string.
     * @lazy boolean | An optional lazy parameter.
     * @lazyIsolated boolean | An optional lazyIsolated parameter. Defaults to true.
     *
     * @return An instance of the specified component after rendering.
     */
    function wire(required string name, struct params = {}, string key = "", lazy, boolean lazyIsolated = true ) {
        return getInstance("CBWIREController@cbwire").wire( argumentCollection=arguments );
    }

	/**
	 * A helper function to set up the view arguments and call the generic wire view.
	 * Eliminates the need to manually create a basic view that would usually only contains a
	 * title (optional) and the wire() method call with the appropriate arguments.
	 *
	 * @wireName string | The name of the wire component to render. Required.
	 * @wireParams struct | The parameters to pass to the wire component. Optional, defaults to an empty struct.
	 * @viewArgs struct | Additional arguments to pass to the view. Optional, defaults to an empty struct.
	 * @viewArgs.title string | An optional title to display above the wire component in the view. { "title" : "My Cool Page Title" }
	 * @viewArgs.titleTag string | An optional HTML tag to wrap the title in. Defaults to h1 if title is provided without a titleTag. { "titleTag" : "h2" }
	 *
	 * @return void | Sets the events view to the generic wire view with the appropriate arguments.
	 */
	function wireGenericView( required string wireName, struct wireParams = {}, struct viewArgs={} ) {
		// init event if not available in the current context and scope it to this method
		if( isNull( event ) ){
			var event = wirebox.getInstance( "coldbox:requestContext" );
		}
		// append wire name and params to view args so they can be used in the view
		viewArgs._wireName = wireName;
		viewArgs._wireParams = wireParams;
		event.setView( view = "genericWireView", module="cbwire", args = viewArgs );
	}
</cfscript>
