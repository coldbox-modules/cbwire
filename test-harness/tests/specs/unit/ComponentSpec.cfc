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
				engineObj = prepareMock(
					getInstance( name = "Component@cbwire", initArguments = { "cbwireRequest" : cbwireRequest } ).startup()
				);
				componentObj = prepareMock( engineObj.getParent() );
				variablesScope = engineObj.getInternals();
				structAppend(
					variablesScope,
					{
						"data" : engineObj._getDataProperties(),
						"computed" : engineObj._getComputedProperties()
					}
				);
			} );

			it( "can instantiate a component", function(){
				expect( isObject( engineObj ) ).toBeTrue();
			} );

			describe( "getID()", function(){
				it( "returns 20 character guid", function(){
					var id = engineObj.get_id();
					expect( len( id ) ).toBe( 20 );
					expect( reFindNoCase( "^[A-Za-z0-9-]+$", id ) ).toBeTrue();
				} );
			} );

			describe( "refresh()", function() {
				it( "changes the component id which will force a re-render of all child components", function() {
					var id = engineObj.get_id();
					engineObj.refresh();
					var newId = engineObj.get_id();
					expect( id ).notToBe( newId );
				} );
			} );

			describe( "_getDataProperties()", function() {
				it( "can call getDataProperties()", function() {
					engineObj._setDataProperties( { "count" : 2 } );
					expect( engineObj._getDataProperties() ).toBeStruct();
					expect( engineObj._getDataProperties().count ).toBe( 2 );
				} );
			} );

			describe( "_getComputedProperties()", function() {
				it( "can call _getComputedProperties()", function() {
					engineObj._setComputedProperties( { "count" : function() { return 2; } } );
					expect( engineObj._getComputedProperties() ).toBeStruct();
					expect( engineObj._getComputedProperties().count() ).toBe( 2 );
				} );
			} );

			describe( "getPath", function(){
				it( "includes properties we've defined in our component as variables.queryString", function(){
					engineObj.$property(
						propertyName = "queryString",
						propertyScope = "variables",
						mock = [ "count" ]
					);

					engineObj._setDataProperties( { "count" : 2 } );

					expect( engineObj._getPath() ).toInclude( "?count=2" );
				} );

				it( "it doesn't duplicate query string params if they are present in cgi.HTTP_REFERER", function(){
					engineObj.$( "_getHTTPReferer", "http://localhost?count=1" );
					engineObj.$property(
						propertyName = "queryString",
						propertyScope = "variables",
						mock = [ "count" ]
					);

					engineObj._setDataProperties( { "count" : 2 } );

					expect( engineObj._getPath() ).toBe( "http://localhost?count=2" );
				} );
			} );

			describe( "$getListeners", function(){
				it( "should return empty struct by default", function(){
					expect( engineObj._getListeners() ).toBe( {} );
				} );

				it( "should return listeners defined on the component", function(){
					engineObj.$property(
						propertyName = "listeners",
						propertyScope = "variables",
						mock = { "someEvent" : "someMethod" }
					);
					expect( engineObj._getListeners() ).toBe( { "someEvent" : "someMethod" } );
				} );
			} );

			describe( "$getMeta", function(){
				it( "should return the meta", function(){
					expect( engineObj._getMeta().name ).toBe( "cbwire.models.Component" );
				} );

				it( "should cache the results", function(){
					engineObj.$property( propertyName = "meta", propertyScope = "variables", mock = "some meta" );

					expect( engineObj._getMeta() ).toBe( "some meta" );
					expect( engineObj._getMeta() ).toBe( "some meta" );
				} );

				it( "should return cached results if they exists", function(){
					engineObj.$property( propertyName = "meta", propertyScope = "variables", mock = "some meta" );
					expect( engineObj._getMeta() ).toBe( "some meta" );
				} );
			} );


			describe( "getInitialData", function(){
				it( "returns a struct", function(){
					expect( engineObj._getInitialData() ).toBeStruct();
				} );

				it( "should include listeners defined on our component", function(){
					engineObj.$property(
						propertyName = "listeners",
						propertyScope = "variables",
						mock = { "postAdded" : "doSomething" }
					);
					expect( engineObj._getInitialData().effects.listeners ).toBeArray();
					expect( engineObj._getInitialData().effects.listeners[ 1 ] ).toBe( "postAdded" );
				} );

				it( "returns the component checksum in the serverMemo", function(){
					engineObj.$( "_getChecksum", "test" );
					expect( engineObj._getInitialData().serverMemo.checksum ).toBe( "test" );
				} );
			} );

			describe( "$getChecksum", function(){
				it( "returns the expected checksum", function(){
					engineObj.$( "_getState", { "test" : "checksum" } );
					expect( engineObj._getChecksum() ).toBe( "8D19A0A0D180FFCD52B7DC0B572DC8D3" );
				} );
			} );



			describe( "renderIt", function(){
				it( "implicitly renders the view of the component's name", function(){
					engineObj.$( "view", "" );
					engineObj._renderIt();
					expect( engineObj.$callLog()[ "view" ][ 1 ][ 1 ] ).toInclude( "Component.cfm" );
				} );
			} );

			describe( "renderView", function(){
				beforeEach( function(){
					engineObj.$property(
						propertyName = "$renderer",
						propertyScope = "variables",
						mock = {
							"renderView" : function(){
								return "<div>test</div>";
							}
						}
					);
				} );

				xit( "provides rendering", function(){
					expect( engineObj.renderView( "testView" ) ).toInclude( "<div" );
				} );

				xit( "should support various outer element tags", function(){
					var outerElements = [ "div", "span", "section" ];

					outerElements.each( function( element ){
						engineObj.$property(
							propertyName = "$renderer",
							propertyScope = "variables",
							mock = {
								"renderView" : function(){
									return "<#element#>test</#element#>";
								}
							}
						);
						expect( engineObj.renderView( "testView" ) ).toInclude( "<#arguments.element# wire:id=" );
					} );
				} );

				xit( "throws error if there's no outer element to bind to", function(){
					engineObj.$property(
						propertyName = "$renderer",
						propertyScope = "variables",
						mock = {
							"renderView" : function(){
								return "test";
							}
						}
					);
					expect( function(){
						engineObj.renderView( "testViewNoOuterElement" )
					} ).toThrow( type = "OuterElementNotFound" );
				} );
			} );

			describe( "$getEmits", function(){
				it( "returns an empty array by default", function(){
					expect( engineObj._getEmittedEvents() ).toBeArray();
					expect( arrayLen( engineObj._getEmittedEvents() ) ).toBe( 0 );
				} );

				it( "tracks emits", function(){
					engineObj.emit( "someEvent" );
					engineObj.emitSelf( "someOtherEvent" );
					expect( arrayLen( engineObj._getEmittedEvents() ) ).toBe( 2 );
				} );
			} );
			
			describe( "emitSelf", function(){
				it( "tracks the expected values", function(){
					engineObj.emitSelf(
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
					expect( engineObj._getEmittedEvents()[ 1 ] ).toBe( {
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
					engineObj.emitUp( "test", [ "hello", "world" ] );
					expect( engineObj._getEmittedEvents()[ 1 ] ).toBe( {
						"event" : "test",
						"params" : [ "hello", "world" ],
						"ancestorsOnly" : true
					} );
				} );
			} );

			xdescribe( "emitTo", function(){
				it( "tracks the expected values", function(){
					engineObj.emitTo( "event1", "component1" );
					engineObj.emitTo( "event2", "component2", [ "hello", "world" ] );
					expect( engineObj._getEmittedEvents()[ 1 ] ).toBe( {
						"event" : "event1",
						"params" : [],
						"to" : "component1"
					} );
					expect( engineObj._getEmittedEvents()[ 2 ] ).toBe( {
						"event" : "event2",
						"params" : [ "hello", "world" ],
						"to" : "component2"
					} );
				} );
			} );

			xdescribe( "getMemento", function(){
				it( "returns a struct", function(){
					engineObj.$( "renderIt", "" );
					expect( engineObj.getMemento() ).toBeStruct();
				} );
				it( "returns an empty array of events by default", function(){
					engineObj.$( "renderIt", "" );
					expect( engineObj.getMemento().effects.emits ).toBeArray();
				} );
				it( "returns emitted events", function(){
					engineObj.$( "renderIt", "" );
					engineObj.emit( "event1" );
					engineObj.emitSelf( eventName = "event2", parameters = { "hello" : "world" } );
					cbwireRequest.$( "getWireComponent", engineObj, false );

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

			describe( "_subsequentRenderIt", function(){
				it( "calls the renderIt() method on our component", function(){
					engineObj.$( "_renderIt", "got here" );
					engineObj._subsequentRenderIt();
					expect( engineObj.$once( "_renderIt" ) ).toBeTrue();
				} );
				it( "returns null if noRender() has been called", function(){
					engineObj.noRender();
					engineObj._subsequentRenderIt();
					expect(
						engineObj
							._getRequestContext()
							.getValue( "_cbwire_subsequent_rendering" )
					).toBe( "" );
				} );
			} );

			describe( "relocate", function(){
				xit( "passes the relocation to the coldbox render", function(){
					var renderer = getMockBox().createStub();

					renderer.$( "relocate" );
					engineObj.$property( propertyName = "$renderer", propertyScope = "variables", mock = renderer );

					engineObj.relocate( uri = "/short-circuit" );

					expect( renderer.$once( "relocate" ) ).toBeTrue();
					expect( renderer.$callLog().relocate[ 1 ].uri ).toBe( "/short-circuit" );
				} );
			} );

			describe( "$set", function(){
				it( "sets data property on our component", function(){
					engineObj._setDataProperties( { "name" : "test" } );
					expect( engineObj._getDataProperties()[ "name" ] ).toBe( "test" );
				} );

				it( "throws an error when 'throwOnMissingSetterMethod' is true", function(){
					engineObj.setSettings( { "throwOnMissingSetterMethod" : true } );
					expect( function(){
						engineObj.setSomeName( "test" );
					} ).toThrow( type = "WireSetterNotFound" );
				} );

				it( "does not throw an error when 'throwOnMissingSetterMethod' is false", function(){
					engineObj.$property(
						propertyName = "$settings",
						propertyScope = "variables",
						mock = { "throwOnMissingSetterMethod" : false }
					);

					expect( function(){
						engineObj.setName( "test" );
					} ).notToThrow( type = "WireSetterNotFound" );
				} );
			} );

			describe( "getState", function(){
				it( "returns empty struct by default", function(){
					expect( engineObj._getState() ).toBe( {} );
				} );

				it( "returns the data property values", function(){
					var state = engineObj._getState();

					engineObj._setDataProperties( { "count" : 1 } );

					expect( engineObj._getState()[ "count" ] ).toBe( 1 );
				} );

				it( "ignores custom functions that are not getters", function(){
					engineObj.$property(
						propertyName = "count",
						mock = function(){
						}
					);

					var state = engineObj._getState();

					expect( structKeyExists( state, "count" ) ).toBeFalse();
				} );
			} );

			describe( "hydrate", function(){
				it( "renders (executes) computed properties on hydrate", function(){
					engineObj
						._setComputedProperties( {
							"add2Plus2" : function(){
								return 4;
							}
						} );

					engineObj._hydrate( cbwireRequest );

					expect(
						engineObj
							._getComputedProperties()
							.add2Plus2()
					).toBe( 4 );
				} );
				it( "sets properties with values from 'serverMemo' payload", function(){
					var rc = cbwireRequest.getCollection();

					rc[ "serverMemo" ] = {
						"data" : { "hello" : "world" },
						"children" : []
					};
					engineObj.$( "setHello", true );
					engineObj._hydrate( cbwireRequest );
					expect( engineObj.$once( "setHello" ) ).toBeTrue();
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

						engineObj.$( "whyAmIAwakeAt3am", true );
						engineObj._hydrate( cbwireRequest );
						expect( engineObj.$once( "whyAmIAwakeAt3am" ) ).toBeTrue();
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

						engineObj.$( "resetName" );
						engineObj._hydrate( cbwireRequest );

						var callLog = engineObj.$callLog()[ "resetName" ][ 1 ];

						expect( engineObj.$once( "resetName" ) ).toBeTrue();
						expect( callLog[ "1" ] ).toBe( "George" );
					} );
				} );
			} );

			describe( "onMount()", function(){
				it( "it calls onMount() if it's defined on component", function(){
					componentObj.$( "onMount", "sup?" );
					componentObj._mount();
					expect( componentObj.$once( "onMount" ) ).toBeTrue();
				} );

				it( "it should pass in the event, rc, and prc into onMount()", function(){
					var rc = cbwireRequest.getCollection();

					rc[ "someRandomVar" ] = "someRandomValue";

					componentObj.$( "onMount" );
					componentObj._mount();

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
					componentObj._mount();
					expect( componentObj.$once( "mount" ) ).toBeTrue();
				} );

				it( "it should pass in the event, rc, and prc into mount()", function(){
					var rc = cbwireRequest.getCollection();

					rc[ "someRandomVar" ] = "someRandomValue";

					componentObj.$( "mount" );
					componentObj._mount();

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
					engineObj._hydrate();
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
					engineObj._hydrate( cbwireRequest );
					expect( componentObj.$once( "onHydrateCount" ) ).toBeTrue();
				} );
			} );

			describe( "getters", function(){
				it( "can access data properties using getter", function(){
					engineObj._setDataProperties( { "count" : 1 } );
					expect( engineObj.getCount() ).toBe( 1 );
				} );

				xit( "can access computed properties using getter", function(){
					engineObj
						._setComputedProperties( {
							"onePlusTwo" : function(){
								return 1 + 2;
							}
						} );
					engineObj._renderComputedProperties( engineObj.getInternals().data );
					expect( engineObj.getOnePlusTwo() ).toBe( 3 );
				} );
			} );

			describe( "validate()", function(){
				it( "provides a validation for 'this.constraints' defined on the component", function(){
					engineObj.$property(
						propertyName = "constraints",
						propertyScope = "variables",
						mock = { "firstname" : { required : true } }
					);
					var result = engineObj._validate();
					expect( result ).toBeInstanceOf( "ValidationResult" );
					expect( result.hasErrors() ).toBeTrue();
					expect( result.getErrors( "firstname" )[ 1 ].getMessage() ).toBe(
						"The 'firstname' value is required"
					);
				} );

				it( "provides validations that can be passed in", function(){
					var result = engineObj._validate(
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
					engineObj.$property(
						propertyName = "constraints",
						propertyScope = "this",
						mock = { "firstname" : { required : true } }
					);

					expect( function(){
						engineObj.validateOrFail();
					} ).toThrow( "ValidationException" );
				} );

				it( "doesn't throws error when 'this.constraints' is defined and validation passes", function(){
					engineObj.$property(
						propertyName = "constraints",
						propertyScope = "this",
						mock = { "firstname" : { required : true } }
					);

					expect( function(){
						engineObj.validateOrFail(
							target = { "firstname" : "test" },
							constraints = { "firstname" : { required : true } }
						);
					} ).notToThrow( "ValidationException" );
				} );
			} );
		} );
	}

}
