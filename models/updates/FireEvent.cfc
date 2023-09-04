component accessors="true" extends="BaseUpdate" {

	/**
	 * Applies this update to the specified component.
	 *
	 * @comp cbwire.models.Component | Component we are updating.
	 */
	function apply( required comp ){
		if ( !arguments.comp.hasListeners() ) {
			return;
		}

		//arguments.comp._renderComputedProperties();

		var payload = getPayload();
		var eventName = payload.event;
		var params = payload.params;

		arguments.comp._fire( eventName = eventName, parameters = params );
	}

}
