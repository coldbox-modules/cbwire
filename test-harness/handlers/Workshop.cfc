component {

    function preHandler( event, rc, prc ) {
        event.setLayout( "workshop" );
    }

    function index() {}

    function counter() {}

    function signupForm() {}

    function taskList() {}

    function nestedDataKeys() {
		// Clear any previously run interceptors
		lock name="clearEventInterceptorKey" timeout="1" {
			application.delete( "cbwire_interceptors_run" );
		}
	}
}