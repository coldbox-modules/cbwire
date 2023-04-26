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
		describe( "ComputedPropertiesProxy.cfc", function(){
			beforeEach( function( currentSpec ){
				setup();
                computedProperties = {};
				wire = getInstance( "Component@cbwire" );
                proxy = getInstance( name="ComputedPropertiesProxy@cbwire", initArguments={ computedProperties: computedProperties, wire: wire });
			} );

			it( "can instantiate a proxy", function(){
				expect( isObject( proxy ) ).toBeTrue();
			} );

            it( "can render computed properties", function() {
                computedProperties[ "someDate" ] = function() {
                    return now();
                };
                expect( proxy.someDate() ).toBeTypeOf( "date" );
            } );

            it ( "caches computed properites by default", function() {
                computedProperties[ "someRandomString" ] = function() {
                    return createUUID();
                };
                var result = proxy.someRandomString();
                expect( proxy.someRandomString() ).toBe( result );
                expect( proxy.someRandomString() ).toBe( result );
                expect( proxy.someRandomString() ).toBe( result );
            } );

            it( "cache can be bypassed with cache=false flag", function() {
                computedProperties[ "someRandomString" ] = function() {
                    return createUUID();
                };
                var result1 = proxy.someRandomString();
                var result2 = proxy.someRandomString( cache=false );
                expect( result1 ).notToBe( result2 );
            } );
		} );
	}

}
