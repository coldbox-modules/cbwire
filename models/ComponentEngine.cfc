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
     * A beautiful constructor
     */
    function init( required wire, required variablesScope ) {
        setWire( arguments.wire );
        setVariablesScope( arguments.variablesScope );
		setBeforeHydrationState( {} );
    }

    /**
     * Returns a unique ID for the component
     */
	function getId(){
        if ( !structKeyExists( variables, "id " ) ){
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
		return arrayLen( getWire().getListenerNames() );
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

		throw(
			type    = "OuterElementNotFound",
			message = "Unable to find an outer element to bind cbwire to."
		);
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

		getWire().get$ComputedProperties().each( function( key, value, computedProperties ){
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
		var currentState = getWire().getState();

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
		getWire().set$IsInitialRendering( true );

		announce(
			"onCBWireMount",
			{
				component  : getWire(),
				parameters : arguments.parameters
			}
		);

		if ( structKeyExists( getWire(), "mount" ) ) {
			getWire().mount(
				parameters = arguments.parameters,
				key        = arguments.key,
				event      = getCBWireRequest().getEvent(),
				rc         = getCBWireRequest().getCollection(),
				prc        = getCBWireRequest().getPrivateCollection()
			);
		} else {
			/**
			 * Use setter population to populate our component.
			 */
			getPopulator().populateFromStruct(
				target       : getWire(),
				trustedSetter: true,
				memento      : arguments.parameters,
				excludes     : ""
			);
		}

		// Capture the state before hydration
		getWire().set$BeforeHydrationState( duplicate( getWire().getState() ) );

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
		getWire().get$Emits().append( result );
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
		if ( arguments.track ) {
			var emitter = createObject(
				"component",
				"cbwire.models.emit.BaseEmit"
			).init(
				arguments.eventName,
				arguments.parameters
			);

			trackEmit( emitter );
		}

		var listeners = getWire().getListeners();

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
			$set(
				arguments.property,
				getBeforeHydrationState()[ arguments.property ]
			);
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
				"id"     : getId(),
				"name"   : getWire().getMeta().name,
				"locale" : "en",
				"path"   : getWire().getPath(),
				"method" : "GET"
			},
			"effects"    : { "listeners" : getWire().getListenerNames() },
			"serverMemo" : {
				"children" : [],
				"errors"   : [],
				"htmlHash" : getChecksum(),
				"data"     : getWire().getState(
					includeComputed = false,
					nullEmpty       = true
				),
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
		return hash( serializeJSON( getWire().getState() ) );
	}

	/**
	 * Hydrates the incoming component with state from our request.
	 *
	 * @wireRequest CBWireRequest
	 *
	 * @return Component
	 */
	function hydrate( event, rc, prc ){
		announce(
			"onCBWireHydrate",
			{ component : getWire() }
		);
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
		if ( getWire().get$IsInitialRendering() ) {
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
	 * Returns the URL which is included in the initial data that is rendered
	 * with the view.
	 *
	 * Inspects the cbwire component for properties that should
	 * be included in the path
	 *
	 * @return String
	 */
	function getPath(){
		var queryStringValues = getWire().getQueryStringValues();

		if ( len( queryStringValues ) ) {
			var referer = getWire().$getHTTPReferer();

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
}