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
		describe( "InitialRender", function(){

			beforeEach( function( currentSpec ){
				setup();
				event = getRequestContext();
				rc = event.getCollection();
				prc = event.getPrivateCollection();
				comp = getInstance( "tests.templates.TestComponent" ).startup( initialRender=true );
				prepareMock( comp );
				parent = comp.getParent();
				prepareMock( parent );
			} );

			it( "is an object", function() {
				expect( isObject( comp ) ).toBeTrue();
			} );

			it( "is an instance of InitialRenderer", function() {
				expect( comp ).toBeInstanceOf( "InitialRenderer" );
			} );

			it( "renders a basic component", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/template.cfm" );
				var result = renderInitial( comp );
				expect( result ).toContain( "wire:id=""" & comp.getID() );
				expect( result ).toContain( "wire:initial-data=" );
				expect( result ).toContain( "Current time: " );
			} );

			it( "can render a child component with random identifiers", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/childcomponent.cfm" );
				var result = renderInitial( comp );
				var initialDataJSON = parseInitialData( result );
				var initialDataStruct = deserializeJSON( initialDataJSON );
				var regexMatches = rematchnocase( 'wire:id="([^"]+)"', result );
				expect( result ).toContain( "Child Component" );
				expect( structCount( initialDataStruct.serverMemo.children ) ).toBe( 1 );
				expect( regexMatches.len() ).toBe( 2 );
				expect( regexMatches[ 2 ] ).notToBe( "wire:id=""childComponent""" );
			} );

			it( "can render a child component with unique keys", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/childcomponentwithkey.cfm" );
				var result = renderInitial( comp );
				var initialDataJSON = parseInitialData( result );
				var initialDataStruct = deserializeJSON( initialDataJSON );
				var regexMatches = rematchnocase( 'wire:id="([^"]+)"', result );
				expect( result ).toContain( "Child Component" );
				expect( structCount( initialDataStruct.serverMemo.children ) ).toBe( 1 );
				expect( regexMatches.len() ).toBe( 2 );
				expect( regexMatches[ 2 ] ).toBe( "wire:id=""childComponent""" );
			} );

			it( "throws error if it's unable to find an outer element", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/templateWithoutOuterElement.cfm" );
				expect( function() {
					renderInitial( comp );
				} ).toThrow( type="OuterElementNotFound" );  
			} );

			it( "fires onDIComplete", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				var result = renderInitial( comp );
				expect( result ).toContain( "onDIComplete: true" );
			} );

			it( "wire:initial-data has properties with their default values", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				var result = renderInitial( comp );
				expect( result ).toContain( "&quot;name&quot;:&quot;Grant&quot;" );
			} );

			it( "wire:initial-data has valid json", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				var result = renderInitial( comp );
				var initialDataJSON = parseInitialData( result );
				expect( isJSON( initialDataJSON ) ).toBeTrue();
			} );

			it( "wire:initial-data contains defined listeners", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				var result = renderInitial( comp );
				var initialDataJSON = parseInitialData( result );
				var initialDataStruct = deserializeJSON( initialDataJSON );
				expect( initialDataStruct.effects.listeners.findNoCase( "onSuccess" ) ).toBeTrue();
			} );

			it( "wire:initial-data has expected structure", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				var result = renderInitial( comp );
				var initialDataJSON = parseInitialData( result );
				var initialDataStruct = deserializeJSON( initialDataJSON );
				expect( initialDataStruct.effects.listeners.findNoCase( "onSuccess" ) ).toBeTrue();
				expect( initialDataStruct.serverMemo.data.mounted ).toBeTrue();
				expect( initialDataStruct.serverMemo.data.name ).toBe( "Grant" );
				expect( structKeyExists( initialDataStruct.serverMemo, "checksum" ) ).toBeTrue();
				expect( structKeyExists( initialDataStruct.serverMemo, "htmlHash" ) ).toBeTrue();
				expect( initialDataStruct.fingerprint.module ).toBe( "" );
				expect( structKeyExists( initialDataStruct.fingerprint, "path" ) ).toBeTrue();
				expect( initialDataStruct.fingerprint.name ).toBe( "tests.templates.TestComponent" );
				expect( initialDataStruct.fingerprint.id.len() ).toBe( 20 );
				expect( initialDataStruct.fingerprint.method ).toBe( "GET" );
			} );

			it( "can render data properties using data property name", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				var result = renderInitial( comp );
				expect( result ).toContain( "name: Grant" );
			} );

			it( "can render data properties using args scope and data property name", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/datapropertyusingargs.cfm" );
				var result = renderInitial( comp );
				expect( result ).toContain( "name: Grant" );
			} );

			it( "can call udf method defined on the component", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/udfmethod.cfm" );
				var result = renderInitial( comp );
				expect( result ).toContain( "<li>Luis</li>" );
				expect( result ).toContain( "<li>Esme</li>" );
				expect( result ).toContain( "<li>Michael</li>" );
			} );

			it( "can call computed property", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/computedproperty.cfm" );
				var result = renderInitial( comp );
				expect( result ).toContain( "result: 10" );
			} );

			it( "caches computed properties", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/cachedcomputedproperty.cfm" );
				var result = renderInitial( comp );
				var ticks = reMatchNoCase( "\d+\|\d+\|\d+", result ).first();
				var ticksArray = listToArray( ticks, "|" );
				expect( ticksArray[ 1 ] ).toBe( ticksArray[ 2 ] );
				expect( ticksArray[ 2 ] ).notToBe( ticksArray[ 3 ] );
			} );

			it( "lifecycle onMount method executes and updates data properties", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/onmount.cfm" );
				comp.$( "getEvent", event );
				var result = renderInitial( comp );
				expect( result ).toContain( "mounted: true" );
			} );

			it( "lifecycle onLoad method executes and updates data properties", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/onload.cfm" );
				comp.$( "getEvent", event );
				var result = renderInitial( comp );
				expect( result ).toContain( "loaded: true" );
			} );

			it( "lifecycle onMount method executes with expected parameters", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/onmount.cfm" );
				comp.$( "getEvent", event );
				parent.$( "onMount", "" );
				var result = renderInitial( comp );
				expect( parent.$once( "onMount" ) ).toBeTrue();
				expect( isStruct( parent.$callLog().onMount[ 1 ].parameters ) ).toBeTrue();
				expect( isStruct( parent.$callLog().onMount[ 1 ].params ) ).toBeTrue();
				expect( isObject( parent.$callLog().onMount[ 1 ].event ) ).toBeTrue();
				expect( isStruct( parent.$callLog().onMount[ 1 ].rc ) ).toBeTrue();
				expect( isStruct( parent.$callLog().onMount[ 1 ].prc ) ).toBeTrue();
			} );

			it( "registers listeners", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/template.cfm" );
				var result = renderInitial( comp );
				var initialDataJSON = parseInitialData( result );
				var initialDataStruct = deserializeJSON( initialDataJSON );
				expect( initialDataStruct.effects.listeners.findNoCase( "onSuccess") ).toBeTrue();
			} );

			it( "can use property injection on component", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/template.cfm" );
				var result = renderInitial( comp );
				expect( parent.getCBWIREService() ).toBeInstanceOf( "cbwire.models.CBWireService" );
			} );

			it( "can call entangle()", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/entangle.cfm" );
				var result = renderInitial( comp );
				expect( result ).toContain( "name: window.Livewire.find( '#comp.getID()#' ).entangle( 'name' )" );
			} );

			it( "uses onRender() if defined", function() {
				parent.$( "onRender", "<div>rendered with onRender</div>" );
				var result = renderInitial( comp );
				expect( result ).toContain( "rendered with onRender" );
			} );

			it( "can use global UDFs in application helpers", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/globaludf.cfm" );
				var result = renderInitial( comp );
				expect( result ).toContain( "yay!" );
			} );

			it( "can use helper methods from other modules ( cbi18n )", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/cbi18n.cfm" );
				var result = renderInitial( comp );
				expect( result ).toContain( "cbi18n says: whatever" );
			} );

			describe( "validation", function() {
				it( "validates constraints", function() {
					comp.$( "getComponentTemplatePath", "/tests/templates/validation.cfm" );
					var result = renderInitial( comp );
					expect( result ).toContain( "The 'EMAIL' value is required" );
				} );
			} );

			xit( "throws error if there are two or more outer elements", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/templateWithTwoOuterElements.cfm" );
				expect( function() {
					renderInitial( comp );
				} ).toThrow( type="OuterElementNotFound" );  
			} );
			
			xit( "can call renderView from a template", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/renderview.cfm" );
				var result = renderInitial( comp );
				expect( result ).toContain( "test view" );
			} );
		} );

		describe( "SubsequentRender", function(){
			beforeEach( function( currentSpec ){
				setup();
				event = getRequestContext();
				rc = event.getCollection();
				comp = getInstance( "tests.templates.TestComponent" ).startup( initialRender=false );
				comp.setEvent( event );
				prepareMock( comp );
				parent = comp.getParent();
				prepareMock( parent );
			} );

			it( "is an object", function() {
				expect( isObject( comp ) ).toBeTrue();
			} );

			it( "is an instance of SubsequentRenderer", function() {
				expect( comp ).toBeInstanceOf( "SubsequentRenderer" );
			} );

			it( "throws an error if we call an action that doesn't exist", function() {
				rc.updates = [ {
					type: "CallMethod",
					payload: {
						method: "methodThatDoesNotExist"
					}
				} ];
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				expect( function() {
					renderSubsequent( comp );
				} ).toThrow( type="WireActionNotFound" );
			} );

			it( "calling noRender() causes no rendering to be returned", function() {
				rc.updates = [ {
					type: "CallMethod",
					payload: {
						method: "doNotRender"
					}
				} ];
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				var result = renderSubsequent( comp );
				expect( isNull( result.effects.html ) ).toBeTrue();
			} );

			it( "declaring queryString causes it to be returned in path", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				var result = renderSubsequent( comp );
				expect( result.effects.path ).toContain( "?name=Grant" );
			} );

			it( "actions can call getInstance()", function() {
				rc.updates = [ {
					type: "CallMethod",
					payload: {
						method: "callGetInstance"
					}
				} ];
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				var result = renderSubsequent( comp );
				expect( result.effects.html ).toContain( "getInstance: true" );
			} );

			describe( "magicActions", function() {

				it( "should be able to $toggle true", function() {
					rc[ "serverMemo" ] = {
						"data": {
							"toggled": false
						}
					};
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "$toggle",
							params: [ "toggled" ]
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).toContain( "toggled: true" );
				} );

				it( "should be able to $toggle false", function() {
					rc[ "serverMemo" ] = {
						"data": {
							"toggled": true
						}
					};
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "$toggle",
							params: [ "toggled" ]
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).toContain( "toggled: false" );
				} );

				it( "should be able to $set property", function() {
					rc[ "serverMemo" ] = {
						"data": {
							"name": "hello"
						}
					};
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "$set",
							params: [ "name", "world" ]
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).toContain( "name: world" );
				} );
			} );

			describe( "reset", function() {

				it( "can reset() a single property", function() {
					rc[ "serverMemo" ] = {
						"data": {
							"name": "Awesome dev"
						}
					};
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "tryResetSingleProperty"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).notToContain( "name: Awesome dev" );
					expect( result.effects.html ).toContain( "name: Grant" );
				} );

				it( "can reset() an array of properties", function() {
					rc[ "serverMemo" ] = {
						"data": {
							"name": "Awesome dev",
							"sum": "10"
						}
					};
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "tryResetArrayOfProperties"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).notToContain( "name: Awesome dev" );
					expect( result.effects.html ).toContain( "name: Grant" );
					expect( result.effects.html ).toContain( "sum: 0" );
				} );

				it( "can reset() all properties", function() {
					rc[ "serverMemo" ] = {
						"data": {
							"name": "Awesome dev",
							"sum": "10"
						}
					};
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "tryResetAllProperties"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).notToContain( "name: Awesome dev" );
					expect( result.effects.html ).toContain( "name: Grant" );
					expect( result.effects.html ).toContain( "sum: 0" );
				} );

				it( "can resetExcept() a single property", function() {
					rc[ "serverMemo" ] = {
						"data": {
							"name": "Awesome dev",
							"sum": "10"
						}
					};
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "tryResetExceptSingleProperty"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).notToContain( "name: Awesome dev" );
					expect( result.effects.html ).toContain( "name: Grant" );
					expect( result.effects.html ).toContain( "sum: 10" );
				} );

				it( "can resetExcept() an array of properties", function() {
					rc[ "serverMemo" ] = {
						"data": {
							"name": "Awesome dev",
							"sum": "10"
						}
					};
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "tryResetExceptArrayOfProperties"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).toContain( "name: Awesome dev" );
					expect( result.effects.html ).toContain( "sum: 10" );
				} );
			} );

			describe( "redirecting", function() {

				it( "can relocate to an uri", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "redirectToURI"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.redirect ).toBe( "/some-url" );
				} );

				it( "can relocate to a URL", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "redirectToURL"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.redirect ).toBe( "https://www.google.com" );
				} );

				it( "can relocate to an event", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "redirectToEvent"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.redirect ).toContain( "/examples/index" );
				} );

				it( "can relocate to an event", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "redirectWithFlash"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					var flashScope = getRequestContext().getController().getRequestService().getFlashScope().getAll();
					expect( result.effects.redirect ).toContain( "/examples/index" );
					expect( flashScope.confirm ).toBe( "Redirect successful" );
				} );

			} );

			describe( "dispatch()", function() {
				it( "can dispatch an event with no arguments", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "dispatchEventWithoutArgs"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					var dispatch = result.effects.dispatches[ 1 ];
					expect( dispatch.event ).toBe( "Event1" );
					expect( isStruct( dispatch.data ) ).toBeTrue();
					expect( structCount( dispatch.data ) ).toBe( 0 );
				} );

				it( "can dispatch an event with arguments", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "dispatchEventWithArgs"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					var dispatch = result.effects.dispatches[ 1 ];
					expect( dispatch.event ).toBe( "Event1" );
					expect( isStruct( dispatch.data ) ).toBeTrue();
					expect( dispatch.data.someVar ).toBeTrue();
				} );
			} );

			describe( "emit()", function() {
				
				it( "can emit an event with no arguments", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "emitEventWithoutArgs"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					var firstEmit = result.effects.emits[ 1 ];
					expect( firstEmit.event ).toBe( "Event1" );
					expect( isArray( firstEmit.params ) ).toBeTrue();
					expect( arrayLen( firstEmit.params ) ).toBe( 0 );
				} );

				it( "can emit an event with one argument", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "emitEventWithOneArg"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					var firstEmit = result.effects.emits[ 1 ];
					expect( firstEmit.event ).toBe( "Event1" );
					expect( firstEmit.params[ 1 ] ).toBe( "someArg" );
				} );

				it( "can emit an event with many arguments", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "emitEventWithManyArgs"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					var firstEmit = result.effects.emits[ 1 ];
					expect( firstEmit.event ).toBe( "Event1" );
					expect( firstEmit.params[ 1 ] ).toBe( "arg1" );
					expect( firstEmit.params[ 2 ] ).toBe( "arg2" );
					expect( firstEmit.params[ 3 ] ).toBe( "arg3" );
				} );
			} );

			describe( "emitSelf()", function() {
				
				it( "can emit an event with no arguments", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "emitSelfEventWithoutArgs"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					var firstEmit = result.effects.emits[ 1 ];
					expect( firstEmit.event ).toBe( "Event1" );
					expect( isArray( firstEmit.params ) ).toBeTrue();
					expect( arrayLen( firstEmit.params ) ).toBe( 0 );
					expect( firstEmit.selfOnly ).toBe( true );
				} );

				it( "can emit an event with one argument", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "emitSelfEventWithOneArg"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					var firstEmit = result.effects.emits[ 1 ];
					expect( firstEmit.event ).toBe( "Event1" );
					expect( firstEmit.params[ 1 ] ).toBe( "someArg" );
					expect( firstEmit.selfOnly ).toBeTrue();
				} );

				it( "can emit an event with many arguments", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "emitSelfEventWithManyArgs"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					var firstEmit = result.effects.emits[ 1 ];
					expect( firstEmit.event ).toBe( "Event1" );
					expect( firstEmit.params[ 1 ] ).toBe( "arg1" );
					expect( firstEmit.params[ 2 ] ).toBe( "arg2" );
					expect( firstEmit.params[ 3 ] ).toBe( "arg3" );
					expect( firstEmit.selfOnly ).toBeTrue();
				} );
			} );

			describe( "emitUp()", function() {
				
				it( "can emit up an event with no arguments", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "emitUpEventWithoutArgs"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					var firstEmit = result.effects.emits[ 1 ];
					expect( firstEmit.event ).toBe( "Event1" );
					expect( isArray( firstEmit.params ) ).toBeTrue();
					expect( arrayLen( firstEmit.params ) ).toBe( 0 );
					expect( firstEmit.ancestorsOnly ).toBe( true );
				} );

				it( "can emit an event with one argument", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "emitUpEventWithOneArg"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					var firstEmit = result.effects.emits[ 1 ];
					expect( firstEmit.event ).toBe( "Event1" );
					expect( firstEmit.params[ 1 ] ).toBe( "someArg" );
					expect( firstEmit.ancestorsOnly ).toBeTrue();
				} );

				it( "can emit an event with many arguments", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "emitUpEventWithManyArgs"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					var firstEmit = result.effects.emits[ 1 ];
					expect( firstEmit.event ).toBe( "Event1" );
					expect( firstEmit.params[ 1 ] ).toBe( "arg1" );
					expect( firstEmit.params[ 2 ] ).toBe( "arg2" );
					expect( firstEmit.params[ 3 ] ).toBe( "arg3" );
					expect( firstEmit.ancestorsOnly ).toBeTrue();
				} );
			} );

			describe( "emitTo()", function() {
				
				it( "can emit an event with no arguments", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "emitToEventWithoutArgs"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					var firstEmit = result.effects.emits[ 1 ];
					expect( firstEmit.event ).toBe( "Event1" );
					expect( isArray( firstEmit.params ) ).toBeTrue();
					expect( arrayLen( firstEmit.params ) ).toBe( 0 );
					expect( firstEmit.to ).toBe( "Component2" );
				} );

				it( "can emit an event with one argument", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "emitToEventWithOneArg"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					var firstEmit = result.effects.emits[ 1 ];
					expect( firstEmit.event ).toBe( "Event1" );
					expect( firstEmit.params[ 1 ] ).toBe( "someArg" );
					expect( firstEmit.to ).toBe( "Component2");
				} );

				it( "can emit an event with many arguments", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "emitToEventWithManyArgs"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					var firstEmit = result.effects.emits[ 1 ];
					expect( firstEmit.event ).toBe( "Event1" );
					expect( firstEmit.params[ 1 ] ).toBe( "arg1" );
					expect( firstEmit.params[ 2 ] ).toBe( "arg2" );
					expect( firstEmit.params[ 3 ] ).toBe( "arg3" );
					expect( firstEmit.to ).toBe( "Component2" );
				} );

				it( "executes a registered listener", function() {
					rc.updates = [ {
						type: "FireEvent",
						payload: {
							event: "onSuccess",
							params: []
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).toContain( "listener: true" );
				} );

				it( "throws error when executing a listener with a missing action", function() {
					rc.updates = [ {
						type: "FireEvent",
						payload: {
							event: "missingAction",
							params: []
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					expect( function() {
						var result = renderSubsequent( comp );
					} ).toThrow( type="WireActionNotFound" );
				} );

			} );


			describe( "hydration", function() {
				
				it( "populates id from fingerperint", function() {
					rc.fingerprint = { id: "abc123" };
					comp.$( "getComponentTemplatePath", "/tests/templates/template.cfm" );
					renderSubsequent( comp );
					expect( comp.getID() ).toBe( "abc123");
				} );

				it( "updates data properties from server memo data", function() {
					rc.serverMemo = {
						data = {
							name: "Copley"
						}
					};
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).toContain( "name: Copley" );
				} );

				it( "executes actions", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "changeDataProperty"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.serverMemo.data.name ).toBe( "Something else" );
				} );


				it( "tracks dirty properties", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "changeDataProperty"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.serverMemo.data.name ).toBe( "Something else" );
				} );

				it( "executes onHydrate()", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "changeDataProperty"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).toContain( "hydrated: true" );
				} );

				it( "executes onHydratePropertyName", function() {
					rc.serverMemo = {
						data = {
							name: "Grant"
						}
					};
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					parent.$( "onHydrateName" );
					var result = renderSubsequent( comp );
					expect( parent.$callLog().onHydrateName[ 1 ].value ).toBe( "Grant" );
				} );

			} );

			it( "executes onLoad", function() {
				rc.updates = [ {
					type: "SyncInput",
					payload: {
						name: "name",
						value: "I synced!"
					}
				} ];
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				parent.$( "onLoad" );
				renderSubsequent( comp );
				expect( parent.$callLog().onLoad[ 1 ].event ).toBeInstanceOf( "RequestContext" );
				expect( parent.$callLog().onLoad[ 1 ].rc ).toBeStruct();
				expect( parent.$callLog().onLoad[ 1 ].prc ).toBeStruct();
			} );

			describe( "updates", function() {
				it( "executes onUpdate", function() {
					rc.updates = [ {
						type: "SyncInput",
						payload: {
							name: "name",
							value: "I synced!"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					parent.$( "onUpdate" );
					renderSubsequent( comp );
					expect( parent.$callLog().onUpdate[ 1 ].oldValues.name ).toBe( "Grant" );
					expect( parent.$callLog().onUpdate[ 1 ].newValues.name ).toBe( "I synced!" );
				} );

				it( "executes onUpdate[Property]", function() {
					rc.updates = [ {
						type: "SyncInput",
						payload: {
							name: "name",
							value: "I synced!"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					parent.$( "onUpdateName" );
					renderSubsequent( comp );
					expect( parent.$callLog().onUpdateName[ 1 ].oldValue ).toBe( "Grant" );
					expect( parent.$callLog().onUpdateName[ 1 ].newValue ).toBe( "I synced!" );
				} );
			} );

			it( "can sync input", function() {
				rc.updates = [ {
					type: "SyncInput",
					payload: {
						name: "name",
						value: "I synced!"
					}
				} ];
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				var result = renderSubsequent( comp );
				expect( result.effects.html ).toContain( "name: I synced!" );
			} );

			describe( "Nested data binding", function() {
				it ( "can sync nested structure data", function(){
					rc.updates = [ {
						type: "SyncInput",
						payload: {
							name: "someStruct.someKey",
							value: "I synced a nested data property!"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).toContain( "someStruct: I synced a nested data property!" );
				} );

				it ( "can sync nested structure array data", function(){
					rc.updates = [ {
						type: "SyncInput",
						payload: {
							name: "someArray.0.someKey",
							value: "I synced a nested array data property!"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).toContain( "someArray: I synced a nested array data property!" );
				} );
			} );

			describe( "validation", function() {

				it( "can call validateOrFail() from an action and FAIL", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "runValidateFailure"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).toContain( "validateOrFail: false" );
				} );
	
				it( "can call validateOrFail() from an action and COMPLETE", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "runValidateSuccess"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).toContain( "validateOrFail: true" );
				} );

				it( "can call validate() from an action", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							method: "runValidate"
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					var result = renderSubsequent( comp );
					expect( result.effects.html ).toContain( "validate: true" );
				} );

			} );

			describe( "file uploads", function() {
				it( "can start an upload", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							"id": "ksfh",
							"method": "startUpload",
							"params": [
		  						"someFile",
								[
									{
									"name": "2022-08-21 07.52.50.gif",
									"size": 424008,
									"type": "image/gif"
									}
								],
								false
							]
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					
					var result = renderSubsequent( comp );
					expect( result.effects.emits[ 1 ].event ).toBe( "upload:generatedSignedUrl" );
					expect( result.effects.emits[ 1 ].params[ 1 ] ).toBe( "someFile" );
					expect( result.effects.emits[ 1 ].params[ 2 ] ).toBe( "/livewire/upload-file?expires=never&signature=someSignature" );
					expect( result.effects.emits[ 1 ].selfOnly ).toBeTrue();
				} );

				it( "can finish an upload", function() {
					rc.updates = [ {
						type: "CallMethod",
						payload: {
							"id": "ksfh",
							"method": "finishUpload",
							"params": [
		  						"someFile",
								[ "37867A38-4DB3-43EC-8FB93DB936302BC5" ],
								false
							]
						}
					} ];
					comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
					
					var result = renderSubsequent( comp );

					//expect( comp.getDataProperties().someFile ).toContain( "cbwire-upload:" );
					expect( result.effects.emits[ 1 ].event ).toBe( "upload:finished" );
					expect( result.effects.emits[ 1 ].params[ 1 ] ).toBe( "someFile" );
					expect( result.effects.emits[ 1 ].selfOnly ).toBeTrue();
				} );

			} );

			it( "can call computed properties from actions", function() {
				rc.updates = [ {
					type: "CallMethod",
					payload: {
						method: "actionWithComputedProperty"
					}
				} ];
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				
				var result = renderSubsequent( comp );

				expect( comp.getDataProperties().sum ).toBe( 10 );
			} );

			it( "can render a component with comments", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/templateWithComments.cfm" );
				var result = renderSubsequent( comp );
				expect( result.effects.html ).notToContain( "This is a template with multiple comments" );
				expect( result.effects.html ).notToContain( "we have single line comments" );
				expect( result.effects.html ).notToContain( "multi" );
			} );

			it( "can call helper methods defined in other modules", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/cbi18n.cfm" );
				var result = renderSubsequent( comp );
				expect( result.effects.html ).toContain( "cbi18n says: whatever" );
			} );

			it( "can render a child component", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/childcomponent.cfm" );
				var result = renderSubsequent( comp );
				var initialDataJSON = parseInitialData( result.effects.html );
				var initialDataStruct = deserializeJSON( initialDataJSON );
				expect( result.effects.html ).toContain( "Child Component" );
				expect( structCount( result.serverMemo.children ) ).toBe( 1 );
				expect( arrayLen( reMatchNoCase( "wire:initial-data=", result.effects.html ) ) ).toBe( 1 );
			} );

			xit( "partially renders a child component if it's already an existing child in the incoming payload", function() {
				
				rc[ "serverMemo" ] = {
					"data": {},
					"children" = {
						"795Fa90Ff42046178345-4": {
							"id": "795Fa90Ff42046178345-4",
							"tag": "div"
						}
					}
				};
				comp.setID( "795Fa90Ff42046178345" );
				comp.$( "getComponentTemplatePath", "/tests/templates/childcomponent.cfm" );
				comp.$( "getChildren", rc.serverMemo.children );
				var result = renderSubsequent( comp );
				expect( result.effects.html ).notToContain( "Child Component" );
				expect( result.effects.html ).toContain( "<div wire:id=""795Fa90Ff42046178345-75""></div>" );
			} );

			xit( "can call refresh() and generate a new id", function() {
				rc.fingerprint = { id: "abc123" };
				rc.updates = [ {
					type: "CallMethod",
					payload: {
						method: "someMethod"
					}
				} ];
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				var result = renderSubsequent( comp );
				expect( result.effects.html ).toContain( 'wire:id="abc123"' );

				rc.updates = [ {
					type: "CallMethod",
					payload: {
						method: "actionWithRefresh"
					}
				} ];
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				result = renderSubsequent( comp );
				expect( result.effects.html ).notToContain( 'wire:id="abc123"' );
			} );

		} );

		describe( "Single-file Components", function() {

			it( "can render single-file components", function() {
				var cbwireService = prepareMock( getInstance( "CBWIREService@cbwire" ) );
				var result = cbwireService.wire( "tests.templates.SingleFileComponent" );
				expect( result ).toContain( "Name: Single File Component" );
			} );

			it( "caches single-file components is 'cacheSingleFileComponents' setting is enabled", function() {
				var settings = getInstance( dsl="coldbox:modulesettings:cbwire" );
				var moduleRootPath = settings.moduleRootPath;
				var tmpFilePath = "#moduleRootPath#/models/tmp/SingleFileComponent.cfc";
				var cbwireService = prepareMock( getInstance( "CBWIREService@cbwire" ) );

				if ( fileExists( tmpFilePath ) ) {
					fileDelete( tmpFilePath );
				}

				expect( fileExists( tmpFilePath ) ).toBeFalse();

				settings.cacheSingleFileComponents = false;
				var result = cbwireService.wire( "tests.templates.SingleFileComponent" );
				expect( fileExists( tmpFilePath ) ).toBeFalse();

				settings.cacheSingleFileComponents = true;
				var result = cbwireService.wire( "tests.templates.SingleFileComponent" );
				expect( fileExists( tmpFilePath ) ).toBeTrue();
			} );
		} );

		describe( "CBWIREService", function() {
			beforeEach( function( currentSpec ){
				setup();
				event = getRequestContext();
				rc = event.getCollection();
				prc = event.getPrivateCollection();
				service = prepareMock( getInstance( "CBWIREService@cbwire" ) );
			} );

			it( "can getStyles()", function() {
				var result = service.getStyles();
				expect( result ).toContain( "<!-- CBWIRE Styles -->" );
				expect( result ).toContain( "<style>" );
				expect( result ).toContain( "</style>" );
			} );

			it( "can getStyles() with Turbo", function() {
				service.$( "getSettings", { "enableTurbo": false }, false );
				var result = service.getStyles();
				expect( result ).notToContain( "import hotwiredTurbo from" );
				service.$( "getSettings", { "enableTurbo": true }, false );
				var result = service.getStyles();
				expect( result ).toContain( "import hotwiredTurbo from" );
			} );

			it( "can getScripts()", function() {
				var result = service.getScripts();
				expect( result ).toContain( "<!-- CBWIRE Scripts -->" );
				expect( result ).toContain( "<script " );
				expect( result ).toContain( "</script>" );
				expect( result ).toContain( "window.Livewire" );
				expect( result ).toContain( "window.cbwire" );
			} );

			it( "can render component from ./wires folder using wire()", function() {
				var result = service.wire( "TestComponent" );
				expect( result ).toContain( "Title: CBWIRE Rocks!" );
			} );

			it( "can render component from nested folder using wire()", function() {
				var result = service.wire( "wires.nestedComponent.NestedFolderComponent" );
				expect( result ).toContain( "Nested folder component" );
			} );

			it( "can render component from outside folder using wire()", function() {
				var result = service.wire( "anotherFolder.OutsideFolderComponent" );
				expect( result ).toContain( "outside component" );
			} );

			it( "throws error if it's unable to find a module component", function() {
				expect( function() {
					var result = service.wire( "missing@someModule" );
				} ).toThrow( type="ModuleNotFound" );  
			} );

			it( "can render component from nested module folder using wire()", function() {
				var result = service.wire( "myComponents.NestedModuleComponent@testingmodule" );
				expect( result ).toContain( "Nested module component" );
			} );

			it( "can render component from nested module using default wires location", function() {
				var result = service.wire( "NestedModuleDefaultComponent@testingmodule" );
				expect( result ).toContain( "Nested module component using default wires location" );
			} );

		} );

		describe( "Auto injected assets", function() {

			it( "it doesn't auto inject assets by default", function() {
				var settings = getInstance( dsl="coldbox:modulesettings:cbwire" );
				settings.autoInjectAssets = false;
				var event = execute( event="examples.index", renderResults=true );
				expect( event.getRenderedContent() ).notToContain( "<!-- CBWIRE Styles -->" );
				expect( event.getRenderedContent() ).notToContain( "<!-- CBWIRE Scripts -->" );
			} );

			xit( "it auto inject assets if 'autoInjectAssets' is enabled", function() {
				var settings = getInstance( dsl="coldbox:modulesettings:cbwire" );
				settings.autoInjectAssets = true;
				var event = execute( event="examples.index", renderResults=true );
				writeDump( event.getRenderedContent() );
				abort;
				expect( event.getRenderedContent() ).notToContain( "<!-- CBWIRE Styles -->" );
				expect( event.getRenderedContent() ).notToContain( "<!-- CBWIRE Scripts -->" );
			} );
		} );
	
		describe( "Component without onMount", function(){
			
			it( "can render with no parameters passed", function() {
				var cbwireService = prepareMock( getInstance( "CBWIREService@cbwire" ) );
				var result = cbwireService.wire( "tests.templates.withoutOnMountEvent" );
				expect( result ).toContain( "COMPLETED-PROCESSING" );
			} );
			
			it( "can render with empty struct parameters passed", function() {
				var cbwireService = prepareMock( getInstance( "CBWIREService@cbwire" ) );
				var result = cbwireService.wire( "tests.templates.withoutOnMountEvent", {} );
				expect( result ).toContain( "COMPLETED-PROCESSING" );
			} );

			it( "throws MissingOnMount when parameters contains value of datatype other than string, boolean, numeric, date, array, or struct (java object)", function(){
				var cbwireService = prepareMock( getInstance( "CBWIREService@cbwire" ) );
				var javaObj = createObject( "java", "java.lang.StringBuilder" ).init( "" );
				expect( function() {
						var result = cbwireService.wire( 
								"tests.templates.withoutOnMountEvent", 
								{ 
									"testString" : "String Value",
									"javaObj" : javaObj
								} 
							);
				}).toThrow( type="MissingOnMount" );  
			} );

			it( "throws MissingOnMount when parameters contains value of datatype other than string, boolean, numeric, date, array, or struct (cfcomponent)", function(){
				var cbwireService = prepareMock( getInstance( "CBWIREService@cbwire" ) );
				var basicCFComponent = new tests.templates.basicCFComponent();
				expect( function() {
						var result = cbwireService.wire( 
								"tests.templates.withoutOnMountEvent", 
								{ 
									"testString" : "String Value",
									"basicCFComponent" : basicCFComponent
								} 
							);
				}).toThrow( type="MissingOnMount" );  
			} );

			it( "throws MissingOnMount when parameters contains value of datatype other than string, boolean, numeric, date, array, or struct (user defined function)", function(){
				var cbwireService = prepareMock( getInstance( "CBWIREService@cbwire" ) );
				var myUDF = function(){
					return "Hello Testbox!";
				};
				expect( function() {
						var result = cbwireService.wire( 
								"tests.templates.withoutOnMountEvent", 
								{ 
									"testString" : "String Value",
									"myUDF" : myUDF
								} 
							);
				}).toThrow( type="MissingOnMount" );  
			} );

			it( "can render with parameters of types string, boolean, numeric, date, array, or struct and merge with pre-existing data properties", function() {
				var cbwireService = prepareMock( getInstance( "CBWIREService@cbwire" ) );
				var result = cbwireService.wire( 
					"tests.templates.withoutOnMountEvent", 
					{ 
						"testString" : "String Value", 
						"testArray" : [ "value1", "value2", "value3" ], 
						"testStruct" : { "keyOne" : 9, "keyTwo" : true, "keyThree" : "Test struct key three text" }, 
						"testNumber" : 5678, 
						"testBoolean" : true, 
						"testDate" : now()
					} 
				);
				expect( result ).toContain( 'variables.data.testString = "String Value"' );
				expect( result ).toContain( "variables.data.preDefinedNumber = 1234" );
				expect( result ).toContain( "variables.data.testNumber = 5678" );
				expect( result ).toContain( 'variables.testString = "String Value"' );
				expect( result ).toContain( "variables.preDefinedNumber = 1234" );
				expect( result ).toContain( "variables.testNumber = 5678" );
				expect( result ).toContain( "COMPLETED-PROCESSING" );
			} );
		
		});
	}

	private function renderInitial( comp ) {
		var event = getRequestContext();
		return comp.mount().renderIt(
			event=event,
			rc=event.getCollection(),
			prc=event.getPrivateCollection()
		);
	}

	private function renderSubsequent( comp ) {
		var event = getRequestContext();
		return comp.hydrate().subsequentRenderIt(
			event=event,
			rc=event.getCollection(),
			prc=event.getPrivateCollection()
		);
	}

	private function parseInitialData( html ) {
		arguments.html = trim( html );
		var regexMatches = reFindNoCase( "wire:initial-data=""([^"">]+)", trim( arguments.html ), 1, true );
		return mid( html, regexMatches.pos[ 2 ], regexMatches.len[ 2 ] ).replaceNoCase( "&quot;", """", "all" );
	}

}
