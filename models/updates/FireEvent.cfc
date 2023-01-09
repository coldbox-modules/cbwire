component extends="WireUpdate" {

	/**
	 * Applies this update to the specified component.
	 *
	 * @comp cbwire.models.Component | Component we are updating.
	 */
	function apply( required comp ){
		if ( !arguments.comp.getEngine().hasListeners() ) {
			return;
		}

		var eventName = this.getPayload()[ "event" ];
		var params = this.getPayload()[ "params" ];

		arguments.comp.getEngine().fire( eventName = eventName, parameters = params );
	}

}
