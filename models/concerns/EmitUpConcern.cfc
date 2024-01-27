component extends="BaseEmitConcern" {

	function handle( required eventName ){
		var emitParameters = parseEmitParameters( argumentCollection = arguments );
		var emitter = {
			"event" : arguments.eventName,
			"params" : emitParameters,
			"ancestorsOnly" : true
		};

		// Capture the emit as we will need to notify the UI in our response
		getCaller().trackEmit( emitter );
	}

}
