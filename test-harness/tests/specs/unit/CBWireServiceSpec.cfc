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
		describe( "CBWireService.cfc", function(){
			beforeEach( function( currentSpec ){
				setup();
				service = prepareMock( getInstance( "CBWireService@cbwire" ) );
			} );

			it( "can instantiate a service", function(){
				expect( isObject( service ) ).toBeTrue();
			} );

			describe( "getStyles()", function(){
				it( "renders the styles", function(){
					var result = service.getStyles();
					expect( result ).toInclude( "@keyframes livewireautofill" );
				} );

				it( "renders turbo drive assets", function(){
					moduleSettings[ "enableTurbo" ] = false;
					service.setSettings( moduleSettings );
					var result = service.getStyles();
					expect( result ).notToInclude( "import hotwiredTurbo from" );
					moduleSettings[ "enableTurbo" ] = true;
					service.setSettings( moduleSettings );
					result = service.getStyles();
					expect( result ).toInclude( "import hotwiredTurbo from" );
				} );
			} );

			describe( "getScripts()", function(){
				it( "renders the scripts", function(){
					var result = service.getScripts();
					expect( result ).toInclude( "window.livewire = new Livewire();" );
				} );

				it( "renders turbo drive assets", function(){
					moduleSettings[ "enableTurbo" ] = false;
					service.setSettings( moduleSettings );
					var result = service.getScripts();
					expect( result ).notToInclude( "https://cdn.jsdelivr.net/gh/livewire/turbolinks@" );
					moduleSettings[ "enableTurbo" ] = true;
					service.setSettings( moduleSettings );
					result = service.getScripts();
					expect( result ).toInclude( "https://cdn.jsdelivr.net/gh/livewire/turbolinks@" );
				} );
			} );

			describe( "getRootComponentPath()", function() {
				
				it( "by default appends the wires directory", function() {
					var result = service.getRootComponentPath( "SomeComponent" );
					expect( result ).toBe( "wires.SomeComponent" );
				} );

				it( "by default keeps the wires directory", function() {
					var result = service.getRootComponentPath( "wires.SomeComponent" );
					expect( result ).toBe( "wires.SomeComponent" );
				} );	

				it( "doesn't alter the path if a full path is already provided", function() {
					var result = service.getRootComponentPath( "myapp.wires.SomeComponent" );
					expect( result ).toBe( "myapp.wires.SomeComponent" );
				} );
			} );
		} );
	}

}
