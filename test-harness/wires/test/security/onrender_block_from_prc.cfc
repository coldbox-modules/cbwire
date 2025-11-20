component extends="cbwire.models.Component" {

	data = {};

	function onSecure( event, prc, isInitial, params ) {
		// Return true to allow rendering, false to block rendering

		// get the value from the event to determine if rendering is allowed
		return event.getValue( "allowTestWireRender", false, true );
	}


}
