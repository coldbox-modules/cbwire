component extends="WireUpdate" {

	/**
	 * Applies this update to the specified component.
	 *
	 * @comp cbwire.models.Component | Component we are updating.
	 */
	function apply( required comp ){
		var engine = arguments.comp.getEngine();

		if ( !arguments.comp._hasListeners() ) {
			return;
		}

		arguments.comp._renderComputedProperties();

		var payload = this.getPayload();
		var eventName = payload.event;
		var params = payload.params;

		arguments.comp._fire( eventName = eventName, parameters = params );
	}

}
