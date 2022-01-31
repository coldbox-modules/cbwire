/**
 * The base interceptor test case will use the 'interceptor' annotation as the instantiation path to the interceptor
 * and then create it, prepare it for mocking, and then place it in the variables scope as 'interceptor'. It is your
 * responsibility to update the interceptor annotation instantiation path.
 */
component
	extends    ="coldbox.system.testing.BaseInterceptorTest"
	interceptor="cbwire.interceptors.hydrate.CheckIncomingRequestHeaders"
{

	/*********************************** LIFE CYCLE Methods ***********************************/

	function beforeAll(){
		// interceptor configuration properties, if any
		configProperties = {};
		// init and configure interceptor
		super.setup();
		// we are now ready to test this interceptor
	}

	function afterAll(){
	}

	/*********************************** BDD SUITES ***********************************/

	function run(){
		describe( "interceptor.test", function(){
			beforeEach( function(){
				mockEvent = getMockRequestContext();
			} );

			it( "should return true and prevent processing if 'X-Livewire' HTTP header is not present", function(){
				mockEvent.$( "noExecution" );
				var result = interceptor.preProcess( mockEvent );
				expect( mockEvent.$once( "noExecution" ) ).toBeTrue();
				expect( mockEvent.getPrivateValue( "cbox_renderdata" ).statusCode ).toBe( 400 );
				expect( result ).toBeTrue();
			} );

			it( "should return null and allow processing if 'X-Livewire' HTTP header is present", function(){
				mockEvent
					.$( "getHTTPHeader" )
					.$args( "X-Livewire" )
					.$results( "true" );
				expect( interceptor.preProcess( mockEvent ) ).toBeNull();
			} );
		} );
	}

}
