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
				cbwireRequest = prepareMock( getInstance( "CBWireRequest@cbwire" ) );
				componentObj = prepareMock(
					getInstance( name = "Component@cbwire", initArguments = { "cbwireRequest" : cbwireRequest } )
				);
				variablesScope = componentObj.getInternals();
				structAppend(
					variablesScope,
					{
						"data" : componentObj.getEngine().getDataProperties(),
						"computed" : componentObj.getEngine().getComputedProperties()
					}
				);
				engine = prepareMock(
					getInstance(
						name = "ComponentEngine@cbwire",
						initArguments = {
							wire : componentObj,
							variablesScope : variablesScope
						}
					)
				);
				componentObj.setEngine( engine );
			} );

			it( "can instantiate a component", function(){
				expect( isObject( componentObj ) ).toBeTrue();
			} );

			describe( "getID()", function(){
				it( "returns 20 character guid", function(){
					var id = componentObj.getEngine().getId();
					expect( len( id ) ).toBe( 20 );
					expect( reFindNoCase( "^[A-Za-z0-9-]+$", id ) ).toBeTrue();
				} );
			} );

			fdescribe( "getDataProperties()", function(){
				it( "can call getDataProperties()", function(){
					componentObj.getEngine().setDataProperties( { "count" : 2 } );
					expect( componentObj.getDataProperties() ).toBeStruct();
					expect( componentObj.getDataProperties().count ).toBe( 2 );
				} );
			} );

			fdescribe( "getComputedProperties()", function(){
				it( "can call getComputedProperties()", function(){
					componentObj
						.getEngine()
						.setComputedProperties( {
							"count" : function(){
								return 2;
							}
						} );
					expect( componentObj.getComputedProperties() ).toBeStruct();
					expect( componentObj.getComputedProperties().count() ).toBe( 2 );
				} );
			} );

			describe( "getPath", function(){
				it( "includes properties we've defined in our component as variables.queryString", function(){
					componentObj.$property(
						propertyName = "queryString",
						propertyScope = "variables",
						mock = [ "count" ]
					);

					componentObj.getEngine().setDataProperties( { "count" : 2 } );

					expect( componentObj.getEngine().getPath() ).toInclude( "?count=2" );
				} );

				it( "it doesn't duplicate query string params if they are present in cgi.HTTP_REFERER", function(){
					engine.$( "getHTTPReferer", "http://localhost?count=1" );
					componentObj.$property(
						propertyName = "queryString",
						propertyScope = "variables",
						mock = [ "count" ]
					);

					componentObj.getEngine().setDataProperties( { "count" : 2 } );

					expect( componentObj.getEngine().getPath() ).toBe( "http://localhost?count=2" );
				} );
			} );

			describe( "$getListeners", function(){
				it( "should return empty struct by default", function(){
					expect( componentObj.getEngine().getListeners() ).toBe( {} );
				} );

				it( "should return listeners defined on the component", function(){
					componentObj.$property(
						propertyName = "listeners",
						propertyScope = "variables",
						mock = { "someEvent" : "someMethod" }
					);
					expect( componentObj.getEngine().getListeners() ).toBe( { "someEvent" : "someMethod" } );
				} );
			} );

			describe( "$getMeta", function(){
				it( "should return the meta", function(){
					expect( componentObj.getEngine().getMeta().name ).toBe( "cbwire.models.Component" );
				} );

				it( "should cache the results", function(){
					engine.$property( propertyName = "meta", propertyScope = "variables", mock = "some meta" );

					expect( componentObj.getEngine().getMeta() ).toBe( "some meta" );
					expect( componentObj.getEngine().getMeta() ).toBe( "some meta" );
				} );

				it( "should return cached results if they exists", function(){
					engine.$property( propertyName = "meta", propertyScope = "variables", mock = "some meta" );
					expect( componentObj.getEngine().getMeta() ).toBe( "some meta" );
				} );
			} );


			describe( "getInitialData", function(){
				it( "returns a struct", function(){
					expect( componentObj.getEngine().getInitialData() ).toBeStruct();
				} );

				it( "should include listeners defined on our component", function(){
					componentObj.$property(
						propertyName = "listeners",
						propertyScope = "variables",
						mock = { "postAdded" : "doSomething" }
					);
					expect( componentObj.getEngine().getInitialData().effects.listeners ).toBeArray();
					expect( componentObj.getEngine().getInitialData().effects.listeners[ 1 ] ).toBe( "postAdded" );
				} );

				it( "returns the component checksum in the serverMemo", function(){
					engine.$( "getChecksum", "test" );
					expect( componentObj.getEngine().getInitialData().serverMemo.checksum ).toBe( "test" );
				} );
			} );

			describe( "$getChecksum", function(){
				it( "returns the expected checksum", function(){
					engine.$( "getState", { "test" : "checksum" } );
					expect( componentObj.getEngine().getChecksum() ).toBe( "8D19A0A0D180FFCD52B7DC0B572DC8D3" );
				} );
			} );



			describe( "renderIt", function(){
				it( "implicitly renders the view of the component's name", function(){
					componentObj.$( "view", "" );
					componentObj.getEngine().renderIt();
					expect( componentObj.$callLog()[ "view" ][ 1 ][ 1 ] ).toBe( "wires/component" );
				} );
			} );

			describe( "renderView", function(){
				beforeEach( function(){
					componentObj.$property(
						propertyName = "$renderer",
						propertyScope = "variables",
						mock = {
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
							propertyName = "$renderer",
							propertyScope = "variables",
							mock = {
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
						propertyName = "$renderer",
						propertyScope = "variables",
						mock = {
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
					expect( componentObj.getEngine().getEmittedEvents() ).toBeArray();
					expect( arrayLen( componentObj.getEngine().getEmittedEvents() ) ).toBe( 0 );
				} );

				it( "tracks emits", function(){
					componentObj.emit( "someEvent" );
					componentObj.emitSelf( "someOtherEvent" );
					expect( arrayLen( componentObj.getEngine().getEmittedEvents() ) ).toBe( 2 );
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
					expect( componentObj.getEngine().getEmittedEvents()[ 1 ] ).toBe( {
						"event" : "test",
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
					expect( componentObj.getEngine().getEmittedEvents()[ 1 ] ).toBe( {
						"event" : "test",
						"params" : [ "hello", "world" ],
						"ancestorsOnly" : true
					} );
				} );
			} );

			describe( "emitTo", function(){
				it( "tracks the expected values", function(){
					componentObj.emitTo( "event1", "component1" );
					componentObj.emitTo( "event2", "component2", [ "hello", "world" ] );
					expect( componentObj.getEngine().getEmittedEvents()[ 1 ] ).toBe( {
						"event" : "event1",
						"params" : [],
						"to" : "component1"
					} );
					expect( componentObj.getEngine().getEmittedEvents()[ 2 ] ).toBe( {
						"event" : "event2",
						"params" : [ "hello", "world" ],
						"to" : "component2"
					} );
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
					componentObj.emitSelf( eventName = "event2", parameters = { "hello" : "world" } );
					cbwireRequest.$( "getWireComponent", componentObj, false );

					var memento = cbwireRequest.getMemento();
					expect( memento.effects.emits ).toBeArray();

					expect( arrayLen( memento.effects.emits ) ).toBe( 2 );
					expect( memento.effects.emits[ 1 ] ).toBe( { "event" : "event1", "params" : {} } );
					expect( memento.effects.emits[ 2 ] ).toBe( {
						"event" : "event2",
						"params" : { "hello" : "world" },
						"selfOnly" : true
					} );
				} );
			} );

			describe( "subsequentRenderIt", function(){
				it( "calls the renderIt() method on our component", function(){
					engine.$( "renderIt", "got here" );
					componentObj.getEngine().subsequentRenderIt();
					expect( engine.$once( "renderIt" ) ).toBeTrue();
				} );
				it( "returns null if noRender() has been called", function(){
					componentObj.noRender();
					componentObj.getEngine().subsequentRenderIt();
					expect(
						componentObj
							.getEngine()
							.getRequestContext()
							.getValue( "_cbwire_subsequent_rendering" )
					).toBe( "" );
				} );
			} );

			describe( "relocate", function(){
				xit( "passes the relocation to the coldbox render", function(){
					var renderer = getMockBox().createStub();

					renderer.$( "relocate" );
					componentObj.$property( propertyName = "$renderer", propertyScope = "variables", mock = renderer );

					componentObj.relocate( uri = "/short-circuit" );

					expect( renderer.$once( "relocate" ) ).toBeTrue();
					expect( renderer.$callLog().relocate[ 1 ].uri ).toBe( "/short-circuit" );
				} );
			} );

			describe( "$set", function(){
				it( "sets data property on our component", function(){
					componentObj.getEngine().setDataProperties( { "name" : "test" } );
					expect( componentObj.getEngine().getDataProperties()[ "name" ] ).toBe( "test" );
				} );

				it( "fires 'preUpdate[prop] event", function(){
					componentObj.$( "preUpdateName", true );
					componentObj
						.getEngine()
						.setProperty( propertyName = "name", value = "test", invokeUpdateMethods = true );
					expect( componentObj.$once( "preUpdateName" ) ).toBeTrue();
					expect( componentObj.$callLog()[ "preUpdateName" ][ 1 ][ "propertyName" ] ).toBe( "test" );
				} );

				it( "fires 'postUpdate[prop] event", function(){
					componentObj.$( "postUpdateName", true );
					componentObj
						.getEngine()
						.setProperty( propertyName = "name", value = "test", invokeUpdateMethods = true );
					expect( componentObj.$once( "postUpdateName" ) ).toBeTrue();
					expect( componentObj.$callLog()[ "postUpdateName" ][ 1 ][ "propertyName" ] ).toBe( "test" );
				} );

				it( "throws an error when 'throwOnMissingSetterMethod' is true", function(){
					engine.setSettings( { "throwOnMissingSetterMethod" : true } );
					expect( function(){
						componentObj.setSomeName( "test" );
					} ).toThrow( type = "WireSetterNotFound" );
				} );

				it( "does not throw an error when 'throwOnMissingSetterMethod' is false", function(){
					componentObj.$property(
						propertyName = "$settings",
						propertyScope = "variables",
						mock = { "throwOnMissingSetterMethod" : false }
					);

					expect( function(){
						componentObj.setName( "test" );
					} ).notToThrow( type = "WireSetterNotFound" );
				} );
			} );

			describe( "getState", function(){
				it( "returns empty struct by default", function(){
					expect( componentObj.getEngine().getState() ).toBe( {} );
				} );

				it( "returns the data property values", function(){
					var state = componentObj.getEngine().getState();

					componentObj.getEngine().setDataProperties( { "count" : 1 } );

					expect( componentObj.getEngine().getState()[ "count" ] ).toBe( 1 );
				} );

				it( "renders computed properties to the state", function(){
					componentObj
						.getEngine()
						.setComputedProperties( {
							"calculator" : function(){
								return 1 + 1;
							},
							"propertyWithNoReturnValue" : function(){
								return;
							}
						} );

					var state = componentObj.getEngine().getState( includeComputed = true );

					expect( state.calculator ).toBe( 2 );
				} );

				it( "ignores custom functions that are not getters", function(){
					componentObj.$property(
						propertyName = "count",
						mock = function(){
						}
					);

					var state = componentObj.getEngine().getState();

					expect( structKeyExists( state, "count" ) ).toBeFalse();
				} );
			} );

			describe( "hydrate", function(){
				it( "renders (executes) computed properties on hydrate", function(){
					componentObj
						.getEngine()
						.setComputedProperties( {
							"add2Plus2" : function(){
								return 4;
							}
						} );

					componentObj.getEngine().hydrate( cbwireRequest );

					expect(
						componentObj
							.getEngine()
							.getComputedProperties()
							.add2Plus2()
					).toBe( 4 );
				} );
				it( "sets properties with values from 'serverMemo' payload", function(){
					var rc = cbwireRequest.getCollection();

					rc[ "serverMemo" ] = {
						"data" : { "hello" : "world" },
						"children" : []
					};
					componentObj.$( "setHello", true );
					componentObj.getEngine().hydrate( cbwireRequest );
					expect( componentObj.$once( "setHello" ) ).toBeTrue();
				} );

				describe( "syncInput", function(){
					it( "executes a setter method on component object", function(){
						var rc = cbwireRequest.getCollection();

						rc[ "updates" ] = [
							{
								"type" : "syncInput",
								"payload" : {
									"name" : "message",
									"value" : "We have input"
								}
							}
						];

						componentObj.$( "setMessage", true );
						componentObj.getEngine().hydrate( cbwireRequest );
						expect( componentObj.$once( "setMessage" ) ).toBeTrue();
						expect( componentObj.$callLog().setMessage[ 1 ][ 1 ] ).toBe( "We have input" );
					} );
				} );

				describe( "callMethod", function(){
					it( "executes method on component object", function(){
						var rc = cbwireRequest.getCollection();

						rc[ "updates" ] = [
							{
								"type" : "callMethod",
								"payload" : { "method" : "whyAmIAwakeAt3am" }
							}
						];

						componentObj.$( "whyAmIAwakeAt3am", true );
						componentObj.getEngine().hydrate( cbwireRequest );
						expect( componentObj.$once( "whyAmIAwakeAt3am" ) ).toBeTrue();
					} );

					it( "passes in params to the method were calling if they are provided", function(){
						var rc = cbwireRequest.getCollection();

						rc[ "updates" ] = [
							{
								"type" : "callMethod",
								"payload" : {
									"method" : "resetName",
									"params" : [ "George" ]
								}
							}
						];

						componentObj.$( "resetName" );
						componentObj.getEngine().hydrate( cbwireRequest );

						var callLog = componentObj.$callLog()[ "resetName" ][ 1 ];

						expect( componentObj.$once( "resetName" ) ).toBeTrue();
						expect( callLog[ "1" ] ).toBe( "George" );
					} );

					it( "uses set", function(){
						var rc = cbwireRequest.getCollection();

						rc[ "updates" ] = [
							{
								"type" : "callMethod",
								"payload" : {
									"method" : "$set",
									"params" : [ "name", "George" ]
								}
							}
						];

						componentObj.$( "setName", true );
						componentObj.getEngine().hydrate( cbwireRequest );

						var passedArgs = componentObj.$callLog()[ "setName" ][ 1 ];
						expect( componentObj.$once( "setName" ) ).toBeTrue();
						expect( passedArgs[ 1 ] ).toBe( "George" );
					} );
				} );
			} );

			describe( "onMount()", function(){
				it( "it calls onMount() if it's defined on component", function(){
					componentObj.$( "onMount", "sup?" );
					componentObj.getEngine().mount();
					expect( componentObj.$once( "onMount" ) ).toBeTrue();
				} );

				it( "it should pass in the event, rc, and prc into onMount()", function(){
					var rc = cbwireRequest.getCollection();

					rc[ "someRandomVar" ] = "someRandomValue";

					componentObj.$( "onMount" );
					componentObj.getEngine().mount();

					var passedArgs = componentObj.$callLog().onMount[ 1 ];

					expect( passedArgs.event ).toBeInstanceOf( "RequestContext" );
					expect( passedArgs.prc ).toBeStruct();
					expect( passedArgs.rc ).toBeStruct();
					expect( passedArgs.rc.someRandomVar ).toBe( "someRandomValue" );
				} );
			} );

			describe( "mount()", function(){
				it( "it calls mount() if it's defined on component", function(){
					componentObj.$( "mount", "sup?" );
					componentObj.getEngine().mount();
					expect( componentObj.$once( "mount" ) ).toBeTrue();
				} );

				it( "it should pass in the event, rc, and prc into mount()", function(){
					var rc = cbwireRequest.getCollection();

					rc[ "someRandomVar" ] = "someRandomValue";

					componentObj.$( "mount" );
					componentObj.getEngine().mount();

					var passedArgs = componentObj.$callLog().mount[ 1 ];

					expect( passedArgs.event ).toBeInstanceOf( "RequestContext" );
					expect( passedArgs.prc ).toBeStruct();
					expect( passedArgs.rc ).toBeStruct();
					expect( passedArgs.rc.someRandomVar ).toBe( "someRandomValue" );
				} );
			} );

			describe( "onHydrate()", function(){
				it( "it calls onHydrate() if it's defined on component", function(){
					componentObj.$( "onHydrate", "got this" );
					componentObj.getEngine().hydrate();
					expect( componentObj.$once( "onHydrate" ) ).toBeTrue();
				} );
			} );

			describe( "onHydrate[DataProperty]()", function(){
				it( "it calls onHydrate[DataProperty]]) if it's defined on component", function(){
					var rc = cbwireRequest.getCollection();

					rc[ "serverMemo" ] = {
						"data" : { "count" : "2" },
						"children" : []
					};

					componentObj.$( "onHydrateCount", "got this" );
					componentObj.getEngine().hydrate( cbwireRequest );
					expect( componentObj.$once( "onHydrateCount" ) ).toBeTrue();
				} );
			} );

			describe( "getters", function(){
				it( "can access data properties using getter", function(){
					componentObj.getEngine().setDataProperties( { "count" : 1 } );
					expect( componentObj.getCount() ).toBe( 1 );
				} );

				it( "can access computed properties using getter", function(){
					componentObj
						.getEngine()
						.setComputedProperties( {
							"onePlusTwo" : function(){
								return 1 + 2;
							}
						} );
					componentObj.getEngine().renderComputedProperties( componentObj.getInternals().data );
					expect( componentObj.getOnePlusTwo() ).toBe( 3 );
				} );
			} );

			describe( "validate()", function(){
				it( "provides a validation for 'this.constraints' defined on the component", function(){
					componentObj.$property(
						propertyName = "constraints",
						propertyScope = "this",
						mock = { "firstname" : { required : true } }
					);
					var result = componentObj.validate();
					expect( result ).toBeInstanceOf( "ValidationResult" );
					expect( result.hasErrors() ).toBeTrue();
					expect( result.getErrors( "firstname" )[ 1 ].getMessage() ).toBe(
						"The 'firstname' value is required"
					);
				} );

				it( "provides validations that can be passed in", function(){
					var result = componentObj.validate(
						target = {},
						constraints = { "firstname" : { required : true } }
					);
					expect( result ).toBeInstanceOf( "ValidationResult" );
					expect( result.hasErrors() ).toBeTrue();
					expect( result.getErrors( "firstname" )[ 1 ].getMessage() ).toBe(
						"The 'firstname' value is required"
					);
				} );
			} );

			describe( "validateOrFail", function(){
				it( "throws error when 'this.constraints' is defined but does not validate", function(){
					componentObj.$property(
						propertyName = "constraints",
						propertyScope = "this",
						mock = { "firstname" : { required : true } }
					);

					expect( function(){
						componentObj.validateOrFail();
					} ).toThrow( "ValidationException" );
				} );

				it( "doesn't throws error when 'this.constraints' is defined and validation passes", function(){
					componentObj.$property(
						propertyName = "constraints",
						propertyScope = "this",
						mock = { "firstname" : { required : true } }
					);

					expect( function(){
						componentObj.validateOrFail(
							target = { "firstname" : "test" },
							constraints = { "firstname" : { required : true } }
						);
					} ).notToThrow( "ValidationException" );
				} );
			} );
		} );
	}

}
