component extends="cbwire.models.BaseWireTest" {

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
		describe( "TestUIComponent.cfc", function(){
			it( "wires up the component with default template", function() {
				var result = wire( "TestUIComponent" ).render();
				expect( result ).toInclude( "<h1>This is the default template</h1>" );
			} );

			it( "changes the message", function(){
				var result = wire( "TestUIComponent" )
								.set( "message", "Something else" )
								.render();
				expect( result ).toInclude( "<h1>Something else</h1>" );
			} );

			it( "toggles showing the button", function() {
				var result = wire( "TestUIComponent" )
								.toggle( "showButton" )
								.render();
				expect( result ).toInclude( "<button>The button</button>" );
			} );

			it( "calls the 'foo' method", function() {
				var result = wire( "TestUIComponent" )
								.call( "foo" )
								.render();
				expect( result ).toInclude( "<h1>Foo called</h1>" );
			} );

			it( "calls the 'foo' method with parameters", function() {
				var result = wire( "TestUIComponent" )
								.call( "foo", [ true ] )
								.render();
				expect( result ).toInclude( "<h1>Foo called with params</h1>" );
			} );

			it( "emits the 'fooEvent'", function() {
				var result = wire( "TestUIComponent" )
								.emit( "fooEvent" )
								.render();
				expect( result ).toInclude( "<h1>Foo event called</h1>" );
			} );

			it( "emits the 'fooEvent' with parameters", function() {
				var result = wire( "TestUIComponent" )
								.emit( "fooEvent", [ "Bar" ] )
								.render();
				expect( result ).toInclude( "<h1>Foo event called by Bar</h1>" );
			} );

			it( "provides 'assertSee' method", function(){
				var result = wire( "TestUIComponent" )
								.set( "message", "Something else" )
								.assertSee( "<h1>Something else</h1>" );
			} );

			it( "provides 'assertDontSee' method", function(){
				var result = wire( "TestUIComponent" )
								.set( "message", "Something else" )
								.assertDontSee( "<h1>Nothing else</h1>" );
			} );

			it( "provides 'assertSet' method", function(){
				var result = wire( "TestUIComponent" )
								.call( "foo" )
								.assertSet( "message", "Foo called" );
			} );

			it( "provides 'assertNotSet' method", function(){
				var result = wire( "TestUIComponent" )
								.call( "foo" )
								.assertNotSet( "message", "Does not exist" );
			} );

		} );
    };

}