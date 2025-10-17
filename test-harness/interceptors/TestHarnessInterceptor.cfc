component {

	property name="log" inject="logbox:root";

	function cbWireOnMount() {
		log.debug( "cbWireOnMount called in TestHarnessInterceptor FIRED" );
		// throw( type="CBWIREException", message="Failure when calling cbWireOnMount() interceptor." );
	}

	function cbWirePreRender() {
		log.debug( "cbWirePreRender called in TestHarnessInterceptor FIRED" );
		// throw( type="CBWIREException", message="Failure when calling cbWirePreRender() interceptor." );
	}

	function cbWireOnRender() {
		log.debug( "cbWireOnRender called in TestHarnessInterceptor FIRED" );
		// throw( type="CBWIREException", message="Failure when calling cbWireOnRender() interceptor." );
	}

	function cbWirePreUpdate() {
		log.debug( "cbWirePreUpdate called in TestHarnessInterceptor FIRED" );
		// throw( type="CBWIREException", message="Failure when calling cbWirePreUpdate() interceptor." );
		return false;
	}

	function cbWireOnUpdate() {
		log.debug( "cbWireOnUpdate called in TestHarnessInterceptor FIRED" );
		// throw( type="CBWIREException", message="Failure when calling cbWireOnUpdate() interceptor." );
		return false;
	}

}