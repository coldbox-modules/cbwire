/**
 * MessageBox tests
 */
component extends="coldbox.system.testing.BaseTestCase" {

	/*********************************** LIFE CYCLE Methods ***********************************/

	// executes before all suites+specs in the run() method
	function beforeAll(){
		super.beforeAll();
	}

	// executes after all suites+specs in the run() method
	function afterAll(){
		super.afterAll();
	}

	/*********************************** BDD SUITES ***********************************/

	function run( testResults, testBox ){
		// all your suites go here.
		describe( "cbLivewire Module", function(){
			beforeEach( function( currentSpec ){
				setup();
			} );

			it( "can render the main event", function(){
				var event = get( "/" );
				expect( event.getRenderedContent() ).toInclude( "done" );
			} );
		} );
	}

}
