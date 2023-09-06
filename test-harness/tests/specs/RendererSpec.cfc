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

			it( "throws error if it's unable to find an outer element", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/templateWithoutOuterElement.cfm" );
				expect( function() {
					renderInitial( comp );
				} ).toThrow( type="OuterElementNotFound" );  
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
				expect( initialDataStruct.effects.listeners[ 1] ).toBe( "onSuccess" );
			} );

			it( "wire:initial-data has expected structure", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/dataproperty.cfm" );
				var result = renderInitial( comp );
				var initialDataJSON = parseInitialData( result );
				var initialDataStruct = deserializeJSON( initialDataJSON );
				expect( initialDataStruct.effects.listeners[ 1 ] ).toBe( "onSuccess" );
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

			it( "lifecycle onMount method executes and updates data properties", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/onmount.cfm" );
				comp.$( "getEvent", event );
				var result = renderInitial( comp );
				expect( result ).toContain( "mounted: true" );
			} );

			it( "lifecycle onMount method executes with expected parameters", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/onmount.cfm" );
				comp.$( "getEvent", event );
				parent.$( "onMount", "" );
				var result = renderInitial( comp );
				expect( parent.$once( "onMount" ) ).toBeTrue();
				expect( isStruct( parent.$callLog().onMount[ 1 ].parameters ) ).toBeTrue();
				expect( isObject( parent.$callLog().onMount[ 1 ].event ) ).toBeTrue();
				expect( isStruct( parent.$callLog().onMount[ 1 ].rc ) ).toBeTrue();
				expect( isStruct( parent.$callLog().onMount[ 1 ].prc ) ).toBeTrue();
			} );

			it( "registers listeners", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/template.cfm" );
				var result = renderInitial( comp );
				var initialDataJSON = parseInitialData( result );
				var initialDataStruct = deserializeJSON( initialDataJSON );
				expect( initialDataStruct.effects.listeners[ 1 ] ).toBe( "onSuccess" );
			} );

			xit( "throws error if there are two or more outer elements", function() {
				comp.$( "getComponentTemplatePath", "/tests/templates/templateWithTwoOuterElements.cfm" );
				expect( function() {
					renderInitial( comp );
				} ).toThrow( type="OuterElementNotFound" );  
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
		} );

		describe( "InlineComponents", function() {

			it( "can render inline components", function() {
				var cbwireService = prepareMock( getInstance( "CBWIREService@cbwire" ) );
				var result = cbwireService.wire( "tests.templates.InlineComponent" );
				expect( result ).toContain( "Name: Inline Component" );
			} );
		} );
	}

	function renderInitial( comp ) {
		return comp.mount().renderIt();
	}

	function renderSubsequent( comp ) {
		return comp.hydrate().subsequentRenderIt().getMemento();
	}

	function parseInitialData( html ) {
		var regexMatches = reFindNoCase( "wire:initial-data=""(.+)""", html, 1, true );
		return mid( html, regexMatches.pos[ 2 ], regexMatches.len[ 2 ] ).replaceNoCase( "&quot;", """", "all" );
	}

}
