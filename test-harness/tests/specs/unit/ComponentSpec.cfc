component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {

         // Create the service instance
        variables.wireComponent = prepareMock( new cbwire.models.Component() );
    }

    function run() {
        describe("Component", function() {

            beforeEach(function(currentSpec) {

                dataProperties = {};

                variables.wireComponent.$property( propertyName="data", mock=dataProperties );

                // Mock configService
                variables.mockConfigService = createStub();

                variables.mockConfigService.$( "normalizeWhitespace" , false );
        
                // Inject mock
                variables.wireComponent.set_ConfigService(variables.mockConfigService);
                variables.wireComponent.onDIComplete();
            } );
           
            describe( "_getDataProperties()", function() {

                it( "returns empty struct when data is empty", function() {
                    variables.wireComponent.setData( {} );
                    var result = variables.wireComponent._getDataProperties();
                    expect( result ).toBeEmpty();
                });

                it( "preserves non-boolean values", function() {
                    variables.wireComponent.setData( {
                        "name": "Grant",
                        "age": 41,
                        "active": true
                    } );
                    var result = variables.wireComponent._getDataProperties();
                    expect( result.name ).toBe( "Grant" );
                    expect( result.age ).toBe( 41 );
                });

                it( "normalizes true boolean to true", function() {
                    variables.wireComponent.setData( {
                        "isMember": true
                    } );
                    var result = variables.wireComponent._getDataProperties();
                    expect( result.isMember ).toBeTrue();
                });

                it( "normalizes false boolean to false", function() {
                    variables.wireComponent.setData( {
                        "isMember": false
                    } );
                    var result = variables.wireComponent._getDataProperties();
                    expect( result.isMember ).toBeFalse();
                });

                it( "does not coerce numeric booleans", function() {
                    variables.wireComponent.setData( {
                        "flag": 1,
                        "enabled": 0
                    } );
                    var result = variables.wireComponent._getDataProperties();
                    expect( result.flag ).toBe( 1 );
                    expect( result.enabled ).toBe( 0 );
                });

                it( "returns a copy, not a reference", function() {
                    variables.wireComponent.setData( { "count": 5 } );
                    var result = variables.wireComponent._getDataProperties();
                    result.count = 10;
                    var original = variables.wireComponent.getData();
                    expect( original.count ).toBe( 5 );
                });

                it( "normalizes whitespace in strings if configService.normalizeWhitespace is true", function() {
                    var dataProperties = { "description": "  This is a                 test.  " };
                    variables.wireComponent.setData( dataProperties );
                    expect( dataProperties.description.len() ).toBe( 35 );
                    variables.mockConfigService.$( "normalizeWhitespace", true );
                    variables.wireComponent.set_ConfigService(variables.mockConfigService);
                    var result = variables.wireComponent._getDataProperties();
                    //expect( result.description ).toBe( "This is a test." );
                    expect( result.description.len() ).toBe( 17 );
                    variables.mockConfigService.$( "normalizeWhitespace", false );
                });

                it( "doesn't normalize whitespace if configService.normalizeWhitespace is false", function() {
                    var dataProperties = { "description": "  This is a                 test.  " };
                    variables.wireComponent.setData( dataProperties );
                    expect( dataProperties.description.len() ).toBe( 35 );
                    variables.mockConfigService.$( "normalizeWhitespace", false );
                    variables.wireComponent.set_ConfigService(variables.mockConfigService);
                    var result = variables.wireComponent._getDataProperties();
                    expect( result.description.len() ).toBe( 35 );
                });

                it( "still normalizes whitespace if normalizeWhitespace if wire has a 'normalizeWhitespace' in variables scope set to true", function() {
                    var dataProperties = { "description": "  This is a                 test.  " };
                    variables.wireComponent.setData( dataProperties );
                    expect( dataProperties.description.len() ).toBe( 35 );
                    variables.wireComponent.$property( propertyName="normalizeWhitespace", mock=true );
                    var result = variables.wireComponent._getDataProperties();
                    //expect( result.description ).toBe( "This is a test." );
                    expect( result.description.len() ).toBe( 17 );
                });

                it( "does not normalize whitespace if normalizeWhitespace is false in wire variables scope", function() {
                    var dataProperties = { "description": "  This is a                 test.  " };
                    variables.wireComponent.setData( dataProperties );
                    expect( dataProperties.description.len() ).toBe( 35 );
                    variables.wireComponent.$property( propertyName="normalizeWhitespace", mock=false );
                    var result = variables.wireComponent._getDataProperties();
                    expect( result.description.len() ).toBe( 35 );
                });

                it( "normalizeWhitespace can handle null values", function() {
                    var dataProperties = { 
                        "description": javaCast( "null", "" ),
                        "products": [ "Product1", "Product2", javaCast( "null", "" ) ]
                    };
                    variables.wireComponent.setData( dataProperties );
                    expect( isNull( dataProperties.description ) ).toBeTrue();
                    variables.mockConfigService.$( "normalizeWhitespace", true );
                    variables.wireComponent.set_ConfigService(variables.mockConfigService);
                    var result = variables.wireComponent._getDataProperties();
                    expect( isNull( result.description ) ).toBeTrue();
                });

            });

        });
    }


}