/*
{"serverMemo":{"checksum":"1ca298d9d162c7967d2313f76ba882d9bce208822308e04920c2080497c04fc1","data":{"message":"We have data binding!1"},"htmlHash":"71146cf2"},"effects":{"dirty":["count"],"html":"\n<div wire:id=\"3F1C0BD49178C76880E9D\">\n    <input type=\"text\" wire:model=\"message\">\n    <div>We have data binding!1</div>\n</div>\n"}}
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
		describe( "CBWireManager", function(){
			beforeEach( function( currentSpec ){
				setup();
				event = getRequestContext();
				cbwireManager = prepareMock(
					getInstance( name = "cbwire.models.CBWireManager", initArguments = { "event" : event } )
				);
			} );

			describe( "getWiresLocation()", function(){
				it( "returns 'wires' by default", function(){
					cbwireManager.$property( "settings", "variables", {} );
					expect( cbwireManager.getWiresLocation() ).toBe( "wires" );
				} );
				it( "returns the wiresLocation from settings", function(){
					cbwireManager.$property( "settings", "variables", { wiresLocation : "somewhere" } );
					expect( cbwireManager.getWiresLocation() ).toBe( "somewhere" );
				} );
			} );
		} );
	}

}
