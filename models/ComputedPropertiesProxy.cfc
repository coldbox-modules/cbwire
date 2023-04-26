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
	 * Holds a reference to our internal cache.
	 */
	property name="cache";

	/**
	 * Constructor
	 *
	 * @returns ComputedPropertiesProxy
	 */
	function init( required struct computedProperties, required Component wire ){
		setComputedProperties( arguments.computedProperties );
		setWire( arguments.wire );
		setCache( {} );
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
		
		var shouldUseCache = missingMethodArguments.keyExists( "cache" ) && !missingMethodArguments.cache ? false : true;
		var cache = getCache();
		
		if ( cache.keyExists( missingMethodName ) && shouldUseCache ) {
			return cache[ missingMethodName ];
		} else {
			var result = invoke( getComputedProperties(), arguments.missingMethodName, arguments.missingMethodArguments );
			
			if ( shouldUseCache ) {
				cache[ missingMethodName ] = result;
			}

			return result;
		}
	}

}
