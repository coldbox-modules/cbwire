component {
    /**
	 * Parse out emit arguments and parameters
	 */
	function parseEmitArguments( required eventName ) {

		var argumentsRef = arguments;

		return argumentsRef.reduce( function ( agg, argument ) {

			if ( isNull( argumentsRef[ argument ] ) || argument == "ComponentName" ) {
				return agg;
			}

			var value = argumentsRef[ argument ];

			if ( argument == "eventName" ) return agg;

			if ( isObject( value ) ) {
				return agg;
			} else if ( isArray( value ) ) {
				value.each( function( nestedArgument ) {
					agg.append( nestedArgument );
				} );
			} else {
				agg.append( value );
			}

			return agg;
		}, [] );
	}
}