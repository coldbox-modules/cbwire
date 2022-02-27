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
			it( "wires up the component with default template", function(){
				var result = wire( "TestUIComponent" ).renderIt();
				expect( result ).toInclude( "<h1>This is the default template</h1>" );
			} );

			it( "changes data property message", function(){
				var result = wire( "TestUIComponent" ).data( "message", "Something else" ).renderIt();
				expect( result ).toInclude( "<h1>Something else</h1>" );
			} );

			it( "changes data property message using a struct", function(){
				var result = wire( "TestUIComponent" ).data( { "message" : "Something else" } ).renderIt();
				expect( result ).toInclude( "<h1>Something else</h1>" );
			} );

			it( "changes computed property counter", function(){
				var result = wire( "TestUIComponent" ).computed( "counter", function() { return 1; } ).renderIt();
				expect( result ).toInclude( "<p>Count 1</p>" );
			} );

			it( "changes computed property message using a struct", function(){
				var result = wire( "TestUIComponent" ).computed( { "counter" : function() { return 2; } } ).renderIt();
				expect( result ).toInclude( "<p>Count 2</p>" );
			} );
			it( "toggles showing the button", function(){
				var result = wire( "TestUIComponent" ).toggle( "showButton" ).renderIt();
				expect( result ).toInclude( "<button>The button</button>" );
			} );

			it( "calls the 'foo' method", function(){
				var result = wire( "TestUIComponent" ).call( "foo" ).renderIt();
				expect( result ).toInclude( "<h1>Foo called</h1>" );
			} );

			it( "calls the 'foo' method with parameters", function(){
				var result = wire( "TestUIComponent" ).call( "foo", [ true ] ).renderIt();
				expect( result ).toInclude( "<h1>Foo called with params</h1>" );
			} );

			it( "emits the 'fooEvent'", function(){
				var result = wire( "TestUIComponent" ).emit( "fooEvent" ).renderIt();
				expect( result ).toInclude( "<h1>Foo event called</h1>" );
			} );

			it( "emits the 'fooEvent' with parameters", function(){
				var result = wire( "TestUIComponent" ).emit( "fooEvent", { "name" : "Bar" } ).renderIt();
				expect( result ).toInclude( "<h1>Foo event called by Bar</h1>" );
			} );

			it( "provides 'see' method", function(){
				var result = wire( "TestUIComponent" )
					.data( "message", "Something else" )
					.see( "<h1>Something else</h1>" );
			} );

			it( "provides 'dontSee' method", function(){
				var result = wire( "TestUIComponent" )
					.data( "message", "Something else" )
					.dontSee( "<h1>Nothing else</h1>" );
			} );

			it( "provides 'seeData' method", function(){
				var result = wire( "TestUIComponent" ).call( "foo" ).seeData( "message", "Foo called" );
			} );

			it( "provides 'dontSeeData' method", function(){
				var result = wire( "TestUIComponent" ).call( "foo" ).dontSeeData( "message", "Does not exist" );
			} );
		} );
	};

}
