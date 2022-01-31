component extends="WireUpdate" {

	/**
	 * Applies this update to the specified component.
	 *
	 * @comp cbwire.models.Component | Component we are updating.
	 */
	function apply( required comp ){
		if ( !arguments.comp.hasListeners() ) {
			return;
		}

		var eventName = this.getPayload()[ "event" ];

		var parameters = this.getPayload()[ "params" ].reduce( function( agg, param ){
			if ( isStruct( param ) ) {
				param.each( function( key, value ){
					agg[ key ] = value;
				} );
			}
			return agg;
		}, {} );

		// Because this is an emit coming from the UI, we need to
		// be sure and not track the emit because track emits are returned
		// to the UI again, resulting in an infinite loop.
		arguments.comp.emit(
			eventName  = eventName,
			parameters = parameters,
			trackEmit  = false
		);
	}

}
