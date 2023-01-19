/**
 * This component is responsible for proxying and caching method calls to
 * any computed properties.
 */
component accessors="true" {

	/**
	 * Holds a reference to our computed properties.
	 */
	property name="computedProperties";

	/**
	 * Holds a reference to our CBWIRE component
	 */
	property name="wire";

	/**
	 * Constructor
	 *
	 * @returns ComputedPropertiesProxy
	 */
	function init( required struct computedProperties, required Component wire ){
		setComputedProperties( arguments.computedProperties );
		setWire( arguments.wire );
		return this;
	}

	/**
	 * Catch all for any methods being invoked.
	 *
	 * @missingMethodName
	 * @missingMethodArguments
	 *
	 * @returns any
	 */
	function onMissingMethod( missingMethodName, missingMethodArguments ){
		return invoke( getComputedProperties(), arguments.missingMethodName, arguments.missingMethodArguments );
	}

}
