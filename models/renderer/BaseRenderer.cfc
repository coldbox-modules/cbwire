/**
 * This is the base object that all cbwire components extend for functionality.
 *
 * Most internal methods and properties here are namespaced with a "$" to avoid collisions
 * with child components.
 */
component accessors="true" {

	property name="wirebox" inject="wirebox";

	// Inject ColdBox, needed by FrameworkSuperType
	property name="controller" inject="coldbox";

	// Inject module settings
	property name="settings" inject="coldbox:modulesettings:cbwire";

	// Inject the cbwire service
	property name="cbwireService" inject="CBWireService@cbwire";

	// Holds our validation result.
	property name="validationResult";

	/**
	 * Injected RequestService so that we can access the current ColdBox RequestContext.
	 */
	property name="requestService" inject="coldbox:requestService";

	// Data utility for working with data properties
	property name="dataUtility" inject="DataUtility@cbwire";

	property name="id";
	property name="parent";
	property name="constraints";
	property name="dataProperties";
	property name="computedProperties";
	property name="listeners";
	property name="dirtyProperties";
	property name="noRendering";
	property name="parentCFCPath";
	property name="beforeHydrationState";
	property name="dispatchedEvents";
	property name="emittedEvents";
	property name="finishedUpload";
	property name="renderingOverrides";
	property name="cache";
	property name="querystring";
	property name="template";
	property name="isInitialRendering";
	property name="redirectTo";
	property name="hasRefreshed";


	/**
	 * A beautiful start.
	 */
	function start( parent, parentCFCPath ){
		setParent( arguments.parent );
		setParentCFCPath( arguments.parentCFCPath );
		setID( generateComponentID() );
		setRenderingOverrides( {} );
		setFinishedUpload( false );
		setBeforeHydrationState( {} );
		setDirtyProperties( [] );
		setDispatchedEvents( [] );
		setEmittedEvents( [] );
		setCache( {} );
		setNoRendering( false );
		setDataProperties( isNull( parent.getData() ) ? {} : parent.getData() );
		setComputedProperties( isNull( parent.getComputed() ) ? {} : parent.getComputed() );
		setTemplate( isNull( parent.getTemplate() ) ? "" : parent.getTemplate() );
		setListeners( isNull( parent.getListeners() ) ? {} : parent.getListeners() );
		setQueryString( isNull( parent.getQueryString() ) ? "" : parent.getQueryString() );
		setConstraints( isNull( parent.getConstraints() ) ? {} : parent.getConstraints() );
		setHasRefreshed( false );
		return this;
	}

	function getConcern( concern ){
		return getCBWIREService().getConcern( arguments.concern );
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
		arguments.comp = this;
		return getConcern( "Relocate" ).handle( argumentCollection=arguments );
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

			var rendering = applyWiring ? applyWiringToOuterElement( templateRendering ) : templateRendering;

		// Add properties to top element to make Livewire actually work.
		return rendering;
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
	function validate( target, fields, constraints, locale, excludeFields, includeFields, profiles ){
		arguments.target = isNull( arguments.target ) ? getDataProperties() : arguments.target;
		arguments.constraints = isNull( arguments.constraints ) ? getConstraints() : arguments.constraints;
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
	function validateOrFail(
		any target,
		string fields = "*",
		any constraints = "",
		string locale = "",
		string excludeFields = "",
		string includeFields = "",
		string profiles = ""
	){
		arguments.target = isNull( arguments.target ) ? getDataProperties() : arguments.target;
		arguments.constraints = getConstraints();
		return getValidationManager().validateOrFail( argumentCollection = arguments );
	}

	/**
	 * Retrieve the application's configured Validation Manager
	 */
	function getValidationManager(){
		return getInstance( dsl="provider:ValidationManager@cbvalidation" );
	}

	/**
	 * Refreshes a component, which mainly is just changing it's id
	 * so that it rerenders in the DOM.
	 */
	function refresh(){
		setHasRefreshed( true );
		//setID( generateComponentID() );
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
	function getComponentTemplatePath(){
		var templatePath = "";
		if ( getParent().isSingleFileComponent() ) {
			return "/cbwire/models/tmp/" & getParent().getParent().getSingleFileComponentID() & ".cfm";
		} else if ( len( getTemplate() ) ) {
			templatePath = getTemplate();
		} else {
			var currentPath = getParentCFCPath();
			var currentDir = getDirectoryFromPath( currentPath );
			currentDir = replaceNoCase( currentDir, getController().getAppRootPath(), "", "one" );
			var templateName = replaceNoCase( getFileFromPath( currentPath ), ".cfc", ".cfm", "one" );
			templatePath = "/" & currentDir & templateName;
		}

		if ( left( templatePath, 1 ) != "/" ) {
			templatePath = "/" & templatePath;
		}

		return templatePath;
	}

	/**
	 * Toggles a data property.
	 *
	 * @returns void
	 */
	function $toggle( dataProperty ){
		return toggleDataProperty( arguments.dataProperty );
	}

	/**
	 * Tracks a dispatch, which is later returned in our API resopnse and
	 * used by cbwire.
	 * 
	 * @dispatcher Struct
	 */
	function trackDispatch( required dispatcher ){
		getDispatchedEvents().append( arguments.dispatcher );
	}

	/**
	 * Tracks an emit, which is later returned in our API response and used
	 * by cbwire.
	 *
	 * @emitter Struct
	 */
	function trackEmit( required emitter ){
		getEmittedEvents().append( arguments.emitter );
	}

	/**
	 * Returns a unique ID for the component.
	 *
	 * @return String
	 */
	function generateComponentID(){
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
	function getInitialData( rendering = "" ){
		if ( getParent().isSingleFileComponent() ) {
			var currentModule = getController()
				.getRenderer()
				.getRequestContext()
				.getCurrentModule();
			var fingerprintName = getParent().getSingleFileComponentType();

			if ( len( currentModule ) ) {
				// fingerprintName = currentModule & "." & getWiresLocation() & "." & fingerprintName;
			}
		} else {
			var fingerprintName = getMeta().name;
		}

		fingerprintName = reReplaceNoCase( fingerprintName, "^root\.", "", "one" );

		return {
			"fingerprint" : {
				"module" : getParent().getModule(),
				"id" : getID(),
				"name" : fingerprintName,
				"locale" : "en",
				"path" : getPath(),
				"method" : "GET",
				"v" : "acj"
			},
			"effects" : { "listeners" : getListenerNames() },
			"serverMemo" : {
				"children" : getChildren( rendering ),
				"errors" : [],
				"htmlHash" : generateHash( rendering ),
				"data" : getState( includeComputed = false ),
				"dataMeta" : [],
				"checksum" : generateChecksum()
			}
		};
	}

	/**
	 * Returns true if listeners are detected on the component.
	 *
	 * @return Boolean
	 */
	function hasListeners(){
		return arrayLen( getListenerNames() );
	}

	/**
	 * Determines the outer element within our rendering.
	 * If an outer element isn't found, an error is thrown.
	 *
	 * @rendering String | The view rendering.
	 */
	function getOuterElement( required rendering ){
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
	function fire( required eventName, array parameters = [] ){
		var listeners = getListeners();

		if ( structKeyExists( listeners, eventName ) ) {
			var listener = listeners[ eventName ];

			if ( !hasMethod( listener ) ){
				throw(
					type = "WireActionNotFound",
					message = "Wire action '" & listener & "' not found on your component."
				);
			}
			if ( len( arguments.eventName ) && hasMethod( listener ) ) {
				return invokeMethod( methodName = listener, passThroughParameters = arguments.parameters );
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
	function invokeMethod( required methodName ){
		var params = structKeyExists( arguments, "passThroughParameters" ) ? arguments.passThroughParameters : arguments;

		return invoke( getParent(), arguments.methodName, params );
	}

	/**
	 * Returns true if trimStringValues settings is enabled.
	 *
	 * @return boolean
	 */
	function whenTrimStrings(){
		return structKeyExists( getSettings(), "trimStringValues" ) && getSettings().trimStringValues == true;
	}

	/**
	 * Sets an individual data property value, first by using a setter
	 * if it exists, and otherwise setting directly to our variables
	 * scope.
	 *
	 * @propertyName String | Name of the property we are setting
	 * @value Any | Value of the property we are settting
	 *
	 * @return Void
	 */
	function setProperty( propertyName, value ){
		var data = getDataProperties();
		dataUtility.setValueByPath( data, arguments.propertyName, arguments.value );
	}

	/**
	 * Returns the checksum hash of our current state.
	 *
	 * @return String
	 */
	function generateChecksum(){
		return hash( serializeJSON( getState() ) );
	}

	/**
	 * Returns the current state of our component.
	 *
	 * @includeComputed Boolean | Set to true to include computed properties in the returned state.
	 * @return Struct
	 */
	function getState( boolean includeComputed = false ){
		var state = {};

		var data = getDataProperties();

		data.each( function( key, value ){
			if ( isClosure( arguments.value ) ) {
				// Render the closure and store in our data properties
				data[ key ] = arguments.value();
				state[ arguments.key ] = data[ key ];
			} else {
				if ( isSimpleValue( arguments.value ) || isArray( arguments.value ) || isStruct( arguments.value ) ) {
					state[ arguments.key ] = arguments.value;
				} else if ( isNull( arguments.value ) ) {
					state[ arguments.key ] = javacast( "null", 0 );
				} else {
					state[ arguments.key ] = "";
				}
			}
		} );

		if ( whenTrimStrings() ) {
			state.each( function( key, value ){
				if ( isSimpleValue( state[ key ] ) ) {
					state[ key ] = trim( state[ key ] );
				}
			} );
		}

		state = state.map( function( key, value, data ){
			if ( isNull( value ) ) {
				return javacast( "null", 0 );
			}
			return value;
		} );

		return state;
	}

	/**
	 * Returns the meta data for this component.
	 * Ensures that we only run this once.
	 *
	 * @return Struct
	 */
	function getMeta(){
		if ( isNull( variables.meta ) ) {
			variables.meta = getMetadata( getParent() );
		}
		return variables.meta;
	}

	function getRequestContext(){
		return getController().getRenderer().getRequestContext();
	}

	/**
	 * Returns the names of the listeners defined on our component.
	 *
	 * @return Array
	 */
	function getListenerNames(){
		return structKeyList( getListeners() ).listToArray();
	}

	/**
	 * Returns our HTTP referer.
	 *
	 * @return String
	 */
	function getHTTPReferer(){
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
	function getPath(){
		var queryStringValues = getQueryStringValues();

		if ( len( queryStringValues ) ) {
			var referer = getHTTPReferer();

			// Strip away any queryString parameters from the referer so
			// we don't duplicate them when we append the queryStringValues below.
			if ( referer contains "?" ) {
				referer = listGetAt( referer, 1, "?" );
			}

			return "#referer#?#queryStringValues#";
		}

		// Return empty string by default;
		return getHTTPReferer();
	}

	/**
	 * Check if there are properties to be included in our query string
	 * and assembles them together in a single string to be used within a URL.
	 *
	 * @return String
	 */
	function getQueryStringValues(){
		// Default with an empty array
		if ( !structKeyExists( variables, "queryString" ) ) {
			return "";
		}

		var currentState = getState();

		// Handle array of property names
		if ( isArray( getQueryString() ) ) {
			var result = getQueryString().reduce( function( agg, prop ){
				agg &= prop & "=" & currentState[ prop ];
				return agg;
			}, "" );
		} else {
			var result = "";
		}

		return result;
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
	function mount( parameters = {}, key = "" ){
		arguments.comp = this;
		arguments.event = getEvent();
		arguments.rc = getCollection();
		arguments.prc = getPrivateCollection();
		getConcern( "OnMount" ).handle( argumentCollection = arguments );
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
	function reset( property ){
		if ( isNull( arguments.property ) ) {
			// Reset all properties
			getDataProperties().each( function( key, value ){
				reset( key );
			} );
		} else if ( isArray( arguments.property ) ) {
			// Reset each property in our array individually
			arguments.property.each( function( prop ){
				reset( prop );
			} );
		} else {
			var beforeHydrationState = getBeforeHydrationState();
			// Reset individual property
			setProperty( arguments.property, beforeHydrationState[ arguments.property ] );
		}
	}

	function resetExcept( property ){
		if ( isNull( arguments.property ) ) {
			throw( type="ResetException", message="Cannot reset a null property." );
		}

		// Reset all properties except what was provided
		getDataProperties().each( function( key, value ){
			if ( isArray( property ) ) {
				if ( !arrayFindNoCase( property, arguments.key ) ) {
					reset( key );
				}
			} else if ( property != key ) {
				reset( key );
			}
		} );
	}

	/**
	 * Returns a SHA-256 hash of the passed in content.
	 *
	 * @return string
	 */
	function generateHash( content ){
		return hash( content, "SHA-256" );
	}

	/**
	 * Toggle a data property
	 */
	function toggleDataProperty( dataProperty ){
		var dataProperties = getDataProperties();

		if ( dataProperties.keyExists( dataProperty ) ) {
			var currentValue = dataProperties[ dataProperty ];

			if ( isBoolean( currentValue ) ) {
				invoke( this, "set#arguments.dataProperty#", [ booleanFormat( !currentValue ) ] );
			} else {
				throw(
					message = "The data property '#arguments.dataProperty#' must be a boolean value (true/false) for toggling."
				);
			}

			return;
		}

		throw( message = "Cannot find data property '#arguments.dataProperty#' for toggling." );
	}

	/**
	 * Finishes an upload.
	 *
	 * @return void
	 */
	function finishUpload( params ){
		var fileUpload = getController()
			.getWireBox()
			.getInstance( name = "FileUpload@cbwire", initArguments = { comp : this, params : params } );

		getRenderingOverrides()[ params[ 1 ] ] = fileUpload;
		setFinishedUpload( true );
		getDirtyProperties().append( params[ 1 ] );
		emitSelf(
			"upload:finished",
			params[ 1 ],
			[ "nf48Fr0I6Buvk6DnxBLbDVw7W2NMtO-metaMjAyMi0wOC0yMSAwNy41Mi41MC5naWY=-.gif" ]
		);
	}

	/**
	 * Apply cbwire attribute to the outer element in the provided rendering.
	 *
	 * @rendering String | The view rendering.
	 */
	function applyWiringToOuterElement( required rendering ){
		var renderingResult = "";

		// Provide a hash of our rendering which is used by Livewire JS.
		var renderingHash = hash( arguments.rendering );

		// Determine our outer element.
		var outerElement = getOuterElement( arguments.rendering );

		// Add properties to top element to make cbwire actually work.
		if ( getIsInitialRendering() ) {
			// Initial rendering
			renderingResult = rendering.replaceNoCase(
				outerElement,
				outerElement & " wire:id=""#getID()#"" wire:initial-data=""#serializeJSON( getInitialData( rendering ) ).replace( """", "&quot;", "all" )#""",
				"once"
			);
			renderingResult &= "#chr( 10 )#<!-- Livewire Component wire-end:#getID()# -->";
		} else {
			// Subsequent renderings
			renderingResult = rendering.replaceNoCase( outerElement, outerElement & " wire:id=""#getID()#""", "once" );
		}


		return renderingResult;
	}

	function _addDirtyProperty( property ){
		getDirtyProperties().append( arguments.property );
	}

	/**
	 * Returns true if the provided method name can be found on our component.
	 *
	 * @methodName String | The method name we are checking.
	 * @return Boolean
	 */
	function hasMethod( required methodName ){
		return structKeyExists( getParent(), arguments.methodName );
	}

	/**
	 * Renders our component's view.
	 *
	 * @return Void
	 */
	function renderIt(){
		if ( structKeyExists( getParent(), "onLoad" ) ) {
			getParent()
				.onLoad( event=event, rc=arguments.rc, prc=arguments.prc );
		}
		var html = view( view = getComponentTemplatePath() );
		cleanup();
		return html;
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
		arguments.args = getState( includeComputed = true );

		// If there are any rendering overrides ( like during file upload ), then merge those in
		structAppend( arguments.args, getRenderingOverrides(), true );

		// Provide validation results, either validation results we captured from our action or run them now.
		if ( isValidationModuleInstalled() ) {
			arguments.args[ "validation" ] = isNull( getValidationResult() ) ? validate() : getValidationResult();
		}

		// Include a reference to the component's id
		arguments.args[ "_id" ] = getID();

		/*
			Store our latest rendered id in the request scope so that it can be
			read by the entangle() method.
		*/
		getEvent().setPrivateValue( "cbwire_lastest_rendered_id", getID() );

		arguments.args[ "computed" ] = getComputedProperties();

		arguments.args[ "parent" ] = this;

		if ( structKeyExists( getParent(), "onRender" ) ) {
			// Render custom onRender method
			var result = getParent().onRender( args = arguments.args );
		} else {
			// Render our view using a RendererEncapsulator
			savecontent variable="result" {
				cfmodule(
					template = "RendererEncapsulator.cfm",
					cbwireTemplate = getComponentTemplatePath(),
					cbwireComponent = this,
					event = getEvent(),
					args = arguments.args
				);
			}
		}

		return result;
	}


	/**
	 * Parses out any directly rendered children for this component.
	 *
	 * @rendering string | The rendering to parse
	 * @return struct
	 */
	function getChildren( required string rendering ){

		var matches = reMatchNoCase( "<[A-Za-z]+\s*wire:id=""[A-Za-z0-9\-]+""", rendering );

		if ( !getIsInitialRendering() && arrayLen( matches) > 1 ) {
			matches.deleteAt( 1 ); // remove first match which is the same as the current component
		}

		var agg = matches.reduce( function( agg, match, index ){
			var idRegexResult = reFindNoCase( "wire:id=""([A-Za-z0-9\-]+)""", match, 1, true );
			var id = idRegexResult.match[ 2 ];

			var tagRegexResult = reFindNoCase( "<([A-Za-z]+)\s*wire:id=""([A-Za-z0-9\-]+)""", match, 1, true );
			var tag = tagRegexResult.match[ 2 ];

			agg[ id ] = { "id" : id, "tag" : tag };
			return agg;
		}, {} );
		return agg;
	}

	/**
	 * Returns true if cbValidation is installed.
	 *
	 * @return boolean
	 */
	function isValidationModuleInstalled(){
		return getController()
			.getModuleService()
			.getLoadedModules()
			.findNoCase( "cbvalidation" ) ? true : false;
	}

	/**
	 * Perform any cleanup work such as
	 * clearing single-file component assets.
	 */
	function cleanup(){
		if ( getParent().isSingleFileComponent() ) {
			var currentDir = getDirectoryFromPath( getCurrentTemplatePath() );
			var templatePath = getSettings().moduleRootPath & "/models/tmp/#getParent().getSingleFileComponentID()#.cfm";
			var componentPath = getSettings().moduleRootPath & "/models/tmp/#getParent().getSingleFileComponentID()#.cfc";

			if ( !getSettings().cacheSingleFileComponents ) {
				if ( fileExists( templatePath ) ) {
					fileDelete( templatePath );
				}

				if ( fileExists( componentPath ) ) {
					fileDelete( componentPath );
				}
			}
		}
	}

	/**
	 * Returns the computed properties wrapped with
	 * checks for caching.
	 *
	 * @return struct
	 */
	function getComputedPropertiesWithCaching(){
		var result = {};
		// Loop through computed properties and setup caching checks
		getComputedProperties().each( function( propertyName, method ){
			result[ propertyName ] = function( caching = true ){
				if ( caching ) {
					var cache = getCache();
					if ( !cache.keyExists( propertyName ) ) {
						cache[ propertyName ] = method();
					}
					return cache[ propertyName ];
				} else {
					return method();
				}
			};
		} );

		return result;
	}

	/**
	 * Returns the current ColdBox RequestContext event.
	 *
	 * @return RequestContext
	 */
	function getEvent(){
		return getRequestService().getContext();
	}

	/**
	 * Returns our event's public request collection.
	 *
	 * @return Struct
	 */
	function getCollection(){
		return getEvent().getCollection( argumentCollection = arguments );
	}

	/**
	 * Returns our event's private request collection.
	 *
	 * @return Struct
	 */
	function getPrivateCollection(){
		return getEvent().getPrivateCollection( argumentCollection = arguments );
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
		getConcern( "DynamicGetterSetter" ).handle(
			comp = this,
			methodName = arguments.missingMethodName,
			methodArguments = arguments.missingMethodArguments
		);

		if ( reFindNoCase( "^reset.+", arguments.missingMethodName ) ) {
			var dataPropertyName = reReplaceNoCase( arguments.missingMethodName, "^reset", "", "one" );
			reset( dataPropertyName );
		}
	}

	function getDataProperties(){
		var props = variables.dataProperties;
		// Merge properties defined with property tag
		getParent().getPropertyTagDataProperties().each( function( prop ) {
			props[ prop.name ] = getParent().getVariables()[ prop.name ];
		} );
		return props;
	}
}
