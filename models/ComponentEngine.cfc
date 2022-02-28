component accessors="true" {


    /** 
     * The CBWIRE component
     */
    property name="wire";

    /**
     * A beautiful constructor
     */
    function init( required wire ) {
        setWire( arguments.wire );
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
}