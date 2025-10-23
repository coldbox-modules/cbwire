component {

	property name="log" inject="logbox:root";

	function onCBWIREMount() {
		log.debug( "onCBWIREMount called in TestHarnessInterceptor FIRED" );
		logRunningEventInterceptor( "onCBWIREMount" );
		// throw( type="CBWIREException", message="Failure when calling onCBWIREMount() interceptor." );
	}

	function preCBWIRERender() {
		log.debug( "preCBWIRERender called in TestHarnessInterceptor FIRED" );
		logRunningEventInterceptor( "preCBWIRERender" );
		// throw( type="CBWIREException", message="Failure when calling preCBWIRERender() interceptor." );
	}

	function onCBWIRERender() {
		log.debug( "onCBWIRERender called in TestHarnessInterceptor FIRED" );
		logRunningEventInterceptor( "onCBWIRERender" );
		// throw( type="CBWIREException", message="Failure when calling onCBWIRERender() interceptor." );
	}

	function preCBWIREUpdate() {
		log.debug( "preCBWIREUpdate called in TestHarnessInterceptor FIRED" );
		logRunningEventInterceptor( "preCBWIREUpdate" );
		// throw( type="CBWIREException", message="Failure when calling preCBWIREUpdate() interceptor." );
		return false;
	}

	function onCBWIREUpdate() {
		log.debug( "onCBWIREUpdate called in TestHarnessInterceptor FIRED" );
		logRunningEventInterceptor( "onCBWIREUpdate" );
		// throw( type="CBWIREException", message="Failure when calling onCBWIREUpdate() interceptor." );
		return false;
	}

	private function logRunningEventInterceptor( interceptorName ){
		lock name="logRunningEventInterceptor" timeout="1" {
			if( !application.keyExists( "cbwire_interceptors_run" ) ){
				application.cbwire_interceptors_run = {};
			}
			application.cbwire_interceptors_run[ arguments.interceptorName ] = {
				"interceptor" = arguments.interceptorName,
				"timestamp"   = now()
			};
		}
	}

}