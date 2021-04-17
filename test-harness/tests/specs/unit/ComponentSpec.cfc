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
				livewireRequest = prepareMock( getInstance( "cbLivewire.core.LivewireRequest" ) );
				componentObj    = prepareMock(
					getInstance(
						name          = "cbLivewire.core.Component",
						initArguments = { livewireRequest : livewireRequest }
					)
				);
			} );

			it( "can instantiate a component", function(){
				expect( isObject( componentObj ) ).toBeTrue();
			} );

			describe( "getId()", function(){
				it( "returns 21 character guid to match Livewire's implmentation", function(){
					var id = componentObj.getId();
					expect( len( id ) ).toBe( 21 );
					expect( reFindNoCase( "^[A-Za-z0-9-]+$", id ) ).toBeTrue();
				} );
			} );

			describe( "hydrate()", function(){
				it( "sets properties with values from 'serverMemo' payload", function(){
					var rc = livewireRequest.getCollection();
					componentObj.$( "setHello", true );
					rc[ "serverMemo" ] = { data : { "hello" : "world" } };
					componentObj.hydrate();
					expect( componentObj.$once( "setHello" ) ).toBeTrue();
				} );

				describe( "callMethod", function(){
					it( "executes method on component object", function(){
						var rc = livewireRequest.getCollection();
						componentObj.$( "whyAmIAwakeAt3am", true );
						rc[ "updates" ] = [
							{
								type    : "callMethod",
								payload : { method : "whyAmIAwakeAt3am" }
							}
						];
						componentObj.hydrate();
						expect( componentObj.$once( "whyAmIAwakeAt3am" ) ).toBeTrue();
					} );

					it( "throws error if you try to call method on component that doesn't exist", function(){
						var rc          = livewireRequest.getCollection();
						rc[ "updates" ] = [
							{
								type    : "callMethod",
								payload : { method : "whyAmIAwakeAt3am" }
							}
						];
						expect( function(){
							componentObj.hydrate();
						} ).toThrow( type = "LivewireMethodNotFound" );
					} );
				} );
			} );
		} );
	}

}
