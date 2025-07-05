component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {
        variables.mockSettings = { trimStringValues: true };

        variables.configService = new cbwire.models.services.ConfigService();
        configService.setSettings( mockSettings );
    }

    function run() {
        describe( "ConfigService", function() {

            describe( "trimStringValues()", function() {

                it( "should return true when trimStringValues is true", function() {
                    mockSettings.trimStringValues = true;
                    var result = configService.trimStringValues();
                    expect( result ).toBeTrue();
                });

                it( "should return false when trimStringValues is false", function() {
                    mockSettings.trimStringValues = false;
                    var result = configService.trimStringValues();
                    expect( result ).toBeFalse();
                });

                it( "should return false when trimStringValues key does not exist", function() {
                    structDelete( mockSettings, "trimStringValues" );
                    var result = configService.trimStringValues();
                    expect( result ).toBeFalse();

                    // reset for other tests
                    mockSettings.trimStringValues = true;
                });

            });

        });

        describe( "normalizeWhitespace()", function() {

            it( "should return true when normalizeWhitespace is true", function() {
                mockSettings.normalizeWhitespace = true;
                var result = configService.normalizeWhitespace();
                expect( result ).toBeTrue();
            });

            it( "should return false when normalizeWhitespace is false", function() {
                mockSettings.normalizeWhitespace = false;
                var result = configService.normalizeWhitespace();
                expect( result ).toBeFalse();
            });

            it( "should return false when normalizeWhitespace key does not exist", function() {
                structDelete( mockSettings, "normalizeWhitespace" );
                var result = configService.normalizeWhitespace();
                expect( result ).toBeFalse();

                // reset for other tests
                mockSettings.normalizeWhitespace = true;
            });

        });
    }
}
