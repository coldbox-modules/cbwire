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
				cbwireHTML = getInstance( "CBWireHTML@cbwire" );
				moduleSettings = getInstance( "coldbox:moduleSettings:cbwire" );
			} );

			it( "can instantiate a component", function(){
				expect( isObject( cbwireHTML ) ).toBeTrue();
			} );

			describe( "getStyles()", function(){
				it( "renders the styles", function(){
					var result = cbwireHTML.getStyles();
					expect( result ).toInclude( "@keyframes livewireautofill" );
				} );

				it( "renders turbo drive assets", function(){
					moduleSettings[ "enableTurbo" ] = false;
					var result = cbwireHTML.getStyles();
					expect( result ).notToInclude( "import hotwiredTurbo from" );
					moduleSettings[ "enableTurbo" ] = true;
					result = cbwireHTML.getStyles();
					expect( result ).toInclude( "import hotwiredTurbo from" );
				} );
			} );

			describe( "getScripts()", function(){
				it( "renders the scripts", function(){
					var result = cbwireHTML.getScripts();
					expect( result ).toInclude( "window.livewire = new Livewire();" );
				} );

				it( "renders turbo drive assets", function(){
					moduleSettings[ "enableTurbo" ] = false;
					var result = cbwireHTML.getScripts();
					expect( result ).notToInclude( "https://cdn.jsdelivr.net/gh/livewire/turbolinks@" );
					moduleSettings[ "enableTurbo" ] = true;
					result = cbwireHTML.getScripts();
					expect( result ).toInclude( "https://cdn.jsdelivr.net/gh/livewire/turbolinks@" );
				} );
			} );

			describe( "entangle", function() {
				it ( "includes expected entanglement code", function() {
					var id = createUUID();
					cbwireHTML.getEvent().setPrivateValue( "cbwire_lastest_rendered_id", id );
					var result = cbwireHTML.entangle( "someProperty" );
					expect( result ).toBe( "window.Livewire.find( '#id#' ).entangle( 'someProperty' )" ) ;
				} );
			} );
		} );
	}

}
