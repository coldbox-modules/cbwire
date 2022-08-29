/**
 * This is the base object that all cbwire components extend for functionality.
 *
 * Most internal methods and properties here are namespaced with a "$" to avoid collisions
 * with child components.
 */
component accessors="true" {

	// Inject ColdBox, needed by FrameworkSuperType
	property name="controller" inject="coldbox";

	// Component engine
	property name="engine";

	// Holds our validation result.
	property name="validationResult";

	/**
	 * Invoked when dependency injection complete.
	 */
	function onDIComplete(){
		variables.$children = {};
		variables.data = isNull( variables.data ) ? {} : variables.data;
		variables.computed = isNull( variables.computed ) ? {} : variables.computed;

		/**
		 * The core functions of cbwire components are separated into ComponentEngine@cbwire.
		 * There were several reasons for this, the biggest being a clean separation of
		 * concerns. This was also done to avoid cluttering up the variables scope of the component
		 * and causing naming collisions with user defined component methods and properties.
		 */
		var engine = getInstance(
			name = "ComponentEngine@cbwire",
			initArguments = {
				wire : this,
				variablesScope : variables
			}
		);
		setEngine( engine );

		engine.setBeforeHydrationState( {} );
		engine.setNoRendering( false );
		engine.setDataProperties( variables.data );
		engine.setComputedProperties( variables.computed );
		engine.setEmittedEvents( [] );
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
		return getEngine().relocate( argumentCollection = arguments );
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
		var engine = getEngine();

		var templateRendering = engine.view( argumentCollection = arguments );
		// Add properties to top element to make Livewire actually work.
		return applyWiring ? engine.applyWiringToOuterElement( templateRendering ) : templateRendering;
	}

	/**
	 * Emits a global event from our cbwire component.
	 *
	 * @eventName String | The name of our event to emit.
	 * @parameters Array | The params passed with the emitter.
	 * @track Boolean | True if you want to notify the UI that the emit occurred.
	 *
	 * @return void
	 */
	function emit( required eventName, parameters = [], track = true ){
		return getEngine().emit( argumentCollection = arguments );
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
		var emitter = createObject( "component", "cbwire.models.emit.EmitSelf" ).init(
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
		return getEngine().emitUp( argumentCollection = arguments );
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
		return getEngine().emitTo( argumentCollection = arguments );
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
		return getEngine().handleMissingMethod( argumentCollection = arguments );
	}

	/**
	 * When called, the component is flagged so that no rendering will occur.
	 *
	 * @return void
	 */
	function noRender(){
		getEngine().setNoRendering( true );
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
		getEngine().reset( arguments.property );
	}
	/**
	 * Renders our component's view.
	 *
	 * @return Void
	 */
	function renderIt(){
		return getEngine().renderIt();
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
