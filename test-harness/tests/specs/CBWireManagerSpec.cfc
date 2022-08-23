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
		describe( "CBWireManager", function(){
			beforeEach( function( currentSpec ){
				setup();
				event = getRequestContext();

				rc = event.getCollection();
				rc[ "fingerprint" ] = {
					"v" : "acj",
					"path" : "/",
					"locale" : "en",
					"name" : "wires.TestComponent",
					"id" : "0686d74bD2d2490E8FbA",
					"method" : "GET"
				};

				event.setValue( "wireComponent", "TestComponent" );


				cbwireManager = prepareMock(
					getInstance( name = "cbwire.models.CBWireManager", initArguments = { "event" : event } )
				);
			} );

			describe( "handleIncomingRequest", function(){
				it( "returns effects and server memo", function(){
					event.setValue( "wireComponent", "TestComponent" );
					var result = cbwireManager.handleIncomingRequest( event );
					expect( result.effects.html ).toInclude( "<div wire:id=" );
					expect( result.effects.dirty ).toBeArray();
					expect( result.effects.emits ).toBeArray();
					expect( result.serverMemo.children ).toBeStruct();
					expect( result.serverMemo.data ).toBeStruct();
				} );

				it( "executes action 'changeTitle'", function(){
					rc[ "serverMemo" ] = {
						"children" : [],
						"data" : { "title" : "CBWIRE rocks!" },
						"errors" : [],
						"dataMeta" : [],
						"checksum" : "BCF81523602F2382F82B9CD8A99410FA",
						"htmlHash" : "ed290ae9"
					};

					rc[ "updates" ] = [
						{
							"type" : "callMethod",
							"payload" : {
								"id" : "zqs3",
								"method" : "changeTitle",
								"params" : []
							}
						}
					];
					var result = cbwireManager.handleIncomingRequest( event );
					expect( result.effects.html ).toInclude( "Title: CBWIRE Slays!" );
					expect( result.effects.dirty ).toBeArray();
					expect( result.effects.emits ).toBeArray();
					expect( result.serverMemo.children ).toBeStruct();
					expect( result.serverMemo.data.title ).toBe( "CBWIRE Slays!" );
					expect( result.serverMemo.data ).toBeStruct();
				} );

				it( "resets property using reset()", function(){
					rc[ "serverMemo" ] = {
						"children" : [],
						"data" : { "title" : "CBWIRE Slays!" },
						"errors" : [],
						"dataMeta" : [],
						"checksum" : "BCF81523602F2382F82B9CD8A99410FA",
						"htmlHash" : "ed290ae9"
					};

					rc[ "updates" ] = [
						{
							"type" : "callMethod",
							"payload" : {
								"id" : "zqs3",
								"method" : "resetTitle",
								"params" : []
							}
						}
					];

					var result = cbwireManager.handleIncomingRequest( event );
					expect( result.effects.html ).toInclude( "Title: CBWIRE Rocks!" );
				} );

				it( "emits event", function(){
					rc[ "serverMemo" ] = {
						"children" : [],
						"data" : { "title" : "CBWIRE Slays!" },
						"errors" : [],
						"dataMeta" : [],
						"checksum" : "BCF81523602F2382F82B9CD8A99410FA",
						"htmlHash" : "ed290ae9"
					};

					rc[ "updates" ] = [
						{
							"type" : "fireEvent",
							"payload" : {
								"id" : "zqs3",
								"event" : "someEvent",
								"params" : []
							}
						}
					];

					var result = cbwireManager.handleIncomingRequest( event );
					expect( result.effects.html ).toInclude( "Title: Fired some event" );
				} );

				it( "syncs input", function(){
					rc[ "serverMemo" ] = {
						"children" : [],
						"data" : { "title" : "CBWIRE Slays!" },
						"errors" : [],
						"dataMeta" : [],
						"checksum" : "BCF81523602F2382F82B9CD8A99410FA",
						"htmlHash" : "ed290ae9"
					};

					rc[ "updates" ] = [
						{
							"type" : "syncInput",
							"payload" : {
								"id" : "zqs3",
								"name" : "title",
								"value" : "CBWIRE Slays!"
							}
						}
					];

					var result = cbwireManager.handleIncomingRequest( event );
				} );

				it( "can start upload", function(){
					rc[ "serverMemo" ] = {
						"children" : [],
						"data" : { "title" : "CBWIRE Slays!" },
						"errors" : [],
						"dataMeta" : [],
						"checksum" : "BCF81523602F2382F82B9CD8A99410FA",
						"htmlHash" : "ed290ae9"
					};

					rc[ "updates" ] = [
						{
							"type" : "callMethod",
							"payload" : {
								"id" : "zqs3",
								"method" : "startUpload",
								"params" : [
									"myFile",
									{
										"name" : "cbwire.jpg",
										"size" : "39019",
										"type" : "image/jpg"
									}
								]
							}
						}
					];

					var result = cbwireManager.handleIncomingRequest( event );
					expect( result.effects.emits[ 1 ].event ).toBe( "upload:generatedSignedUrl" )
					expect( result.effects.emits[ 1 ].params[ 1 ] ).toBe( "myFile" );
					expect( result.effects.emits[ 1 ].params[ 2 ] ).toInclude( "/livewire/upload-file?expires=" );
					expect( result.effects.emits[ 1 ].params[ 2 ] ).toInclude( "signature=" );
					expect( result.effects.emits[ 1 ].selfOnly ).toBeTrue();
				} );
			} );

			describe( "getWiresLocation()", function(){
				it( "returns 'wires' by default", function(){
					cbwireManager.$property( "settings", "variables", {} );
					expect( cbwireManager.getWiresLocation() ).toBe( "wires" );
				} );
				it( "returns the wiresLocation from settings", function(){
					cbwireManager.$property( "settings", "variables", { wiresLocation : "somewhere" } );
					expect( cbwireManager.getWiresLocation() ).toBe( "somewhere" );
				} );
			} );
		} );
	}

}
