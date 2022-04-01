component extends="coldbox.system.FrameworkSupertype" accessors="true" {

	/**
	 * Inject ColdBox, needed by FrameworkSuperType
	 */
	property name="controller" inject="coldbox";

	/**
	 * Inject module settings
	 */
	property name="settings" inject="coldbox:modulesettings:cbwire";

	/**
	 * The CBWIRE component
	 */
	property name="wire";

	/**
	 * The component's variables scope
	 */
	property name="variablesScope";

	/**
	 * WireBox's populator object
	 */
	property name="populator" inject="wirebox:populator";

	/**
	 * Inject the wire request that's incoming from the browser.
	 */
	property name="cbwireRequest" inject="CBWireRequest@cbwire";

	/**
	 * Holds the component's state values before hydration occurs.
	 * Used to compare what's changed and perform dirty tracking
	 */
	property name="beforeHydrationState";

	/**
	 * Determines if component should be rendered or not.
	 */
	property name="noRendering" default="false";

	/**
	 * Determines if component is being initially rendered or subsequently rendered.
	 */
	property name="isInitialRendering" default="false";

	/**
	 * Determines if file upload operation is being performed.
	 */
	property name="isFileUpload" default="false";

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
	 * Tracks any emitted events during a request lifecycle
	 */
	property name="emittedEvents";

	/**
	 * Holds component metadata.
	 */
	property name="meta";

	/**
	 * A beautiful constructor
	 */
	function init( required wire, required variablesScope ){
		setWire( arguments.wire );
		setVariablesScope( arguments.variablesScope );
		setBeforeHydrationState( {} );
		setDataProperties( {} );
		setComputedProperties( {} );
		setEmittedEvents( [] );
	}

	/**
	 * Returns a unique ID for the component
	 */
	function getId(){
		if ( !structKeyExists( variables, "id " ) ) {
			variables.id = createUUID().replace( "-", "", "all" ).left( 21 )
		}
		return variables.id;
	}

	/**
	 * Returns true if the provided method name can be found on our component.
	 *
	 * @methodName String | The method name we are checking.
	 * @return Boolean
	 */
	function hasMethod( required methodName ){
		return structKeyExists( getWire(), arguments.methodName );
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
	 * Loops through the defined computed properties and invokes the functions once.
	 *
	 * @return void
	 */
	function renderComputedProperties(){
		if ( !structKeyExists( getVariablesScope(), "computed" ) ) {
			return;
		}

		getComputedProperties().each( function( key, value, computedProperties ){
			if ( isCustomFunction( value ) ) {
				computedProperties[ key ] = value();
			}
		} );
	}

	/**
	 * Returns an array of properties that have changed during the request.
	 *
	 * @return Array
	 */
	function getDirtyProperties(){
		var currentState = getState();

		var arrayUtil = createObject( "java", "java.util.Arrays" );

		var result = getBeforeHydrationState().reduce( function( result, key, value, state ){
			if ( isSimpleValue( value ) && value == currentState[ key ] ) {
				return result;
			} else {
				beforeHydrateValue = createObject( "java", "java.lang.String" ).init( value.toString() ).toCharArray();
				afterHydrateValue = createObject( "java", "java.lang.String" )
					.init( currentState[ key ].toString() )
					.toCharArray();

				arrayUtil.sort( beforeHydrateValue );
				arrayUtil.sort( afterHydrateValue );

				if ( arrayUtil.equals( beforeHydrateValue, afterHydrateValue ) ) {
					return result;
				}
			}

			result.append( key );

			return result;
		}, [] );

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
		setIsInitialRendering( true );

		announce(
			"onCBWireMount",
			{
				component : getWire(),
				parameters : arguments.parameters
			}
		);

		if ( structKeyExists( getWire(), "mount" ) ) {
			getWire().mount(
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
				target: getWire(),
				trustedSetter: true,
				memento: arguments.parameters,
				excludes: ""
			);
		}

		// Capture the state before hydration
		getWire().set$BeforeHydrationState( duplicate( getState() ) );

		return getWire();
	}

	/**
	 * Tracks an emit, which is later returned in our API response and used
	 * by cbwire.
	 *
	 * @emitter cbwire.models.emit.BaseEmit | An instance of an emitter.
	 * @return Array;
	 */
	function trackEmit( required emitter ){
		var result = emitter.getResult();
		getEmittedEvents().append( result );
	}

	/**
	 * Emits a global event from our cbwire component.
	 *
	 * @eventName String | The name of our event to emit.
	 * @parameters Struct | The params passed with the emitter.
	 * @trackEmit Boolean | True if you want to notify the UI that the emit occurred.
	 */
	function emit( required eventName, parameters = {}, track = true ){
		// Invoke 'preEmit' event
		invokeMethod( methodName = "preEmit", eventName = arguments.eventName, parameters = arguments.parameters );

		// Invoke 'preEmit[EventName]' event
		invokeMethod( methodName = "preEmit" & arguments.eventName, parameters = arguments.parameters );

		// Capture the emit as we will need to notify the UI in our response
		if ( arguments.track ) {
			var emitter = createObject( "component", "cbwire.models.emit.BaseEmit" ).init(
				arguments.eventName,
				arguments.parameters
			);

			trackEmit( emitter );
		}

		var listeners = getListeners();

		if ( structKeyExists( listeners, eventName ) ) {
			var listener = listeners[ eventName ];

			if ( len( arguments.eventName ) && hasMethod( listener ) ) {
				return invokeMethod( methodName = listener, passThroughParameters = arguments.parameters );
			}
		}

		// Invoke 'postEmit' event
		invokeMethod( methodName = "postEmit", eventName = arguments.eventName, parameters = arguments.parameters );

		// Invoke 'postEmit[EventName]' event
		invokeMethod( methodName = "postEmit" & arguments.eventName, parameters = arguments.parameters );
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
		var emitter = createObject( "component", "cbwire.models.emit.EmitUp" ).init(
			arguments.eventName,
			arguments.parameters
		);

		// Capture the emit as we will need to notify the UI in our response
		trackEmit( emitter );
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
		var emitter = createObject( "component", "cbwire.models.emit.EmitTo" ).init(
			arguments.eventName,
			arguments.componentName,
			arguments.parameters
		);

		// Capture the emit as we will need to notify the UI in our response
		trackEmit( emitter );
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
			getWire(),
			arguments.methodName,
			params.filter( function( key, value ){
				return !key.findNoCase( "methodName" )
			} )
		);
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
			setProperty( arguments.property, getBeforeHydrationState()[ arguments.property ] );
		}
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
		return getRenderer().relocate( argumentCollection = arguments );
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
				"id" : getId(),
				"name" : getMeta().name,
				"locale" : "en",
				"path" : getPath(),
				"method" : "GET"
			},
			"effects" : { "listeners" : getListenerNames() },
			"serverMemo" : {
				"children" : [],
				"errors" : [],
				"htmlHash" : getChecksum(),
				"data" : getState( includeComputed = false, nullEmpty = true ),
				"dataMeta" : [],
				"checksum" : getChecksum()
			}
		};
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
	 * Hydrates the incoming component with state from our request.
	 *
	 * @wireRequest CBWireRequest
	 *
	 * @return Component
	 */
	function hydrate( event, rc, prc ){
		announce( "onCBWireHydrate", { component : getWire() } );
		return getWire();
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
				outerElement & " wire:id=""#getId()#"" wire:initial-data=""#serializeJSON( getInitialData( renderingHash = renderingHash ) ).replace( """", "&quot;", "all" )#""",
				"once"
			);
		} else {
			// Subsequent renderings
			renderingResult = rendering.replaceNoCase( outerElement, outerElement & " wire:id=""#getId()#""", "once" );
		}

		renderingResult &= "#chr( 10 )#<!-- Livewire Component wire-end:#getId()# -->";

		return renderingResult;
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
		return "";
	}

	/**
	 * Check if there are properties to be included in our query string
	 * and assembles them together in a single string to be used within a URL.
	 *
	 * @return String
	 */
	function getQueryStringValues(){
		// Default with an empty array
		if ( !structKeyExists( getVariablesScope(), "queryString" ) ) {
			return "";
		}

		var currentState = getState();

		// Handle array of property names
		if ( isArray( getVariablesScope().queryString ) ) {
			var result = getVariablesScope().queryString.reduce( function( agg, prop ){
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
	function getListeners(){
		if ( structKeyExists( getVariablesScope(), "listeners" ) && isStruct( getVariablesScope().listeners ) ) {
			return getVariablesScope().listeners;
		}
		return {};
	}

	/**
	 * Renders our component's view.
	 *
	 * @return Void
	 */
	function renderIt(){
		announce( "onCBWireRenderIt", { component : getWire() } );
		return getRequestContext().getValue( "_cbwire_rendering" );
	}

	/**
	 * Invokes renderIt() on the cbwire component and caches the rendered
	 * results into variables.rendering.
	 *
	 * @return String
	 */
	function subsequentRenderIt(){
		announce( "onCBWireSubsequentRenderIt", { component : getWire() } );
		return getWire();
	}

	/**
	 * Returns our HTTP referer.
	 *
	 * @return String
	 */
	function getHTTPReferer(){
		return cgi.HTTP_REFERER;
	}

	/**
	 * Returns the names of the listeners defined on our component.
	 *
	 * @return Array
	 */
	function getListenerNames(){
		return structKeyList( getListeners() ).listToArray().append( "upload.generatedSignedUrl" );
	}

	/**
	 * Returns the current state of our component.
	 *
	 * @includeComputed Boolean | Set to true to include computed properties in the returned state.
	 * @return Struct
	 */
	function getState( boolean includeComputed = false, boolean nullEmpty = false ){
		var state = {};

		var data = getDataProperties();

		data.each( function( key, value ){
			if ( isClosure( arguments.value ) ) {
				// Render the closure and store in our data properties
				data[ key ] = arguments.value();
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
			renderComputedProperties();
			getComputedProperties().each( function( key, value ){
				state[ key ] = value;
			} );
		}

		return state;
	}

	/**
	 * Returns the memento for our component which holds the current
	 * state of our component. This is returned on subsequent XHR requests
	 * from cbwire.
	 *
	 * @return Struct
	 */
	function getMemento(){
		if ( getIsFileUpload() ) {
			return {
				"effects" : {
					"html" : javacast( "null", 0 ),
					"emits" : [
						{
							"event" : "upload:generatedSignedUrl",
							"params" : [
								"photo",
								"/livewire/upload-file?expires=1648817149&signature=f7ac1a845425e5d1062a47659c22489a6a38709824ed7dd42a8f5f5a0ad3a38a"
							],
							"selfOnly" : true
						}
					],
					"dirty" : []
				},
				"serverMemo" : { "checksum" : "2f2c1a8b71bc1fc789d21903f500e39033202b94d2693c3357f59efa0ca05815" }
			};
		}
		var rendering = getRequestContext().getValue( "_cbwire_subsequent_rendering" );

		var dirtyProperties = getDirtyProperties();

		return {
			"effects" : {
				"html" : len( rendering ) ? rendering : javacast( "null", 0 ),
				"dirty" : getDirtyProperties(),
				"path" : getPath(),
				"emits" : getEmittedEvents()
			},
			"serverMemo" : {
				"children" : isArray( getVariablesScope().$children ) ? [] : getVariablesScope().$children,
				"htmlHash" : "71146cf2",
				"data" : getState( includeComputed = false, nullEmpty = true ),
				"checksum" : getChecksum()
			}
		}
	}

	/**
	 * Returns the meta data for this component.
	 * Ensures that we only run this once.
	 *
	 * @return Struct
	 */
	function getMeta(){
		if ( isNull( variables.meta ) ) {
			variables.meta = getMetadata( getWire() );
		}
		return variables.meta;
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
		name
	){
		// Pass the properties of the cbwire component as variables to the view
		arguments.args = getState( includeComputed = true, nullEmpty = false );

		// Provide validation results, either validation results we captured from our action or run them now.
		arguments.args[ "validation" ] = isNull( getWire().getValidationResult() ) ? getWire().validate() : getWire().getValidationResult();

		// Render our view using coldbox rendering
		var rendering = super.view( argumentCollection = arguments );

		// Add properties to top element to make cbwire actually work.
		return applyWiringToOuterElement( rendering );
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
	function setProperty( propertyName, value, invokeUpdateMethods = false ){
		if ( arguments.invokeUpdateMethods ) {
			// Invoke '$preUpdate[prop]' event
			invokeMethod( methodName = "preUpdate" & arguments.propertyName, propertyName = arguments.value );
		}

		var data = getDataProperties();

		data[ "#arguments.propertyName#" ] = arguments.value;

		if ( arguments.invokeUpdateMethods ) {
			// Invoke 'postUpdate[prop]' event
			invokeMethod( methodName = "postUpdate" & arguments.propertyName, propertyName = arguments.value );
		}
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
	function handleMissingMethod( required missingMethodName, required missingMethodArguments ){
		var settings = getSettings();

		var data = getDataProperties();

		var computed = getComputedProperties();

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
					setProperty( dataPropertyName, arguments.missingMethodArguments.value );
				} else {
					setProperty( dataPropertyName, arguments.missingMethodArguments[ 1 ], true );
				}
			} else if (
				structKeyExists( settings, "throwOnMissingSetterMethod" ) && settings.throwOnMissingSetterMethod == true
			) {
				throw( type = "WireSetterNotFound", message = "The wire property '#dataPropertyName#' was not found." );
			}
		}

		if ( reFindNoCase( "^reset.+", arguments.missingMethodName ) ) {
			var dataPropertyName = reReplaceNoCase( arguments.missingMethodName, "^reset", "", "one" );
			reset( dataPropertyName );
		}
	}

	function startUpload( required params ){
		setIsFileUpload( true );
		emit( eventName = "upload.generatedSignedUrl", parameters = params, track = true );
	}

	function finishUpload(){
		//
	}

}
