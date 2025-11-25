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
        
                // Inject mock
                variables.wireComponent.set_ConfigService(variables.mockConfigService);
                variables.wireComponent.onDIComplete();
            } );
           
            describe( "_getDataProperties()", function() {

                it( "should return empty struct when data is empty", function() {
                    variables.wireComponent.setData( {} );
                    var result = variables.wireComponent._getDataProperties();
                    expect( result ).toBeEmpty();
                });

                it( "should preserve non-boolean values", function() {
                    variables.wireComponent.setData( {
                        "name": "Grant",
                        "age": 41,
                        "active": true
                    } );
                    var result = variables.wireComponent._getDataProperties();
                    expect( result.name ).toBe( "Grant" );
                    expect( result.age ).toBe( 41 );
                });

                it( "should normalize true boolean to true", function() {
                    variables.wireComponent.setData( {
                        "isMember": true
                    } );
                    var result = variables.wireComponent._getDataProperties();
                    expect( result.isMember ).toBeTrue();
                });

                it( "should normalize false boolean to false", function() {
                    variables.wireComponent.setData( {
                        "isMember": false
                    } );
                    var result = variables.wireComponent._getDataProperties();
                    expect( result.isMember ).toBeFalse();
                });

                it( "should not coerce numeric booleans", function() {
                    variables.wireComponent.setData( {
                        "flag": 1,
                        "enabled": 0
                    } );
                    var result = variables.wireComponent._getDataProperties();
                    expect( result.flag ).toBe( 1 );
                    expect( result.enabled ).toBe( 0 );
                });

                it( "should return a copy, not a reference", function() {
                    variables.wireComponent.setData( { "count": 5 } );
                    var result = variables.wireComponent._getDataProperties();
                    result.count = 10;
                    var original = variables.wireComponent.getData();
                    expect( original.count ).toBe( 5 );
                });

            });

        });
    }


}