/**
 * This is the base object that all cbwire components extend for functionality.
 *
 * Most internal methods and properties here are namespaced with a "$" to avoid collisions
 * with child components.
 */
component extends="coldbox.system.FrameworkSupertype" accessors="true" {

	property name="controller" inject="coldbox";

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

	// Determines if component should be rendered or not.
	property name="noRendering" default="false";

	// Determines if component is being initially rendered or subsequently rendered
	property name="isInitialRendering" default="false";

	/**
	 * Holds the component's state values before hydration occurs.
	 * Used to compare what's changed and perform dirty tracking
	 */
	property name="beforeHydrationState";

	/**
	 * Component UUID
	 */
	property name="id";

	/**
	 * The default data struct for cbwire components.
	 * This should be overidden in the child component
	 * with data properties.
	 */
	property name="dataProperties";

	/**
	 * The default computed struct for cbwire components.
	 * This should be overidden in the child component with
	 * computed properties.
	 */
	property name="computedProperties";

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
		setIsInitialRendering( false );
		setComputedProperties( variables.computed );
		setBeforeHydrationState( {} );
		setDataProperties( variables.data );
		variables.emits = [];
		setID( $generateId() );
		variables.$children = {};
		setNoRendering( false );
		return this;
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
		return getRenderer().relocate( argumentCollection = arguments );
	}

	/**
	 * Returns a 21 character UUID to uniquely identify the component HTML during rendering.
	 * The 21 characters matches Livewire JS native implementation.
	 *
	 * @return String
	 */
	function getId(){
		return variables.id;
	}

	/**
	 * Returns the initial data of our component, which is ultimately serialized
	 * to json and return in the view as our component is first rendered.
	 *
	 * @renderingHash String | Hash of the view rendering. Used to populate serverMemo.htmlHash in struct response.
	 *
	 * @return Struct
	 */
	function getInitialData( renderingHash = "" ){
		return {
			"fingerprint" : {
				"id"     : getId(),
				"name"   : getMeta().name,
				"locale" : "en",
				"path"   : getPath(),
				"method" : "GET"
			},
			"effects"    : { "listeners" : variables.getListenerNames() },
			"serverMemo" : {
				"children" : [],
				"errors"   : [],
				"htmlHash" : getChecksum(),
				"data"     : getState(
					includeComputed = false,
					nullEmpty       = true
				),
				"dataMeta" : [],
				"checksum" : getChecksum()
			}
		};
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
	function subsequentRenderIt(){
		announce(
			"onCBWireSubsequentRenderIt",
			{ component : this }
		);
		return this;
	}

	/**
	 * Returns the checksum hash of our current state.
	 *
	 * @return String
	 */
	function getChecksum(){
		return hash( serializeJSON( getState() ) );
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

		var data = getDataProperties();

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
			getComputedProperties().each( function( key, value ){
				state[ key ] = value();
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

		// Render our view using coldbox rendering
		var rendering = super.view( argumentCollection = arguments );

		// Add properties to top element to make cbwire actually work.
		return applyWiringToOuterElement( rendering );
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
	function $mount( parameters = {}, key = "" ){
		setIsInitialRendering( true );

		announce(
			"onCBWireMount",
			{
				component  : this,
				parameters : arguments.parameters
			}
		);

		if ( structKeyExists( this, "mount" ) && isCustomFunction( mount ) ) {
			this[ "mount" ](
				parameters = arguments.parameters,
				key        = arguments.key,
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

		// Capture the state before hydration
		setBeforeHydrationState( duplicate( getState() ) );

		return this;
	}

	/**
	 * Hydrates the incoming component with state from our request.
	 *
	 * @wireRequest CBWireRequest
	 *
	 * @return Component
	 */
	function $hydrate( event, rc, prc ){
		announce(
			"onCBWireHydrate",
			{ component : this }
		);
		return this;
	}

	/**
	 * Returns an array of properties that have changed during the request.
	 *
	 * @return Array
	 */
	function $getDirtyProperties(){
		var currentState = getState();

		var arrayUtil = createObject( "java", "java.util.Arrays" );

		var result = getBeforeHydrationState().reduce( function( result, key, value, state ){
			if ( isSimpleValue( value ) && value == currentState[ key ] ) {
				return result;
			} else {
				beforeHydrateValue = createObject( "java", "java.lang.String" ).init( value.toString() ).toCharArray();
				afterHydrateValue  = createObject( "java", "java.lang.String" )
					.init( currentState[ key ].toString() )
					.toCharArray();
				arrayUtil.sort( beforeHydrateValue );
				arrayUtil.sort( afterHydrateValue );
				if (
					arrayUtil.equals(
						beforeHydrateValue,
						afterHydrateValue
					)
				) {
					return result;
				}
			}

			result.append( key );

			return result;
		}, [] );


		return result;
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

		var dirtyProperties = $getDirtyProperties();

		return {
			"effects" : {
				"html"  : len( rendering ) ? rendering : javacast( "null", 0 ),
				"dirty" : $getDirtyProperties(),
				"path"  : getPath(),
				"emits" : getEmits()
			},
			"serverMemo" : {
				"children" : isArray( variables.$children ) ? [] : variables.$children,
				"htmlHash" : "71146cf2",
				"data"     : getState(
					includeComputed = false,
					nullEmpty       = true
				),
				"checksum" : getChecksum()
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
			invokeMethod(
				methodName   = "preUpdate" & arguments.propertyName,
				propertyName = arguments.value
			);
		}

		var data = getDataProperties();

		data[ "#arguments.propertyName#" ] = arguments.value;

		if ( arguments.invokeUpdateMethods ) {
			// Invoke 'postUpdate[prop]' event
			invokeMethod(
				methodName   = "postUpdate" & arguments.propertyName,
				propertyName = arguments.value
			);
		}
	}

	function $getChildren(){
		return variables.$children;
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
		var queryStringValues = variables.getQueryStringValues();

		if ( len( queryStringValues ) ) {
			var referer = variables.getHTTPReferer();

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
	 * Returns any captured emits that need to be returned
	 *
	 * @return Array
	 */
	function getEmits(){
		return variables.emits;
	}

	/**
	 * Returns true if listeners are detected on the component.
	 *
	 * @return Boolean
	 */
	function hasListeners(){
		return arrayLen( variables.getListenerNames() );
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

		return invoke(
			this,
			arguments.methodName,
			params.filter( function( key, value ){
				return !key.findNoCase( "methodName" )
			} )
		);
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
		invokeMethod( "postRefresh" );
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
		trackEmit  = true
	){
		// Invoke 'preEmit' event
		invokeMethod(
			methodName = "preEmit",
			eventName  = arguments.eventName,
			parameters = arguments.parameters
		);

		// Invoke 'preEmit[EventName]' event
		invokeMethod(
			methodName = "preEmit" & arguments.eventName,
			parameters = arguments.parameters
		);

		// Capture the emit as we will need to notify the UI in our response
		if ( arguments.trackEmit ) {
			var emitter = createObject(
				"component",
				"cbwire.models.emit.BaseEmit"
			).init(
				arguments.eventName,
				arguments.parameters
			);

			variables.trackEmit( emitter );
		}

		var listeners = getListeners();

		if ( structKeyExists( listeners, eventName ) ) {
			var listener = listeners[ eventName ];

			if ( len( arguments.eventName ) && hasMethod( listener ) ) {
				return invokeMethod(
					methodName            = listener,
					passThroughParameters = arguments.parameters
				);
			}
		}

		// Invoke 'postEmit' event
		invokeMethod(
			methodName = "postEmit",
			eventName  = arguments.eventName,
			parameters = arguments.parameters
		);

		// Invoke 'postEmit[EventName]' event
		invokeMethod(
			methodName = "postEmit" & arguments.eventName,
			parameters = arguments.parameters
		);
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
		variables.trackEmit( emitter );
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
		var emitter = createObject(
			"component",
			"cbwire.models.emit.EmitUp"
		).init(
			arguments.eventName,
			arguments.parameters
		);

		// Capture the emit as we will need to notify the UI in our response
		variables.trackEmit( emitter );
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
		var emitter = createObject(
			"component",
			"cbwire.models.emit.EmitTo"
		).init(
			arguments.eventName,
			arguments.componentName,
			arguments.parameters
		);

		// Capture the emit as we will need to notify the UI in our response
		variables.trackEmit( emitter );
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
		var settings = variables.$settings;

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
				getDataProperties(),
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
			reset( dataPropertyName );
		}
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
		if ( isArray( arguments.property ) ) {
			// Reset each property in our array individually
			arguments.property.each( function( prop ){
				reset( prop );
			} );
		} else {
			// Reset individual property
			$set(
				arguments.property,
				getBeforeHydrationState()[ arguments.property ]
			);
		}
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
	 * Set the components id.
	 *
	 * @id String | GUID
	 *
	 * @return Void
	 */
	function $setId( required id ){
		variables.id = arguments.id;
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
	 * Check if there are properties to be included in our query string
	 * and assembles them together in a single string to be used within a URL.
	 *
	 * @return String
	 */
	private function getQueryStringValues(){
		// Default with an empty array
		if ( !structKeyExists( variables, "queryString" ) ) {
			return "";
		}

		var currentState = getState();

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
	private function trackEmit( required emitter ){
		var result = emitter.getResult();
		variables.emits.append( result );
	}

	/**
	 * Returns the names of the listeners defined on our component.
	 *
	 * @return Array
	 */
	private function getListenerNames(){
		return structKeyList( getListeners() ).listToArray();
	}

	/**
	 * Apply cbwire attribute to the outer element in the provided rendering.
	 *
	 * @rendering String | The view rendering.
	 */
	private function applyWiringToOuterElement( required rendering ){
		var renderingResult = "";

		// Provide a hash of our rendering which is used by Livewire JS.
		var renderingHash = hash( arguments.rendering );

		// Determine our outer element.
		var outerElement = variables.getOuterElement( arguments.rendering );

		// Add properties to top element to make cbwire actually work.
		if ( getIsInitialRendering() ) {
			// Initial rendering
			renderingResult = rendering.replaceNoCase(
				outerElement,
				outerElement & " wire:id=""#getId()#"" wire:initial-data=""#serializeJSON( getInitialData( renderingHash = renderingHash ) ).replace( """", "&quot;", "all" )#""",
				"once"
			);
		} else {
			// Subsequent renderings
			renderingResult = rendering.replaceNoCase(
				outerElement,
				outerElement & " wire:id=""#getId()#""",
				"once"
			);
		}

		renderingResult &= "#chr( 10 )#<!-- Livewire Component wire-end:#getId()# -->";

		return renderingResult;
	}

	/**
	 * Determines the outer element within our rendering.
	 * If an outer element isn't found, an error is thrown.
	 *
	 * @rendering String | The view rendering.
	 */
	private function getOuterElement( required rendering ){
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
	private function getHTTPReferer(){
		return cgi.HTTP_REFERER;
	}

	function $generateId(){
		return createUUID().replace( "-", "", "all" ).left( 21 );
	}

}
