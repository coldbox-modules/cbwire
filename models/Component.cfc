/**
 * This is the base object that all cbLivewire components extend for functionality.
 * 
 * Most internal methods and properties here are namespaced with a "$" to avoid collisions
 * with child components. 
 */
component {

	// Injected ColdBox Renderer for rendering operations.
	property name="$renderer" inject="coldbox:renderer";

	// Injected WireBox for dependency injection.
	property name="$wirebox" inject="wirebox";

	// Injected LivewireRequest that's incoming from the browser.
	property name="$livewireRequest" inject="LivewireRequest@cbLivewire";

	// Injected populator.
	property name="$populator" inject="wirebox:populator";

	// Method aliases, mainly for backwards compatability.	
	variables[ "$view" ] = this.$renderView;

	/**
	 * Our beautiful, simple constructor.
	 * 
	 * @return Component
	 */
	function init(){
		variables.$isInitialRendering = true;
		variables.$emits = [];
		return this;
	}

	/**
	 * Returns a 21 character UUID to uniquely identify the component HTML during rendering.
	 * The 21 characters matches Livewire's native implementation.
	 * 
	 * @return String
	 */
	function $getId(){
		return createUUID().replace( "-", "", "all" ).left( 21 );
	}

	/**
	 * Returns the initial data of our component, which is ultimately serialized
	 * to json and return in the view as our component is first rendered.
	 * 
	 * @renderingHash String | Hash of the view rendering. Used to populate serverMemo.htmlHash in struct response.
	 * 
	 * @return Struct
	 */
	function $getInitialData( renderingHash="" ){
		return {
			"fingerprint" : {
				"id"     : this.$getID(),
				"name"   : this.$getMeta().name,
				"locale" : "en",
				"path"   : this.$getPath(),
				"method" : "GET"
			},
			"effects"    : { "listeners" : variables.$getListenerNames() },
			"serverMemo" : {
				"children" 		: [],
				"errors"   		: [],
				"htmlHash" 		: arguments.renderingHash,
				"data"     		: this.$getState(),
				"dataMeta" 		: [],
				"checksum" 		: this.$getChecksum(),
				"mountedState" 	: variables.$getMountedState()
			}
		};
	}

	/**
	 * Returns the memento for our component which holds the current 
	 * state of our component. This is returned on subsequent XHR requests
	 * called by Livewire's JS.
	 * 
	 * @return Struct
	 */
	function $getMemento(){
		return {
			"effects" : {
				"html"  : this.$getRendering(),
				"dirty" : [
					"count" // need to fix
				],
				"path": this.$getPath(),
				"emits": this.$getEmits()
			},
			"serverMemo" : {
				"htmlHash" 		: "71146cf2",
				"data"     		: this.$getState(),
				"checksum" 		: this.$getChecksum(),
				"mountedState"  : variables.$getMountedState()
			}
		}
	}

	/**
	 * Throws an error if $renderIt() is not defined on our child class.
	 * 
	 * @return Void
	 */
	function $renderIt(){
		throw( type="RenderMethodNotFound", message="Couldn't find a $renderIt() method defined on the component '#this.$getMeta().name#'." );
	}

	/**
	 * Invokes $renderIt() on the cbLivewire component and caches the rendered
	 * results into variables.$rendering.
	 * 
	 * @return String
	 */
	function $getRendering(){
		if ( !structKeyExists( variables, "$rendering" ) ){
			variables.$rendering = this.$renderIt();
		}
		return variables.$rendering;
	}

	/**
	 * Returns the checksum hash of our current state.
	 * 
	 * @return String
	 */
	function $getChecksum(){
		return hash( serializeJSON( this.$getState() ) );
	}

	/**
	 * Returns the current state of our component.
	 * 
	 * @return Struct
	 */
	function $getState(){

		var state = variables.filter( function( key, value ){
			return !reFindNoCase( "^(\$|this)", arguments.key ) && !isCustomFunction( arguments.value );
		});

		return state.map( function( key, value ){
			if ( this.$hasMethod( "get" & arguments.key ) ){
				return this[ "get" & arguments.key ]();
			}
			return value;
		} );
	}

	/**
	 * Returns true if the provided method name can be found on our component.
	 *
	 * @methodName String | The method name we are checking.
	 * @return Boolean
	 */
	function $hasMethod( required methodName ) {
		return structKeyExists( this, arguments.methodName );
	}

	/**
	 * This hydrates (re-populates) our component state with
	 * values provided by the incoming LivewireRequest object.
	 * 
	 * @return Component
	 */
	function $hydrate(){
		variables.$isInitialRendering = false;
		variables.$livewireRequest.hydrateComponent( this );
		return this;
	}

	/**
	 * Renders our component's view and returns the rendering.
	 * 
	 * @return String
	 */
	function $renderView() {
		// Pass the properties of the cbLivewire component as variables to the view
		arguments.args = this.$getState();

		// Render our view using coldbox rendering
		var rendering = variables.$renderer.renderView( argumentCollection = arguments );

		// Add livewire properties to top element to make livewire actually work.
		return variables.$applyLivewireAttributesToOuterElement( rendering );
	}

	/**
	 * Fires when the cbLivewire component is initially created.
	 * Looks to see if a $mount() method is defined on our component and if so, invokes it.
	 * 
	 * This method is given the $_ prefix to avoid collision with the $mount method
	 * that can be optionally defined on a cbLivewire component.
	 * 
	 * @parameters Struct of params to bind into the component
	 * 
	 * @return Component
	 */
	function $_mount( parameters = {} ) {

		if ( structKeyExists( this, "$mount" ) && isCustomFunction( this.$mount ) ) {
			this[ "$mount" ](
				parameters = arguments.parameters,
				event = variables.$livewireRequest.getEvent(),
				rc = variables.$livewireRequest.getCollection(),
				prc = variables.$livewireRequest.getPrivateCollection()
			);
		} else {
			//Injecting the state from our passed in parameters
			variables.$populator.populateFromStruct(
				target : this,
	            scope: "variables",
				memento : arguments.parameters,
				excludes : ""
			);
		}

		// Capture the mounted state 
		variables.$mountedState = duplicate( this.$getState() );

		return this;
	}

	/**
	 * Loads the passed parameters into our component's variables scope
	 *
	 * @target The target variable or scope to load into
	 * @parameters The parameters that we want to load into our variables scope
	 * 
	 * @return Void
	 */
	function $loadParameters( required struct target, required struct parameters ) {
		arguments.parameters.each( function( key, value ) {
			arguments.target[ arguments.key ] = arguments.value;
		} );
	}

	/**
	 * Sets an individual property value, first by using a setter
	 * if it exists, and otherwise setting directly to our variables
	 * scope.
	 * 
	 * Fires '$preUpdate[prop]' and '$postUpdate[prop]' events on the cbLivewire component.
	 *
	 * @propertyName String | Name of the property we are setting
	 * @value Any | Value of the property we are settting
	 * 
	 * @return Void
	 */
	function $set( propertyName, value ) {

		// Invoke '$preUpdate[prop]' event
		this.$invoke( "$preUpdate" & arguments.propertyName, arguments.value );

		if ( structKeyExists( this, "set#arguments.propertyName#" ) ){
			this[ "set#arguments.propertyName#" ]( arguments.value );
		} else {
			variables[ propertyName ] = arguments.value;
		}

		// Invoke '$postUpdate[prop]' event
		this.$invoke( "$postUpdate" & arguments.propertyName, arguments.value );
	}

	/**
	 * Returns the URL which is included in the initial data that is rendered
	 * with the view.
	 * 
	 * Inspects the cbLivewire component for properties that should
	 * be included in the path
	 * 
	 * @return String
	 */
	function $getPath(){

		var queryStringValues = variables.$getQueryStringValues();

		if ( len( queryStringValues ) ){

			var referer = variables.$getHTTPReferer();

			// Strip away any queryString parameters from the referer so
			// we don't duplicate them when we append the queryStringValues below. 
			if ( referer contains "?" ){
				referer = listGetAt( referer, 1, "?" );
			}

			return "#referer#?#queryStringValues#";
		}

		// Return empty string by default;
		return "";
	}

	/**
	 * Sets the mounted state for our component for the ability to rollback changes.
	 * 
	 * @state Struct
	 * @return Void
	 */
	function $setMountedState( required state ){
		variables.$mountedState = arguments.state;
	}

	/**
	 * Returns any captured emits that need to be returned
	 *
	 * @return Array
	 */
	function $getEmits(){
		return variables.$emits;
	}

	/**
	 * Resets a property back to it's original state when the component
	 * was initially hydrated.
	 * 
	 * This accepts either a single property or an array of properties
	 * 
	 * @return Void
	 */
	private function $reset( property ){

		if ( isArray( arguments.property ) ){
			// Reset each property in our array individually
			arguments.property.each( function( prop){
				this.reset( prop );
			} );
		} else {
			// Reset individual property
			this.$set( property, variables.$getMountedState()[ property ] );
		}

	}

	/**
	 * Gets our mounted state.
	 *
	 * @return Struct
	 */
	private function $getMountedState(){
		if ( structKeyExists( variables, "$mountedState" ) ){
			return variables.$mountedState;
		}
		return {};
	}

	/**
	 * Redirects/relocates using ColdBox relocation
	 */
	private function $relocate(){
		return $renderer.relocate( argumentCollection=arguments );
	}

	/**
	 * Check if there are properties to be included in our query string
	 * and assembles them together in a single string to be used within a URL.
	 * 
	 * @return String
	 */
	private function $getQueryStringValues(){

		// Default with an empty array
		if ( !structKeyExists( this, "$queryString" ) ){
			return "";
		}

		var currentState = this.$getState();

		// Handle array of property names
		if ( isArray( this.$queryString ) ){
			var result = this.$queryString.reduce( function( agg, prop ){
				agg &= prop & "=" & currentState[ prop ];
				return agg;
			}, "" );
		} else {
			var result = "";
		}

		return result;
	}

	/**
	 * Returns true if listeners are detected on the component.
	 * 
	 * @return Boolean
	 */
	function $hasListeners(){
		return arrayLen( variables.$getListenerNames() );
	}

	/**
	 * Returns the listeners defined on the component.
	 * If no listeners are defined, an empty struct is returned.
	 * 
	 * @return Struct
	 */
	function $getListeners(){
		if ( structKeyExists( this, "$listeners" ) && isStruct( this.$listeners ) ){
			return this.$listeners;
		}
		return {};
	}

	/**
	 * Returns the meta data for this component.
	 * Ensures that we only run this once.
	 * 
	 * @return Struct
	 */
	function $getMeta(){
		if ( !structKeyExists( this, "$meta" ) ){
			this.$meta = getMetaData( this );
		}
		return this.$meta;
	}


	/** 
	 * Invokes a dynamic method on our component. If the method doesn't exist, then it proceeds without error.
	 * Returns whatever the method returns.
	 * Used mainly with lifecycle hooks.
	 * 
	 * @return Any
	 */
	function $invoke( required methodName, value = "" ){
		if ( this.$hasMethod( arguments.methodName ) ){
			return invoke( this, arguments.methodName, [ arguments.value ] );
		}
	}

	/**
	 * Emits a global event from our cbLivewire component.
	 *
	 * @eventName String | The name of our event to emit.
	 * @params Array | The params pass with the emit 
	 */
	function $emit( required eventName ){

		// Capture the emit as we will need to notify the UI in our response
		variables.$trackEmit( argumentCollection=arguments );	

		var listeners = this.$getListeners();

		if ( structKeyExists( listeners, eventName ) ){
			var listener = listeners[ eventName ];

			if ( len( arguments.eventName ) && this.$hasMethod( listener )){
				return this.$invoke( listener );
			}
		}
	}

	/**
	 * Emits a event that is scoped to just the current cbLivewire component.
	 *
	 * Additional parameters can be passed through.

	 * @eventName String | The name of our event to emit.
	 * 
	 * @return Void
	 */
	function $emitSelf( required eventName ){

		arguments.isEmitSelf = true;

		// Capture the emit as we will need to notify the UI in our response
		variables.$trackEmit( argumentCollection=arguments );


	}

	/**
	 * Tracks an emit, which is later returned in our API response and used
	 * by Livewire.
	 * 
	 * @eventName String | The name of our event to emit.
	 * @return Array;
	 */
	private function $trackEmit( required eventName ){
		
		// Duplicate our arguments so that we don't alter them
		var params = duplicate( arguments );

		// Get only the params we want
		params = params.reduce( function( agg, arg ){
			if ( arg != "isEmitSelf" && arg != "eventName" ){
				agg.append( params[ arg ] );
			}
			return agg;
		}, [] );
	
		// Setup our result
		var result = {
			"event": arguments.eventName,
			"params": params
		};
		
		var isEmitSelf = structKeyExists( arguments, "isEmitSelf" ) && arguments.isEmitSelf ? true : false;

		if ( isEmitSelf ){
			// We are tracking a .$emitSelf() call and need to alter our
			// returned result to Livewire.
			result[ "selfOnly" ] = true;
		}

		variables.$emits.append( result );
	}

	/**
	 * Returns the names of the listeners defined on our component.
	 * 
	 * @return Array
	 */
	private function $getListenerNames(){
		return structKeyList( this.$getListeners() ).listToArray();
	}

	/**
	 * Apply livewire attribute to the outer element in the provided rendering.
	 *
	 * @rendering String | The view rendering.
	 */
	private function $applyLivewireAttributesToOuterElement( required rendering ){
		var renderingResult = "";

		// Provide a hash of our rendering which is used by Livewire.js
		var renderingHash = hash( arguments.rendering );

		// Determine our outer element
		var outerElement = variables.$getOuterElement( arguments.rendering );

		// Add livewire properties to top element to make livewire actually work.
		if ( variables.$isInitialRendering ) {
			// Initial rendering
			renderingResult = rendering.replaceNoCase(
				outerElement,
				outerElement & " wire:id=""#this.$getId()#"" wire:initial-data=""#serializeJSON( this.$getInitialData( renderingHash=renderingHash ) ).replace( """", "&quot;", "all" )#""",
				"once"
			);
		} else {
			// Subsequent renderings
			renderingResult = rendering.replaceNoCase(
				outerElement,
				outerElement & " wire:id=""#this.$getId()#""",
				"once"
			);
		}
		
		return renderingResult;
	}

	/**
	 * Determines the outer element within our rendering.
	 * If an outer element isn't found, an error is thrown.
	 *
	 * @rendering String | The view rendering.
	 */
	private function $getOuterElement( required rendering ){
		var matches = reMatchNoCase( "<[a-z]+\s*", arguments.rendering );

		if ( arrayLen( matches ) ){
			return matches[ 1 ];
		}

		throw( type="OuterElementNotFound", message="Unable to find an outer element to bind cbLivewire to." );
	}

	/**
	 * Returns our HTTP referer.
	 * 
	 * @return String
	 */
	private function $getHTTPReferer(){
		return cgi.HTTP_REFERER;
	}
}
