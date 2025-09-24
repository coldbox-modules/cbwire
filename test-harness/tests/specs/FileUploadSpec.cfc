component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {
        super.beforeAll();

        // Clean out tmp directory before all tests
        local.tempFolder = expandPath( "../../../models/tmp" );
        if ( directoryExists( local.tempFolder ) ) {
            directoryDelete( local.tempFolder, true );
        }
        directoryCreate( local.tempFolder );

        // Ensure /resources exists
        local.resourcePath = expandPath( "../resources" );
        if ( !directoryExists( local.resourcePath ) ) {
            directoryCreate( local.resourcePath );
        }
    }

    function run( testResults, testBox ) {
        describe( "FileUpload.cfc", function() {

            beforeEach( function( currentSpec ) {
                setup();

                testComponent = getInstance( "wires.TestComponent" );
                testComponent
                    ._withEvent( getRequestContext() )
                    ._withPath( "wires.TestComponent" );

                prepareMock( testComponent );

                fileUpload = getInstance( "FileUpload@cbwire" );
                prepareMock( fileUpload );
            });

            it( "should return an object", function() {
                var result = getInstance( "FileUpload@cbwire" );
                expect( isObject( result ) ).toBeTrue();
            });

            it( "should load without error", function() {
                var result = loadMockedFileUpload( "test", "text", "plain" );
                expect( isObject( result ) ).toBeTrue();
            });

            it( "should return the meta data", function() {
                var result = loadMockedFileUpload( "test", "text", "plain" );
                expect( result.getMeta().uuid ).toBe( "test" );
            });

            it( "should return fileupload: uuid on serializeIt", function() {
                var result = loadMockedFileUpload( "test", "text", "plain" );
                expect( result.serializeIt() ).toBe( "fileupload:test" );
            });

            it( "should return expected preview URL", function() {
                var result = loadMockedFileUpload( "test", "text", "plain" );
                expect( result.getPreviewURL() ).toBe( "/cbwire/preview-file/test" );
            });

            it( "should determine is image", function() {
                var result = loadMockedFileUpload( "test", "image", "png" );
                expect( result.isImage() ).toBeTrue();
            });

            it( "should determine is NOT image", function() {
                var result = loadMockedFileUpload( "test", "text", "plain" );
                expect( result.isImage() ).toBeFalse();
            });

            it( "should return the file size", function() {
                var result = loadMockedFileUpload( "test", "text", "plain" );
                expect( result.getSize() ).toBe( 1234 );
            });

            it( "should return the MIME type", function() {
                var result = loadMockedFileUpload( "test", "text", "plain" );
                expect( result.getMIMEType() ).toBe( "text/plain" );
            });

            it( "should return the temporary storage path", function() {
                var result = loadMockedFileUpload( "test", "text", "plain" );
                expect( result.getTemporaryStoragePath() ).toBe( expandPath( "./resources/logo.png" ) );
            });

            it( "should return binary file contents when calling get", function() {
                var result = loadMockedFileUpload( "test", "text", "plain" );
                expect( isBinary( result.get() ) ).toBeTrue();
            });

            it ( "should return base 64 encoded string when calling getBase64", function() {
                var result = loadMockedFileUpload( "test", "text", "plain" );
                expect( isBinary( toBinary( result.getBase64() ) ) ).toBeTrue();
            });

            it( "should return base 64 src attribute contents when calling getBase64Src", function() {
                var result = loadMockedFileUpload( "test", "text", "plain" );
                expect( result.getBase64Src() ).toInclude( "data:" );
            });

            it( "should return correct upload temp directory path with proper slash separation", function() {
                // Create a fresh FileUpload instance (not mocked) to test getUploadTempDirectory
                var fileUploadInstance = getInstance( "FileUpload@cbwire" );
                var tempDir = fileUploadInstance.getUploadTempDirectory();
                
                // The path should contain "/models/tmp" with proper slash separation
                expect( tempDir ).toInclude( "/models/tmp" );
                // Should not have malformed concatenation like "wiremodels"
                expect( tempDir ).notToInclude( "wiremodels" );
                // Should end with models/tmp
                expect( right( tempDir, 10 ) ).toBe( "models/tmp" );
            });

        });
    }

    private function writeTestMetaFile( required path, required struct data ) {
        if ( fileExists( arguments.path ) ) {
            fileDelete( arguments.path );
        }
        fileWrite( arguments.path, serializeJSON( arguments.data ) );
    }

    private function loadMockedFileUpload(
        required string uuid,
        required string contentType,
        required string contentSubType
    ) {
        var metaPath = expandPath( "../resources/fileupload_metadata.json" );

        writeTestMetaFile(
            path = metaPath,
            data = {
                "uuid" : arguments.uuid,
                "serverDirectory" : expandPath( "./resources" ),
                "serverFile" : "logo.png",
                "contentType" : arguments.contentType,
                "contentSubType" : arguments.contentSubType,
                "fileSize" : 1234
            }
        );

        fileUpload.$( "getMetaPath", metaPath );
        return fileUpload.load( testComponent, "test", arguments.uuid );
    }
}
