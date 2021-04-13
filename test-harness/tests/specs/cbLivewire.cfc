/**
 * MessageBox tests
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
		describe( "cbLivewire Module", function(){
			beforeEach( function( currentSpec ){
				setup();
			} );

			it( "can render the main event", function(){
				var event = get( "/" );
				expect( event.getRenderedContent() ).toInclude( "Hello World" );
			} );

			describe( "livewire()", function() {
				it( "renders simple 'Hello World'", function() {
					var event = get( "/_tests/hello_world" );
					expect( event.getRenderedContent() ).toInclude( "Hello World" );
				} );

				it( "renders 'Hello world' using a view and passing args to the view'", function() {
					var event = get( "/_tests/hello_world_with_render_view_and_args" );
					expect( event.getRenderedContent() ).toInclude( "Hello World" );
				} );
			} );

			it( "livewireStyles() renders the livewire styles", function(){
				var event = get( "/_tests/livewire_styles" );
				var content = event.getRenderedContent();
				expect( content ).toInclude( "<!-- Livewire Styles -->" );
				expect( content ).toInclude( "@keyframes livewireautofill { from {} }" );
			} );
			
		} );
	}

}
