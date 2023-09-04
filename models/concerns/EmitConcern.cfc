component accessors="true" singleton {

    function handle( comp, eventName ) {

 		var parameters = parseEmitArguments( argumentCollection=arguments );
        
		if ( !arguments.keyExists( "track" ) ) {
            arguments.track = true;
		}

		// Capture the emit as we will need to notify the UI in our response
		if ( arguments.track ) {
			var emitter = {
				"event" : arguments.eventName,
				"params" : parameters
			};

			comp.trackEmit( emitter );
		}

    }

    /**
	 * Parse out emit arguments and parameters
	 */
	function parseEmitArguments( required eventName ) {
		var argumentsRef = arguments;
		return arguments.reduce( function ( agg, argument ) {
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