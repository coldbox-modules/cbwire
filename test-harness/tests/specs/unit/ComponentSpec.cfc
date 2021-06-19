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
				livewireRequest = prepareMock( getInstance( "cbLivewire.models.LivewireRequest" ) );
				componentObj    = prepareMock(
					getInstance(
						name          = "cbLivewire.models.Component",
						initArguments = { livewireRequest : livewireRequest }
					)
				);
			} );

			it( "can instantiate a component", function(){
				expect( isObject( componentObj ) ).toBeTrue();
			} );

			describe( "getId()", function(){
				it( "returns 21 character guid to match Livewire's implmentation", function(){
					var id = componentObj.$getId();
					expect( len( id ) ).toBe( 21 );
					expect( reFindNoCase( "^[A-Za-z0-9-]+$", id ) ).toBeTrue();
				} );
			} );

			describe( "$getPath", function(){
				it( "returns empty string by default", function(){
					expect( componentObj.$getPath() ).toBe( "" );
				} );

				it( "includes properties we've defined in our component as queryString", function(){
					componentObj.$property( propertyName="queryString", mock=["count"] );
					componentObj.$property( propertyName="count", mock=2 );
					expect( componentObj.$getPath() ).toInclude( "?count=2" );
				} );
			} );

			describe( "$getListeners", function(){
				it( "should return empty struct by default", function(){
					expect( componentObj.$getListeners() ).toBe( {} );
				} );

				it( "should return listeners defined on the component", function(){
					componentObj.$property( propertyName="$listeners", propertyScope="this", mock={"someEvent": "someMethod"} );
					expect( componentObj.$getListeners() ).toBe( {"someEvent": "someMethod"}  );
				} );

			} );

			describe( "$getMeta", function(){
				it( "should return the meta", function(){
					expect( componentObj.$getMeta().name ).toBe( "cbLivewire.models.Component" );
				} );

				it( "should cache the results", function(){
					expect( structKeyExists( componentObj, "$meta") ).toBeFalse();
					componentObj.$getMeta();
					expect( structKeyExists( componentObj, "$meta") ).toBeTrue();
				} );

				it( "should return cached results if they exists", function(){
					componentObj.$property( propertyName="$meta", propertyScope="this", mock="some meta" );
					expect( componentObj.$getMeta() ).toBe( "some meta" );
				} );

			} );


			describe( "$getInitialData", function(){
				
				it( "returns a struct", function(){
					expect( componentObj.$getInitialData() ).toBeStruct();
				} );

				it( "should include listeners defined on our component", function(){
					componentObj.$property(
						propertyName="$listeners",
						propertyScope="this",
						mock={
							"postAdded": "doSomething"
						}
					);
					expect( componentObj.$getInitialData().effects.listeners ).toBeArray();
					expect( componentObj.$getInitialData().effects.listeners[ 1 ] ).toBe( "postAdded" );
				} );

				it( "returns the component checksum in the serverMemo", function(){
					componentObj.$( "$getChecksum", "test" );
					expect( componentObj.$getInitialData().serverMemo.checksum ).toBe( "test" );
				} );
			} );

			describe( "$getChecksum", function(){
				it( "returns the expected checksum", function(){
					componentObj.$( "$getState", { "test" : "checksum" } );
					expect( componentObj.$getChecksum() ).toBe( "8D19A0A0D180FFCD52B7DC0B572DC8D3" );
				} );
			} );

			describe( "$renderIt", function(){
				it( "throw an error if it's not been implemented on the child class", function(){
					expect( function() {
						componentObj.$renderIt();
					} ).toThrow( type="RenderMethodNotFound" );
				} );
			});

			describe( "$renderView", function(){

				beforeEach( function(){
					componentObj.$property( propertyName="$renderer", propertyScope="variables", mock={
						"renderView": function() { return "<div>test</div>"; }
					});
				} );

				it( "provides rendering", function(){
					expect( componentObj.$renderView( "someView" ) ).toInclude( "<div" );
				} );

				it( "should support various outer element tags", function(){
					var outerElements = [
						"div",
						"span",
						"section"
					];

					outerElements.each( function( element ) {	
						componentObj.$property( propertyName="$renderer", propertyScope="variables", mock={
							"renderView": function() { return "<#element#>test</#element#>"; }
						});
						expect( componentObj.$renderView( "someView" ) ).toInclude( "<#arguments.element# wire:id=" );
					} );
					
				} );

				it( "throws error if there's no outer element to bind to", function(){
					componentObj.$property( propertyName="$renderer", propertyScope="variables", mock={
						"renderView": function() { return "test"; }
					});
					expect( function(){
						componentObj.$renderView( "someView" )
					 } ).toThrow( type="OuterElementNotFound" );
				} );
			} );

			describe( "$getEmits", function(){
				it( "returns an empty array by default", function(){
					expect( componentObj.$getEmits() ).toBeArray();
					expect( arrayLen( componentObj.$getEmits() ) ).toBe( 0 );
				} );

				it( "tracks emits", function(){
					componentObj.$emit( "someEvent" );
					componentObj.$emitSelf( "someOtherEvent" );
					expect( arrayLen( componentObj.$getEmits() ) ).toBe( 2 );
				} );
			} );

			describe( "$emitSelf", function(){
				it( "tracks the expected values", function(){
					componentObj.$emitSelf( "test", 1 );
					expect( componentObj.$getEmits()[ 1 ] ).toBe( {
						"event": "test",
						"params": [ 1 ],
						"selfOnly": true
					} );
				} );
			} );

			describe( "$getMemento", function(){
				it( "returns a struct", function(){
					componentObj.$( "$renderIt", "" );
					expect( componentObj.$getMemento() ).toBeStruct();
				} );
				it( "returns an empty array of events by default", function(){
					componentObj.$( "$renderIt", "" );
					expect( componentObj.$getMemento().effects.emits ).toBeArray();
				} );
				it( "returns emitted events", function(){
					componentObj.$( "$renderIt", "" );
					componentObj.$emit( "event1" );
					componentObj.$emitSelf( "event2", "hello" );
					expect( componentObj.$getMemento().effects.emits ).toBeArray();
					expect( arrayLen( componentObj.$getMemento().effects.emits ) ).toBe( 2 );
					expect( componentObj.$getMemento().effects.emits[ 1 ] ).toBe( {
						"event": "event1",
						"params": []
					} );
					expect( componentObj.$getMemento().effects.emits[ 2 ] ).toBe( {
						"event": "event2",
						"params": [ "hello" ],
						"selfOnly": true
					} );
				} );
			} );

			describe( "$getRendering", function(){
				it( "calls the $renderIt() method on our component", function(){
					componentObj.$( "$renderIt", "got here" );
					expect( componentObj.$getRendering() ).toBe( "got here" );
				} );

				it( "returns the cached results in variables.$rendering", function(){
					componentObj.$property( propertyName="$rendering", propertyScope="variables", mock="got here too" );
					expect( componentObj.$getRendering() ).toBe( "got here too" );
				} );
			} );

			describe( "$set", function(){
				it( "calls setter on our component", function(){
					componentObj.$( "setName", true );
					componentObj.$set( propertyName="name", value="test" );
					expect( componentObj.$once( "setName") ).toBeTrue();
				} );

				it( "sets value in variables scope if component doesn't contain a setter method", function(){
					componentObj.$set( propertyName="name", value="test" );
					expect( componentObj.$getState()["name"] ).toBe( "test" );
				} );

				it( "fires 'preUpdate[prop] event", function(){
					componentObj.$( "$preUpdateName", true );
					componentObj.$set( propertyName="name", value="test" );
					expect( componentObj.$once( "$preUpdateName" ) ).toBeTrue();
					expect( componentObj.$callLog()["$preUpdateName"][1][1] ).toBe( "test" );
				} );

				it( "fires 'postUpdate[prop] event", function(){
					componentObj.$( "$postUpdateName", true );
					componentObj.$set( propertyName="name", value="test" );
					expect( componentObj.$once( "$postUpdateName" ) ).toBeTrue();
					expect( componentObj.$callLog()["$postUpdateName"][1][1] ).toBe( "test" );
				} );
			} );

			describe( "$getState", function(){
				it( "returns empty struct by default", function(){
					expect( componentObj.$getState() ).toBe( {} );
				} );

				it( "returns the property values", function(){
					var state = componentObj.$getState();

					componentObj.$property( propertyName="count", mock=1 );

					expect( componentObj.$getState()[ "count" ] ).toBe( 1 );
				} );

				it( "ignores custom functions that are not getters", function(){
					componentObj.$property( propertyName="count", mock=function() {} );
					
					var state = componentObj.$getState();

					expect( structKeyExists( state, "count" ) ).toBeFalse();
				} );

				it( "returns value from getter function if it exists", function(){
					componentObj.$property( propertyName="count", mock=1 );
					componentObj.$( "getCount", 2 );
					
					var state = componentObj.$getState();

					expect( componentObj.$getState()[ "count" ] ).toBe( 2 );
				} );
			
			} );

			describe( "$hydrate()", function(){
				it( "sets properties with values from 'serverMemo' payload", function(){
					var rc = livewireRequest.getCollection();

					rc[ "serverMemo" ] = { data : { "hello" : "world" } };

					componentObj.$( "setHello", true );
					componentObj.$hydrate();
					expect( componentObj.$once( "setHello" ) ).toBeTrue();
				} );

				it( "fires 'preHydrate' event", function(){
					componentObj.$( "$preHydrate", true );
					componentObj.$hydrate();
					expect( componentObj.$once( "$preHydrate" ) ).toBeTrue();
				} );

				it( "fires 'postHydrate' event", function(){
					componentObj.$( "$postHydrate", true );
					componentObj.$hydrate();
					expect( componentObj.$once( "$postHydrate" ) ).toBeTrue();
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
						componentObj.$hydrate();
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
							componentObj.$hydrate();
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
						componentObj.$hydrate();

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
						componentObj.$hydrate();

						var passedArgs = componentObj.$callLog()[ "setName" ][1];
						expect( componentObj.$once( "setName") ).toBeTrue();
						expect( passedArgs[ 1 ] ).toBe( "George" );
					} );

				} );
			} );

			describe( "$mount()", function(){
				it( "it calls $mount() if it's defined on component", function(){
					componentObj.$( "$mount", "sup?" );
					componentObj.$_mount();
					expect( componentObj.$once( "$mount" ) ).toBeTrue();
				} );

				it( "it should pass in the event, rc, and prc into $mount()", function(){
					var rc = livewireRequest.getCollection();

					rc[ "someRandomVar" ] = "someRandomValue";

					componentObj.$( "$mount" );
					componentObj.$_mount();

					var passedArgs = componentObj.$callLog().$mount[ 1 ];

					expect( passedArgs.event ).toBeInstanceOf( "RequestContext" );
					expect( passedArgs.prc ).toBeStruct();
					expect( passedArgs.rc ).toBeStruct();
					expect( passedArgs.rc.someRandomVar ).toBe( "someRandomValue" );
				} );
			} );
		} );
	}

}
