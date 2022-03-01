/**
 * This is the base object that all cbwire components extend for functionality.
 *
 * Most internal methods and properties here are namespaced with a "$" to avoid collisions
 * with child components.
 */
component extends="coldbox.system.FrameworkSupertype" accessors="true" {

	// Inject ColdBox, needed by FrameworkSuperType
	property name="controller" inject="coldbox";

	// Inject LogBox.
	property name="logBox" inject="logbox";

	// Inject scoped logger.
	property name="log" inject="logbox:logger:{this}";

	// Component engine
	property name="engine";

	// Inject the wire request that's incoming from the browser.
	property name="$cbwireRequest" inject="CBWireRequest@cbwire";

	// Determines if component should be rendered or not.
	property name="$noRendering" default="false";

	// Determines if component is being initially rendered or subsequently rendered
	property name="$isInitialRendering" default="false";

	/**
	 * The default data struct for cbwire components.
	 * This should be overidden in the child component
	 * with data properties.
	 */
	property name="$dataProperties";

	/**
	 * The default computed struct for cbwire components.
	 * This should be overidden in the child component with
	 * computed properties.
	 */
	property name="$computedProperties";

	/**
	 * Track any emitted events during a request lifecycle
	 */
	property name="$emits";

	/**
	 * Our beautiful, simple constructor.
	 *
	 * @return Component
	 */
	function init(){
		if ( isNull( variables.data ) ) {
			variables.data = {};
		}
		if ( isNull( variables.computed ) ) {
			variables.computed = {};
		}
		set$IsInitialRendering( false );
		set$ComputedProperties( variables.computed );
		set$DataProperties( variables.data );
		set$Emits( [] );
		variables.$children = {};
		set$NoRendering( false );
		return this;
	}

	function onDIComplete(){
		setEngine( getInstance( name="ComponentEngine@cbwire", initArguments={ wire: this, variablesScope: variables } ) );
		getEngine().setBeforeHydrationState( {} );
	}

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
	void function relocate(
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
		return getEngine().relocate( argumentCollection=arguments );
	}

	/**
	 * Renders our component's view.
	 *
	 * @return Void
	 */
	function renderIt(){
		announce(
			"onCBWireRenderIt",
			{ component : this }
		);
		return getRequestContext().getValue( "_cbwire_rendering" );
	}

	/**
	 * Invokes renderIt() on the cbwire component and caches the rendered
	 * results into variables.rendering.
	 *
	 * @return String
	 */
	function $subsequentRenderIt(){
		announce(
			"onCBWireSubsequentRenderIt",
			{ component : this }
		);
		return this;
	}

	/**
	 * Returns the current state of our component.
	 *
	 * @includeComputed Boolean | Set to true to include computed properties in the returned state.
	 * @return Struct
	 */
	function getState(
		boolean includeComputed = false,
		boolean nullEmpty       = false
	){
		/**
		 * Get our data properties for our current state.
		 */
		var state = {};

		var data = get$DataProperties();

		data.each( function( key, value ){
			if ( isClosure( arguments.value ) ) {
				// Render the closure and store in our data properties
				data[ key ]            = arguments.value();
				state[ arguments.key ] = data[ key ];
			} else {
				state[ arguments.key ] = arguments.value;
			}
		} );

		if ( arguments.nullEmpty ) {
			state = state.map( function( key, value, data ){
				if (
					isNull( value ) ||
					( isValid( "String", value ) && !len( value ) )
				) {
					return javacast( "null", 0 );
				}
				return value;
			} );
		}


		if ( arguments.includeComputed ) {
			getEngine().renderComputedProperties();
			get$ComputedProperties().each( function( key, value ){
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
	function hasMethod( required methodName ){
		return structKeyExists( this, arguments.methodName );
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
		view                   = "",
		struct args            = {},
		module                 = "",
		boolean cache          = false,
		cacheTimeout           = "",
		cacheLastAccessTimeout = "",
		cacheSuffix            = "",
		cacheProvider          = "template",
		collection,
		collectionAs               = "",
		numeric collectionStartRow = "1",
		numeric collectionMaxRows  = 0,
		collectionDelim            = "",
		boolean prePostExempt      = false,
		name
	){
		// Pass the properties of the cbwire component as variables to the view
		arguments.args = getState(
			includeComputed = true,
			nullEmpty       = false
		);

		arguments.args[ "validation" ] = validate( this );

		// Render our view using coldbox rendering
		var rendering = super.view( argumentCollection = arguments );

		// Add properties to top element to make cbwire actually work.
		return getEngine().applyWiringToOuterElement( rendering );
	}

	/**
	 * Returns the memento for our component which holds the current
	 * state of our component. This is returned on subsequent XHR requests
	 * from cbwire.
	 *
	 * @return Struct
	 */
	function $getMemento(){
		var rendering = getRequestContext().getValue( "_cbwire_subsequent_rendering" );

		var dirtyProperties = getEngine().getDirtyProperties();

		return {
			"effects" : {
				"html"  : len( rendering ) ? rendering : javacast( "null", 0 ),
				"dirty" : getEngine().getDirtyProperties(),
				"path"  : getEngine().getPath(),
				"emits" : get$Emits()
			},
			"serverMemo" : {
				"children" : isArray( variables.$children ) ? [] : variables.$children,
				"htmlHash" : "71146cf2",
				"data"     : getState(
					includeComputed = false,
					nullEmpty       = true
				),
				"checksum" : getEngine().getChecksum()
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
	function $set(
		propertyName,
		value,
		invokeUpdateMethods = false
	){
		if ( arguments.invokeUpdateMethods ) {
			// Invoke '$preUpdate[prop]' event
			getEngine().invokeMethod(
				methodName   = "preUpdate" & arguments.propertyName,
				propertyName = arguments.value
			);
		}

		var data = get$DataProperties();

		data[ "#arguments.propertyName#" ] = arguments.value;

		if ( arguments.invokeUpdateMethods ) {
			// Invoke 'postUpdate[prop]' event
			getEngine().invokeMethod(
				methodName   = "postUpdate" & arguments.propertyName,
				propertyName = arguments.value
			);
		}
	}

	function $getChildren(){
		return variables.$children;
	}

	/**
	 * Returns the listeners defined on the component.
	 * If no listeners are defined, an empty struct is returned.
	 *
	 * @return Struct
	 */
	function getListeners(){
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
	function getMeta(){
		if ( !structKeyExists( variables, "meta" ) ) {
			variables.meta = getMetadata( this );
		}
		return variables.meta;
	}

	/**
	 * Invokes a postRefresh event and currently nothing else.
	 * This is used with cbwire's polling functionality which
	 * refreshes the component.
	 *
	 * @return Void
	 */
	function refresh(){
		// Invoke 'postRefresh' event
		getEngine().invokeMethod( "postRefresh" );
	}

	/**
	 * Emits a global event from our cbwire component.
	 *
	 * @eventName String | The name of our event to emit.
	 * @parameters Struct | The params passed with the emitter.
	 * @trackEmit Boolean | True if you want to notify the UI that the emit occurred.
	 */
	function emit(
		required eventName,
		parameters = {},
		track  = true
	){
		return getEngine().emit( argumentCollection=arguments );
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
	function emitSelf( required eventName, parameters = {} ){
		var emitter = createObject(
			"component",
			"cbwire.models.emit.EmitSelf"
		).init(
			arguments.eventName,
			arguments.parameters
		);

		// Capture the emit as we will need to notify the UI in our response
		getEngine().trackEmit( emitter );
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
		return getEngine().emitUp( argumentCollection=arguments );
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
	function emitTo(
		required eventName,
		required componentName,
		parameters = []
	){
		return getEngine().emitTo( argumentCollection=arguments );
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
		var settings = getEngine().getSettings();

		var data = get$DataProperties();

		var computed = get$ComputedProperties();

		if (
			reFindNoCase(
				"^get.+",
				arguments.missingMethodName
			)
		) {
			// Extract data property name from the getter method called.
			var propertyName = reReplaceNoCase(
				arguments.missingMethodName,
				"^get",
				"",
				"one"
			)

			// Check to see if the data property name is defined on the component.
			if ( structKeyExists( get$DataProperties(), propertyName ) ) {
				return data[ propertyName ];
			}

			// Check to see if the computed property name is defined in the component.
			if (
				structKeyExists(
					get$ComputedProperties(),
					propertyName
				)
			) {
				return computed[ propertyName ];
			}
		}

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
			var dataPropertyExists = structKeyExists(
				get$DataProperties(),
				dataPropertyName
			);

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
						arguments.missingMethodArguments[ 1 ],
						true
					);
				}
			} else if (
				structKeyExists(
					settings,
					"throwOnMissingSetterMethod"
				) && settings.throwOnMissingSetterMethod == true
			) {
				throw(
					type    = "WireSetterNotFound",
					message = "The wire property '#dataPropertyName#' was not found."
				);
			}
		}

		if (
			reFindNoCase(
				"^reset.+",
				arguments.missingMethodName
			)
		) {
			var dataPropertyName = reReplaceNoCase(
				arguments.missingMethodName,
				"^reset",
				"",
				"one"
			);
			getEngine().reset( dataPropertyName );
		}
	}

	/**
	 * When called, the component is flagged so that no rendering will occur.
	 *
	 * @return void
	 */
	function noRender(){
		set$NoRendering( true );
	}

	/**
	 * Returns LogBox instance.
	 *
	 * @return LogBox
	 */
	function getLogBox(){
		return variables.logbox;
	}

	/**
	 * Returns Logger instance.
	 */
	function getLogger(){
		return variables.log;
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
	function $getHTTPReferer(){
		return cgi.HTTP_REFERER;
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
	function validate(){
		arguments.target            = isNull( arguments.target ) ? this : arguments.target;
		var result                  = getValidationManager().validate( argumentCollection = arguments );
		variables.$validationResult = result;
		return result;
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

}
