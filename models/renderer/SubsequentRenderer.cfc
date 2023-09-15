component extends="BaseRenderer" {

	/**
	 * A beautiful start.
	 */
	function start( parent, parentCFCPath ){
		setIsInitialRendering( false );
		return super.start( argumentCollection = arguments );
	}

	/**
	 * Hydrates the incoming component with state from our request.
	 *
	 * @return Component
	 */
	function hydrate(){
		getConcern( "Hydrate" ).handle( comp = this );
		return this;
	}

	/**
	 * Emits a global event from our cbwire component.
	 *
	 * @eventName String | The name of our event to emit.
	 */
	function emit( required eventName, parameters ){
		arguments.comp = this;
		return getConcern( "Emit" ).handle( argumentCollection = arguments );
	}

	/**
	 * Emits an event that is scoped to just the current cbwire component.
	 *
	 * Additional parameters can be passed through.

	 * @eventName String | The name of our event to emit.
	 *
	 * @return Void
	 */
	function emitSelf( required eventName, parameters ){
		arguments.comp = this;
		return getConcern( "EmitSelf" ).handle( argumentCollection = arguments );
	}

	/**
	 * Emits an event that is scoped to parents and not children or sibling components.
	 *
	 * Additional parameters can be passed through.
	 * @eventName String | The name of our event to emit.
	 *
	 * @return Void
	 */
	function emitUp( required eventName, parameters ){
		arguments.comp = this;
		return getConcern( "EmitUp" ).handle( argumentCollection = arguments );
	}

	/**
	 * Emits an event that is scoped to only a specific component.
	 *
	 * Additional parameters can be passed through.
	 * @eventName String | The name of our event to emit.
	 *
	 * @return Void
	 */
	function emitTo( required componentName, required eventName, parameters ){
		arguments.comp = this;
		return getConcern( "EmitTo" ).handle( argumentCollection = arguments );
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
		return hasServerMemo() && isStruct( getServerMemoChildren() ) && len(
			structKeyList( getCollection().serverMemo.children )
		);
	}

	/**
	 * Returns children in server memo
	 */
	function getServerMemoChildren(){
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

	/**
	 * Invokes renderIt() on the cbwire component and caches the rendered
	 * results into variables.rendering.
	 *
	 * @return String
	 */
	function subsequentRenderIt(){
		setIsInitialRendering( false );
		var rendering = getNoRendering() ? "" : renderIt();

		// Ensure that comments are removed otherwise it will cause rendering issues
		rendering = reReplaceNoCase( rendering, "<!--.+-->", "", "all" );

		var memento = {
			"effects" : {
				"html" : !len( rendering ) ? javaCast( "null", 0 ) : rendering,
				"dirty" : getDirtyProperties(),
				"emits" : getEmittedEvents(),
				"redirect" : !isNull( getRedirectTo() ) ? getRedirectTo() : javacast( "null", 0 )
			},
			"serverMemo" : {
				"children": getChildren( rendering ),
				"data" : getState( includeComputed = false ),
				"checksum" : generateChecksum()
			}
		}

		if ( !getFinishedUpload() ) {
			memento.effects[ "path" ] = getPath();
			memento.serverMemo[ "htmlHash" ] = generateHash( rendering );
		}

		return memento;
	}

}
