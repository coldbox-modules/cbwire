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
		describe( "Component.cfc", function(){
			beforeEach( function( currentSpec ){
				setup();
				cbwireHTML = getInstance( "CBWireHTML@cbwire" );
				moduleSettings = getInstance( "coldbox:moduleSettings:cbwire" );
			} );

			it( "can instantiate a component", function(){
				expect( isObject( cbwireHTML ) ).toBeTrue();
			} );

			describe( "entangle", function(){
				it( "includes expected entanglement code", function(){
					var id = createUUID();
					cbwireHTML.getRequestService().getContext().setPrivateValue( "cbwire_lastest_rendered_id", id );
					var result = cbwireHTML.entangle( "someProperty" );
					expect( result ).toBe( "window.Livewire.find( '#id#' ).entangle( 'someProperty' )" );
				} );
			} );
		} );
	}

}
