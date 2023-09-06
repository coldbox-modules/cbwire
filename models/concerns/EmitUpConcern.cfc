component extends="BaseEmitConcern" {

    function handle( comp, eventName ) {
		var localParameters = parseEmitArguments( argumentCollection=arguments );
		
		var emitter = {
			"event" : arguments.eventName,
			"params" : localParameters,
			"ancestorsOnly" : true
		};

		// Capture the emit as we will need to notify the UI in our response
		arguments.comp.trackEmit( emitter );
    }
}