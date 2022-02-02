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
				cbwireRequest = prepareMock( getInstance( "cbwire.models.CBWireRequest" ) );
				componentObj  = prepareMock(
					getInstance(
						name          = "cbwire.models.Component",
						initArguments = { "cbwireRequest" : cbwireRequest }
					)
				);
			} );

			it( "can instantiate a component", function(){
				expect( isObject( componentObj ) ).toBeTrue();
			} );

			describe( "logbox", function(){
				it( "has reference to logbox", function(){
					var logBox = componentObj.getLogBox();
					expect( logBox ).toBeInstanceOf( "LogBox" );
				} );

				it( "has reference to logger", function(){
					var logger = componentObj.getLogger();
					expect( logger ).toBeInstanceOf( "Logger" );
				} );
			} );

			describe( "getID()", function(){
				it( "returns 21 character guid", function(){
					var id = componentObj.getID();
					expect( len( id ) ).toBe( 21 );
					expect( reFindNoCase( "^[A-Za-z0-9-]+$", id ) ).toBeTrue();
				} );
			} );

			describe( "$getDirtyProperties", function() {
				it( "can compare simple values", function() {
					componentObj.$property(
						propertyName  = "beforeHydrateState",
						propertyScope = "variables",
						mock          = { "count" : 2 }
					);

					componentObj.$( "getState", { "count": 1 } );

					var dirtyProperties = componentObj.$getDirtyProperties();

					expect( dirtyProperties ).toBeArray();
					expect ( !!dirtyProperties.find( "count" ) ).toBeTrue();
				} );

				it( "can compare a struct", function() {
					componentObj.$property(
						propertyName  = "beforeHydrateState",
						propertyScope = "variables",
						mock          = { "foo" : { "value": "bar" } }
					);

					componentObj.$( "getState", { "foo": { "value": "baz" } } );

					var dirtyProperties = componentObj.$getDirtyProperties();

					expect( dirtyProperties ).toBeArray();
					expect ( !!dirtyProperties.find( "foo" ) ).toBeTrue();
				} );

				it( "can compare a struct with different key orders", function(){
					componentObj.$property(
						propertyName  = "beforeHydrateState",
						propertyScope = "variables",
						mock          = { "foo" : { "value": "bar", "baz": "foo" } }
					);

					componentObj.$( "getState", { "foo": { "baz": "foo", "value": "bar" } } );

					var dirtyProperties = componentObj.$getDirtyProperties();

					expect( dirtyProperties ).toBeArray().toHaveLength( 0 );
				} );

				it( "can compare an array", function() {
					componentObj.$property(
						propertyName  = "beforeHydrateState",
						propertyScope = "variables",
						mock          = { "foo" : [ "bar", "baz" ] }
					);

					componentObj.$( "getState", { "foo": [ "bar", "baz" ] } );

					var dirtyProperties = componentObj.$getDirtyProperties();

					expect( dirtyProperties ).toBeArray().toHaveLength( 0 );
				} );
			} );

			describe( "getPath", function(){
				it( "returns empty string by default", function(){
					expect( componentObj.getPath() ).toBe( "" );
				} );

				it( "includes properties we've defined in our component as variables.queryString", function(){
					componentObj.$property(
						propertyName  = "queryString",
						propertyScope = "variables",
						mock          = [ "count" ]
					);

					componentObj.$property(
						propertyName  = "data",
						propertyScope = "variables",
						mock          = { "count" : 2 }
					);

					expect( componentObj.getPath() ).toInclude( "?count=2" );
				} );

				it( "it doesn't duplicate query string params if they are present in cgi.HTTP_REFERER", function(){
					componentObj.$(
						"getHTTPReferer",
						"http://localhost?count=1"
					);
					componentObj.$property(
						propertyName  = "queryString",
						propertyScope = "variables",
						mock          = [ "count" ]
					);

					componentObj.$property(
						propertyName  = "data",
						propertyScope = "variables",
						mock          = { "count" : 2 }
					);

					expect( componentObj.getPath() ).toBe( "http://localhost?count=2" );
				} );
			} );

			describe( "$getListeners", function(){
				it( "should return empty struct by default", function(){
					expect( componentObj.getListeners() ).toBe( {} );
				} );

				it( "should return listeners defined on the component", function(){
					componentObj.$property(
						propertyName  = "listeners",
						propertyScope = "variables",
						mock          = { "someEvent" : "someMethod" }
					);
					expect( componentObj.getListeners() ).toBe( { "someEvent" : "someMethod" } );
				} );
			} );

			describe( "$getMeta", function(){
				it( "should return the meta", function(){
					expect( componentObj.getMeta().name ).toBe( "cbwire.models.Component" );
				} );

				it( "should cache the results", function(){
					componentObj.$property(
						propertyName  = "meta",
						propertyScope = "variables",
						mock          = "some meta"
					);

					expect( componentObj.getMeta() ).toBe( "some meta" );
					expect( componentObj.getMeta() ).toBe( "some meta" );
				} );

				it( "should return cached results if they exists", function(){
					componentObj.$property(
						propertyName  = "meta",
						propertyScope = "variables",
						mock          = "some meta"
					);
					expect( componentObj.getMeta() ).toBe( "some meta" );
				} );
			} );


			describe( "$getInitialData", function(){
				it( "returns a struct", function(){
					expect( componentObj.getInitialData() ).toBeStruct();
				} );

				it( "should include listeners defined on our component", function(){
					componentObj.$property(
						propertyName  = "listeners",
						propertyScope = "variables",
						mock          = { "postAdded" : "doSomething" }
					);
					expect( componentObj.getInitialData().effects.listeners ).toBeArray();
					expect( componentObj.getInitialData().effects.listeners[ 1 ] ).toBe( "postAdded" );
				} );

				it( "returns the component checksum in the serverMemo", function(){
					componentObj.$( "getChecksum", "test" );
					expect( componentObj.getInitialData().serverMemo.checksum ).toBe( "test" );
				} );
			} );

			describe( "$getChecksum", function(){
				it( "returns the expected checksum", function(){
					componentObj.$( "getState", { "test" : "checksum" } );
					expect( componentObj.getChecksum() ).toBe( "8D19A0A0D180FFCD52B7DC0B572DC8D3" );
				} );
			} );



			describe( "renderIt", function(){
				it( "implicitly renders the view of the component's name", function(){
					componentObj.$( "view", "" );
					componentObj.renderIt();
					expect( componentObj.$callLog()[ "view" ][ 1 ][ 1 ] ).toBe( "wires/component" );
				} );
			} );

			describe( "renderView", function(){
				beforeEach( function(){
					componentObj.$property(
						propertyName  = "$renderer",
						propertyScope = "variables",
						mock          = {
							"renderView" : function(){
								return "<div>test</div>";
							}
						}
					);
				} );

				it( "provides rendering", function(){
					expect( componentObj.renderView( "testView" ) ).toInclude( "<div" );
				} );

				xit( "should support various outer element tags", function(){
					var outerElements = [ "div", "span", "section" ];

					outerElements.each( function( element ){
						componentObj.$property(
							propertyName  = "$renderer",
							propertyScope = "variables",
							mock          = {
								"renderView" : function(){
									return "<#element#>test</#element#>";
								}
							}
						);
						expect( componentObj.renderView( "testView" ) ).toInclude( "<#arguments.element# wire:id=" );
					} );
				} );

				it( "throws error if there's no outer element to bind to", function(){
					componentObj.$property(
						propertyName  = "$renderer",
						propertyScope = "variables",
						mock          = {
							"renderView" : function(){
								return "test";
							}
						}
					);
					expect( function(){
						componentObj.renderView( "testViewNoOuterElement" )
					} ).toThrow( type = "OuterElementNotFound" );
				} );
			} );

			describe( "$getEmits", function(){
				it( "returns an empty array by default", function(){
					expect( componentObj.getEmits() ).toBeArray();
					expect( arrayLen( componentObj.getEmits() ) ).toBe( 0 );
				} );

				it( "tracks emits", function(){
					componentObj.emit( "someEvent" );
					componentObj.emitSelf( "someOtherEvent" );
					expect( arrayLen( componentObj.getEmits() ) ).toBe( 2 );
				} );
			} );

			describe( "emit", function(){
				it( "invokes a preEmit method on the component if it's defined", function(){
					componentObj.$( "preEmit", true );
					componentObj.emit( "SomeEvent" );
					expect( componentObj.$once( "preEmit" ) ).toBeTrue();
					expect( componentObj.$callLog()[ "preEmit" ][ 1 ].eventName ).toBe( "SomeEvent" );
				} );

				it( "invokes a postEmit method on the component if it's defined", function(){
					componentObj.$( "postEmit", true );
					componentObj.emit( "SomeEvent" );
					expect( componentObj.$once( "postEmit" ) ).toBeTrue();
					expect( componentObj.$callLog()[ "postEmit" ][ 1 ].eventName ).toBe( "SomeEvent" );
				} );

				it( "invokes a preEmit[EventName] method on the component if it's defined", function(){
					componentObj.$( "preEmitBTTF", true );
					componentObj.emit( "BTTF", [ "gigawatt" ] );
					expect( componentObj.$once( "preEmitBTTF" ) ).toBeTrue();
					expect( componentObj.$callLog()[ "preEmitBTTF" ][ 1 ].parameters ).toBe( [ "gigawatt" ] );
				} );

				it( "invokes a postEmit[EventName] method on the component if it's defined", function(){
					componentObj.$( "postEmitBTTF", true );
					componentObj.emit( "BTTF", [ "gigawatt" ] );
					expect( componentObj.$once( "postEmitBTTF" ) ).toBeTrue();
					expect( componentObj.$callLog()[ "postEmitBTTF" ][ 1 ].parameters ).toBe( [ "gigawatt" ] );
				} );
			} );

			describe( "emitSelf", function(){
				it( "tracks the expected values", function(){
					componentObj.emitSelf(
						"test",
						[
							"how",
							"much",
							"wood",
							"could",
							"a",
							"wood",
							"chuck",
							"chuck"
						]
					);
					expect( componentObj.getEmits()[ 1 ] ).toBe( {
						"event"  : "test",
						"params" : [
							"how",
							"much",
							"wood",
							"could",
							"a",
							"wood",
							"chuck",
							"chuck"
						],
						"selfOnly" : true
					} );
				} );
			} );

			describe( "emitUp", function(){
				it( "tracks the expected values", function(){
					componentObj.emitUp( "test", [ "hello", "world" ] );
					expect( componentObj.getEmits()[ 1 ] ).toBe( {
						"event"         : "test",
						"params"        : [ "hello", "world" ],
						"ancestorsOnly" : true
					} );
				} );
			} );

			describe( "emitTo", function(){
				it( "tracks the expected values", function(){
					componentObj.emitTo( "event1", "component1" );
					componentObj.emitTo(
						"event2",
						"component2",
						[ "hello", "world" ]
					);
					expect( componentObj.getEmits()[ 1 ] ).toBe( {
						"event"  : "event1",
						"params" : [],
						"to"     : "component1"
					} );
					expect( componentObj.getEmits()[ 2 ] ).toBe( {
						"event"  : "event2",
						"params" : [ "hello", "world" ],
						"to"     : "component2"
					} );
				} );
			} );

			describe( "refresh", function(){
				it( "fires 'postRefresh' event", function(){
					componentObj.$( "postRefresh", true );
					componentObj.refresh();
					expect( componentObj.$once( "postRefresh" ) ).toBeTrue();
				} );
			} );

			xdescribe( "getMemento", function(){
				it( "returns a struct", function(){
					componentObj.$( "renderIt", "" );
					expect( componentObj.getMemento() ).toBeStruct();
				} );
				it( "returns an empty array of events by default", function(){
					componentObj.$( "renderIt", "" );
					expect( componentObj.getMemento().effects.emits ).toBeArray();
				} );
				it( "returns emitted events", function(){
					componentObj.$( "renderIt", "" );
					componentObj.emit( "event1" );
					componentObj.emitSelf(
						eventName  = "event2",
						parameters = { "hello" : "world" }
					);
					cbwireRequest.$(
						"getWireComponent",
						componentObj,
						false
					);

					var memento = cbwireRequest.getMemento();
					expect( memento.effects.emits ).toBeArray();

					expect( arrayLen( memento.effects.emits ) ).toBe( 2 );
					expect( memento.effects.emits[ 1 ] ).toBe( { "event" : "event1", "params" : {} } );
					expect( memento.effects.emits[ 2 ] ).toBe( {
						"event"    : "event2",
						"params"   : { "hello" : "world" },
						"selfOnly" : true
					} );
				} );
			} );

			describe( "subsequentRenderIt", function(){
				it( "calls the renderIt() method on our component", function(){
					componentObj.$( "renderIt", "got here" );
					expect( componentObj.subsequentRenderIt() ).toBe( "got here" );
				} );
				it( "returns null if noRender() has been called", function(){
					componentObj.noRender();
					componentObj.subsequentRenderIt();
					expect( componentObj.getRequestContext().getValue( "_cbwire_subsequent_rendering" ) ).toBe( "" );
				} );
			} );

			describe( "$relocate", function(){
				xit( "passes the relocation to the coldbox render", function(){
					var renderer = getMockBox().createStub();

					renderer.$( "relocate" );
					componentObj.$property(
						propertyName  = "$renderer",
						propertyScope = "variables",
						mock          = renderer
					);

					componentObj.$relocate( uri = "/short-circuit" );

					expect( renderer.$once( "relocate" ) ).toBeTrue();
					expect( renderer.$callLog().relocate[ 1 ].uri ).toBe( "/short-circuit" );
				} );
			} );

			describe( "$set", function(){
				it( "sets data property on our component", function(){
					componentObj.$property(
						propertyName  = "data",
						propertyScope = "this",
						mock          = { "name" : "test" }
					);
					expect( componentObj.data[ "name" ] ).toBe( "test" );
				} );

				it( "fires 'preUpdate[prop] event", function(){
					componentObj.$( "preUpdateName", true );
					componentObj.$set(
						propertyName        = "name",
						value               = "test",
						invokeUpdateMethods = true
					);
					expect( componentObj.$once( "preUpdateName" ) ).toBeTrue();
					expect( componentObj.$callLog()[ "preUpdateName" ][ 1 ][ "propertyName" ] ).toBe( "test" );
				} );

				it( "fires 'postUpdate[prop] event", function(){
					componentObj.$( "postUpdateName", true );
					componentObj.$set(
						propertyName        = "name",
						value               = "test",
						invokeUpdateMethods = true
					);
					expect( componentObj.$once( "postUpdateName" ) ).toBeTrue();
					expect( componentObj.$callLog()[ "postUpdateName" ][ 1 ][ "propertyName" ] ).toBe( "test" );
				} );

				it( "throws an error when 'throwOnMissingSetterMethod' is true", function(){
					componentObj.$property(
						propertyName  = "$settings",
						propertyScope = "variables",
						mock          = { "throwOnMissingSetterMethod" : true }
					);
					expect( function(){
						componentObj.setSomeName( "test" );
					} ).toThrow( type = "WireSetterNotFound" );
				} );

				it( "does not throw an error when 'throwOnMissingSetterMethod' is false", function(){
					componentObj.$property(
						propertyName  = "$settings",
						propertyScope = "variables",
						mock          = { "throwOnMissingSetterMethod" : false }
					);

					expect( function(){
						componentObj.setName( "test" );
					} ).notToThrow( type = "WireSetterNotFound" );
				} );
			} );

			describe( "getState", function(){
				it( "returns empty struct by default", function(){
					expect( componentObj.getState() ).toBe( {} );
				} );

				it( "returns the data property values", function(){
					var state = componentObj.getState();

					componentObj.$property(
						propertyName  = "data",
						propertyScope = "variables",
						mock          = { "count" : 1 }
					);

					expect( componentObj.getState()[ "count" ] ).toBe( 1 );
				} );

				it( "ignores custom functions that are not getters", function(){
					componentObj.$property(
						propertyName = "count",
						mock         = function(){
						}
					);

					var state = componentObj.getState();

					expect( structKeyExists( state, "count" ) ).toBeFalse();
				} );
			} );

			describe( "$hydrate", function(){
				it( "fires '$preHydrate' event", function(){
					var comp = prepareMock(
						getInstance(
							name          = "cbwire.models.Component",
							initArguments = { "cbwireRequest" : cbwireRequest }
						)
					);
					comp.$( "$preHydrate", true );
					comp.$hydrate( cbwireRequest );
					expect( comp.$once( "$preHydrate" ) ).toBeTrue();
				} );

				it( "fires '$postHydrate' event", function(){
					var comp = prepareMock(
						getInstance(
							name          = "cbwire.models.Component",
							initArguments = { "cbwireRequest" : cbwireRequest }
						)
					);
					comp.$( "$preHydrate", true );
					comp.$( "$postHydrate", true );
					comp.$hydrate( cbwireRequest );
					expect( comp.$once( "$preHydrate" ) ).toBeTrue();
					expect( comp.$once( "$postHydrate" ) ).toBeTrue();
				} );

				it( "sets properties with values from 'serverMemo' payload", function(){
					var rc = cbwireRequest.getCollection();

					rc[ "serverMemo" ] = {
						"data"     : { "hello" : "world" },
						"children" : []
					};
					componentObj.$( "setHello", true );
					componentObj.$hydrate( cbwireRequest );
					expect( componentObj.$once( "setHello" ) ).toBeTrue();
				} );

				it( "fires 'preHydrate' event", function(){
					componentObj.$( "$preHydrate", true );
					componentObj.$hydrate( cbwireRequest );
					expect( componentObj.$once( "$preHydrate" ) ).toBeTrue();
				} );

				it( "fires 'postHydrate' event", function(){
					componentObj.$( "$postHydrate", true );
					cbwireRequest.$(
						"getWireComponent",
						componentObj,
						false
					);
					componentObj.$hydrate( cbwireRequest );
					expect( componentObj.$once( "$postHydrate" ) ).toBeTrue();
				} );

				describe( "syncInput", function(){
					it( "executes a setter method on component object", function(){
						var rc = cbwireRequest.getCollection();

						rc[ "updates" ] = [
							{
								"type"    : "syncInput",
								"payload" : {
									"name"  : "message",
									"value" : "We have input"
								}
							}
						];

						componentObj.$( "setMessage", true );
						componentObj.$hydrate( cbwireRequest );
						expect( componentObj.$once( "setMessage" ) ).toBeTrue();
						expect( componentObj.$callLog().setMessage[ 1 ][ 1 ] ).toBe( "We have input" );
					} );
				} );

				describe( "callMethod", function(){
					it( "executes method on component object", function(){
						var rc = cbwireRequest.getCollection();

						rc[ "updates" ] = [
							{
								"type"    : "callMethod",
								"payload" : { "method" : "whyAmIAwakeAt3am" }
							}
						];

						componentObj.$( "whyAmIAwakeAt3am", true );
						componentObj.$hydrate( cbwireRequest );
						expect( componentObj.$once( "whyAmIAwakeAt3am" ) ).toBeTrue();
					} );

					it( "passes in params to the method were calling if they are provided", function(){
						var rc = cbwireRequest.getCollection();

						rc[ "updates" ] = [
							{
								"type"    : "callMethod",
								"payload" : {
									"method" : "resetName",
									"params" : [ "George" ]
								}
							}
						];

						componentObj.$( "resetName" );
						componentObj.$hydrate( cbwireRequest );

						var callLog = componentObj.$callLog()[ "resetName" ][ 1 ];

						expect( componentObj.$once( "resetName" ) ).toBeTrue();
						expect( callLog[ "1" ] ).toBe( "George" );
					} );

					it( "uses set", function(){
						var rc = cbwireRequest.getCollection();

						rc[ "updates" ] = [
							{
								"type"    : "callMethod",
								"payload" : {
									"method" : "$set",
									"params" : [ "name", "George" ]
								}
							}
						];

						componentObj.$( "setName", true );
						componentObj.$hydrate( cbwireRequest );

						var passedArgs = componentObj.$callLog()[ "setName" ][ 1 ];
						expect( componentObj.$once( "setName" ) ).toBeTrue();
						expect( passedArgs[ 1 ] ).toBe( "George" );
					} );
				} );
			} );

			describe( "mount()", function(){
				it( "it calls mount() if it's defined on component", function(){
					componentObj.$( "mount", "sup?" );
					componentObj.$mount();
					expect( componentObj.$once( "mount" ) ).toBeTrue();
				} );

				it( "it should pass in the event, rc, and prc into mount()", function(){
					var rc = cbwireRequest.getCollection();

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
