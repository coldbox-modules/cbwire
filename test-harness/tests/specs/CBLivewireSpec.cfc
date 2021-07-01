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
		describe( "cbwire Module", function(){
			beforeEach( function( currentSpec ){
				setup();
			} );

			it( "can render the main event", function(){
				var event = get( "/" );
				expect( event.getRenderedContent() ).toInclude( "Hello World" );
			} );

			describe( "livewire()", function(){
				it( "renders simple 'Hello World'", function(){
					var event = get( "/_tests/helloWorld" );
					expect( event.getRenderedContent() ).toInclude( "Hello World" );
				} );

				it( "renders 'Hello world' using renderView() and passing args to the view'", function(){
					var event = get( "/_tests/helloWorldWithRenderViewPropertyAndArgs" );
					expect( event.getRenderedContent() ).toInclude( "Hello World" );
				} );

				it( "renders 'Hello world' using view() and passing args to the view'", function(){
					var event = get( "/_tests/usingViewtoRender" );
					expect( event.getRenderedContent() ).toInclude( "Hello World" );
				} );

				it( "renders with wire:id and wire:initial-data attributes added to outer div tag'", function(){
					var event   = get( "/_tests/dataBinding" );
					var content = event.getRenderedContent();
					expect( content ).toInclude( "<div wire:id=" );
					expect( content ).toInclude( "wire:initial-data=" );
				} );

				it( "has ability to pass parameters'", function(){
					var event = get( "/_tests/passParameters" );
					var content = event.getRenderedContent();
					expect( content ).toInclude( "<ul>" );
					expect( content ).toInclude( "<li>Pepperoni</li>" );
				} );

				it( "has ability to pass parameters that are then passed into our mount() method'", function(){
					var event = get( "/_tests/passedParametersProvidedToMount" );
					var content = event.getRenderedContent();
					expect( content ).toInclude( "<ul>" );
					expect( content ).toInclude( "<li>Bacon</li>" );
				} );

				it( "renders defined getter 'getName()' on our component automatically'", function(){
					var event = get( "/_tests/getter" );
					var content = event.getRenderedContent();
					expect( content ).toInclude( "Rubble On The Double" );
				} );

			} );

			it( "livewireStyles() renders the livewire styles", function(){
				var event   = get( "/_tests/livewireStyles" );
				var content = event.getRenderedContent();
				expect( content ).toInclude( "<!-- Livewire Styles -->" );
				expect( content ).toInclude( "@keyframes livewireautofill { from {} }" );
			} );

			it( "livewireScripts() renders the livewire scripts", function(){
				var event   = get( "/_tests/livewireScripts" );
				var content = event.getRenderedContent();
				expect( content ).toInclude( "/moduleroot/cbwire/includes/js/livewire.js" );
			} );

			it( "can handle incoming request payloads to /livewire/message/:componentPath", function(){
				var event         = post( "/livewire/message/livewire.DataBinding" );
				var content       = event.getRenderedContent();
				var parsedContent = deserializeJSON( content );

				expect( content ).toBeJSON();
				expect( structKeyExists( parsedContent.serverMemo, "checksum" ) ).toBeTrue();
				expect( structKeyExists( parsedContent.serverMemo, "data" ) ).toBeTrue();
				expect( parsedContent.serverMemo.data.message ).toBe( "We have data binding!" );
			} );
		} );
	}

}
