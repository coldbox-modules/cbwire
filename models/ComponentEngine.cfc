component extends="coldbox.system.FrameworkSupertype" accessors="true" {


	/**
	 * Inject ColdBox, needed by FrameworkSuperType
	 */
	property name="controller" inject="coldbox";

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
     * A beautiful constructor
     */
    function init( required wire, required variablesScope ) {
        setWire( arguments.wire );
        setVariablesScope( arguments.variablesScope );
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

		var result = getWire().get$BeforeHydrationState().reduce( function( result, key, value, state ){
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

}