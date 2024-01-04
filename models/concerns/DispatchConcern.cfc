component extends="BaseEmitConcern" singleton {

	function handle( comp, eventName, parameters ){
		var dispatcher = {
			"event" : arguments.eventName,
			"data" : arguments.parameters
		};

		comp.trackDispatch( dispatcher );
	}

}
