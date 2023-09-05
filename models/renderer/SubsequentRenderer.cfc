component extends="BaseRenderer" {

	/**
	 * A beautiful start.
	 */
	function start( parent, parentCFCPath ) {
        setIsInitialRendering( false );
        return super.start( argumentCollection=arguments );
    }

	/**
	 * Hydrates the incoming component with state from our request.
	 *
	 * @wireRequest CBWireRequest
	 *
	 * @return Component
	 */
	function hydrate(){
		handleConcern( concern="Hydrate" );
		return this;
	}

	/**
	 * Emits a global event from our cbwire component.
	 *
	 * @eventName String | The name of our event to emit.
	 */
	function emit( required eventName ){
		return handleConcern( concern="Emit", eventName=arguments.eventName );
	}

	/**
	 * Emits an event that is scoped to just the current cbwire component.
	 *
	 * Additional parameters can be passed through.

	 * @eventName String | The name of our event to emit.
	 *
	 * @return Void
	 */
	function emitSelf( required eventName ) {
		var parameters = parseEmitArguments( argumentCollection=arguments );

		var emitter = {
			"event" : arguments.eventName,
			"params" : parameters,
			"selfOnly" : true
		};

		// Capture the emit as we will need to notify the UI in our response
		trackEmit( emitter );
	}

	/**
	 * Emits an event that is scoped to parents and not children or sibling components.
	 *
	 * Additional parameters can be passed through.
	 * @eventName String | The name of our event to emit.
	 *
	 * @return Void
	 */
	function emitUp( required eventName ){
		var parameters = parseEmitArguments( argumentCollection=arguments );
		
		var emitter = {
			"event" : arguments.eventName,
			"params" : parameters,
			"ancestorsOnly" : true
		};

		// Capture the emit as we will need to notify the UI in our response
		trackEmit( emitter );
	}

	/**
	 * Emits an event that is scoped to only a specific component.
	 *
	 * Additional parameters can be passed through.
	 * @eventName String | The name of our event to emit.
	 *
	 * @return Void
	 */
	function emitTo( required componentName, required eventName ){
		var parameters = parseEmitArguments( argumentCollection=arguments );

		// Remove the first param since it's our component name.
		parameters.deleteAt( 1 );

		var emitter = {
			"event" : arguments.eventName,
			"params" : parameters,
			"to" : arguments.componentName
		};

		// Capture the emit as we will need to notify the UI in our response
		trackEmit( emitter );
	}

	/**
	 * When called, the component is flagged so that no rendering will occur.
	 *
	 * @return void
	 */
	function noRender(){
		setNoRendering( true );
	}

	/**
	 * Returns true if our request context contains a 'fingerprint' property.
	 *
	 * @return Boolean
	 */
	function hasFingerprint(){
		return structKeyExists( getCollection(), "fingerprint" );
	}


	/**
	 * Returns the serverMemo from our request context.
	 *
	 * @return struct
	 */
	function getServerMemo(){
		return getCollection().serverMemo;
	}

	/**
	 * Returns true if the server memo contains children
	 */
	function hasChildren(){
		return hasServerMemo() && isStruct( getChildren() ) && len(
			structKeyList( getCollection().serverMemo.children )
		);
	}

	/**
	 * Returns children in server memo
	 */
	function getChildren(){
		return getCollection().serverMemo.children;
	}

	/**
	 * Returns the fingerprint for the request.
	 *
	 * @return Struct
	 */
	function getFingerprint(){
		return getCollection().fingerprint;
	}

	/**
	 * Returns true if our server memo contains a data property.
	 *
	 * @return Boolean
	 */
	function hasServerMemoData(){
		return hasServerMemo() && structKeyExists( getServerMemo(), "data" );
	}

	/**
	 * Returns true if our request context contains a 'serverMemo' property.
	 *
	 * @return Boolean
	 */
	function hasServerMemo(){
		return structKeyExists( getCollection(), "serverMemo" );
	}

	/**
	 * Returns our data
	 *
	 * @return Struct
	 */
	function getServerMemoData(){
		return getServerMemo().data;
	}

}