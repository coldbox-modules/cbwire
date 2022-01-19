/**
 * This is the base object that all cbwire components extend for functionality.
 *
 * Most internal methods and properties here are namespaced with a "$" to avoid collisions
 * with child components.
 */
component {

	// Inject ColdBox Renderer for rendering operations.
	property name="$renderer" inject="coldbox:renderer";

	// Inject WireBox for dependency injection.
	property name="$wirebox" inject="wirebox";

	// Inject the wire request that's incoming from the browser.
	property name="$cbwireRequest" inject="CBWireRequest@cbwire";

	// Inject populator.
	property name="$populator" inject="wirebox:populator";

	// Inject settings.
	property name="$settings" inject="coldbox:modulesettings:cbwire";

	// Inject LogBox.
	property name="logBox" inject="logbox";

	// Inject scoped logger.
	property name="log" inject="logbox:logger:{this}";

	/**
	 * The default data struct for cbwire components.
	 * This should be overidden in the child component
	 * with data properties.
	 */
	variables.data = {};

	/**
	 * The default computed struct for cbwire components.
	 * This should be overidden in the child component with
	 * computed properties.
	 */
	variables.computed = {};

	/**
	 * Our beautiful, simple constructor.
	 *
	 * @return Component
	 */
	function init(){
		variables.$isInitialRendering = false;
		variables.$noRender	          = false;
		variables.$emits              = [];
		variables.$id                 = createUUID().replace( "-", "", "all" ).left( 21 );
		return this;
	}

	include "componentPublicMethods.cfm";

	/**
	 * Relocate user browser requests to other events, URLs, or URIs.
	 *
	 * @event The name of the event to run, if not passed, then it will use the default event found in your configuration file
	 * @URL The full URL you would like to relocate to instead of an event: ex: URL='http://www.google.com'
	 * @URI The relative URI you would like to relocate to instead of an event: ex: URI='/mypath/awesome/here'
	 * @queryString The query string or struct to append, if needed. If in SES mode it will be translated to convention name value pairs
	 * @persist What request collection keys to persist in flash ram
	 * @persistStruct A structure key-value pairs to persist in flash ram
	 * @addToken Wether to add the tokens or not. Default is false
	 * @ssl Whether to relocate in SSL or not
	 * @baseURL Use this baseURL instead of the index.cfm that is used by default. You can use this for ssl or any full base url you would like to use. Ex: https://mysite.com/index.cfm
	 * @postProcessExempt Do not fire the postProcess interceptors
	 * @statusCode The status code to use in the relocation
	 */
	void function $relocate(
		event,
		URL,
		URI,
		queryString,
		persist,
		struct persistStruct,
		boolean addToken,
		boolean ssl,
		baseURL,
		boolean postProcessExempt,
		numeric statusCode
	){
		return variables.$renderer.relocate( argumentCollection = arguments );
	}

	/**
	 * Returns a 21 character UUID to uniquely identify the component HTML during rendering.
	 * The 21 characters matches Livewire JS native implementation.
	 *
	 * @return String
	 */
	function $getID(){
		return variables.$id;
	}

	/**
	 * Returns the initial data of our component, which is ultimately serialized
	 * to json and return in the view as our component is first rendered.
	 *
	 * @renderingHash String | Hash of the view rendering. Used to populate serverMemo.htmlHash in struct response.
	 *
	 * @return Struct
	 */
	function $getInitialData( renderingHash = "" ){
		return {
			"fingerprint" : {
				"id"     : $getID(),
				"name"   : $getMeta().name,
				"locale" : "en",
				"path"   : $getPath(),
				"method" : "GET"
			},
			"effects"    : { 
				"listeners" : $getListenerNames() 
			},
			"serverMemo" : {
				"children"     : [],
				"errors"       : [],
				"htmlHash"     : $getChecksum(),
				"data"         : $getState(),
				"dataMeta"     : [],
				"checksum"     : $getChecksum()
			}
		};
	}

	/**
	 * Renders our component's view.
	 *
	 * @return Void
	 */
	function $renderIt(){

		// If the user has defined their own renderIt() method on the 
		// component, let's call that instead
		if ( structKeyExists( variables, "renderIt" ) ) {
			return variables.renderIt();
		}

		if ( structKeyExists( variables, "view" ) && isValid( "string", variables.view ) && len( variables.view ) ) {
			return renderView( variables.view );
		}

		var componentName = lCase( getMetaData( this ).name );

		return renderView( "wires/#listLast( componentName, "." )#" );
	}

	/**
	 * Invokes $renderIt() on the cbwire component and caches the rendered
	 * results into variables.rendering.
	 *
	 * @return String
	 */
	function $getRendering(){
		if ( !structKeyExists( variables, "rendering" ) ) {
			variables.rendering = $renderIt();
		}
		return variables.rendering;
	}

	/**
	 * Returns the checksum hash of our current state.
	 *
	 * @return String
	 */
	function $getChecksum(){
		return hash( serializeJSON( $getState() ) );
	}

	/**
	 * Returns the current state of our component.
	 *
	 * @includeComputed Boolean | Set to true to include computed properties in the returned state.
	 * @return Struct
	 */
	function $getState( boolean includeComputed = false ){
		/**
		 * Get our data properties for our current state.
		 */
		var state = {};

		variables.data.each( function( key, value ){
			if ( isClosure( arguments.value ) ) {
				// Render the closure and store in our data properties
				variables.data[ key ]  = arguments.value();
				state[ arguments.key ] = variables.data[ key ];
			} else {
				state[ arguments.key ] = arguments.value;
			}
		} );

		if ( arguments.includeComputed && structKeyExists( variables, "computed" ) ) {
			variables.computed.each( function( key, value ){
				state[ key ] = value;
			} );
		}

		return state;
	}

	/**
	 * Returns true if the provided method name can be found on our component.
	 *
	 * @methodName String | The method name we are checking.
	 * @return Boolean
	 */
	function $hasMethod( required methodName ){
		return structKeyExists( this, arguments.methodName );
	}

	/**
	 * Fires when the cbwire component is initially created.
	 * Looks to see if a mount() method is defined on our component and if so, invokes it.
	 *
	 * This method is given the $ prefix to avoid collision with the mount method
	 * that can be optionally defined on a cbwire component.
	 *
	 * @parameters Struct of params to bind into the component
	 *
	 * @return Component
	 */
	function $mount( parameters = {} ){
		variables.$isInitialRendering = true;

		if ( structKeyExists( this, "mount" ) && isCustomFunction( mount ) ) {
			this[ "mount" ](
				parameters = arguments.parameters,
				event      = variables.$cbwireRequest.getEvent(),
				rc         = variables.$cbwireRequest.getCollection(),
				prc        = variables.$cbwireRequest.getPrivateCollection()
			);
		} else {
			/**
			 * Use setter population to populate our component.
			 */
			variables.$populator.populateFromStruct(
				target       : this,
				trustedSetter: true,
				memento      : arguments.parameters,
				excludes     : ""
			);
		}

		return this;
	}

	/**
	 * Hydrates the incoming component with state from our request.
	 *
	 * @wireRequest CBWireRequest
	 *
	 * @return Component
	 */
	function $hydrate( CBWireRequest cbwireRequest ){
		if ( arguments.cbwireRequest.hasFingerprint() ) {
			$setId( arguments.cbwireRequest.getFingerPrint()[ "id" ] );
		}

		// Invoke '$preHydrate' event
		$invokeMethod( "$preHydrate" );

		if ( arguments.cbwireRequest.hasData() ) {
			$setData( arguments.cbwireRequest.getData() );
		}

		// Check if our request contains a server memo, and if so update our component state.
		if ( arguments.cbwireRequest.hasServerMemo() ) {
			arguments.cbwireRequest
				.getServerMemo()
				.data
				.each( function( key, value ){
					// Call the setter method
					$invokeMethod(
						methodName = "set" & arguments.key,
						value      = arguments.value
					);
				} );
		}

		// Invoke '$postHydrate' event
		$invokeMethod( "$postHydrate" );

		// Check if our request contains updates, and if so apply them.
		if ( arguments.cbwireRequest.hasUpdates() ) {
			arguments.cbwireRequest.applyUpdates( this );
		}

		return this;
	}

	/**
	 * Returns the memento for our component which holds the current
	 * state of our component. This is returned on subsequent XHR requests
	 * from cbwire.
	 *
	 * @return Struct
	 */
	function $getMemento( mountedState ){
		return {
			"effects" : {
				"html"  : $getRendering(),
				"dirty" : [
					"count" // need to fix
				],
				"path"  : $getPath(),
				"emits" : $getEmits()
			},
			"serverMemo" : {
				"htmlHash"     : "71146cf2",
				"data"         : $getState( false ),
				"checksum"     : $getChecksum()
			}
		}
	}

	/**
	 * Sets an individual data property value, first by using a setter
	 * if it exists, and otherwise setting directly to our variables
	 * scope.
	 *
	 * Fires '$preUpdate[prop]' and 'postUpdate[prop]' events on the cbwire component.
	 *
	 * @propertyName String | Name of the property we are setting
	 * @value Any | Value of the property we are settting
	 *
	 * @return Void
	 */
	function $set( propertyName, value ){
		// Invoke '$preUpdate[prop]' event
		$invokeMethod(
			methodName   = "preUpdate" & arguments.propertyName,
			propertyName = arguments.value
		);

		variables.data[ "#arguments.propertyName#" ] = arguments.value;

		// Invoke 'postUpdate[prop]' event
		$invokeMethod(
			methodName   = "postUpdate" & arguments.propertyName,
			propertyName = arguments.value
		);
	}

	/**
	 * Returns the URL which is included in the initial data that is rendered
	 * with the view.
	 *
	 * Inspects the cbwire component for properties that should
	 * be included in the path
	 *
	 * @return String
	 */
	function $getPath(){
		var queryStringValues = variables.$getQueryStringValues();

		if ( len( queryStringValues ) ) {
			var referer = variables.$getHTTPReferer();

			// Strip away any queryString parameters from the referer so
			// we don't duplicate them when we append the queryStringValues below.
			if ( referer contains "?" ) {
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
	function $setData( required state ){
		variables.$data = arguments.state;
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
		if ( structKeyExists( variables, "listeners" ) && isStruct( variables.listeners ) ) {
			return variables.listeners;
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
		if ( !structKeyExists( variables, "meta" ) ) {
			variables.meta = getMetadata( this );
		}
		return variables.meta;
	}

	/**
	 * Invokes a dynamic method on our component. If the method doesn't exist,
	 * then it proceeds without error because of onMissingMethod.
	 *
	 * Returns whatever the method returns.
	 *
	 * Used mainly with lifecycle hooks.
	 *
	 * @return Any
	 */
	function $invokeMethod( required methodName, methodArgs = {} ){
		return invoke(
			this,
			arguments.methodName,
			arguments.filter( function( key, value ){
				return !arguments.key.findNoCase( "methodName" )
			} )
		);
	}

	/**
	 * Runs if any missing methods are called on our component.
	 *
	 * Mainly used for component populator using the wirebox populator
	 * and trusted setters.
	 *
	 * @missingMethodName String | Name of the missing method that was called.
	 * @missingMethodArguments Struct | The arguments provided to the missing method.
	 *
	 * @return Void
	 */
	function onMissingMethod(
		required missingMethodName,
		required missingMethodArguments
	){
		if (
			reFindNoCase(
				"^set.+",
				arguments.missingMethodName
			)
		) {
			// Extract data property name from the setter method called.
			var dataPropertyName = reReplaceNoCase(
				arguments.missingMethodName,
				"^set",
				"",
				"one"
			);

			// Check to see if the data property name is defined in the component.
			var dataPropertyExists = structKeyExists( variables.data, dataPropertyName );

			if ( dataPropertyExists ) {
				// Handle variations in missingMethodArguments from wirebox bean populator and our own implemented setters.
				if (
					structKeyExists(
						arguments.missingMethodArguments,
						"value"
					)
				) {
					$set(
						dataPropertyName,
						arguments.missingMethodArguments.value
					);
				} else {
					$set(
						dataPropertyName,
						arguments.missingMethodArguments[ 1 ]
					);
				}
			} else if (
				structKeyExists(
					variables.$settings,
					"throwOnMissingSetterMethod"
				) && variables.$settings.throwOnMissingSetterMethod == true
			) {
				throw(
					type    = "WireSetterNotFound",
					message = "The wire property '#dataPropertyName#' was not found."
				);
			}
		}
	}

	/**
	 * Set the components id.
	 *
	 * @id String | GUID
	 *
	 * @return Void
	 */
	function $setId( required id ){
		variables.$id= arguments.id;
	}

	/**
	 * Check if there are properties to be included in our query string
	 * and assembles them together in a single string to be used within a URL.
	 *
	 * @return String
	 */
	function $getQueryStringValues(){
		// Default with an empty array
		if ( !structKeyExists( variables, "queryString" ) ) {
			return "";
		}

		var currentState = $getState();

		// Handle array of property names
		if ( isArray( variables.queryString ) ) {
			var result = variables.queryString.reduce( function( agg, prop ){
				agg &= prop & "=" & currentState[ prop ];
				return agg;
			}, "" );
		} else {
			var result = "";
		}

		return result;
	}

	/**
	 * Tracks an emit, which is later returned in our API response and used
	 * by cbwire.
	 *
	 * @emitter cbwire.models.emit.BaseEmit | An instance of an emitter.
	 * @return Array;
	 */
	function $trackEmit( required emitter ){
		var result = emitter.getResult();
		variables.$emits.append( result );
	}

	/**
	 * Returns the names of the listeners defined on our component.
	 *
	 * @return Array
	 */
	function $getListenerNames(){
		return structKeyList( $getListeners() ).listToArray();
	}

	/**
	 * Apply cbwire attribute to the outer element in the provided rendering.
	 *
	 * @rendering String | The view rendering.
	 */
	function $applyWiringToOuterElement( required rendering ){
		var renderingResult = "";

		// Provide a hash of our rendering which is used by Livewire JS.
		var renderingHash = hash( arguments.rendering );

		// Determine our outer element.
		var outerElement = variables.$getOuterElement( arguments.rendering );

		// Add properties to top element to make cbwire actually work.
		if ( variables.$isInitialRendering ) {
			// Initial rendering
			renderingResult = rendering.replaceNoCase(
				outerElement,
				outerElement & " wire:id=""#$getID()#"" wire:initial-data=""#serializeJSON( $getInitialData( renderingHash = renderingHash ) ).replace( """", "&quot;", "all" )#""",
				"once"
			);
		} else {
			// Subsequent renderings
			renderingResult = rendering.replaceNoCase(
				outerElement,
				outerElement & " wire:id=""#$getID()#""",
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
	function $getOuterElement( required rendering ){
		var matches = reMatchNoCase( "<[a-z]+\s*", arguments.rendering );

		if ( arrayLen( matches ) ) {
			return matches[ 1 ];
		}

		throw(
			type    = "OuterElementNotFound",
			message = "Unable to find an outer element to bind cbwire to."
		);
	}

	/**
	 * Returns our HTTP referer.
	 *
	 * @return String
	 */
	function $getHTTPReferer(){
		return cgi.HTTP_REFERER;
	}

}
