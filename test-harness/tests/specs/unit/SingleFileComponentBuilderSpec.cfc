component extends="coldbox.system.testing.BaseTestCase" {

    function beforeAll() {
        // Create the service instance
        variables.builder = new cbwire.models.SingleFileComponentBuilder();
        // Track temp files for cleanup
        variables.tempFiles = [];
    }

    function afterAll() {
        // Clean up any remaining temp files
        for ( var tempFile in variables.tempFiles ) {
            if ( fileExists( tempFile ) ) {
                fileDelete( tempFile );
            }
        }
    }

    /**
     * Helper method to create a temp file with the given content.
     * The file is automatically tracked for cleanup.
     *
     * @content string The content to write to the file
     * @extension string The file extension (default: .cfm)
     *
     * @return string The path to the created temp file
     */
    private function createTempFile( required string content, string extension = ".cfm" ) {
        var tempFile = getTempDirectory() & "testWire_" & createUUID() & arguments.extension;
        fileWrite( tempFile, arguments.content );
        variables.tempFiles.append( tempFile );
        return tempFile;
    }

    function run() {
        describe( "SingleFileComponentBuilder", function() {

            describe( "parseContents()", function() {

                it( "should track the line number where @startWire begins", function() {
                    var testContent = "<cfscript>" & chr( 10 ) &
                                      "// some comment" & chr( 10 ) &
                                      "// @startWire" & chr( 10 ) &
                                      "    data = { 'name': 'test' };" & chr( 10 ) &
                                      "// @endWire" & chr( 10 ) &
                                      "</cfscript>" & chr( 10 ) &
                                      "<cfoutput><div>test</div></cfoutput>";
                    
                    var tempFile = createTempFile( testContent );
                    var result = variables.builder.parseContents( tempFile );
                    
                    // @startWire is on line 3
                    expect( result.startWireLineNumber ).toBe( 3 );
                    expect( result ).toHaveKey( "singleFileContents" );
                    expect( result ).toHaveKey( "remainingContents" );
                    expect( result ).toHaveKey( "extendsPath" );
                });

                it( "should return 0 for startWireLineNumber when @startWire is not found", function() {
                    var testContent = "<cfscript>" & chr( 10 ) &
                                      "// some comment" & chr( 10 ) &
                                      "</cfscript>" & chr( 10 ) &
                                      "<cfoutput><div>test</div></cfoutput>";
                    
                    var tempFile = createTempFile( testContent );
                    var result = variables.builder.parseContents( tempFile );
                    
                    expect( result.startWireLineNumber ).toBe( 0 );
                });

                it( "should correctly parse the wire contents between @startWire and @endWire", function() {
                    var testContent = "<cfscript>" & chr( 10 ) &
                                      "// @startWire" & chr( 10 ) &
                                      "    data = { 'counter': 0 };" & chr( 10 ) &
                                      "    function increment() { data.counter++; }" & chr( 10 ) &
                                      "// @endWire" & chr( 10 ) &
                                      "</cfscript>" & chr( 10 ) &
                                      "<cfoutput><div>test</div></cfoutput>";
                    
                    var tempFile = createTempFile( testContent );
                    var result = variables.builder.parseContents( tempFile );
                    
                    // Wire contents should include the data and function definitions
                    expect( result.singleFileContents ).toInclude( "data = { 'counter': 0 }" );
                    expect( result.singleFileContents ).toInclude( "function increment()" );
                    
                    // Remaining contents should include the template part
                    expect( result.remainingContents ).toInclude( "<cfoutput>" );
                    expect( result.remainingContents ).toInclude( "<div>test</div>" );
                });

            });

        });
    }

}
