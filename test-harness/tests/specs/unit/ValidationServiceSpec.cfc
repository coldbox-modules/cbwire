component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {
        variables.mockValidationManager = prepareMock( createStub() );
        variables.mockProvider = prepareMock( createStub() );
        variables.mockProvider.$( "$get", variables.mockValidationManager );

        variables.validationService = prepareMock( new cbwire.models.ValidationService() );
        validationService.setValidationManager( mockProvider );
    }

    function run() {
        describe( "ValidationService", function() {

            describe( "getManager()", function() {
                it( "should return the ValidationManager from provider", function() {
                    var result = validationService.getManager();
                    expect( result ).toBe( mockValidationManager );
                });

                it( "should throw CBWIREException if provider fails", function() {
                    mockProvider.$( "$get" ).$throws( type="ProviderNotFound" );
                    expect( function() {
                        validationService.getManager();
                    } ).toThrow( "CBWIREException" );
                    mockProvider.$( "$get", mockValidationManager );
                });
            });

            describe( "isCBValidationInstalled()", function() {
                it( "should return true when ValidationManager is available", function() {
                    expect( validationService.isCBValidationInstalled() ).toBeTrue();
                });

                it( "should return false when ValidationManager is unavailable", function() {
                    mockProvider.$( "$get" ).$throws( "any" );
                    expect( validationService.isCBValidationInstalled() ).toBeFalse();
                    mockProvider.$( "$get", mockValidationManager );
                });
            });

            describe( "validate()", function() {
                it( "should validate with given target and constraints", function() {
                    var wire = {};
                    var target = { "foo": "bar" };
                    var constraints = { "foo": { "required": true } };

                    mockValidationManager.$( "validate", { "ok": true } );

                    var result = validationService.validate( wire, target, [], constraints );
                    expect( result ).toHaveKey( "ok" );
                });

                it( "should fallback to _getDataProperties and _getConstraints", function() {
                    var wire = prepareMock( createStub() );
                    wire.$( "_getDataProperties", { "bar": "baz" } );
                    wire.$( "_getConstraints", { "bar": { "required": true } } );

                    mockValidationManager.$( "validate", { "ok": true } );

                    var result = validationService.validate( wire );
                    expect( result ).toHaveKey( "ok" );
                });
            });

            describe( "validateOrFail()", function() {
                it( "should throw ValidationException when validation fails", function() {
                    var wire = preparemock( createStub() );
                    wire.$( "_getDataProperties", { "bar": "baz" } );
                    wire.$( "_getConstraints", { "bar": { "required": true } } );
                    validationService.$( "validate", {
                        hasErrors: function() { return true; }
                    } );

                    expect( function() {
                        validationService.validateOrFail( wire );
                    } ).toThrow( "ValidationException" );
                });

                it( "should not throw when validation passes", function() {
                    var wire = {};
                    validationService.$( "validate", {
                        hasErrors: function() { return false; }
                    } );

                    expect( function() {
                        validationService.validateOrFail( wire );
                    } ).notToThrow();
                });
            });

        });
    }
}
