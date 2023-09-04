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
		var cbwireRequest = getInstance( "CBWireRequest@cbwire" );

        if ( hasFingerprint() ) {
			setID( getFingerPrint()[ "id" ] );
		}

		setBeforeHydrationState( duplicate( getState() ) );

		if ( hasServerMemoData() ) {
			getDataProperties().each( function( key, value ) {
				if ( structKeyExists( getServerMemoData(), key ) ) {
					getDataProperties()[ key ] = getServerMemoData()[ key ];
				}
			} );
		}

		// Check if our request contains a server memo, and if so update our component state.
		if ( hasServerMemo() ) {
			var serverMemo = getServerMemo();

			serverMemo.data.each( function( key, value ){
				if ( !isNull( arguments.value ) && isSimpleValue( arguments.value ) && findNoCase( "cbwire-upload:", arguments.value ) ) {
					var uploadFullReference = duplicate( arguments.value );
					var uuid = replaceNoCase( arguments.value, "cbwire-upload:", "", "once" );
					arguments.value = getController().getWireBox().getInstance( name="FileUpload@cbwire", initArguments={ comp=this, params=[ key, [ uuid  ] ] } );		
				}

				setProperty( arguments.key, isNull( arguments.value ) ? "" : arguments.value );	

				if ( structKeyExists( getParent(), "onHydrate#arguments.key#" ) ) {
					invoke( getParent(), "onHydrate#arguments.key#", {
						data : getDataProperties(),
						computed : getComputedProperties()
					} );
				}
			} );

			if ( hasChildren() ) {
				variables.$children = getChildren();
			}
		}

		if ( structKeyExists( getParent(), "onHydrate" ) ) {
			getParent().onHydrate(
				data=getDataProperties(),
				computed=getComputedProperties()
			);
		}

		// Check if our request contains updates, and if so apply them.
		handleConcern( "ApplyUpdates" );

		return this;
	}

	function handleConcern( concern ) {
		arguments.comp = this;
		return getInstance( arguments.concern & "Concern@cbwire" ).handle( argumentCollection=arguments );
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