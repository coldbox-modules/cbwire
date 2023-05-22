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

	// Inject the cbwire service
	property name="cbwireService" inject="CBWireService@cbwire";

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
		variables._inlineComponentType = "";
		variables._inlineComponentId = "";
		variables._module = "";
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

		var rendering = applyWiring ? _applyWiringToOuterElement( templateRendering ) : templateRendering;

		// Add properties to top element to make Livewire actually work.
		return rendering;
	}

	/**
	 * Emits a global event from our cbwire component.
	 *
	 * @eventName String | The name of our event to emit.
	 */
	function emit( required eventName ){

		var parameters = _parseEmitArguments( argumentCollection=arguments );

		if ( !arguments.keyExists( "track" ) ) {
			arguments.track = true;
		}

		// Invoke 'preEmit' event
		_invokeMethod( methodName = "preEmit", eventName = arguments.eventName, parameters = parameters );

		// Invoke 'preEmit[EventName]' event
		_invokeMethod( methodName = "preEmit" & arguments.eventName, parameters = parameters );

		// Capture the emit as we will need to notify the UI in our response
		if ( arguments.track ) {
			var emitter = {
				"event" : arguments.eventName,
				"params" : parameters
			};

			_trackEmit( emitter );
		}

		// Invoke 'postEmit' event
		_invokeMethod( methodName = "postEmit", eventName = arguments.eventName, parameters = parameters );

		// Invoke 'postEmit[EventName]' event
		_invokeMethod( methodName = "postEmit" & arguments.eventName, parameters = parameters );
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
		var parameters = _parseEmitArguments( argumentCollection=arguments );

		var emitter = {
			"event" : arguments.eventName,
			"params" : parameters,
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
	 *
	 * @return Void
	 */
	function emitUp( required eventName ){
		var parameters = _parseEmitArguments( argumentCollection=arguments );
		
		var emitter = {
			"event" : arguments.eventName,
			"params" : parameters,
			"ancestorsOnly" : true
		};

		// Capture the emit as we will need to notify the UI in our response
		_trackEmit( emitter );
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
		var parameters = _parseEmitArguments( argumentCollection=arguments );

		// Remove the first param since it's our component name.
		parameters.deleteAt( 1 );

		var emitter = {
			"event" : arguments.eventName,
			"params" : parameters,
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
	function _validate( constraints ){
		arguments.target = isNull( arguments.target ) ? this : arguments.target;
		arguments.constraints = isNull( arguments.constraints ) ? _getConstraints() : arguments.constraints;
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

}
