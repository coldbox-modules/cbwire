component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {
        super.beforeAll();
        variables.storage = getInstance( "CacheCSRFStorage@cbwire" );
    }

    function run() {
        describe("CacheCSRFStorage", function() {

            beforeEach(function() {
                storage.clear();
            });

            it("should store and retrieve a token", function() {
                var token = "test-token-12345";
                storage.set( token );

                expect( storage.get() ).toBe( token );
            });

            it("should return empty string when no token exists", function() {
                expect( storage.get() ).toBe( "" );
            });

            it("should detect token existence", function() {
                expect( storage.exists() ).toBeFalse();

                storage.set( "token" );
                expect( storage.exists() ).toBeTrue();
            });

            it("should delete token", function() {
                storage.set( "token" );
                storage.delete();

                expect( storage.exists() ).toBeFalse();
            });

            it("should support method chaining", function() {
                var result = storage.set( "token" ).delete();

                expect( result ).toBe( storage );
            });

            it("should clear token", function() {
                storage.set( "token" );
                storage.clear();

                expect( storage.exists() ).toBeFalse();
            });
        });
    }
}
