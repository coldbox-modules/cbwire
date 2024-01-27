component extends="BaseEmitConcern" {

	function handle( required eventName ){
		var emitParameters = parseEmitParameters( argumentCollection=arguments );

		if ( !arguments.keyExists( "track" ) ) {
			arguments.track = true;
		}

		// Capture the emit as we will need to notify the UI in our response
		if ( arguments.track ) {
			var emitter = {
				"event" : arguments.eventName,
				"params" : emitParameters
			};

			getCaller().trackEmit( emitter );
		}
	}

}
