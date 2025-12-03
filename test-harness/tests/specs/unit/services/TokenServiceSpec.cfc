component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {
        super.beforeAll();

        // Get the token service from WireBox
        variables.tokenService = getInstance( "TokenService@cbwire" );
    }

    function run() {
        describe("TokenService", function() {

            beforeEach(function() {
                // Clear any existing token before each test
                tokenService.rotate();
            });

            describe("generate()", function() {

                it("should generate a token", function() {
                    var token = tokenService.generate();

                    expect( token ).toBeString();
                    expect( len( token ) ).toBeGT( 0 );
                });

                it("should return same token on subsequent calls", function() {
                    var token1 = tokenService.generate();
                    var token2 = tokenService.generate();

                    expect( token1 ).toBe( token2 );
                });
            });

            describe("verify()", function() {

                it("should verify a valid token", function() {
                    var token = tokenService.generate();
                    var isValid = tokenService.verify( token );

                    expect( isValid ).toBeTrue();
                });

                it("should reject an invalid token", function() {
                    var isValid = tokenService.verify( "invalid-token-12345" );

                    expect( isValid ).toBeFalse();
                });

                it("should reject empty token", function() {
                    var isValid = tokenService.verify( "" );

                    expect( isValid ).toBeFalse();
                });
            });

            describe("rotate()", function() {

                it("should invalidate old token after rotation", function() {
                    var oldToken = tokenService.generate();

                    tokenService.rotate();

                    var isValid = tokenService.verify( oldToken );
                    expect( isValid ).toBeFalse();
                });

                it("should generate new token after rotation", function() {
                    var oldToken = tokenService.generate();

                    tokenService.rotate();

                    var newToken = tokenService.generate();

                    expect( newToken ).notToBe( oldToken );
                    expect( tokenService.verify( newToken ) ).toBeTrue();
                });
            });
        });
    }
}
