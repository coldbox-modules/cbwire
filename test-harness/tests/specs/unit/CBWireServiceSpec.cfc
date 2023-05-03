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
				service = getInstance( "CBWireService@cbwire" );
			} );

			it( "can instantiate a service", function(){
				expect( isObject( service ) ).toBeTrue();
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
