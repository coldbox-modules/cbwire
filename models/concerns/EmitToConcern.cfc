component extends="BaseEmitConcern" singleton {

	function handle( comp, componentName, eventName ){
		var localParameters = parseEmitArguments( argumentCollection = arguments );

		var emitter = {
			"event" : arguments.eventName,
			"params" : localParameters,
			"to" : arguments.componentName
		};

		// Capture the emit as we will need to notify the UI in our response
		arguments.comp.trackEmit( emitter );
	}

}
