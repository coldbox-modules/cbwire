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

            });

            describe( "Single-file component error reporting", function() {

                it( "_isSingleFileComponent returns false for regular components", function() {
                    // Regular components don't have _singleFileSourcePath set
                    var result = variables.wireComponent._isSingleFileComponent();
                    expect( result ).toBeFalse();
                });

                it( "_getSingleFileSourcePath returns empty string for regular components", function() {
                    var result = variables.wireComponent._getSingleFileSourcePath();
                    expect( result ).toBe( "" );
                });

                it( "_getSingleFileLineOffset returns 0 for regular components", function() {
                    var result = variables.wireComponent._getSingleFileLineOffset();
                    expect( result ).toBe( 0 );
                });

                it( "_isSingleFileComponent returns true when _singleFileSourcePath is set", function() {
                    // Simulate a single-file component by setting the variables
                    variables.wireComponent.$property( propertyName="_singleFileSourcePath", mock="/path/to/TestComponent.cfm" );
                    var result = variables.wireComponent._isSingleFileComponent();
                    expect( result ).toBeTrue();
                });

                it( "_getSingleFileSourcePath returns the path when set", function() {
                    var testPath = "/path/to/TestComponent.cfm";
                    variables.wireComponent.$property( propertyName="_singleFileSourcePath", mock=testPath );
                    var result = variables.wireComponent._getSingleFileSourcePath();
                    expect( result ).toBe( testPath );
                });

                it( "_getSingleFileLineOffset returns the offset when set", function() {
                    variables.wireComponent.$property( propertyName="_singleFileLineOffset", mock=15 );
                    var result = variables.wireComponent._getSingleFileLineOffset();
                    expect( result ).toBe( 15 );
                });

                it( "_buildEnhancedErrorMessage includes source file path", function() {
                    variables.wireComponent.$property( propertyName="_singleFileSourcePath", mock="/path/to/TestComponent.cfm" );
                    variables.wireComponent.$property( propertyName="_singleFileLineOffset", mock=10 );
                    
                    var mockException = {
                        "message": "Test error message",
                        "detail": "Test detail",
                        "type": "TestException"
                    };
                    
                    var result = variables.wireComponent._buildEnhancedErrorMessage( mockException );
                    
                    expect( result ).toInclude( "Test error message" );
                    expect( result ).toInclude( "/path/to/TestComponent.cfm" );
                    expect( result ).toInclude( "CBWIRE Single-File Component Debug Info" );
                    expect( result ).toInclude( "Wire code starts at line: 10" );
                });

                it( "_enhanceExceptionForSingleFile returns enhanced struct for single-file components", function() {
                    variables.wireComponent.$property( propertyName="_singleFileSourcePath", mock="/path/to/TestComponent.cfm" );
                    variables.wireComponent.$property( propertyName="_singleFileLineOffset", mock=10 );
                    
                    var mockException = {
                        "message": "Test error message",
                        "detail": "Test detail",
                        "type": "TestException"
                    };
                    
                    var result = variables.wireComponent._enhanceExceptionForSingleFile( mockException );
                    
                    expect( result ).toHaveKey( "isSingleFileComponent" );
                    expect( result.isSingleFileComponent ).toBeTrue();
                    expect( result ).toHaveKey( "singleFileSourcePath" );
                    expect( result.singleFileSourcePath ).toBe( "/path/to/TestComponent.cfm" );
                    expect( result ).toHaveKey( "singleFileLineOffset" );
                    expect( result.singleFileLineOffset ).toBe( 10 );
                    expect( result ).toHaveKey( "enhancedMessage" );
                });

                it( "_enhanceExceptionForSingleFile returns basic struct for regular components", function() {
                    var mockException = {
                        "message": "Test error message",
                        "detail": "Test detail",
                        "type": "TestException"
                    };
                    
                    var result = variables.wireComponent._enhanceExceptionForSingleFile( mockException );
                    
                    expect( result ).toHaveKey( "isSingleFileComponent" );
                    expect( result.isSingleFileComponent ).toBeFalse();
                    expect( result ).notToHaveKey( "singleFileSourcePath" );
                    expect( result ).notToHaveKey( "enhancedMessage" );
                });

            });

        });
    }


}