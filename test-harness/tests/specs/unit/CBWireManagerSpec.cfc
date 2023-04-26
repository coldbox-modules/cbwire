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
		describe( "CBWIREManager.cfc", function(){
			beforeEach( function( currentSpec ){
				setup();
				manager = getInstance( "CBWireManager@cbwire" );
			} );

			it( "can instantiate a manager", function(){
				expect( isObject( manager ) ).toBeTrue();
			} );

			describe( "getRootComponentPath()", function() {
				
				it( "by default appends the wires directory", function() {
					var result = manager.getRootComponentPath( "SomeComponent" );
					expect( result ).toBe( "wires.SomeComponent" );
				} );

				it( "by default keeps the wires directory", function() {
					var result = manager.getRootComponentPath( "wires.SomeComponent" );
					expect( result ).toBe( "wires.SomeComponent" );
				} );	

				it( "doesn't alter the path if a full path is already provided", function() {
					var result = manager.getRootComponentPath( "myapp.wires.SomeComponent" );
					expect( result ).toBe( "myapp.wires.SomeComponent" );
				} );
			} );
		} );
	}

}
