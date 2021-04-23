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

					rc[ "serverMemo" ] = { data : { "hello" : "world" } };

					componentObj.$( "setHello", true );
					componentObj.hydrate();
					expect( componentObj.$once( "setHello" ) ).toBeTrue();
				} );

				describe( "callMethod", function(){
					it( "executes method on component object", function(){
						var rc = livewireRequest.getCollection();

						rc[ "updates" ] = [
							{
								type    : "callMethod",
								payload : { method : "whyAmIAwakeAt3am" }
							}
						];

						componentObj.$( "whyAmIAwakeAt3am", true );
						componentObj.hydrate();
						expect( componentObj.$once( "whyAmIAwakeAt3am" ) ).toBeTrue();
					} );

					it( "throws error if you try to call method on component that doesn't exist", function(){
						var rc = livewireRequest.getCollection();

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

					it( "passes in params to the method were calling if they are provided", function(){
						var rc = livewireRequest.getCollection();

						rc[ "updates" ] = [
							{
								type    : "callMethod",
								payload : {
									method : "resetName",
									params : [ "George" ]
								}
							}
						];

						componentObj.$( "resetName" );
						componentObj.hydrate();

						var callLog = componentObj.$callLog()[ "resetName" ][ 1 ];

						expect( componentObj.$once( "resetName" ) ).toBeTrue();
						expect( callLog[ "1" ] ).toBe( "George" );
					} );

					it( "uses set", function(){
						var rc = livewireRequest.getCollection();

						rc[ "updates" ] = [
							{
								type    : "callMethod",
								payload : {
									method : "$set",
									params : [ "name", "George" ]
								}
							}
						];

						componentObj.$("setName", true );
						componentObj.hydrate();

						var passedArgs = componentObj.$callLog()[ "setName" ][1];
						expect( componentObj.$once( "setName") ).toBeTrue();
						expect( passedArgs[ 1 ] ).toBe( "George" );
					} );

				} );
			} );

			describe( "$mount()", function(){
				it( "it calls mount() if it's defined on component", function(){
					componentObj.$( "mount", "sup?" );
					componentObj.$mount();
					expect( componentObj.$once( "mount" ) ).toBeTrue();
				} );

				it( "it should pass in the event, rc, and prc into mount()", function(){
					var rc = livewireRequest.getCollection();

					rc[ "someRandomVar" ] = "someRandomValue";

					componentObj.$( "mount" );
					componentObj.$mount();

					var passedArgs = componentObj.$callLog().mount[ 1 ];

					expect( passedArgs.event ).toBeInstanceOf( "RequestContext" );
					expect( passedArgs.prc ).toBeStruct();
					expect( passedArgs.rc ).toBeStruct();
					expect( passedArgs.rc.someRandomVar ).toBe( "someRandomValue" );
				} );
			} );
		} );
	}

}
