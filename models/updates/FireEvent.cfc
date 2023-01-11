component extends="WireUpdate" {

	/**
	 * Applies this update to the specified component.
	 *
	 * @comp cbwire.models.Component | Component we are updating.
	 */
	function apply( required comp ){
		var engine = arguments.comp.getEngine();

		if ( !engine.hasListeners() ) {
			return;
		}

		engine.renderComputedProperties();

		var payload = this.getPayload();
		var eventName = payload.event;
		var params = payload.params;

		engine.fire( eventName = eventName, parameters = params );
	}

}
