component extends="BaseEmitConcern" {

	function handle( required componentName, required eventName ){
		var emitParameters = parseEmitToParameters( argumentCollection = arguments );

		var emitter = {
			"event" : arguments.eventName,
			"params" : emitParameters,
			"to" : arguments.componentName
		};

		// Capture the emit as we will need to notify the UI in our response
		getCaller().trackEmit( emitter );
	}

}
