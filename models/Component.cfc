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
				"id"     : "#this.$getID()#",
				"name"   : "#this.$getMeta().name#",
				"locale" : "en",
				"path"   : "#this.$getPath()#",
				"method" : "GET"
			},
			"effects"    : { "listeners" : this.$getListenerNames() },
			"serverMemo" : {
				"children" 		: [],
				"errors"   		: [],
				"htmlHash" 		: arguments.renderingHash,
				"data"     		: this.$getState(),
				"dataMeta" 		: [],
				"checksum" 		: this.$getChecksum(),
				"mountedState" : this.$getMountedState()
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
				"path": "http://127.0.0.1:60299/_tests/usingSet?yoyo=true"
			},
			"serverMemo" : {
				"htmlHash" 		: "71146cf2",
				"data"     		: this.$getState(),
				"checksum" 		: this.$getChecksum(),
				"mountedState"  : this.$getMountedState()
			}
		}
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
	 * Renders our component's view and returns the HTML
	 * 
	 * @return String
	 */
	function $renderView() {
		// Pass the properties of the cbLivewire component as variables to the view
		arguments.args = this.$getState();

		var rendering = variables.$renderer.renderView( argumentCollection = arguments );

		var renderingHash = hash( rendering );

		// Add livewire properties to top element to make livewire actually work
		// We will need to make this work with more than just <div>s of course
		if ( variables.$isInitialRendering ) {
			rendering = rendering.replaceNoCase(
				"<div",
				"<div wire:id=""#this.$getId()#"" wire:initial-data=""#serializeJSON( this.$getInitialData( renderingHash=renderingHash ) ).replace( """", "&quot;", "all" )#""",
				"once"
			);
		} else {
			rendering = rendering.replaceNoCase(
				"<div",
				"<div wire:id=""#this.$getId()#""",
				"once"
			);
		}

		return rendering;
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
				memento : arguments.parameters,
				excludes : ""
			);
		}

		// Capture our current 
		variables.$mountedState = duplicate( $getState() );

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
	 * @propertyName String | Name of the property we are setting
	 * @value Any | Value of the property we are settting
	 * 
	 * @return Void
	 */
	function $set( propertyName, value ) {
		if ( structKeyExists( this, "set#arguments.propertyName#" ) ){
			this[ "set#arguments.propertyName#" ]( arguments.value );
		} else {
			variables[ propertyName ] = value;
		}
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

		var queryStringValues = this.$getQueryStringValues();

		if ( len( queryStringValues ) ){
			return "#cgi.http_host#?#queryStringValues#";
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
			this.$set( property, this.$getMountedState()[ property ] );
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
		if ( !structKeyExists( variables, "queryString" ) ){
			return [];
		}

		var currentState = this.$getState();

		// Handle array of property names
		if ( isArray( variables.queryString ) ){
			var result = variables.queryString.reduce( function( agg, prop ){
				agg &= prop & "=" & currentState[ prop ];
				return agg;
			}, "" );
		} else {
			writeDump( variables.queryString );
			abort;
		}

		return result;
	}

	/**
	 * Returns true if listeners are detected on the component.
	 * 
	 * @return Boolean
	 */
	function $hasListeners(){
		return arrayLen( this.$getListenerNames() );
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

	function $emit( required eventName ){

		var listeners = this.$getListeners();

		if ( !structKeyExists( listeners, arguments.eventName )){
			throw( message="Couldn't find a listener definition for '#listener#'." );
		}

		var listener = this.$getListeners()[ eventName ];

        if ( len( arguments.eventName ) && this.$hasMethod( listener )){
            return this[ listener ]();
        }

        throw( message="Couldn't find a listener definition for '#listener#'." );
	}

	/**
	 * Returns the names of the listeners defined on our component.
	 * 
	 * @return Array
	 */
	private function $getListenerNames(){
		return structKeyList( this.$getListeners() ).listToArray();
	}
}
