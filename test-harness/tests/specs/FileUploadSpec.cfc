component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {
        super.beforeAll();

        // Clean out tmp directory before all tests
        // Use system temp directory + cbwire subdirectory
        local.tempFolder = getTempDirectory() & "/cbwire";
        if ( directoryExists( local.tempFolder ) ) {
            directoryDelete( local.tempFolder, true );
        }
        directoryCreate( local.tempFolder );

        // Ensure /resources exists
        local.resourcePath = expandPath( "/resources" );
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
                expect( result.getTemporaryStoragePath() ).toBe( expandPath( "./resources/logo_test.png" ) );
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

            it( "should return correct upload temp directory path using system temp directory", function() {
                // Create a fresh FileUpload instance (not mocked) to test getUploadTempDirectory
                var fileUploadInstance = getInstance( "FileUpload@cbwire" );
                var tempDir = fileUploadInstance.getUploadTempDirectory();
                
                // The path should end with /cbwire
                expect( tempDir ).toInclude( "/cbwire" );
                // Should use the system temp directory
                expect( tempDir ).toInclude( getTempDirectory() );
            });

            it( "should store file to a specified directory path", function() {
                var result = loadMockedFileUpload( "test-store", "text", "plain" );
                var destinationDir = getTempDirectory() & "/cbwire-test-store";

                // Ensure the test directory exists
                if ( !directoryExists( destinationDir ) ) {
                    directoryCreate( destinationDir );
                }

                // Store the file
                var storedPath = result.store( destinationDir );

                // Verify the file was moved to the destination
                expect( fileExists( storedPath ) ).toBeTrue();
                // Use getCanonicalPath to normalize the path for comparison
                expect( storedPath ).toInclude( getCanonicalPath( destinationDir ) );
                expect( storedPath ).toInclude( "logo_test-store.png" );

                // Clean up
                if ( directoryExists( destinationDir ) ) {
                    directoryDelete( destinationDir, true );
                }
            });

            it( "should store file to a specified file path", function() {
                var result = loadMockedFileUpload( "test-store-file", "text", "plain" );
                var destinationDir = getTempDirectory() & "/cbwire-test-store-file";
                var destinationPath = destinationDir & "/myfile.png";

                // Store the file with specific filename
                var storedPath = result.store( destinationPath );

                // Verify the file was moved to the destination with the new name
                expect( fileExists( storedPath ) ).toBeTrue();
                // Normalize both paths to handle platform differences (e.g., /var vs /private/var on macOS)
                expect( getCanonicalPath( storedPath ) ).toBe( getCanonicalPath( destinationPath ) );

                // Clean up
                if ( directoryExists( destinationDir ) ) {
                    directoryDelete( destinationDir, true );
                }
            });

            it( "should update temporary storage path after store", function() {
                var result = loadMockedFileUpload( "test-store-update", "text", "plain" );
                var destinationDir = getTempDirectory() & "/cbwire-test-store-update";
                
                // Store the file
                var storedPath = result.store( destinationDir );
                
                // Verify the temporary storage path was updated
                expect( result.getTemporaryStoragePath() ).toBe( storedPath );
                
                // Clean up
                if ( directoryExists( destinationDir ) ) {
                    directoryDelete( destinationDir, true );
                }
            });

            it( "should be able to destroy file after store", function() {
                var result = loadMockedFileUpload( "test-store-destroy", "text", "plain" );
                var destinationDir = getTempDirectory() & "/cbwire-test-store-destroy";
                
                // Store the file
                var storedPath = result.store( destinationDir );
                
                // Verify file exists at new location
                expect( fileExists( storedPath ) ).toBeTrue();
                
                // Now destroy should delete from the new location
                result.destroy();
                
                // Verify file was deleted
                expect( fileExists( storedPath ) ).toBeFalse();
                
                // Clean up directory
                if ( directoryExists( destinationDir ) ) {
                    directoryDelete( destinationDir, true );
                }
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
        var metaPath = expandPath( "/cbwire/test-harness/tests/resources/fileupload_metadata.json" );

        // Create a unique copy of logo.png for this test instance
        // This ensures each test that calls store() has its own file to move
        var uniqueFileName = "logo_" & arguments.uuid & ".png";
        var sourcePath = expandPath( "/cbwire/test-harness/tests/resources/logo.png" );
        var destinationPath = expandPath( "/cbwire/test-harness/tests/resources/" & uniqueFileName );

        // Always create a fresh copy for each test
        if ( fileExists( sourcePath ) ) {
            // Delete destination if it exists (from previous test run)
            if ( fileExists( destinationPath ) ) {
                fileDelete( destinationPath );
            }
            fileCopy( sourcePath, destinationPath );
        }

        writeTestMetaFile(
            path = metaPath,
            data = {
                "uuid" : arguments.uuid,
                "serverDirectory" : expandPath( "/cbwire/test-harness/tests/resources" ),
                "serverFile" : uniqueFileName,
                "contentType" : arguments.contentType,
                "contentSubType" : arguments.contentSubType,
                "fileSize" : 1234
            }
        );

        fileUpload.$( "getMetaPath", metaPath );
        return fileUpload.load( testComponent, "test", arguments.uuid );
    }
}
