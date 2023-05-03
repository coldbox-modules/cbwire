/**
 * This is the base object that all cbwire components extend for functionality.
 *
 * Most internal methods and properties here are namespaced with a "$" to avoid collisions
 * with child components.
 */
component accessors="true" {

	// Inject ColdBox, needed by FrameworkSuperType
	property name="controller" inject="coldbox";

	// WireBox's populator object
	property name="populator" inject="wirebox:populator";

	// Inject module settings
	property name="settings" inject="coldbox:modulesettings:cbwire";

	// Inject the wire request that's incoming from the browser.
	property name="cbwireRequest" inject="CBWireRequest@cbwire";

	// Holds our validation result.
	property name="validationResult";

	// Holds the template path
	property name="template";

	/**
	 * Determines if component is being initially rendered or subsequently rendered.
	 */
	property name="_isInitialRendering" default="true";

	/**
	 * Holds component id
	 */
	property name="_id";

	/**
	 * Holds redirect to
	 */
	property name="_redirectTo";

	/**
	 * A beautiful constructor.
	 */
	function init() {
		variables._id = _generateId();
		variables._renderingOverrides = {};
		variables._dataProperties = {};
		variables._computedProperties = {};
		variables._finishedUpload = false;
		variables._beforeHydrationState = {};
		variables._dirtyProperties = [];
		variables._emittedEvents = [];
		variables._children = {};
		variables._noRendering = false;
	}

	/**
	 * Invoked when dependency injection complete.
	 */
	function onDIComplete(){
		variables.data = isNull( variables.data ) ? {} : variables.data;
		variables.computed = isNull( variables.computed ) ? {} : variables.computed;
		variables._noRendering = false;
		variables._dataProperties = variables.data;
		variables._computedProperties = variables.computed;
	}

	/**
	 * Get a instance object from WireBox
	 *
	 * @name The mapping name or CFC path or DSL to retrieve
	 * @initArguments The constructor structure of arguments to passthrough when initializing the instance
	 * @dsl The DSL string to use to retrieve an instance
	 *
	 * @return The requested instance
	 */
	function getInstance( name, initArguments = {}, dsl ){
		return getController().getWirebox().getInstance( argumentCollection = arguments );
	}

	/**
	 * Relocate user browser requests to other events, URLs, or URIs.
	 *
	 * @event             The name of the event to relocate to, if not passed, then it will use the default event found in your configuration file.
	 * @queryString       The query string or a struct to append, if needed. If in SES mode it will be translated to convention name value pairs
	 * @addToken          Wether to add the tokens or not to the relocation. Default is false
	 * @persist           What request collection keys to persist in flash RAM automatically for you
	 * @persistStruct     A structure of key-value pairs to persist in flash RAM automatically for you
	 * @ssl               Whether to relocate in SSL or not. You need to explicitly say TRUE or FALSE if going out from SSL. If none passed, we look at the even's SES base URL (if in SES mode)
	 * @baseURL           Use this baseURL instead of the index.cfm that is used by default. You can use this for SSL or any full base url you would like to use. Ex: https://mysite.com/index.cfm
	 * @postProcessExempt Do not fire the postProcess interceptors, by default it does
	 * @URL               The full URL you would like to relocate to instead of an event: ex: URL='http://www.google.com'
	 * @URI               The relative URI you would like to relocate to instead of an event: ex: URI='/mypath/awesome/here'
	 *
	 * @return void
	 */
	function relocate(
		event = "",
		queryString = "",
		boolean addToken = false,
		persist = "",
		struct persistStruct = structNew()
		boolean ssl,
		baseURL = "",
		boolean postProcessExempt = false,
		URL,
		URI
	){
		// Determine the type of relocation
		var relocationType = "SES";
		var relocationURL = "";
		var eventName = getController().getConfigSettings()[ "EventName" ];
		var frontController = listLast( CGI.SCRIPT_NAME, "/" );
		var oRequestContext = getController().getRequestService().getContext();
		var routeString = 0;

		// Determine relocation type
		if ( !isNull( arguments.url ) && len( arguments.url ) ) {
			relocationType = "URL";
		}
		if ( !isNull( arguments.URI ) && len( arguments.URI ) ) {
			relocationType = "URI";
		}

		// Cleanup event string to default if not sent in
		if ( len( trim( arguments.event ) ) eq 0 ) {
			arguments.event = getController().getSetting( "DefaultEvent" );
		}

		// Query String Struct to String
		if ( isStruct( arguments.queryString ) ) {
			arguments.queryString = arguments.queryString
				.reduce( function( result, key, value ){
					arguments.result.append( "#encodeForURL( arguments.key )#=#encodeForURL( arguments.value )#" );
					return arguments.result;
				}, [] )
				.toList( "&" );
		}

		// Overriding Front Controller via baseURL argument
		if ( len( trim( arguments.baseURL ) ) ) {
			frontController = arguments.baseURL;
		}

		// Relocation Types
		switch ( relocationType ) {
			// FULL URL relocations
			case "URL": {
				relocationURL = arguments.URL;
				// Check SSL?
				if ( !isNull( arguments.ssl ) ) {
					relocationURL = getController().updateSSL( relocationURL, arguments.ssl );
				}
				// Query String?
				if ( len( trim( arguments.queryString ) ) ) {
					relocationURL = relocationURL & "?#arguments.queryString#";
				}
				break;
			}

			// URI relative relocations
			case "URI": {
				relocationURL = arguments.URI;
				// Query String?
				if ( len( trim( arguments.queryString ) ) ) {
					relocationURL = relocationURL & "?#arguments.queryString#";
				}
				break;
			}

			// Default event relocations
			default: {
				// Convert module into proper entry point
				if ( listLen( arguments.event, ":" ) > 1 ) {
					var mConfig = getController().getSetting( "modules" );
					var module = listFirst( arguments.event, ":" );
					if ( structKeyExists( mConfig, module ) ) {
						arguments.event = mConfig[ module ].inheritedEntryPoint & "/" & listRest( arguments.event, ":" );
					}
				}
				// Route String start by converting event syntax to / syntax
				routeString = replace( arguments.event, ".", "/", "all" );
				// Convert Query String to convention name value-pairs
				if ( len( trim( arguments.queryString ) ) ) {
					// If the routestring ends with '/' we do not want to
					// double append '/'
					if ( right( routeString, 1 ) NEQ "/" ) {
						routeString = routeString & "/" & replace( arguments.queryString, "&", "/", "all" );
					} else {
						routeString = routeString & replace( arguments.queryString, "&", "/", "all" );
					}
					routeString = replace( routeString, "=", "/", "all" );
				}

				// Get Base relocation URL from context
				relocationURL = oRequestContext.getSESBaseURL();
				// if the sesBaseURL is nothing, set it to the setting
				if ( !len( relocationURL ) ) {
					relocationURL = getController().getSetting( "sesBaseURL" );
				}
				// add the trailing slash if there isnt one
				if ( right( relocationURL, 1 ) neq "/" ) {
					relocationURL = relocationURL & "/";
				}
				// Check SSL?
				if ( !isNull( arguments.ssl ) ) {
					relocationURL = getController().updateSSL( relocationURL, arguments.ssl );
				}

				// Finalize the URL
				relocationURL = relocationURL & routeString;

				break;
			}
		}

		// persist Flash RAM
		_persistVariables( argumentCollection = arguments );

		// Post Processors
		if ( NOT arguments.postProcessExempt ) {
			getController().getInterceptorService().announce( "postProcess" );
		}

		// Save Flash RAM
		if ( getController().getConfigSettings().flash.autoSave ) {
			controller
				.getRequestService()
				.getFlashScope()
				.saveFlash();
		}

		set_redirectTo( relocationURL2 );
	}

	/**
	 * Render out a view
	 *
	 * @deprecated Use view() instead
	 *
	 * @view The the view to render, if not passed, then we look in the request context for the current set view.
	 * @args A struct of arguments to pass into the view for rendering, will be available as 'args' in the view.
	 * @module The module to render the view from explicitly
	 * @cache Cached the view output or not, defaults to false
	 * @cacheTimeout The time in minutes to cache the view
	 * @cacheLastAccessTimeout The time in minutes the view will be removed from cache if idle or requested
	 * @cacheSuffix The suffix to add into the cache entry for this view rendering
	 * @cacheProvider The provider to cache this view in, defaults to 'template'
	 * @collection A collection to use by this Renderer to render the view as many times as the items in the collection (Array or Query)
	 * @collectionAs The name of the collection variable in the partial rendering.  If not passed, we will use the name of the view by convention
	 * @collectionStartRow The start row to limit the collection rendering with
	 * @collectionMaxRows The max rows to iterate over the collection rendering with
	 * @collectionDelim  A string to delimit the collection renderings by
	 * @prePostExempt If true, pre/post view interceptors will not be fired. By default they do fire
	 * @name The name of the rendering region to render out, Usually all arguments are coming from the stored region but you override them using this function's arguments.
	 *
	 * @return The rendered view
	 */
	function renderView(){
		return view( argumentCollection = arguments );
	}

	/**
	 * Render out our component's view
	 *
	 * @view The the view to render, if not passed, then we look in the request context for the current set view.
	 * @args A struct of arguments to pass into the view for rendering, will be available as 'args' in the view.
	 * @module The module to render the view from explicitly
	 * @cache Cached the view output or not, defaults to false
	 * @cacheTimeout The time in minutes to cache the view
	 * @cacheLastAccessTimeout The time in minutes the view will be removed from cache if idle or requested
	 * @cacheSuffix The suffix to add into the cache entry for this view rendering
	 * @cacheProvider The provider to cache this view in, defaults to 'template'
	 * @collection A collection to use by this Renderer to render the view as many times as the items in the collection (Array or Query)
	 * @collectionAs The name of the collection variable in the partial rendering.  If not passed, we will use the name of the view by convention
	 * @collectionStartRow The start row to limit the collection rendering with
	 * @collectionMaxRows The max rows to iterate over the collection rendering with
	 * @collectionDelim  A string to delimit the collection renderings by
	 * @prePostExempt If true, pre/post view interceptors will not be fired. By default they do fire
	 * @name The name of the rendering region to render out, Usually all arguments are coming from the stored region but you override them using this function's arguments.
	 *
	 * @return The rendered view
	 */
	function view(
		view = "",
		struct args = {},
		module = "",
		boolean cache = false,
		cacheTimeout = "",
		cacheLastAccessTimeout = "",
		cacheSuffix = "",
		cacheProvider = "template",
		collection,
		collectionAs = "",
		numeric collectionStartRow = "1",
		numeric collectionMaxRows = 0,
		collectionDelim = "",
		boolean prePostExempt = false,
		name,
		boolean applyWiring = true
	){
		var templateRendering = _view( argumentCollection = arguments );
		// Add properties to top element to make Livewire actually work.
		return applyWiring ? _applyWiringToOuterElement( templateRendering ) : templateRendering;
	}

	/**
	 * Emits a global event from our cbwire component.
	 *
	 * @eventName String | The name of our event to emit.
	 * @parameters Arrays | The params passed with the emitter.
	 * @trackEmit Boolean | True if you want to notify the UI that the emit occurred.
	 */
	function emit( required eventName, array parameters = [], track = true ){	
		// Invoke 'preEmit' event
		_invokeMethod( methodName = "preEmit", eventName = arguments.eventName, parameters = arguments.parameters );

		// Invoke 'preEmit[EventName]' event
		_invokeMethod( methodName = "preEmit" & arguments.eventName, parameters = arguments.parameters );

		// Capture the emit as we will need to notify the UI in our response
		if ( arguments.track ) {
			var emitter = {
				"event" : arguments.eventName,
				"params" : isArray( arguments.parameters ) ? arguments.parameters : [ arguments.parameters ]
			};

			_trackEmit( emitter );
		}

		// Invoke 'postEmit' event
		_invokeMethod( methodName = "postEmit", eventName = arguments.eventName, parameters = arguments.parameters );

		// Invoke 'postEmit[EventName]' event
		_invokeMethod( methodName = "postEmit" & arguments.eventName, parameters = arguments.parameters );
	}

	/**
 * Emits an event that is scoped to just the current cbwire component.
	 *
	 * Additional parameters can be passed through.

	 * @eventName String | The name of our event to emit.
	 * @parameters Struct | The emitter's params.
	 *
	 * @return Void
	 */
	function emitSelf( required eventName, parameters = {} ) {
		var emitter = {
			"event" : arguments.eventName,
			"params" : arguments.parameters,
			"selfOnly" : true
		};

		// Capture the emit as we will need to notify the UI in our response
		_trackEmit( emitter );
	}

	/**
	 * Emits an event that is scoped to parents and not children or sibling components.
	 *
	 * Additional parameters can be passed through.
	 * @eventName String | The name of our event to emit.
	 * @parameters Struct  The emitter's params.
	 *
	 * @return Void
	 */
	function emitUp( required eventName, parameters = {} ){
		var emitter = {
			"event" : arguments.eventName,
			"params" : arguments.parameters,
			"ancestorsOnly" : true
		};

		// Capture the emit as we will need to notify the UI in our response
		_trackEmit( emitter );
	}

	/**
	 * Emits an event that is scoped to only a specific compnoent.
	 *
	 * Additional parameters can be passed through.
	 * @eventName String | The name of our event to emit.
	 * @componentName String | The name of our component to emit to.
	 * @parameters Array | The emitter's params. Must be an array to preserve order of arguments that are return to cbwire.
	 *
	 * @return Void
	 */
	function emitTo( required eventName, required componentName, parameters = [] ){
		var emitter = {
			"event" : arguments.eventName,
			"params" : arguments.parameters,
			"to" : arguments.componentName
		};

		// Capture the emit as we will need to notify the UI in our response
		_trackEmit( emitter );
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
	function onMissingMethod( required missingMethodName, required missingMethodArguments ){
		var settings = getSettings();

		var data = _getDataProperties();

		var computed = _getComputedProperties();

		if ( reFindNoCase( "^get.+", arguments.missingMethodName ) ) {
			// Extract data property name from the getter method called.
			var propertyName = reReplaceNoCase( arguments.missingMethodName, "^get", "", "one" )

			// Check to see if the data property name is defined on the component.
			if ( structKeyExists( data, propertyName ) ) {
				return data[ propertyName ];
			}

			// Check to see if the computed property name is defined in the component.
			if ( structKeyExists( computed, propertyName ) ) {
				return computed[ propertyName ];
			}
		}

		if ( reFindNoCase( "^set.+", arguments.missingMethodName ) ) {
			// Extract data property name from the setter method called.
			var dataPropertyName = reReplaceNoCase( arguments.missingMethodName, "^set", "", "one" );

			// Check to see if the data property name is defined in the component.
			var dataPropertyExists = structKeyExists( data, dataPropertyName );

			if ( dataPropertyExists ) {
				// Handle variations in missingMethodArguments from wirebox bean populator and our own implemented setters.
				if ( structKeyExists( arguments.missingMethodArguments, "value" ) ) {
					_setProperty( dataPropertyName, arguments.missingMethodArguments.value );
				} else {
					_setProperty( dataPropertyName, arguments.missingMethodArguments[ 1 ], true );
				}
			} else if (
				structKeyExists( settings, "throwOnMissingSetterMethod" ) && settings.throwOnMissingSetterMethod == true
			) {
				throw( type = "WireSetterNotFound", message = "The wire property '#dataPropertyName#' was not found." );
			}
		}

		if ( reFindNoCase( "^reset.+", arguments.missingMethodName ) ) {
			var dataPropertyName = reReplaceNoCase( arguments.missingMethodName, "^reset", "", "one" );
			_reset( dataPropertyName );
		}
	}

	/**
	 * When called, the component is flagged so that no rendering will occur.
	 *
	 * @return void
	 */
	function noRender(){
		variables._noRendering = true;
	}

	/**
	 * Validate an object or structure according to the constraints rules.
	 *
	 * @target An object or structure to validate
	 * @fields The fields to validate on the target. By default, it validates on all fields
	 * @constraints A structure of constraint rules or the name of the shared constraint rules to use for validation
	 * @locale The i18n locale to use for validation messages
	 * @excludeFields The fields to exclude from the validation
	 * @includeFields The fields to include in the validation
	 * @profiles If passed, a list of profile names to use for validation constraints
	 *
	 * @return cbvalidation.model.result.IValidationResult
	 */
	function _validate(){
		arguments.target = isNull( arguments.target ) ? this : arguments.target;
		setValidationResult( getValidationManager().validate( argumentCollection = arguments ) );
		return getValidationResult();
	}

	/**
	 * Validate an object or structure according to the constraints rules and throw an exception if the validation fails.
	 * The validation errors will be contained in the `extendedInfo` of the exception in JSON format
	 *
	 * @target An object or structure to validate
	 * @fields The fields to validate on the target. By default, it validates on all fields
	 * @constraints A structure of constraint rules or the name of the shared constraint rules to use for validation
	 * @locale The i18n locale to use for validation messages
	 * @excludeFields The fields to exclude from the validation
	 * @includeFields The fields to include in the validation
	 * @profiles If passed, a list of profile names to use for validation constraints
	 *
	 * @return The validated object or the structure fields that where validated
	 * @throws ValidationException
	 */
	function validateOrFail(){
		arguments.target = isNull( arguments.target ) ? this : arguments.target;
		return getValidationManager().validateOrFail( argumentCollection = arguments );
	}

	/**
	 * Retrieve the application's configured Validation Manager
	 */
	function getValidationManager(){
		return getInstance( "ValidationManager@cbvalidation" );
	}

	/**
	 * Resets a property back to it's original state when the component
	 * was initially hydrated.
	 *
	 * This accepts either a single property or an array of properties
	 *
	 * @return Void
	 */
	function reset( property ){
		_reset( argumentCollection = arguments );
	}

	/**
	 * Remove once refectoring is done.
	 *
	 * @return struct
	 */
	function getInternals(){
		return variables;
	}

	/**
	 * Returns the template path for the component.
	 * 
	 * @returns string
	 */
	function _getTemplatePath() {
		if ( structKeyExists( variables, "template" ) ) {
			return variables.template;
		}

		var componentName = lCase( getMetadata( this ).name );

		return "wires/#listLast( componentName, "." )#";
	}

	/**
	 * Toggles a data property.
	 * 
	 * @returns void
	 */
	function $toggle( dataProperty ) {
		return _toggleDataProperty( arguments.dataProperty );
	}

	/**
	 * Tracks an emit, which is later returned in our API response and used
	 * by cbwire.
	 *
	 * @emitter cbwire.models.emit.BaseEmit | An instance of an emitter.
	 * @return Array;
	 */
	function _trackEmit( required emitter ){
		variables._emittedEvents.append( arguments.emitter );
	}

	/**
	 * Returns a unique ID for the component.
	 *
	 * @return String
	 */
	function _generateId(){
		var guidChars = listToArray( createUUID(), "" )
			.filter( function( char ){
				return char != "-";
			} )
			.filter( function( char, index ){
				return index <= 20;
			} )
			.map( function( char ){
				return randRange( 0, 1 ) == 0 ? uCase( char ) : lCase( char );
			} );
		return arrayToList( guidChars, "" );
	}

	/**
	 * Returns the initial data of our component, which is ultimately serialized
	 * to json and return in the view as our component is first rendered.
	 *
	 * @return Struct
	 */
	function _getInitialData( rendering = "" ){

		var fingerprintName = _getMeta().name;

		fingerprintName = reReplaceNoCase( fingerprintName, "^root\.", "", "one" );

		return {
			"fingerprint" : {
				"id" : variables._id,
				"name" : fingerprintName,
				"locale" : "en",
				"path" : _getPath(),
				"method" : "GET",
				"v" : "acj"
			},
			"effects" : { "listeners" : _getListenerNames() },
			"serverMemo" : {
				"children" : [],
				"errors" : [],
				"htmlHash" : _getHTMLHash( rendering ),
				"data" : _getState( includeComputed = false ),
				"dataMeta" : [],
				"checksum" : _getChecksum()
			}
		};
	}

	function _getRenderingOverrides() {
		return variables._renderingOverrides;
	}

	/**
	 * Returns true if listeners are detected on the component.
	 *
	 * @return Boolean
	 */
	function _hasListeners(){
		return arrayLen( _getListenerNames() );
	}

	/**
	 * Determines the outer element within our rendering.
	 * If an outer element isn't found, an error is thrown.
	 *
	 * @rendering String | The view rendering.
	 */
	function _getOuterElement( required rendering ){
		var matches = reMatchNoCase( "<[a-z]+\s*", arguments.rendering );

		if ( arrayLen( matches ) ) {
			return matches[ 1 ];
		}

		throw( type = "OuterElementNotFound", message = "Unable to find an outer element to bind cbwire to." );
	}

	/**
	 * Executes the listeners associated with the provided event.
	 *
	 * @eventName String | The name of our event to emit.
	 * @parameters Arrays | The params passed with the emitter.
	 */
	function _fire( required eventName, array parameters = [] ){
		var listeners = _getListeners();

		if ( structKeyExists( listeners, eventName ) ) {
			var listener = listeners[ eventName ];

			if ( len( arguments.eventName ) && _hasMethod( listener ) ) {
				return _invokeMethod( methodName = listener, passThroughParameters = arguments.parameters );
			}
		}
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
	function _invokeMethod( required methodName ){
		var params = structKeyExists( arguments, "passThroughParameters" ) ? arguments.passThroughParameters : arguments;

		return invoke( this, arguments.methodName, params );
	}

	/**
	 * Returns true if trimStringValues settings is enabled.
	 * 
	 * @return boolean
	 */
	function _shouldTrimStringValues(){
		return structKeyExists( getSettings(), "trimStringValues" ) && getSettings().trimStringValues == true;
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
	function _setProperty( propertyName, value, invokeUpdateMethods = false ){
		if ( arguments.invokeUpdateMethods ) {
			// Invoke '$preUpdate[prop]' event
			_invokeMethod( methodName = "preUpdate" & arguments.propertyName, propertyName = arguments.value );
		}

		var data = _getDataProperties();

		data[ "#arguments.propertyName#" ] = arguments.value;

		if ( arguments.invokeUpdateMethods ) {
			// Invoke 'postUpdate[prop]' event
			_invokeMethod( methodName = "postUpdate" & arguments.propertyName, propertyName = arguments.value );
		}
	}

	/**
	 * Returns the checksum hash of our current state.
	 *
	 * @return String
	 */
	function _getChecksum(){
		return hash( serializeJSON( _getState() ) );
	}

	/**
	 * Returns the current state of our component.
	 *
	 * @includeComputed Boolean | Set to true to include computed properties in the returned state.
	 * @return Struct
	 */
	function _getState( boolean includeComputed = false ){
		var state = {};

		var data = _getDataProperties();

		data.each( function( key, value ){
			if ( isClosure( arguments.value ) ) {
				// Render the closure and store in our data properties
				data[ key ] = arguments.value();
				state[ arguments.key ] = data[ key ];
			} else {
				if ( isSimpleValue( arguments.value ) || isArray( arguments.value ) || isStruct( arguments.value ) ) {
					state[ arguments.key ] = arguments.value;
				} else if ( isNull( arguments.value ) ) {
					state[ arguments.key ] = javaCast( "null", 0 );
				} else {
					state[ arguments.key ] = "";
				}
			}
		} );

		if ( _shouldTrimStringValues() ) {
			state.each( function( key, value ){
				if ( isSimpleValue( state[ key ] ) ) {
					state[ key ] = trim( state[ key ] );
				}
			} );
		}

		state = state.map( function( key, value, data ){
			if ( isNull( value ) ) {
				return javaCast( "null", 0 );
			}
			return value;
		} );

		if ( arguments.includeComputed ) {
			_renderComputedProperties( data );

			if ( !_useComputedPropertiesProxy() ) {
				_getComputedProperties().each( function( key, value ){
					if ( !isNull( value ) ) {
						state[ key ] = value;
					}
				} );
			}
		}

		return state;
	}

	/**
	 * Returns the meta data for this component.
	 * Ensures that we only run this once.
	 *
	 * @return Struct
	 */
	function _getMeta(){
		if ( isNull( variables.meta ) ) {
			variables.meta = getMetadata( this );
		}
		return variables.meta;
	}

	/**
	 * Returns the memento for our component which holds the current
	 * state of our component. This is returned on subsequent XHR requests
	 * from cbwire.
	 *
	 * @return Struct
	 */
	function _getMemento(){
		var rendering = _getRequestContext().getValue( "_cbwire_subsequent_rendering" );

		var memento = {
			"effects" : {
				"html" : _getHTML(),
				"dirty" : variables._dirtyProperties,
				"emits" : variables._emittedEvents,
				"redirect" : !isNull( get_RedirectTo() ) ? get_RedirectTo() : javacast( "null", 0 )
			},
			"serverMemo" : {
				"data" : _getState( includeComputed = false ),
				"checksum" : _getChecksum()
			}
		}

		if ( !variables._finishedUpload ) {
			memento.effects[ "path" ] = _getPath();
			memento.serverMemo[ "htmlHash" ] = _getHTMLHash( rendering );
			memento.serverMemo[ "children" ] = isArray( variables._children ) ? [] : variables._children;
		}

		return memento;
	}

	function _getRequestContext() {
		return getController().getRenderer().getRequestContext();
	}

	/**
	 * Returns the HTML rendering or null
	 *
	 * @return Any
	 */
	function _getHTML(){
		var rendering = _getRequestContext().getValue( "_cbwire_subsequent_rendering" );
		return len( rendering ) ? rendering : javacast( "null", 0 );
	}

	/**
	 * Returns the names of the listeners defined on our component.
	 *
	 * @return Array
	 */
	function _getListenerNames(){
		return structKeyList( _getListeners() ).listToArray();
	}

	/**
	 * Returns our HTTP referer.
	 *
	 * @return String
	 */
	function _getHTTPReferer(){
		return len( cgi.HTTP_REFERER ) ? CGI.HTTP_REFERER : "/";
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
	function _getPath(){
		var queryStringValues = _getQueryStringValues();

		if ( len( queryStringValues ) ) {
			var referer = _getHTTPReferer();

			// Strip away any queryString parameters from the referer so
			// we don't duplicate them when we append the queryStringValues below.
			if ( referer contains "?" ) {
				referer = listGetAt( referer, 1, "?" );
			}

			return "#referer#?#queryStringValues#";
		}

		// Return empty string by default;
		return _getHTTPReferer();
	}

	/**
	 * Check if there are properties to be included in our query string
	 * and assembles them together in a single string to be used within a URL.
	 *
	 * @return String
	 */
	function _getQueryStringValues(){
		// Default with an empty array
		if ( !structKeyExists( variables, "queryString" ) ) {
			return "";
		}

		var currentState = _getState();

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
	 * Returns the listeners defined on the component.
	 * If no listeners are defined, an empty struct is returned.
	 *
	 * @return Struct
	 */
	function _getListeners(){
		if ( structKeyExists( variables, "listeners" ) && isStruct( variables.listeners ) ) {
			return variables.listeners;
		}
		return {};
	}

	/**
	 * Loops through the defined computed properties and invokes the functions once.
	 *
	 * @return void
	 */
	function _renderComputedProperties( data = _getDataProperties() ){
		if ( !structKeyExists( variables, "computed" ) ) {
			return;
		}

		if ( _useComputedPropertiesProxy() ) {
			variables._computedProperties = _getComputedPropertiesProxy();
		} else {
			_getComputedProperties().each( function( key, value, computedProperties ){
				if ( isCustomFunction( value ) ) {
					variables._computedProperties[ key ] = value( data );
				}
			} );
		}
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
	function _mount( parameters = {}, key = "" ){
		getController().getInterceptorService().announce(
			"onCBWireMount",
			{
				component : this,
				parameters : arguments.parameters
			}
		);

		if ( structKeyExists( this, "mount" ) ) {
			mount(
				parameters = arguments.parameters,
				key = arguments.key,
				event = getCBWireRequest().getEvent(),
				rc = getCBWireRequest().getCollection(),
				prc = getCBWireRequest().getPrivateCollection()
			);
		} else if ( structKeyExists( this, "onMount" ) ) {
			onMount(
				parameters = arguments.parameters,
				key = arguments.key,
				event = getCBWireRequest().getEvent(),
				rc = getCBWireRequest().getCollection(),
				prc = getCBWireRequest().getPrivateCollection()
			);
		} else {
			/**
			 * Use setter population to populate our component.
			 */
			getPopulator().populateFromStruct(
				target: this,
				trustedSetter: true,
				memento: arguments.parameters,
				excludes: ""
			);
		}

		// Capture the state before hydration
		variables._beforeHydrationState = duplicate( _getState() );

		return this;
	}

	/**
	 * Resets a property back to it's original state when the component
	 * was initially hydrated.
	 *
	 * This accepts either a single property or an array of properties
	 *
	 * @return Void
	 */
	function _reset( property ){
		if ( isNull( arguments.property ) ) {
			// Reset all properties
			_getDataProperties().each( function( key, value ){
				_reset( key );
			} );
		} else if ( isArray( arguments.property ) ) {
			// Reset each property in our array individually
			arguments.property.each( function( prop ){
				_reset( prop );
			} );
		} else {
			// Reset individual property
			_setProperty( arguments.property, variables._beforeHydrationState[ arguments.property ] );
		}
	}

	/**
	 * Returns a SHA-256 hash of the passed in content.
	 *
	 * @return string
	 */
	function _getHTMLHash( content ){
		return hash( content, "SHA-256" );
	}

	/**
	 * Toggle a data property
	 */
	function _toggleDataProperty( dataProperty ) {
		var dataProperties = _getDataProperties();
	
		if ( dataProperties.keyExists( dataProperty ) ) {
			var currentValue = dataProperties [ dataProperty ];

			if ( isBoolean( currentValue ) ) {
				invoke( this, "set#arguments.dataProperty#", [ booleanFormat( !currentValue ) ] );
			} else {
				throw( message = "The data property '#arguments.dataProperty#' must be a boolean value (true/false) for toggling." );
			}

			return;
		}

		throw( message = "Cannot find data property '#arguments.dataProperty#' for toggling." );
	}

	/**
	 * Returns our computed properties proxy
	 */
	function _getComputedPropertiesProxy(){
		return getController()
			.getWirebox()
			.getInstance(
				name = "ComputedPropertiesProxy@cbwire",
				initArguments = {
					computedProperties : _getComputedProperties(),
					wire : this
				}
			);
	}

	/**
	 * Returns true if a proxy should be used for computed properties.
	 * 
	 * @return boolean
	 */
	function _useComputedPropertiesProxy(){
		return structKeyExists( getSettings(), "useComputedPropertiesProxy" ) && getSettings().useComputedPropertiesProxy == true;
	}

	/**
	 * Internal helper to flash persist elements
	 *
	 * @persist       What request collection keys to persist in flash RAM automatically for you
	 * @persistStruct A structure of key-value pairs to persist in flash RAM automatically for you
	 *
	 * @return Controller
	 */
	private function _persistVariables( persist = "", struct persistStruct = {} ){
		var flash = getController().getRequestService().getFlashScope();

		// persist persistStruct if passed
		if ( !isNull( arguments.persistStruct ) ) {
			flash.putAll( map = arguments.persistStruct, saveNow = true );
		}

		// Persist RC keys if passed.
		if ( len( trim( arguments.persist ) ) ) {
			flash.persistRC( include = arguments.persist, saveNow = true );
		}

		return this;
	}

	/**
	 * Finishes an upload.
	 *
	 * @return void
	 */
	function _finishUpload( params ){
		var fileUpload = getController()
			.getWireBox()
			.getInstance( name = "FileUpload@cbwire", initArguments = { comp : this, params : params } );
		_getRenderingOverrides()[ params[ 1 ] ] = fileUpload;
		variables._finishedUpload = true;
		variables._dirtyProperties.append( "myFile" );
		variables.data[ params[ 1 ] ] = "cbwire-upload:#fileUpload.getUUID()#";
		emitSelf(
			eventName = "upload:finished",
			parameters = [
				"myFile",
				[ "nf48Fr0I6Buvk6DnxBLbDVw7W2NMtO-metaMjAyMi0wOC0yMSAwNy41Mi41MC5naWY=-.gif" ]
			]
		);
	}

	function _getComputedProperties() {
		return variables._computedProperties;
	}

	function _setComputedProperties( value ) {
		variables._computedProperties = arguments.value;
	}

	/**
	 * Apply cbwire attribute to the outer element in the provided rendering.
	 *
	 * @rendering String | The view rendering.
	 */
	function _applyWiringToOuterElement( required rendering ){
		var renderingResult = "";

		// Provide a hash of our rendering which is used by Livewire JS.
		var renderingHash = hash( arguments.rendering );

		// Determine our outer element.
		var outerElement = _getOuterElement( arguments.rendering );

		// Add properties to top element to make cbwire actually work.
		if ( get_IsInitialRendering() ) {
			// Initial rendering
			renderingResult = rendering.replaceNoCase(
				outerElement,
				outerElement & " wire:id=""#get_id()#"" wire:initial-data=""#serializeJSON( _getInitialData( rendering ) ).replace( """", "&quot;", "all" )#""",
				"once"
			);
			renderingResult &= "#chr( 10 )#<!-- Livewire Component wire-end:#get_id()# -->";
		} else {
			// Subsequent renderings
			renderingResult = rendering.replaceNoCase( outerElement, outerElement & " wire:id=""#get_id()#""", "once" );
		}


		return renderingResult;
	}

	/**
	 * Hydrates the incoming component with state from our request.
	 *
	 * @wireRequest CBWireRequest
	 *
	 * @return Component
	 */
	function _hydrate(){
		set_IsInitialRendering( false );
		getController().getInterceptorService().announce( "onCBWireHydrate", { component : this } );
		return this;
	}

	function _setBeforeHydrationState( value ) {
		variables._beforeHydrationState = arguments.value;
	}

	/**
	 * Invokes renderIt() on the cbwire component and caches the rendered
	 * results into variables.rendering.
	 *
	 * @return String
	 */
	function _subsequentRenderIt(){
		getController().getInterceptorService().announce( "onCBWireSubsequentRenderIt", { component : this } );
		return this;
	}

	function _addDirtyProperty( property ) {
		variables._dirtyProperties.append( arguments.property );
	}

	function _getEmittedEvents() {
		return variables._emittedEvents;
	}

	function _getDataProperties() {
		return variables._dataProperties;
	}

	function _setDataProperties( value ) {
		variables._dataProperties = arguments.value;
	}

		/**
	 * Returns true if the provided method name can be found on our component.
	 *
	 * @methodName String | The method name we are checking.
	 * @return Boolean
	 */
	function _hasMethod( required methodName ){
		return structKeyExists( this, arguments.methodName );
	}

	function _getNoRendering() {
		return variables._noRendering;
	}

	/**
	 * Renders our component's view.
	 *
	 * @return Void
	 */
	function _renderIt(){
		return view( view = _getTemplatePath() );
	}

/**
	 * Render out our component's view
	 *
	 * @view The the view to render, if not passed, then we look in the request context for the current set view.
	 * @args A struct of arguments to pass into the view for rendering, will be available as 'args' in the view.
	 * @module The module to render the view from explicitly
	 * @cache Cached the view output or not, defaults to false
	 * @cacheTimeout The time in minutes to cache the view
	 * @cacheLastAccessTimeout The time in minutes the view will be removed from cache if idle or requested
	 * @cacheSuffix The suffix to add into the cache entry for this view rendering
	 * @cacheProvider The provider to cache this view in, defaults to 'template'
	 * @collection A collection to use by this Renderer to render the view as many times as the items in the collection (Array or Query)
	 * @collectionAs The name of the collection variable in the partial rendering.  If not passed, we will use the name of the view by convention
	 * @collectionStartRow The start row to limit the collection rendering with
	 * @collectionMaxRows The max rows to iterate over the collection rendering with
	 * @collectionDelim  A string to delimit the collection renderings by
	 * @prePostExempt If true, pre/post view interceptors will not be fired. By default they do fire
	 * @name The name of the rendering region to render out, Usually all arguments are coming from the stored region but you override them using this function's arguments.
	 *
	 * @return The rendered view
	 */
	function _view(
		view = "",
		struct args = {},
		module = "",
		boolean cache = false,
		cacheTimeout = "",
		cacheLastAccessTimeout = "",
		cacheSuffix = "",
		cacheProvider = "template",
		collection,
		collectionAs = "",
		numeric collectionStartRow = "1",
		numeric collectionMaxRows = 0,
		collectionDelim = "",
		boolean prePostExempt = false,
		name
	){
		// Pass the properties of the cbwire component as variables to the view
		arguments.args = _getState( includeComputed = true );

		// If there are any rendering overrides ( like during file upload ), then merge those in
		structAppend( arguments.args, _getRenderingOverrides(), true );

		// Provide validation results, either validation results we captured from our action or run them now.
		arguments.args[ "validation" ] = isNull( getValidationResult() ) ? _validate() : getValidationResult();

		// Include a reference to the component's id
		arguments.args[ "_id" ] = get_id();

		/*
			Store our latest rendered id in the request scope so that it can be
			read by the entangle() method.
		*/
		getCBWireRequest().getEvent().setPrivateValue( "cbwire_lastest_rendered_id", get_id() );

		arguments.args[ "computed" ] = _getComputedProperties();

		if ( structKeyExists( this, "onRender" ) ) {
			// Render custom onRender method
			var result = onRender( args = arguments.args );
		} else {
			if ( structKeyExists( this, "template" ) ) {
				arguments.view = template;
			}
			// Render our view using coldbox rendering
			var result = getController().getRenderer().renderView( argumentCollection = arguments );
		}

		return result;
	}
}
