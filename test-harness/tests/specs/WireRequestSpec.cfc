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
		describe( "WireRequest", function(){
			beforeEach( function( currentSpec ){
				setup();
				event       = getRequestContext();
				wireRequest = prepareMock(
					getInstance(
						name          = "cbwire.models.WireRequest",
						initArguments = { "event" : event }
					)
				);
			} );

			it( "can be instantiated", function(){
				expect( isObject( wireRequest ) ).toBeTrue();
			} );

			it( "can detect updates", function(){
				event.setValue( "updates", [] );
				expect( wireRequest.hasUpdates() ).toBeFalse();
				event.setValue( "updates", [ {} ] );
				expect( wireRequest.hasUpdates() ).toBeTrue();
			} );

			describe( "getUpdates", function(){
				it( "can get updates", function(){
					event.setValue(
						"updates",
						[ { "type" : "callMethod" } ]
					);
					expect( wireRequest.getUpdates() ).toBeArray();
					expect( arrayLen( wireRequest.getUpdates() ) ).toBe( 1 );
					expect( wireRequest.getUpdates()[ 1 ] ).toBeInstanceOf( "WireUpdate" );
				} );

				it( "returns type of callmethod", function(){
					event.setValue(
						"updates",
						[ { "type" : "callMethod" } ]
					);
					expect( wireRequest.getUpdates() ).toBeArray();
					expect( arrayLen( wireRequest.getUpdates() ) ).toBe( 1 );
					expect( wireRequest.getUpdates()[ 1 ] ).toBeInstanceOf( "CallMethod" );
				} );

				it( "returns type of fireevent", function(){
					event.setValue(
						"updates",
						[ { "type" : "fireEvent" } ]
					);
					expect( wireRequest.getUpdates() ).toBeArray();
					expect( arrayLen( wireRequest.getUpdates() ) ).toBe( 1 );
					expect( wireRequest.getUpdates()[ 1 ] ).toBeInstanceOf( "FireEvent" );
				} );
			} );

			it( "can detect fingerprint", function(){
				event.setValue( "fingerprint", { "id" : "" } );
				expect( wireRequest.hasFingerprint() ).toBeTrue();
			} );

			it( "can detect serverMemo", function(){
				event.setValue( "serverMemo", {} );
				expect( wireRequest.hasServerMemo() ).toBeTrue();
			} );

			it( "can get serverMemo", function(){
				event.setValue( "serverMemo", { "checksum" : "123" } );
				expect( wireRequest.getServerMemo().checksum ).toBe( "123" );
			} );

			describe( "getWiresLocation()", function(){
				it( "returns 'wires' by default", function(){
					wireRequest.$property( "$settings", "variables", {} );
					expect( wireRequest.getWiresLocation() ).toBe( "wires" );
				} );
				it( "returns the wiresLocation from settings", function(){
					wireRequest.$property( "$settings", "variables", {
						wiresLocation = "somewhere"
					} );
					expect( wireRequest.getWiresLocation() ).toBe( "somewhere" );

				} );
			} );
		} );
	}

}
