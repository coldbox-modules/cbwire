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
		describe( "FireEvent.cfc", function(){
			beforeEach( function( currentSpec ){
				setup();
				update = {};
				fireEventUpdate = prepareMock(
					getInstance( name = "cbwire.models.updates.FireEvent", initArguments = { "update" : update } )
				);
				wireRequest = prepareMock( getInstance( "cbwire.models.CBWireRequest" ) );
				componentObj = prepareMock( getInstance( name = "cbwire.models.Component" ) );
			} );

			it( "returns an object", function(){
				expect( isObject( fireEventUpdate ) ).toBeTrue();
			} );

			describe( "apply()", function(){
				it( "does nothing when no listener definitions are present", function(){
					componentObj.$( "$fireEvent" );
					fireEventUpdate.apply( componentObj );
					expect( componentObj.$once( "$fireEvent" ) ).toBeFalse();
				} );

				it( "calls listener", function(){
					update[ "payload" ] = { "event" : "someEvent", params : [] };
					componentObj.$property(
						propertyName = "listeners",
						propertyScope = "variables",
						mock = { "someEvent" : "someListener" }
					);
					componentObj.$( "someListener", true );
					fireEventUpdate.apply( componentObj );
					expect( componentObj.$once( "someListener" ) ).toBeTrue();
				} );
			} );
		} );
	}

}
