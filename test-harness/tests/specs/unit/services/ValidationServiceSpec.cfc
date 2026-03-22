component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {
        variables.mockValidationManager = prepareMock( createStub() );
        variables.mockProvider = prepareMock( createStub() );
        variables.mockProvider.$( "$get", variables.mockValidationManager );

        variables.validationService = prepareMock( new cbwire.models.services.ValidationService() );
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

                it( "shoud validate an object other than the wire itself", function() {
					var oValidationTest = getInstance( "validationTest" );
                    var wire = prepareMock( createStub() );
                    wire.$( "_getDataProperties", { "bar": "baz" } );
                    wire.$( "_getConstraints", { "bar": { "required": true } } );
					// mock the validate method to return the arguments passed to it so that
					// we can validate that the correct mutation of the arguments is occurring
					// in the validate() method of the service
					mockValidationManager.$(
						method = "validate",
						callback = function() {
							return arguments;
						}
					);
					var result = validationService.validate( wire=wire, target=oValidationTest );
					// validate that we do not have the wires constraints and that there
					// are no constraints passed to validate() method so that the constraints
					// from the object will be used
					expect( result ).notToHaveKey( "constraints" );
					// validate that we have a target passed into the validate method
					expect( result ).toHaveKey( "target" );
					// validate that the target contains the constraints from the object
					expect( result.target ).toHaveKey( "constraints" );
					expect( result.target.constraints ).toBeTypeOf( "struct" );
					expect( result.target.constraints ).toHaveLength( 2 );
					expect( result.target.constraints ).toHaveKey( "firstname" );
					expect( result.target.constraints ).toHaveKey( "lastname" );
					expect( result.target.constraints ).notToHaveKey( "bar" );
					// get the metadata of the target to validate that it is the correct object and not the wire
					var resultTargetMetaData = getMetadata( result.target );
					// validate that the target metadata contains the name of the component (validationTest)
					expect( resultTargetMetaData ).toHaveKey( "name" );
					expect( resultTargetMetaData.name ).toInclude( "validationTest" );
                });

                it( "shoud validate an object other than the wire itself with custom validation constraints", function() {
					var oValidationTest = getInstance( "validationTest" );
                    var wire = prepareMock( createStub() );
                    wire.$( "_getDataProperties", { "bar": "baz" } );
                    wire.$( "_getConstraints", { "bar": { "required": true } } );
					var customConstraints = {
						password : {
							required : true,
							requiredMessage : "Password is required",
							size : "8..50",
							sizeMessage : "Password name must be 2-50 characters"
						}
					};
					// mock the validate method to return the arguments passed to it so that
					// we can validate that the correct mutation of the arguments is occurring
					// in the validate() method of the service
					mockValidationManager.$(
						method = "validate",
						callback = function() {
							return arguments;
						}
					);
					var result = validationService.validate( wire=wire, target=oValidationTest, constraints=customConstraints );
					// validate that we do not have the wires constraints and that the constraints
					// passed to the validate() method are the custom constraints and not the objects
					// or wires constraints
					expect( result ).toHaveKey( "constraints" );
					expect( result.constraints ).toBeTypeOf( "struct" );
					expect( result.constraints ).toHaveLength( 1 );
					expect( result.constraints ).toHaveKey( "password" );
					expect( result.constraints ).notToHaveKey( "lastname" );
					expect( result.constraints ).notToHaveKey( "bar" );
					// validate that we have a target passed into the validate method
					expect( result ).toHaveKey( "target" );
					// get the metadata of the target to validate that it is the correct object and not the wire
					var resultTargetMetaData = getMetadata( result.target );
					// validate that the target metadata contains the name of the component (validationTest)
					expect( resultTargetMetaData ).toHaveKey( "name" );
					expect( resultTargetMetaData.name ).toInclude( "validationTest" );
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
